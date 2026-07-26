# frozen_string_literal: true

# Reproducible A37/A38/A39 audit for the three frozen Attempt 6 RAW outputs.
# Default mode verifies the baselines and proves every named mutation fails.
# --records emits the tracked field-level Markdown ledger.

FILES = {
  "display" => "green-display-report.md",
  "row-action" => "green-row-action-list.md",
  "bulk-action" => "green-bulk-action-table.md"
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
  end

  def run
    audit_capabilities
    audit_state_groups
    audit_lifecycle
    audit_atomic_checklist
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
      next unless cells && cells[0].match?(/原子规则族|规则族/) && cells.include?("验证状态")

      header_hits << index
    end
    @errors << "checklist: separate 验证状态 column missing" unless header_hits.size == 1

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
      applicability = cells[1].to_s
      unless ["适用", "不适用"].include?(applicability)
        @errors << "checklist #{row}: non-binary applicability=#{applicability.inspect}"
      end
      if cells.length < 4
        @errors << "checklist #{row}: verification status not separate"
      end
      status = cells[-1].to_s
      @errors << "checklist #{row}: empty verification status" if status.empty?
      evidence = cells[2...-1].join(" ")
      if applicability == "适用" && !evidence.match?(/第?\s*\d|节|RAW OUTPUT:L/)
        @errors << "checklist #{row}: applicable outputLocation missing"
      elsif applicability == "不适用"
        missing = []
        missing << "DOM" unless evidence.match?(/DOM|role=/i)
        missing << "state" unless evidence.match?(/状态|state/i)
        missing << "handler/event" unless evidence.match?(/handler|事件|键盘/i)
        missing << "request" unless evidence.match?(/请求|request/i)
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
unless baseline_errors.empty?
  warn "BASELINE FAIL errors=#{baseline_errors.size}"
  baseline_errors.each { |error| warn "  #{error}" }
  exit 1
end

if ARGV.include?("--records")
  columns = %w[
    scenario recordKind capabilityKey currentValue stateGroup minimumField
    lifecycleRole checklistRow applicability verificationStatus outputLocation
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
  exit 0
end

puts "BASELINE PASS scenarios=#{audits.size} records=#{audits.values.map { |audit| audit.records.size }.sum}"
audits.each do |scenario, audit|
  puts "  #{scenario}: PASS records=#{audit.records.size}"
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
                "remove #{field} from viewState", outputs["bulk-action"].sub(field, "removed#{index}")]
end
mutations << ["M11-lifecycle-substitutes-group", "row-action", "replace independent lifecycle guard heading with lifecycleState",
              outputs["row-action"].sub("### 独立 `lifecycleGuard`", "### lifecycleState")]
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

unexpected_passes = []
mutations.each do |id, scenario, description, mutated|
  result = Audit.new(scenario, mutated).run
  if result.errors.empty?
    unexpected_passes << id
    puts "MUTATION UNEXPECTED_PASS id=#{id} scenario=#{scenario} operator=#{description.inspect}"
  else
    puts "MUTATION EXPECTED_FAIL id=#{id} scenario=#{scenario} operator=#{description.inspect} errors=#{result.errors.size}"
    result.errors.each { |error| puts "  #{error}" }
  end
end

unless unexpected_passes.empty?
  warn "MUTATION AUDIT FAIL unexpected_passes=#{unexpected_passes.join(',')}"
  exit 1
end

puts "MUTATION AUDIT PASS expected_failures=#{mutations.size}/#{mutations.size}"
