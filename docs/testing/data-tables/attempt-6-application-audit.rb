# frozen_string_literal: true

# Reproducible A37/A38/A39 audit for a frozen attempt's three RAW outputs.
# DATA_TABLE_AUDIT_PREFIX selects the attempt; default remains the preserved
# Attempt 6 corpus, which is intentionally RED under the corrected contract.
# --records emits the tracked field-level Markdown ledger.

file_prefix = ENV.fetch("DATA_TABLE_AUDIT_PREFIX", "green")
FILES = {
  "display" => "#{file_prefix}-display-report.md",
  "row-action" => "#{file_prefix}-row-action-list.md",
  "bulk-action" => "#{file_prefix}-bulk-action-table.md"
}.freeze

CAPABILITIES = %w[
  capabilityTier resolvedTier filteringEnabled sortingEnabled paginationMode
  pageSize pageSelectionEnabled allFilteredSelectionEnabled rowOperationEnabled
  bulkOperationEnabled columnVisibilityEnabled columnPinningEnabled
  columnResizeEnabled responsivePresentation
].freeze

BOOLEAN_CAPABILITIES = %w[
  filteringEnabled sortingEnabled pageSelectionEnabled
  allFilteredSelectionEnabled rowOperationEnabled bulkOperationEnabled
  columnVisibilityEnabled columnPinningEnabled columnResizeEnabled
].freeze

ATOMIC_ROWS = [
  "能力与状态", "查询", "筛选", "排序", "分页", "数据状态", "选择",
  "单行操作", "批量操作", "基础列状态", "可选列控制", "Table 语义",
  "ARIA Grid 语义", "键盘", "焦点", "响应式", "ARIA 与公告",
  "disposal", "实例隔离", "运行时验证边界"
].freeze

QUERY_FIELDS = %w[
  appliedFilters sortRules pagination pageSize querySnapshot snapshotId
  datasetVersion requestGeneration requestPhase queryError stale
].freeze

VIEW_FIELDS = {
  "visibleColumnIds" => /visibleColumnIds/,
  "pinnedColumnIds" => /pinnedColumnIds/,
  "columnWidths" => /columnWidths/,
  "density" => /density/,
  "rows" => /\brows\b|currentRows|当前结果行/,
  "resultSummary" => /resultSummary|结果摘要/
}.freeze

INTERACTION_FIELDS = {
  "focusIntent" => /focusIntent/,
  "recordId" => /recordId/i,
  "columnId" => /columnId/i
}.freeze

FORBIDDEN_MERGED_ROWS = [
  "选择与操作", "选择与批量操作", "列", "Table/Grid", "Table / Grid",
  "disposal/实例隔离", "Disposal/实例隔离"
].freeze

def raw_output(path)
  source = File.binread(path).force_encoding("UTF-8")
  raise "invalid UTF-8: #{path}" unless source.valid_encoding?

  source = source.gsub("\r\n", "\n").gsub("\r", "\n")
  matches = source.scan(/<!-- BEGIN RAW OUTPUT -->\n(.*?)\n<!-- END RAW OUTPUT -->/m)
  raise "#{path}: RAW OUTPUT markers=#{matches.size}" unless matches.size == 1

  matches[0][0]
end

def table_cells(line)
  return nil unless line.start_with?("|") && line.end_with?("|")

  line.split("|", -1)[1...-1].map(&:strip)
end

