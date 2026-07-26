# frozen_string_literal: true

# A40 fixed-output-slot audit. It is intentionally separate from the frozen
# Attempt 6/7 auditor so historical hashes and replay receipts remain intact.

prefix = ENV.fetch("DATA_TABLE_AUDIT_PREFIX", "attempt-7")
files = {
  "display" => "#{prefix}-display-report.md",
  "row-action" => "#{prefix}-row-action-list.md",
  "bulk-action" => "#{prefix}-bulk-action-table.md"
}.freeze

ATOMIC_ROWS = [
  "能力与状态", "查询", "筛选", "排序", "分页", "数据状态", "选择",
  "单行操作", "批量操作", "基础列状态", "可选列控制", "Table 语义",
  "ARIA Grid 语义", "键盘", "焦点", "响应式", "ARIA 与公告",
  "disposal", "实例隔离", "运行时验证边界"
].freeze

FAMILY_SLOTS = {
  "filtering" => %w[
    draft-applied-separation declared-apply-mode default-reset
    visible-removable-applied-values url-safety field-error-owner
    pagination-reset
  ],
  "sorting" => %w[
    actual-key-direction null-order case-rule locale-rule natural-order-rule
    unique-stable-key interactive-dom interactive-aria interactive-keyboard
    interactive-focus reset-to-origin
  ],
  "pagination-numbered" => %w[
    reliable-total-and-range direct-pages validated-jump native-boundaries
    page-size-control reset-to-first single-invalid-page-recovery
    input-semantics single-focus-transition
  ],
  "pagination-cursor" => %w[
    opaque-bidirectional-cursors missing-direction-disabled
    forbidden-numbered-and-stream-entries origin-and-single-recovery
    input-semantics single-focus-transition
  ]
}.freeze

