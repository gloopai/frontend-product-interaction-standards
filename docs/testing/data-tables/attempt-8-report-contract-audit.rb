# frozen_string_literal: true

# Attempt 8 compatibility audit for DT-REPORT-04 / A39. The historical
# Attempt 6/7 auditor remains frozen. This parser accepts the Markdown shapes
# the owner contract permits (labelled current-value declarations or exact
# first-column table rows; fixed state names as headings or table rows) while
# retaining the same field-level and selection-generation semantics.

prefix = ENV.fetch("DATA_TABLE_AUDIT_PREFIX", "attempt-8")
files = {
  "display" => "#{prefix}-display-report.md",
  "row-action" => "#{prefix}-row-action-list.md",
  "bulk-action" => "#{prefix}-bulk-action-table.md"
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

STATE_FIELDS = {
  "queryState" => {
    "appliedFilters" => /appliedFilters/,
    "sortRules" => /sortRules/,
    "pagination" => /pagination/,
    "pageSize" => /pageSize/,
    "querySnapshot" => /querySnapshot/,
    "snapshotId" => /snapshotId/,
    "datasetVersion" => /datasetVersion/,
    "requestGeneration" => /requestGeneration/,
    "requestPhase" => /requestPhase/,
    "queryError" => /queryError/,
    "stale" => /stale/
  },
  "viewState" => {
    "visibleColumnIds" => /visibleColumnIds/,
    "pinnedColumnIds" => /pinnedColumnIds/,
    "columnWidths" => /columnWidths/,
    "density" => /density/,
    "rows" => /\brows\b|currentRows|当前结果行/,
    "resultSummary" => /resultSummary|结果摘要/
  },
  "interactionState" => {
    "focusIntent" => /focusIntent/,
    "recordId" => /recordId/i,
    "columnId" => /columnId/i
  },
  "operationState" => {
    "row-operation-or-absence" => /\brow\b|rowOperation|单行/i,
    "bulk-operation-or-absence" => /\bbulk\b|bulkOperation|批量/i
  }
}.freeze

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

  line.split("|", -1)[1...-1].map { |cell| cell.strip }
end

def plain(value)
  value.to_s.gsub("`", "").gsub("**", "").strip
end

class ReportAudit
  attr_reader :errors, :records

  def initialize(scenario, output)
    @scenario = scenario
    @output = output
    @lines = output.lines.map(&:chomp)
    @errors = []
    @records = []
  end

  def run
    audit_capabilities
    audit_state_groups
    audit_lifecycle
    audit_selection_contract if @scenario == "bulk-action"
    audit_contradictions
    self
  end

  private

  def location(index)
    "RAW OUTPUT:L#{index + 1}"
  end

  def record(kind, key, value, index)
    @records << [kind, key, value, location(index)]
  end

  def capability_hits(key)
    hits = []
    @lines.each_with_index do |line, index|
      cells = table_cells(line)
      if cells && plain(cells[0]) == key && cells.size >= 2
        hits << [index, cells[1]]
        next
      end

      normalized = plain(line)
      match = normalized.match(/^[-*]\s+#{Regexp.escape(key)}\s*[:：=]\s*(.+)$/i)
      hits << [index, match[1].strip] if match
    end
    hits
  end

  def audit_capabilities
    CAPABILITIES.each do |key|
      hits = capability_hits(key)
      if hits.size != 1
        @errors << "capability #{key}: declarations=#{hits.size}"
        next
      end

      index, value = hits[0]
      normalized = plain(value)
      @errors << "capability #{key}: current value empty" if normalized.empty?
      if BOOLEAN_CAPABILITIES.include?(key) &&
         !normalized.match?(/\A(?:true|false|enabled|disabled)(?:[，、；\s]|$)|\A(?:不启用|启用|关闭|开启)(?:[，、；\s]|$)/i)
        @errors << "capability #{key}: conditional/non-current value=#{value.inspect}"
      end
      if key == "paginationMode" && !normalized.match?(/\b(?:numbered|cursor)\b/i)
        @errors << "capability paginationMode: exact current mode missing"
      end
      record("capability", key, value, index)
    end
  end

  def heading_section(index)
    match = @lines[index].match(/\A(#+)\s+/)
    return @lines[index] unless match

    level = match[1].length
    finish = ((index + 1)...@lines.length).find do |position|
      next false unless (candidate = @lines[position].match(/\A(#+)\s+/))

      candidate[1].length <= level
    end
    finish ||= @lines.length
    @lines[index...finish].join("\n")
  end

  def state_declarations(group)
    row_hits = []
    heading_hits = []
    @lines.each_with_index do |line, index|
      cells = table_cells(line)
      if cells && plain(cells[0]) == group && cells.size >= 2
        row_hits << [index, cells[1..].join(" | ")]
      elsif line.match?(/^#+\s+.*`?#{Regexp.escape(group)}`?\b/)
        heading_hits << [index, heading_section(index)]
      end
    end
    # A later operationState sub-slot heading is subordinate detail, not a
    # duplicate state-group declaration. Other duplicate row/heading
    # declarations remain visible to the cardinality check.
    if group == "operationState"
      heading_hits.reject! { |index, _evidence| plain(@lines[index]).match?(/操作子槽|operation\s+slots?/i) }
    end
    row_hits + heading_hits
  end

  def audit_state_groups
    STATE_FIELDS.each do |group, fields|
      hits = state_declarations(group)
      if hits.size != 1
        @errors << "state group #{group}: declarations=#{hits.size}"
        next
      end

      index, evidence = hits[0]
      record("state-group", group, "declared", index)
      fields.each do |field, pattern|
        if evidence.match?(pattern)
          record("state-minimum", "#{group}.#{field}", "present", index)
        else
          @errors << "#{group}.#{field}: missing minimum field"
        end
      end
    end
  end

  def audit_lifecycle
    headings = []
    @lines.each_with_index do |line, index|
      next unless line.match?(/^#+\s+/)
      next unless plain(line).match?(/lifecycleGuard|生命周期(?:保护|门禁)/i)

      headings << [index, heading_section(index)]
    end
    if headings.size != 1
      @errors << "lifecycleRole: independent guard declarations=#{headings.size}"
      return
    end

    index, evidence = headings[0]
    {
      "ownerId" => /ownerId/,
      "lifecycleToken" => /lifecycleToken/,
      "live/disposed" => /live.*disposed|disposed.*live/m,
      "ownedResources" => /ownedResources|owned resources|资源/i
    }.each do |field, pattern|
      if evidence.match?(pattern)
        record("lifecycle", field, "present", index)
      else
        @errors << "lifecycleRole #{field}: missing"
      end
    end
  end

  def rows_with_header(header)
    header_index = @lines.each_index.find do |index|
      cells = table_cells(@lines[index])
      cells&.map { |cell| plain(cell) } == header
    end
    return [nil, []] unless header_index

    rows = []
    ((header_index + 2)...@lines.length).each do |index|
      cells = table_cells(@lines[index])
      break unless cells

      rows << [index, cells.map { |cell| plain(cell) }]
    end
    [header_index, rows]
  end

  def audit_selection_contract
    header = ["路径", "generationEffect", "snapshotEffect", "commitGuard", "mismatchEffect"]
    header_index, rows = rows_with_header(header)
    unless header_index
      @errors << "selection contract: exact semantic header missing"
      return
    end

    expected_paths = ["资格变化", "异步选择协调回调", "操作结果调整当前选择"]
    selected = {}
    expected_paths.each do |path|
      hits = rows.select { |_index, cells| cells[0] == path }
      if hits.size != 1
        @errors << "selection contract #{path}: rows=#{hits.size}"
      else
        selected[path] = hits[0]
      end
    end

    if (entry = selected["资格变化"])
      index, cells = entry
      generation = cells[1].gsub(/\s+/, "")
      unless generation.match?(/\AselectionGeneration(?:恰好)?\+1\z/)
        @errors << "selection contract 资格变化: generationEffect must increment exactly once"
      end
      unless cells[2].match?(/新的?不可变后继.*selectionSnapshot/i) &&
             cells[2].match?(/旧快照.*(?:写入\s*(?:[=:：]|为)?\s*0|不变)/)
        @errors << "selection contract 资格变化: immutable successor/prior-write=0 missing"
      end
      record("selection-contract", "资格变化", cells[1..].join(" | "), index)
    end

    if (entry = selected["异步选择协调回调"])
      index, cells = entry
      generation = cells[1].gsub(/\s+/, "")
      unless generation.match?(/(?:接受|采纳).*(?:选择)?意图.*selectionGeneration(?:恰好)?\+1|selectionGeneration(?:恰好)?\+1.*(?:接受|采纳).*(?:选择)?意图/i) &&
             !generation.match?(/(?:结果|回调).*(?:接受|提交)后.*(?:递增|\+1)/)
        @errors << "selection contract 异步选择协调回调: generationEffect must increment when intent is accepted, before async result"
      end
      guard = cells[3].scan(/live|ownerId|lifecycleToken|selectionGeneration/i).map(&:downcase).uniq.sort
      expected = %w[live ownerid lifecycletoken selectiongeneration].sort
      @errors << "selection contract 异步选择协调回调: exact four-part guard missing" unless guard == expected
      unless cells[4].include?("selection-result-discarded") && cells[4].match?(/(?:selectionWrite|selection write|选择写入)\s*(?:[=:：]|为)?\s*0/i)
        @errors << "selection contract 异步选择协调回调: discard/selectionWrite=0 missing"
      end
      record("selection-contract", "异步选择协调回调", cells[1..].join(" | "), index)
    end

    if (entry = selected["操作结果调整当前选择"])
      index, cells = entry
      guard = cells[3].gsub(/\s+/, "")
      unless guard.match?(/(?:capturedSelectionGeneration|捕获的?selectionGeneration).*(?:===|==|等于).*(?:currentSelectionGeneration|当前selectionGeneration|interactionState\.selectionGeneration)/i)
        @errors << "selection contract 操作结果调整当前选择: captured/current comparison missing"
      end
      owner_only = cells[4].match?(/只写.*(?:operation\s*result|操作结果).*owner|(?:operation\s*result|操作结果).*owner.*只写/i)
      unless owner_only && cells[4].match?(/(?:selectionWrite|selection write|选择写入)\s*(?:[=:：]|为)?\s*0/i)
        @errors << "selection contract 操作结果调整当前选择: owner-only/selectionWrite=0 missing"
      end
      record("selection-contract", "操作结果调整当前选择", cells[1..].join(" | "), index)
    end
  end

  def audit_contradictions
    {
      "in-place snapshot mutation" => /原地修改当前\s*selectionSnapshot/i,
      "partial live-only guard" => /异步选择协调回调只校验\s*live/i,
      "late selection result accepted" => /迟到结果仍可提交/i,
      "mismatched operation result writes selection" => /捕获代次不匹配.*仍调整当前选择/m
    }.each do |name, pattern|
      @errors << "selection contract contradiction: #{name}" if @output.match?(pattern)
    end
  end
end

def delete_capability(output, key)
  lines = output.lines
  index = lines.each_index.find do |position|
    cells = table_cells(lines[position].chomp)
    (cells && plain(cells[0]) == key) || plain(lines[position]).match?(/^[-*]\s+#{Regexp.escape(key)}\s*[:：=]/)
  end
  raise "mutation capability missing: #{key}" unless index

  lines.delete_at(index)
  lines.join
end

def delete_state_row(output, group)
  lines = output.lines
  index = lines.each_index.find do |position|
    cells = table_cells(lines[position].chomp)
    cells && plain(cells[0]) == group
  end
  raise "mutation state row missing: #{group}" unless index

  lines.delete_at(index)
  lines.join
end

def replace_state_cell(output, group, source, replacement)
  lines = output.lines
  index = lines.each_index.find do |position|
    cells = table_cells(lines[position].chomp)
    cells && plain(cells[0]) == group
  end
  raise "mutation state row missing: #{group}" unless index
  raise "mutation state token missing: #{source}" unless lines[index].include?(source)

  lines[index] = lines[index].sub(source, replacement)
  lines.join
end

def replace_contract_cell(output, path, column, value)
  header = ["路径", "generationEffect", "snapshotEffect", "commitGuard", "mismatchEffect"]
  lines = output.lines
  index = lines.each_index.find do |position|
    cells = table_cells(lines[position].chomp)
    cells && plain(cells[0]) == path
  end
  raise "mutation selection path missing: #{path}" unless index

  cells = lines[index].chomp.split("|", -1)[1...-1].map(&:strip)
  cells[header.index(column)] = value
  lines[index] = "| #{cells.join(' | ')} |\n"
  lines.join
end

base_dir = File.expand_path(__dir__)
outputs = files.to_h { |scenario, filename| [scenario, raw_output(File.join(base_dir, filename))] }
audits = outputs.to_h { |scenario, output| [scenario, ReportAudit.new(scenario, output).run] }
errors = audits.values.flat_map(&:errors)

if ARGV.include?("--records")
  puts "| scenario | recordKind | key | currentValue | outputLocation |"
  puts "| --- | --- | --- | --- | --- |"
  audits.each do |scenario, audit|
    audit.records.each do |kind, key, value, location|
      escaped = value.to_s.gsub("|", "\\|").gsub("\n", " ")
      puts "| #{scenario} | #{kind} | #{key} | #{escaped} | #{location} |"
    end
  end
end

puts "REPORT-CONTRACT #{errors.empty? ? 'PASS' : 'FAIL'} scenarios=#{audits.size} records=#{audits.values.sum { |audit| audit.records.size }} errors=#{errors.size}"
audits.each do |scenario, audit|
  puts "  #{scenario}: #{audit.errors.empty? ? 'PASS' : 'FAIL'} records=#{audit.records.size} errors=#{audit.errors.size}"
  audit.errors.each { |error| puts "    #{error}" }
end

if ARGV.include?("--mutations")
  mutations = [
    ["M45-remove-labelled-capability", "display", delete_capability(outputs["display"], "capabilityTier")],
    ["M46-remove-state-row", "row-action", delete_state_row(outputs["row-action"], "queryState")],
    ["M47-remove-state-minimum", "display", replace_state_cell(outputs["display"], "queryState", "snapshotId", "snapshotRef")],
    ["M48-remove-lifecycle-owner", "display", outputs["display"].gsub("ownerId", "ownerRef")],
    ["M49-weaken-selection-guard", "bulk-action",
     replace_contract_cell(outputs["bulk-action"], "异步选择协调回调", "commitGuard",
                           "live + ownerId + selectionGeneration")],
    ["M50-reverse-operation-selection-guard", "bulk-action",
     replace_contract_cell(outputs["bulk-action"], "操作结果调整当前选择", "mismatchEffect",
                           "捕获代次不匹配时仍调整当前选择；选择写入=1")]
  ]

  unexpected = []
  mutations.each do |id, scenario, mutated|
    result = ReportAudit.new(scenario, mutated).run
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