class Audit
  attr_reader :errors, :records

  def initialize(scenario, output)
    @scenario = scenario
    @output = output
    @lines = output.lines.map { |line| line.chomp }
    @errors = []
    @records = []
    @capability_values = {}
  end

  def run
    audit_capabilities
    audit_state_groups
    audit_lifecycle
    audit_atomic_checklist
    audit_query_adjacent_semantics
    audit_selection_generation_contract
    self
  end

  private

  def location(index)
    "RAW OUTPUT:L#{index + 1}"
  end

  def add_record(kind, values)
    @records << {
      "scenario" => @scenario,
      "recordKind" => kind,
      "capabilityKey" => "",
      "currentValue" => "",
      "stateGroup" => "",
      "minimumField" => "",
      "lifecycleRole" => "",
      "checklistRow" => "",
      "selectionContractPath" => "",
      "adjacentFamily" => "",
      "semanticObligation" => "",
      "generationEffect" => "",
      "snapshotEffect" => "",
      "commitGuard" => "",
      "mismatchEffect" => "",
      "applicability" => "",
      "verificationStatus" => "",
      "outputLocation" => ""
    }.merge(values)
  end

  def audit_capabilities
    CAPABILITIES.each do |key|
      hits = []
      @lines.each_with_index do |line, index|
        next unless line.match?(/^\|.*`#{Regexp.escape(key)}`.*\|$/)

        cells = table_cells(line)
        hits << [index, cells] if cells && cells.length >= 2
      end
      if hits.size != 1
        @errors << "capability #{key}: rows=#{hits.size}"
        next
      end

      index, cells = hits[0]
      value = cells[1]
      @capability_values[key] = value.to_s
      if value.nil? || value.empty?
        @errors << "capability #{key}: empty current value"
      elsif BOOLEAN_CAPABILITIES.include?(key) &&
            !value.match?(/\A`?(?:true|false|enabled|disabled)`?(?:[，、；\s]|$)|\A(?:不启用|启用|关闭|开启)(?:[，、；\s]|$)/i)
        @errors << "capability #{key}: conditional/non-current value=#{value.inspect}"
      end
      add_record("capability", {
        "capabilityKey" => key,
        "currentValue" => value.to_s,
        "outputLocation" => location(index)
      })
    end
  end

  def section_for(group)
    heading = @lines.each_index.find do |index|
      @lines[index].match?(/^###\s+.*`#{Regexp.escape(group)}`/)
    end
    return nil unless heading

    finish = ((heading + 1)...@lines.length).find do |index|
      @lines[index].start_with?("### ")
    end
    finish ||= @lines.length
    [heading, finish, @lines[heading...finish].join("\n")]
  end

  def field_in_section(group, field, pattern, section)
    heading, finish, text = section
    unless text.match?(pattern)
      @errors << "#{group}.#{field}: missing minimum field"
      return
    end

    relative = @lines[heading...finish].each_index.find do |offset|
      @lines[heading + offset].match?(pattern)
    end
    add_record("state-minimum", {
      "stateGroup" => group,
      "minimumField" => field,
      "currentValue" => "present",
      "outputLocation" => location(heading + relative)
    })
  end

  def audit_state_groups
    groups = %w[queryState viewState interactionState operationState]
    groups.each do |group|
      section = section_for(group)
      unless section
        @errors << "state group #{group}: missing exact heading"
        next
      end
      add_record("state-group", {
        "stateGroup" => group,
        "currentValue" => "declared",
        "outputLocation" => location(section[0])
      })

      case group
      when "queryState"
        QUERY_FIELDS.each do |field|
          field_in_section(group, field, /#{Regexp.escape(field)}/, section)
        end
      when "viewState"
        VIEW_FIELDS.each do |field, pattern|
          field_in_section(group, field, pattern, section)
        end
      when "interactionState"
        INTERACTION_FIELDS.each do |field, pattern|
          field_in_section(group, field, pattern, section)
        end
      when "operationState"
        field_in_section(group, "row-operation-or-absence", /单行|row/i, section)
        field_in_section(group, "bulk-operation-or-absence", /批量|bulk|operationSnapshot/i, section)
      end
    end
  end

  def audit_lifecycle
    heading = @lines.each_index.find do |index|
      @lines[index].match?(/^###\s+.*(?:`lifecycleGuard`|生命周期门禁)/)
    end
    unless heading
      @errors << "lifecycleRole: independent guard heading missing"
      return
    end

    finish = ((heading + 1)...@lines.length).find do |index|
      @lines[index].start_with?("### ")
    end
    finish ||= @lines.length
    text = @lines[heading...finish].join("\n")
    fields = {
      "ownerId" => [/ownerId/, /ownerId/],
      "lifecycleToken" => [/lifecycleToken/, /lifecycleToken/],
      "live/disposed" => [/live.*disposed|disposed.*live/m, /live|disposed/],
      "ownedResources" => [/ownedResources|持有.*资源|资源/, /ownedResources|持有.*资源|资源/]
    }
    fields.each do |field, patterns|
      section_pattern, line_pattern = patterns
      unless text.match?(section_pattern)
        @errors << "lifecycleGuard.#{field}: missing"
        next
      end
      relative = @lines[heading...finish].each_index.find do |offset|
        @lines[heading + offset].match?(line_pattern)
      end
      add_record("lifecycle", {
        "minimumField" => field,
        "lifecycleRole" => "guard",
        "currentValue" => "present",
        "outputLocation" => location(heading + relative)
      })
    end
    @errors << "lifecycleRole: lifecycleState used as state group" if @output.match?(/^###\s+.*lifecycleState/)
  end

  def audit_atomic_checklist
    header_hits = []
    @lines.each_with_index do |line, index|
      cells = table_cells(line)
      next unless cells && cells[0].match?(/\A(?:原子规则族|规则族)\z/) &&
                  cells.include?("适用性") && cells.include?("验证状态")

      header_hits << [index, cells]
    end
    @errors << "checklist: separate 验证状态 column missing" unless header_hits.size == 1

    header = header_hits.one? ? header_hits[0][1] : ["规则族", "适用性", "正文定位", "验证状态"]
    applicability_index = header.index("适用性") || 1
    status_index = header.index("验证状态") || (header.size - 1)
    evidence_indexes = (0...header.size).to_a - [0, applicability_index, status_index]

    ATOMIC_ROWS.each do |row|
      hits = []
      @lines.each_with_index do |line, index|
        cells = table_cells(line)
        hits << [index, cells] if cells && cells[0] == row
      end
      if hits.size != 1
        @errors << "checklist #{row}: rows=#{hits.size}"
        next
      end

      index, cells = hits[0]
      applicability = cells[applicability_index].to_s
      unless ["适用", "不适用"].include?(applicability)
        @errors << "checklist #{row}: non-binary applicability=#{applicability.inspect}"
      end
      if cells.length != header.length || evidence_indexes.empty?
        @errors << "checklist #{row}: verification status not separate"
      end
      status = cells[status_index].to_s
      @errors << "checklist #{row}: empty verification status" if status.empty?
      evidence = evidence_indexes.map { |position| cells[position].to_s }.join(" ").strip
      if applicability == "适用" && evidence.empty?
        @errors << "checklist #{row}: applicable outputLocation missing"
      elsif applicability == "不适用"
        missing = []
        missing << "DOM" unless evidence.match?(/DOM|role=|渲染|入口/i)
        missing << "state" unless evidence.match?(/状态|state|roving\s+tabindex|活动单元格|appliedFilters|固定空/i)
        missing << "handler/event" unless evidence.match?(/handler|事件|键盘/i)
        missing << "request" unless evidence.match?(/请求|request|不触发查询|查询(?:入口)?(?:为|=)?\s*0/i)
        @errors << "checklist #{row}: N/A zero evidence missing #{missing.join(',')}" unless missing.empty?
      end
      add_record("checklist", {
        "currentValue" => evidence,
        "checklistRow" => row,
        "applicability" => applicability,
        "verificationStatus" => status,
        "outputLocation" => location(index)
      })
    end

    @lines.each_with_index do |line, index|
      cells = table_cells(line)
      next unless cells

      if cells[1].to_s.match?(/部分适用|条件适用|适用\s*\/\s*不适用/)
        @errors << "checklist #{cells[0]}: forbidden mixed applicability at #{location(index)}"
      end
      if FORBIDDEN_MERGED_ROWS.include?(cells[0])
        @errors << "checklist #{cells[0]}: forbidden merged row at #{location(index)}"
      end
    end
  end

  def normalized_guard(value)
    value.gsub("`", "").gsub(/(?:全部|同时)匹配/, "").split(/[+＋]/).map(&:strip).reject(&:empty?).sort
  end

  def capability_enabled?(key)
    value = @capability_values.fetch(key, "").gsub("`", "")
    value.match?(/\A(?:true|enabled|启用|开启)(?:[，、；\s]|\z)/i)
  end

  def semantic_obligation(family, obligation, pattern)
    index = @lines.each_index.find { |position| @lines[position].match?(pattern) }
    if index
      add_record("adjacent-semantic", {
        "adjacentFamily" => family,
        "semanticObligation" => obligation,
        "currentValue" => "present",
        "outputLocation" => location(index)
      })
    else
      @errors << "#{family}.#{obligation}: semantic evidence missing"
      add_record("adjacent-semantic", {
        "adjacentFamily" => family,
        "semanticObligation" => obligation,
        "currentValue" => "missing"
      })
    end
  end

  def audit_query_adjacent_semantics
    if capability_enabled?("filteringEnabled")
      semantic_obligation("filtering", "draft-applied-separation", /filterDraft.*appliedFilters|appliedFilters.*filterDraft/i)
      semantic_obligation("filtering", "declared-apply-mode", /applyMode|(?:采用|配置为|使用).*?(?:显式|即时)应用模式|filteringEnabled.*显式应用/i)
      semantic_obligation("filtering", "default-reset", /defaultFilters/)
      semantic_obligation("filtering", "visible-removable-applied-values", /已应用条件.*(?:持续可见|摘要).*(?:移除)|(?:移除).*已应用条件/m)
      semantic_obligation("filtering", "url-safety", /urlSafe|敏感.*(?:URL|标题|日志)|(?:URL|标题|日志).*敏感/i)
      semantic_obligation("filtering", "field-error-owner", /字段错误|aria-invalid|筛选错误/i)
      semantic_obligation("filtering", "pagination-reset", /筛选.*(?:第\s*1\s*页|页码.*(?:归|回).*1|初始游标)|(?:第\s*1\s*页|页码.*(?:归|回).*1|初始游标).*筛选/)
    end

    semantic_obligation("sorting", "actual-key-direction", /[A-Za-z][A-Za-z0-9_.]*\s+(?:ASC|DESC)\b/)
    semantic_obligation("sorting", "null-order", /NULLS\s+(?:FIRST|LAST)|空值.*(?:前|后|首|末)/i)
    semantic_obligation("sorting", "case-rule", /大小写|case[- ]?fold/i)
    semantic_obligation("sorting", "locale-rule", /locale|collation|区域/i)
    semantic_obligation("sorting", "natural-order-rule", /自然排序/)
    semantic_obligation("sorting", "unique-stable-key", /(?:唯一.*(?:不可变|稳定)|(?:不可变|稳定).*唯一).*(?:键|key)|(?:键|key).*(?:唯一.*(?:不可变|稳定)|(?:不可变|稳定).*唯一)/i)
    if capability_enabled?("sortingEnabled")
      semantic_obligation("sorting", "interactive-dom", /排序按钮|<button>/i)
      semantic_obligation("sorting", "interactive-aria", /aria-sort|排序.*可访问名称|可访问名称.*排序/i)
      semantic_obligation("sorting", "interactive-keyboard", /(?:Enter|Space).*排序|排序.*(?:Enter|Space)/i)
      semantic_obligation("sorting", "interactive-focus", /排序.*焦点|焦点.*排序/)
      semantic_obligation("sorting", "reset-to-origin", /排序.*(?:第\s*1\s*页|页码.*(?:归|回).*1|初始游标)|(?:第\s*1\s*页|页码.*(?:归|回).*1|初始游标).*排序/)
    end

    pagination = @capability_values.fetch("paginationMode", "").gsub("`", "")
    if pagination.include?("numbered")
      semantic_obligation("pagination-numbered", "reliable-total-and-range", /可靠.*(?:总数|totalCount)|(?:总数|totalCount).*可靠/i)
      semantic_obligation("pagination-numbered", "direct-pages", /直接页码|页码按钮/)
      semantic_obligation("pagination-numbered", "validated-jump", /跳页.*(?:整数|totalPages|非法|校验)/i)
      semantic_obligation("pagination-numbered", "native-boundaries", /(?:首页|末页).*(?:disabled|禁用)/i)
      semantic_obligation("pagination-numbered", "page-size-control", /页大小(?:控件|选择器)|页大小.*(?:原生单选组|有名称)|可选页大小|每页显示条数/i)
      semantic_obligation("pagination-numbered", "reset-to-first", /(?:筛选|排序|页大小).*(?:第\s*1\s*页|页码.*(?:归|回).*1)/)
      semantic_obligation("pagination-numbered", "single-invalid-page-recovery", /(?:失效页|当前页失效|超过.*末页).*(?:最近有效页|最新末页).*(?:一次|只请求)|(?:只请求一次|单次请求).*(?:最近有效页|最新末页)/)
      semantic_obligation("pagination-numbered", "input-semantics", /aria-current|跳页.*(?:标签|名称)|页大小.*(?:名称|单选)/i)
      semantic_obligation("pagination-numbered", "single-focus-transition", /翻页.*焦点.*(?:一次|不移动)|焦点.*(?:一次|不移动).*翻页/)
    elsif pagination.include?("cursor")
      semantic_obligation("pagination-cursor", "opaque-bidirectional-cursors", /不透明.*(?:上一页.*下一页|双向游标)|(?:上一页.*下一页).*不透明/)
      semantic_obligation("pagination-cursor", "missing-direction-disabled", /缺少.*游标.*(?:disabled|禁用)|没有对应游标.*(?:disabled|禁用)/i)
      semantic_obligation("pagination-cursor", "forbidden-numbered-and-stream-entries", /不得.*(?:总页数|页码|跳页).*(?:加载更多|无限滚动)|(?:总页数|页码|跳页).*(?:不得|不显示).*(?:加载更多|无限滚动)/)
      semantic_obligation("pagination-cursor", "origin-and-single-recovery", /(?:无效游标|游标.*失效).*(?:一次|只执行一次|初始游标)|(?:一次|只执行一次).*(?:无效游标|游标.*失效)/)
      semantic_obligation("pagination-cursor", "input-semantics", /上一页.*下一页.*(?:disabled|按钮)|(?:disabled|按钮).*上一页.*下一页/i)
      semantic_obligation("pagination-cursor", "single-focus-transition", /翻页.*焦点.*(?:一次|不移动)|焦点.*(?:一次|不移动).*翻页/)
    else
      @errors << "pagination: exact numbered/cursor current value missing"
    end
  end

  def audit_selection_generation_contract
    return unless @scenario == "bulk-action"

    expected_header = ["路径", "generationEffect", "snapshotEffect", "commitGuard", "mismatchEffect"]
    headers = []
    @lines.each_with_index do |line, index|
      cells = table_cells(line)
      headers << index if cells&.map { |cell| cell.gsub("`", "") } == expected_header
    end
    @errors << "selection contract: exact semantic header rows=#{headers.size}" unless headers.size == 1

    paths = ["资格变化", "异步选择协调回调", "操作结果调整当前选择"]
    rows = {}
    paths.each do |path|
      hits = []
      @lines.each_with_index do |line, index|
        cells = table_cells(line)
        hits << [index, cells] if cells && cells[0] == path
      end
      if hits.size != 1
        @errors << "selection contract #{path}: rows=#{hits.size}"
        next
      end
      index, cells = hits[0]
      if cells.size != 5
        @errors << "selection contract #{path}: columns=#{cells.size}"
        next
      end
      rows[path] = [index, cells]
    end

    if rows["资格变化"]
      index, cells = rows["资格变化"]
      generation = cells[1].gsub("`", "").gsub(/\s+/, "")
      unless generation.match?(/\AselectionGeneration(?:恰好)?\+1\z/)
        @errors << "selection contract 资格变化: generationEffect must increment exactly once"
      end
      snapshot = cells[2].gsub("`", "")
      unless snapshot.match?(/新的?不可变后继.*selectionSnapshot/i) && snapshot.match?(/旧快照.*(?:写入\s*(?:[=:：]|为)?\s*0|不变)/)
        @errors << "selection contract 资格变化: snapshotEffect must create immutable successor with prior write=0"
      end
      add_record("selection-contract", {
        "selectionContractPath" => "资格变化",
        "generationEffect" => cells[1],
        "snapshotEffect" => cells[2],
        "commitGuard" => cells[3],
        "mismatchEffect" => cells[4],
        "outputLocation" => location(index)
      })
    end

    if rows["异步选择协调回调"]
      index, cells = rows["异步选择协调回调"]
      expected_guard = %w[live ownerId lifecycleToken selectionGeneration].sort
      unless normalized_guard(cells[3]) == expected_guard
        @errors << "selection contract 异步选择协调回调: commitGuard must equal live+ownerId+lifecycleToken+selectionGeneration"
      end
      mismatch = cells[4].gsub("`", "")
      unless mismatch.include?("selection-result-discarded") && mismatch.match?(/(?:selection(?:Write| write|写入)|选择写入)\s*(?:[=:：]|为)?\s*0/i)
        @errors << "selection contract 异步选择协调回调: mismatchEffect must discard with selectionWrite=0"
      end
      add_record("selection-contract", {
        "selectionContractPath" => "异步选择协调回调",
        "generationEffect" => cells[1],
        "snapshotEffect" => cells[2],
        "commitGuard" => cells[3],
        "mismatchEffect" => cells[4],
        "outputLocation" => location(index)
      })
    end

    if rows["操作结果调整当前选择"]
      index, cells = rows["操作结果调整当前选择"]
      guard = cells[3].gsub("`", "").gsub(/\s+/, "")
      english_guard = guard.match?(/(?:capturedSelectionGeneration|operationSnapshot\.selectionGeneration)(?:==|===|等于)(?:currentSelectionGeneration|interactionState\.selectionGeneration|selectionGeneration)/)
      chinese_guard = guard.match?(/捕获的?selectionGeneration(?:==|===|等于)当前selectionGeneration/)
      unless english_guard || chinese_guard
        @errors << "selection contract 操作结果调整当前选择: commitGuard must compare captured and current generation before write"
      end
      mismatch = cells[4].gsub("`", "")
      operation_owner_only = mismatch.match?(/operation(?:Result)?Owner(?:Write)?\s*[=:：]?\s*1/i) ||
                             mismatch.match?(/(?:operation\s*result|操作结果)\s*owner.*(?:只写|写入\s*[=:：]?\s*1)/i) ||
                             mismatch.match?(/只写.*(?:operation\s*result|操作结果)\s*owner/i)
      unless operation_owner_only &&
             mismatch.match?(/(?:selection(?:Write| write|写入)|选择写入)\s*(?:[=:：]|为)?\s*0/i)
        @errors << "selection contract 操作结果调整当前选择: mismatchEffect must be operation owner only with selectionWrite=0"
      end
      add_record("selection-contract", {
        "selectionContractPath" => "操作结果调整当前选择",
        "generationEffect" => cells[1],
        "snapshotEffect" => cells[2],
        "commitGuard" => cells[3],
        "mismatchEffect" => cells[4],
        "outputLocation" => location(index)
      })
    end

    contradictions = {
      "in-place snapshot mutation" => /原地修改当前\s*selectionSnapshot/i,
      "generation display-only" => /selectionGeneration\s*\+?\s*1.*只写入展示/m,
      "partial live-only guard" => /异步选择协调回调只校验\s*live/i,
      "recorded but not compared guard" => /(?:ownerId|lifecycleToken|selectionGeneration).*不参与门禁/m,
      "late selection result accepted" => /迟到结果仍可提交/i,
      "mismatched operation result writes selection" => /捕获代次不匹配.*仍调整当前选择/m
    }
    contradictions.each do |name, pattern|
      @errors << "selection contract contradiction: #{name}" if @output.match?(pattern)
    end
  end
end

def replace_capability_value(output, key, new_value)
  lines = output.lines
  index = lines.each_index.find { |i| lines[i].match?(/^\|.*`#{Regexp.escape(key)}`.*\|$/) }
  raise "mutation source capability missing: #{key}" unless index

  cells = table_cells(lines[index].chomp)
  cells[1] = new_value
  lines[index] = "| #{cells.join(' | ')} |\n"
  lines.join
end

def remove_table_row(output, label)
  lines = output.lines
  before = lines.length
  lines.reject! do |line|
    cells = table_cells(line.chomp)
    cells && cells[0] == label
  end
  raise "mutation source row missing: #{label}" if lines.length == before

  lines.join
end

def replace_applicability(output, label, value)
  lines = output.lines
  index = lines.each_index.find do |i|
    cells = table_cells(lines[i].chomp)
    cells && cells[0] == label
  end
  raise "mutation source row missing: #{label}" unless index

  cells = table_cells(lines[index].chomp)
  cells[1] = value
  lines[index] = "| #{cells.join(' | ')} |\n"
  lines.join
end

def replace_contract_cell(output, path, column, value)
  headers = ["路径", "generationEffect", "snapshotEffect", "commitGuard", "mismatchEffect"]
  raise "unknown selection contract column: #{column}" unless headers.include?(column)

  lines = output.lines
  index = lines.each_index.find do |i|
    cells = table_cells(lines[i].chomp)
    cells && cells[0] == path
  end
  raise "mutation source selection contract row missing: #{path}" unless index

  cells = table_cells(lines[index].chomp)
  raise "mutation source selection contract columns=#{cells.size}" unless cells.size == headers.size

  cells[headers.index(column)] = value
  lines[index] = "| #{cells.join(' | ')} |\n"
  lines.join
end

def replace_in_heading_section(output, heading_name, source, replacement)
  lines = output.lines
  heading = lines.each_index.find do |index|
    lines[index].match?(/^###\s+.*`#{Regexp.escape(heading_name)}`/)
  end
  raise "mutation source heading missing: #{heading_name}" unless heading

  finish = ((heading + 1)...lines.length).find { |index| lines[index].start_with?("### ") }
  finish ||= lines.length
  indexes = (heading...finish).select { |position| lines[position].include?(source) }
  raise "mutation source text missing in #{heading_name}: #{source}" if indexes.empty?

  indexes.each { |index| lines[index] = lines[index].gsub(source, replacement) }
  lines.join
end

def merge_rows(output, labels, merged_label)
  lines = output.lines
  indexes = []
  lines.each_with_index do |line, index|
    cells = table_cells(line.chomp)
    indexes << index if cells && labels.include?(cells[0])
  end
  raise "mutation source rows missing: #{labels.inspect}" unless indexes.size == labels.size

  insertion = indexes.min
  lines = lines.each_with_index.reject { |_line, index| indexes.include?(index) }.map(&:first)
  lines.insert(insertion, "| #{merged_label} | 部分适用 | 合并后的混合证据 | 未验证 |\n")
  lines.join
end

base_dir = File.expand_path(__dir__)
outputs = {}
audits = {}
FILES.each do |scenario, file|
  outputs[scenario] = raw_output(File.join(base_dir, file))
  audits[scenario] = Audit.new(scenario, outputs[scenario]).run
end

baseline_errors = audits.values.flat_map(&:errors)

if ARGV.include?("--records")
  columns = %w[
    scenario recordKind capabilityKey currentValue stateGroup minimumField
    lifecycleRole checklistRow adjacentFamily semanticObligation selectionContractPath generationEffect
    snapshotEffect commitGuard mismatchEffect applicability verificationStatus
    outputLocation
  ]
  puts "| #{columns.join(' | ')} |"
  puts "| #{columns.map { '---' }.join(' | ')} |"
  audits.each_value do |audit|
    audit.records.each do |record|
      values = columns.map do |column|
        record[column].to_s.gsub("|", "\\|").gsub("\n", " ")
      end
      puts "| #{values.join(' | ')} |"
    end
  end
  audits.each do |scenario, audit|
    puts "RECORD_COUNT #{scenario}=#{audit.records.size}"
  end
  if baseline_errors.empty?
    puts "AUDIT_STATUS PASS"
    exit 0
  end
  puts "AUDIT_STATUS FAIL errors=#{baseline_errors.size}"
  baseline_errors.each { |error| puts "AUDIT_ERROR #{error}" }
  exit 1
end

unless baseline_errors.empty? || ARGV.include?("--mutations-on-failing-baseline")
  warn "BASELINE FAIL errors=#{baseline_errors.size}"
  baseline_errors.each { |error| warn "  #{error}" }
  exit 1
end

baseline_status = baseline_errors.empty? ? "PASS" : "FAIL"
puts "BASELINE #{baseline_status} scenarios=#{audits.size} records=#{audits.values.map { |audit| audit.records.size }.sum} errors=#{baseline_errors.size}"
audits.each do |scenario, audit|
  puts "  #{scenario}: #{audit.errors.empty? ? 'PASS' : 'FAIL'} records=#{audit.records.size} errors=#{audit.errors.size}"
  audit.errors.each { |error| puts "    #{error}" }
end

mutations = []
mutations << ["M01-remove-bulkOperationEnabled", "bulk-action", "delete capability current value",
              remove_table_row(outputs["bulk-action"], "`bulkOperationEnabled`")]
mutations << ["M02-conditional-allFilteredSelectionEnabled", "bulk-action", "replace current boolean with condition-only text",
              replace_capability_value(outputs["bulk-action"], "allFilteredSelectionEnabled", "满足后端条件时启用")]
mutations << ["M03-remove-row-viewState", "row-action", "rename fixed viewState heading",
              outputs["row-action"].sub("### `viewState`", "### view model")]
mutations << ["M04-remove-bulk-interactionState", "bulk-action", "rename fixed interactionState heading",
              outputs["bulk-action"].sub("### `interactionState`", "### interaction model")]
VIEW_FIELDS.keys.each_with_index do |field, index|
  mutations << [format("M%02d-remove-bulk-view-%s", index + 5, field), "bulk-action",
                "remove #{field} from viewState",
                replace_in_heading_section(outputs["bulk-action"], "viewState", field, "removed#{index}")]
end
mutations << ["M11-lifecycle-substitutes-group", "row-action", "replace independent lifecycle guard heading with lifecycleState",
              outputs["row-action"].sub(/^###\s+.*`lifecycleGuard`.*$/, "### `lifecycleState`")]
mutations << ["M12-delete-runtime-checklist-row", "display", "delete standalone runtime verification checklist row",
              remove_table_row(outputs["display"], "运行时验证边界")]
mutations << ["M13-delete-filter-checklist-row", "display", "delete independent A38 filter checklist row",
              remove_table_row(outputs["display"], "筛选")]
mutations << ["M14-partial-applicability", "row-action", "replace binary selection applicability with 部分适用",
              replace_applicability(outputs["row-action"], "选择", "部分适用")]
mutations << ["M15-merge-selection-operations", "row-action", "merge selection, row operation and bulk operation",
              merge_rows(outputs["row-action"], ["选择", "单行操作", "批量操作"], "选择与操作")]
mutations << ["M16-merge-column-families", "bulk-action", "merge base column state and optional column controls",
              merge_rows(outputs["bulk-action"], ["基础列状态", "可选列控制"], "列")]
mutations << ["M17-merge-table-grid", "display", "merge Table and ARIA Grid semantics",
              merge_rows(outputs["display"], ["Table 语义", "ARIA Grid 语义"], "Table/Grid")]
mutations << ["M18-merge-disposal-isolation", "display", "merge disposal and instance isolation",
              merge_rows(outputs["display"], ["disposal", "实例隔离"], "disposal/实例隔离")]
mutations << ["M19-status-in-applicability", "display", "mix runtime verification status into applicability",
              replace_applicability(outputs["display"], "运行时验证边界", "适用，当前未验证")]
mutations << ["M20-break-selection-generation-contract", "bulk-action",
              "preserve selectionGeneration reference while changing +1 state transition to display-only",
              replace_contract_cell(outputs["bulk-action"], "资格变化", "generationEffect",
                                    "selectionGeneration +1 只计算展示数字，状态保持不变")]
mutations << ["M21-drop-selection-lifecycleToken-guard", "bulk-action",
              "remove lifecycleToken from the async selection commit guard",
              replace_contract_cell(outputs["bulk-action"], "异步选择协调回调", "commitGuard",
                                    "live + ownerId + selectionGeneration")]
mutations << ["M22-operation-generation-mismatch-writes-selection", "bulk-action",
              "allow operation result to adjust selection after captured generation mismatch",
              replace_contract_cell(outputs["bulk-action"], "操作结果调整当前选择", "mismatchEffect",
                                    "operationResultOwnerWrite=1；selectionWrite=1")]

unexpected_passes = []
mutations.each do |id, scenario, description, mutated|
  result = Audit.new(scenario, mutated).run
  new_errors = result.errors - audits.fetch(scenario).errors
  if new_errors.empty?
    unexpected_passes << id
    puts "MUTATION UNEXPECTED_PASS id=#{id} scenario=#{scenario} operator=#{description.inspect}"
  else
    puts "MUTATION EXPECTED_FAIL id=#{id} scenario=#{scenario} operator=#{description.inspect} new_errors=#{new_errors.size}"
    new_errors.each { |error| puts "  #{error}" }
  end
end

unless unexpected_passes.empty?
  warn "MUTATION AUDIT FAIL unexpected_passes=#{unexpected_passes.join(',')}"
  exit 1
end

puts "MUTATION AUDIT PASS expected_failures=#{mutations.size}/#{mutations.size}"
exit 1 unless baseline_errors.empty?