SEMANTIC_PATTERNS = {
  ["filtering", "draft-applied-separation"] => /(?:filterDraft|草稿).*(?:appliedFilters|已应用)|(?:appliedFilters|已应用).*(?:filterDraft|草稿)/i,
  ["filtering", "declared-apply-mode"] => /explicit|immediate|显式|即时/i,
  ["filtering", "default-reset"] => /重置|reset/i,
  ["filtering", "visible-removable-applied-values"] => /(?:条件|已应用).*(?:显示|可见|摘要).*(?:移除)|(?:移除).*(?:条件|已应用)/m,
  ["filtering", "url-safety"] => /urlSafe|URL[- ]?safe|URL.*(?:敏感|禁止)|(?:敏感|禁止).*URL/i,
  ["filtering", "field-error-owner"] => /字段.*(?:owner|归)|aria-invalid|queryError/i,
  ["filtering", "pagination-reset"] => /(?:应用|移除|重置|筛选).*(?:第\s*1\s*页|初始游标|origin)/,
  ["sorting", "actual-key-direction"] => /[A-Za-z][A-Za-z0-9_.]*\s+(?:ASC|DESC)\b/,
  ["sorting", "null-order"] => /NULLS\s+(?:FIRST|LAST)|空值.*(?:前|后|首|末)/i,
  ["sorting", "case-rule"] => /大小写|case[- ]?fold/i,
  ["sorting", "locale-rule"] => /locale|collation|区域|zh-CN|und/i,
  ["sorting", "natural-order-rule"] => /natural|自然/i,
  ["sorting", "unique-stable-key"] => /(?:唯一|不可变|稳定).*(?:recordId|键|key)|(?:recordId|键|key).*(?:唯一|不可变|稳定)/i,
  ["sorting", "interactive-dom"] => /<button>|按钮/i,
  ["sorting", "interactive-aria"] => /aria-sort|可访问名称/i,
  ["sorting", "interactive-keyboard"] => /Enter|Space|键盘/i,
  ["sorting", "interactive-focus"] => /焦点|focus/i,
  ["sorting", "reset-to-origin"] => /(?:排序|方向).*(?:第\s*1\s*页|初始游标|origin)/,
  ["pagination-numbered", "reliable-total-and-range"] => /(?:可靠|服务端).*(?:total|总数).*(?:范围|总页|pageCount)|(?:范围|总页).*(?:total|总数)/i,
  ["pagination-numbered", "direct-pages"] => /直接页码|页码.*按钮|aria-current/i,
  ["pagination-numbered", "validated-jump"] => /跳页.*(?:整数|pageCount|totalPages|无效|非法|校验)|(?:1\.\.|1…).*整数/i,
  ["pagination-numbered", "native-boundaries"] => /(?:首页|末页|上一页|下一页).*(?:disabled|禁用)/i,
  ["pagination-numbered", "page-size-control"] => /页大小|每页|选择控件/i,
  ["pagination-numbered", "reset-to-first"] => /(?:筛选|排序|页大小).*(?:第\s*1\s*页|回.*1)/,
  ["pagination-numbered", "single-invalid-page-recovery"] => /(?:一次|只恢复一次|单次).*(?:有效末页|失效页)|(?:失效页|有效末页).*(?:一次|只恢复一次|单次)/,
  ["pagination-numbered", "input-semantics"] => /(?:按钮|跳页|页大小).*(?:原生|输入|Enter|Space|可访问名称)|(?:原生|Enter|Space).*(?:按钮|跳页|页大小)/i,
  ["pagination-numbered", "single-focus-transition"] => /(?:一次|仅一次|不二次).*(?:焦点|聚焦)|(?:焦点|聚焦).*(?:一次|仅一次|不二次)/,
  ["pagination-cursor", "opaque-bidirectional-cursors"] => /不透明.*(?:prevCursor|nextCursor|上一页|下一页|双向)|(?:prevCursor|nextCursor|上一页|下一页).*(?:不透明)/i,
  ["pagination-cursor", "missing-direction-disabled"] => /(?:缺少|没有).*(?:游标|方向).*(?:disabled|禁用)|(?:disabled|禁用).*(?:游标|方向)/i,
  ["pagination-cursor", "forbidden-numbered-and-stream-entries"] => /(?:页码|跳页).*(?:加载更多|无限滚动).*(?:0|禁止|不得)|(?:页码|跳页|加载更多|无限滚动).*(?:DOM.*0|均为\s*0)/,
  ["pagination-cursor", "origin-and-single-recovery"] => /(?:初始游标|origin).*(?:一次|最多)|(?:一次|最多).*(?:初始游标|失败快照|失效游标)/i,
  ["pagination-cursor", "input-semantics"] => /上一页.*下一页.*(?:按钮|原生|键盘|触摸)|(?:按钮|原生).*(?:上一页|下一页)/,
  ["pagination-cursor", "single-focus-transition"] => /(?:一次|仅一次|额外焦点为\s*0).*(?:焦点|聚焦)|(?:焦点|聚焦).*(?:一次|仅一次|额外.*0)/
}.freeze

CHECKLIST_HEADER = [
  "原子规则族", "适用性", "DOM", "state", "handler/event", "request",
  "正文定位", "验证状态"
].freeze
OPERATION_HEADER = [
  "operationKind", "currentValue", "stateSlot", "DOM", "handler/event",
  "request"
].freeze
SLOT_HEADER = [
  "ruleFamily", "obligationKey", "applicability", "currentValueOrZeroEvidence",
  "outputLocation", "verificationStatus"
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

  line.split("|", -1)[1...-1].map { |cell| cell.strip.gsub("`", "") }
end

class SlotAudit
  attr_reader :errors, :records

  def initialize(scenario, output)
    @scenario = scenario
    @lines = output.lines.map(&:chomp)
    @errors = []
    @records = []
    @capabilities = capability_values
  end

  def run
    audit_checklist
    audit_operation_slots
    audit_family_slots
    self
  end

  private

  def capability_values
    values = {}
    @lines.each do |line|
      cells = table_cells(line)
      values[cells[0]] = cells[1] if cells&.size.to_i >= 2

      # DT-REPORT-04 fixes the field names, not a Markdown presentation shape.
      # Accept either a table row or a labelled list item while retaining the
      # literal declared value for the semantic checks below.
      normalized = line.gsub("`", "").gsub("**", "")
      %w[
        capabilityTier resolvedTier paginationMode filteringEnabled
        sortingEnabled rowOperationEnabled bulkOperationEnabled
      ].each do |name|
        match = normalized.match(/\b#{Regexp.escape(name)}\b\s*[:：=]\s*([^|；;]+)/i)
        values[name] = match[1].strip if match
      end
    end
    values
  end

  def normalized_family(value, pagination_family)
    case value.to_s.strip.downcase
    when "filtering", "筛选"
      "filtering"
    when "sorting", "排序"
      "sorting"
    when "pagination-numbered", "numbered"
      "pagination-numbered"
    when "pagination-cursor", "cursor"
      "pagination-cursor"
    when "pagination", "分页"
      pagination_family
    else
      value.to_s.strip
    end
  end

  def rows_with_header(header)
    header_indexes = @lines.each_index.select { |index| table_cells(@lines[index]) == header }
    return [nil, [], header_indexes.size] unless header_indexes.size == 1

    header_index = header_indexes[0]

    rows = []
    ((header_index + 2)...@lines.length).each do |index|
      cells = table_cells(@lines[index])
      break unless cells

      rows << [index, cells]
    end
    [header_index, rows, 1]
  end

  def location(index)
    "RAW OUTPUT:L#{index + 1}"
  end

  def audit_checklist
    header_index, rows, header_count = rows_with_header(CHECKLIST_HEADER)
    unless header_index
      @errors << "checklist: exact fixed header rows=#{header_count}"
      return
    end

    @errors << "checklist: exact row count must be #{ATOMIC_ROWS.size}, got #{rows.size}" unless rows.size == ATOMIC_ROWS.size

    ATOMIC_ROWS.each do |name|
      hits = rows.select { |_index, cells| cells[0] == name }
      if hits.size != 1
        @errors << "checklist #{name}: rows=#{hits.size}"
        next
      end

      index, cells = hits[0]
      applicability = cells[1]
      unless %w[适用 不适用].include?(applicability)
        @errors << "checklist #{name}: non-binary applicability=#{applicability.inspect}"
      end
      if applicability == "不适用"
        %w[DOM state handler/event request].each_with_index do |key, offset|
          value = cells[offset + 2]
          @errors << "checklist #{name}: #{key} must equal 0" unless value == "0"
        end
      else
        %w[DOM state handler/event request].each_with_index do |key, offset|
          @errors << "checklist #{name}: #{key} field empty" if cells[offset + 2].to_s.empty?
        end
      end
      @errors << "checklist #{name}: outputLocation missing" if cells[6].to_s.empty?
      @errors << "checklist #{name}: verificationStatus missing" if cells[7].to_s.empty?
      @records << ["checklist", name, location(index), cells]
    end
  end

  def audit_operation_slots
    header_index, rows, header_count = rows_with_header(OPERATION_HEADER)
    unless header_index
      @errors << "operation slots: exact fixed header rows=#{header_count}"
      return
    end

    @errors << "operation slots: exact row count must be 2, got #{rows.size}" unless rows.size == 2

    { "row" => "rowOperationEnabled", "bulk" => "bulkOperationEnabled" }.each do |kind, capability|
      hits = rows.select { |_index, cells| cells[0] == kind }
      if hits.size != 1
        @errors << "operation slot #{kind}: rows=#{hits.size}"
        next
      end

      index, cells = hits[0]
      enabled = @capabilities.fetch(capability, "").match?(/\A(?:true|enabled|启用|开启)/i)
      if enabled
        @errors << "operation slot #{kind}: currentValue must be instantiated" if cells[1].to_s.empty? || cells[1] == "not-instantiated"
        @errors << "operation slot #{kind}: stateSlot missing" if cells[2].to_s.empty? || cells[2] == "0"
        %w[DOM handler/event request].each_with_index do |key, offset|
          @errors << "operation slot #{kind}: #{key} field empty" if cells[offset + 3].to_s.empty?
        end
      else
        @errors << "operation slot #{kind}: currentValue must be not-instantiated" unless cells[1] == "not-instantiated"
        %w[stateSlot DOM handler/event request].each_with_index do |key, offset|
          @errors << "operation slot #{kind}: #{key} must equal 0" unless cells[offset + 2] == "0"
        end
      end
      @records << ["operation", kind, location(index), cells]
    end
  end

  def audit_family_slots
    header_index, rows, header_count = rows_with_header(SLOT_HEADER)
    unless header_index
      @errors << "family slots: exact fixed header rows=#{header_count}"
      return
    end

    expected = FAMILY_SLOTS["filtering"].map { |key| ["filtering", key] }
    expected.concat(FAMILY_SLOTS["sorting"].map { |key| ["sorting", key] })
    pagination = @capabilities.fetch("paginationMode", "")
    family = pagination.include?("cursor") ? "pagination-cursor" : "pagination-numbered"
    expected.concat(FAMILY_SLOTS.fetch(family).map { |key| [family, key] })

    @errors << "family slots: exact row count must be #{expected.size}, got #{rows.size}" unless rows.size == expected.size

    expected.each do |slot_family, key|
      hits = rows.select do |_index, cells|
        normalized_family(cells[0], family) == slot_family && cells[1] == key
      end
      if hits.size != 1
        @errors << "family slot #{slot_family}.#{key}: rows=#{hits.size}"
        next
      end

      index, cells = hits[0]
      applicability = cells[2]
      unless %w[适用 不适用].include?(applicability)
        @errors << "family slot #{slot_family}.#{key}: non-binary applicability=#{applicability.inspect}"
      end
      evidence = cells[3].to_s
      if evidence.empty? || evidence.match?(/\A(?:见|第?\s*\d+\s*节|§\s*\d+(?:\.\d+)*)\z/)
        @errors << "family slot #{slot_family}.#{key}: concrete current value/zero evidence missing"
      end
      if applicability == "不适用" && evidence != "DOM=0;state=0;handler/event=0;request=0"
        @errors << "family slot #{slot_family}.#{key}: zero evidence must use four exact fields"
      elsif applicability == "适用"
        pattern = SEMANTIC_PATTERNS.fetch([slot_family, key])
        unless evidence.match?(pattern)
          @errors << "family slot #{slot_family}.#{key}: concrete semantic value does not satisfy slot contract"
        end
      end
      @errors << "family slot #{slot_family}.#{key}: outputLocation missing" if cells[4].to_s.empty?
      @errors << "family slot #{slot_family}.#{key}: verificationStatus missing" if cells[5].to_s.empty?
      @records << ["family-slot", "#{slot_family}.#{key}", location(index), cells]
    end


    filtering_enabled = @capabilities.fetch("filteringEnabled", "").match?(/\A(?:true|enabled|启用|开启)/i)
    sorting_enabled = @capabilities.fetch("sortingEnabled", "").match?(/\A(?:true|enabled|启用|开启)/i)
    rows.each do |_index, cells|
      next unless cells.size == SLOT_HEADER.size

      slot_family = normalized_family(cells[0], family)
      key, applicability = cells[1], cells[2]
      expected_applicability = if slot_family == "filtering"
                                 filtering_enabled ? "适用" : "不适用"
                               elsif slot_family == "sorting" && FAMILY_SLOTS["sorting"].last(5).include?(key)
                                 sorting_enabled ? "适用" : "不适用"
                               elsif expected.include?([slot_family, key])
                                 "适用"
                               end
      next unless expected_applicability && applicability != expected_applicability

      @errors << "family slot #{slot_family}.#{key}: applicability must equal #{expected_applicability}"
    end
  end
end

def remove_row(output, header, identity)
  lines = output.lines
  header_index = lines.each_index.find { |index| table_cells(lines[index].chomp) == header }
  raise "mutation header missing: #{header.inspect}" unless header_index

  index = ((header_index + 2)...lines.length).find do |position|
    cells = table_cells(lines[position].chomp)
    cells && identity.all? { |column, value| cells[header.index(column)]&.gsub("`", "") == value }
  end
  raise "mutation row missing: #{identity.inspect}" unless index

  lines.delete_at(index)
  lines.join
end

def replace_cell(output, header, identity, column, value)
  lines = output.lines
  header_index = lines.each_index.find { |index| table_cells(lines[index].chomp) == header }
  raise "mutation header missing: #{header.inspect}" unless header_index

  index = ((header_index + 2)...lines.length).find do |position|
    cells = table_cells(lines[position].chomp)
    cells && identity.all? { |key, expected| cells[header.index(key)]&.gsub("`", "") == expected }
  end
  raise "mutation row missing: #{identity.inspect}" unless index

  raw_cells = lines[index].chomp.split("|", -1)[1...-1].map(&:strip)
  raw_cells[header.index(column)] = value
  lines[index] = "| #{raw_cells.join(' | ')} |\n"
  lines.join
end

def duplicate_row(output, header, identity)
  lines = output.lines
  header_index = lines.each_index.find { |index| table_cells(lines[index].chomp) == header }
  raise "mutation header missing: #{header.inspect}" unless header_index

  index = ((header_index + 2)...lines.length).find do |position|
    cells = table_cells(lines[position].chomp)
    cells && identity.all? { |key, expected| cells[header.index(key)]&.gsub("`", "") == expected }
  end
  raise "mutation row missing: #{identity.inspect}" unless index

  lines.insert(index + 1, lines[index].dup)
  lines.join
end

base_dir = File.expand_path(__dir__)
outputs = files.to_h do |scenario, filename|
  [scenario, raw_output(File.join(base_dir, filename))]
end
audits = outputs.to_h do |scenario, output|
  [scenario, SlotAudit.new(scenario, output).run]
end
errors = audits.values.flat_map(&:errors)

if ARGV.include?("--records")
  columns = %w[
    scenario recordKind checklistRow operationKind ruleFamily obligationKey
    applicability currentValueOrZeroEvidence DOM state handler/event request
    authoredOutputLocation verificationStatus auditLocation
  ]
  puts "| #{columns.join(' | ')} |"
  puts "| #{columns.map { '---' }.join(' | ')} |"
  audits.each do |scenario, audit|
    audit.records.each do |kind, key, audit_location, cells|
      values = columns.to_h { |column| [column, ""] }
      values["scenario"] = scenario
      values["recordKind"] = kind
      values["auditLocation"] = audit_location
      case kind
      when "checklist"
        values.merge!({
          "checklistRow" => key, "applicability" => cells[1],
          "DOM" => cells[2], "state" => cells[3],
          "handler/event" => cells[4], "request" => cells[5],
          "authoredOutputLocation" => cells[6], "verificationStatus" => cells[7]
        })
      when "operation"
        values.merge!({
          "operationKind" => key, "currentValueOrZeroEvidence" => cells[1],
          "state" => cells[2], "DOM" => cells[3],
          "handler/event" => cells[4], "request" => cells[5]
        })
      when "family-slot"
        values.merge!({
          "ruleFamily" => cells[0], "obligationKey" => cells[1],
          "applicability" => cells[2], "currentValueOrZeroEvidence" => cells[3],
          "authoredOutputLocation" => cells[4], "verificationStatus" => cells[5]
        })
      end
      escaped = columns.map { |column| values[column].to_s.gsub("|", "\\|").gsub("\n", " ") }
      puts "| #{escaped.join(' | ')} |"
    end
  end
end

puts "A40 #{errors.empty? ? 'PASS' : 'FAIL'} scenarios=#{audits.size} records=#{audits.values.sum { |audit| audit.records.size }} errors=#{errors.size}"
audits.each do |scenario, audit|
  puts "  #{scenario}: #{audit.errors.empty? ? 'PASS' : 'FAIL'} records=#{audit.records.size} errors=#{audit.errors.size}"
  audit.errors.each { |error| puts "    #{error}" }
end

if ARGV.include?("--mutations")
  unless errors.empty?
    warn "mutation baseline must pass"
    exit 1
  end

  mutations = []
  mutations << ["M23-remove-row-operation-slot", "bulk-action",
                remove_row(outputs["bulk-action"], OPERATION_HEADER, "operationKind" => "row")]
  mutations << ["M24-remove-grid-request-zero", "bulk-action",
                replace_cell(outputs["bulk-action"], CHECKLIST_HEADER,
                             { "原子规则族" => "ARIA Grid 语义" }, "request", "")]

  missing_slots = [
    ["M25", "filtering", "draft-applied-separation"],
    ["M26", "filtering", "default-reset"],
    ["M27", "filtering", "url-safety"],
    ["M28", "filtering", "field-error-owner"],
    ["M29", "filtering", "pagination-reset"],
    ["M30", "sorting", "natural-order-rule"],
    ["M31", "sorting", "interactive-aria"],
    ["M32", "sorting", "interactive-keyboard"],
    ["M33", "sorting", "reset-to-origin"],
    ["M34", "pagination-numbered", "reliable-total-and-range"],
    ["M35", "pagination-numbered", "direct-pages"],
    ["M36", "pagination-numbered", "validated-jump"],
    ["M37", "pagination-numbered", "native-boundaries"],
    ["M38", "pagination-numbered", "page-size-control"],
    ["M39", "pagination-numbered", "reset-to-first"],
    ["M40", "pagination-numbered", "single-invalid-page-recovery"],
    ["M41", "pagination-numbered", "input-semantics"]
  ]
  missing_slots.each do |id, family, key|
    mutations << ["#{id}-remove-#{family}-#{key}", "bulk-action",
                  remove_row(outputs["bulk-action"], SLOT_HEADER,
                             "obligationKey" => key)]
  end
  mutations << ["M42-coarse-reference", "display",
                replace_cell(outputs["display"], SLOT_HEADER,
                             { "obligationKey" => "default-reset" },
                             "currentValueOrZeroEvidence", "见第 3 节")]
  mutations << ["M43-shift-checklist-header", "display",
                outputs["display"].sub(
                  "| #{CHECKLIST_HEADER.join(' | ')} |",
                  "| 原子规则族 | 适用性 | state | DOM | handler/event | request | 正文定位 | 验证状态 |"
                )]
  mutations << ["M44-incomplete-zero-evidence", "row-action",
                replace_cell(outputs["row-action"], SLOT_HEADER,
                             { "obligationKey" => "url-safety" },
                             "currentValueOrZeroEvidence", "DOM=0;state=0;handler/event=0")]
  mutations << ["A40-M45-remove-checklist-row", "display",
                remove_row(outputs["display"], CHECKLIST_HEADER, "原子规则族" => "键盘")]
  mutations << ["A40-M46-duplicate-checklist-row", "display",
                duplicate_row(outputs["display"], CHECKLIST_HEADER, "原子规则族" => "键盘")]
  mutations << ["A40-M47-replace-disabled-operation-slot", "bulk-action",
                replace_cell(outputs["bulk-action"], OPERATION_HEADER,
                             { "operationKind" => "row" }, "operationKind", "bulk")]

  unexpected = []
  mutations.each do |id, scenario, mutated|
    result = SlotAudit.new(scenario, mutated).run
    new_errors = result.errors - audits.fetch(scenario).errors
    if new_errors.empty?
      unexpected << id
      puts "MUTATION UNEXPECTED_PASS id=#{id} scenario=#{scenario}"
    else
      puts "MUTATION EXPECTED_FAIL id=#{id} scenario=#{scenario} new_errors=#{new_errors.size}"
      new_errors.each { |error| puts "  #{error}" }
    end
  end
  unless unexpected.empty?
    warn "MUTATION AUDIT FAIL unexpected_passes=#{unexpected.join(',')}"
    exit 1
  end
  puts "MUTATION AUDIT PASS expected_failures=#{mutations.size}/#{mutations.size}"
end

exit(errors.empty? ? 0 : 1)
