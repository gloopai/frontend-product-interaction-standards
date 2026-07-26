#!/usr/bin/env ruby
# frozen_string_literal: true

HEADER = %w[actorPath event generationWrite sequence asyncStartSequence relativeTiming snapshotEffect commitGuard mismatchEffect].freeze
REQUIRED = {
  "selection-owner" => "selection-intent-accepted",
  "selection-owner-eligibility" => "selection-eligibility-change-accepted",
  "async-selection-coordination-callback" => "selection-coordination-result-arrived",
  "operation-result-owner" => "operation-result-adjust-selection"
}.freeze

def plain(value)
  value.to_s.gsub("`", "").strip
end

def cells(line)
  return nil unless line.start_with?("|") && line.end_with?("|")
  line.split("|", -1)[1...-1].map { |cell| plain(cell) }
end

def normalized(value)
  plain(value).gsub(/\s+/, "").tr("；，", ";;")
end

def audit_document(source, require_owner_contract: false)
  errors = []
  lines = source.lines.map(&:chomp)
  headers = lines.each_index.select { |index| cells(lines[index]) == HEADER }
  errors << "selection generation event table count=#{headers.size}, expected=1" unless headers.size == 1
  return errors unless headers.size == 1

  rows = []
  index = headers.first + 2
  while index < lines.size && (row = cells(lines[index])) && row.size == HEADER.size
    rows << row
    index += 1
  end

  errors << "event rows=#{rows.size}, expected exactly 4" unless rows.size == 4
  actual_keys = rows.map { |row| [row[0], row[1]] }
  expected_keys = REQUIRED.to_a
  errors << "event key set must equal required four keys" unless actual_keys.sort == expected_keys.sort

  REQUIRED.each do |actor, event|
    hits = rows.select { |row| row[0] == actor && row[1] == event }
    errors << "#{actor}/#{event} rows=#{hits.size}, expected=1" unless hits.size == 1
  end
  return errors unless errors.empty?

  by_actor = rows.to_h { |row| [row[0], row] }
  intent = by_actor.fetch("selection-owner")
  eligibility = by_actor.fetch("selection-owner-eligibility")
  callback = by_actor.fetch("async-selection-coordination-callback")
  operation = by_actor.fetch("operation-result-owner")

  [["intent", intent], ["eligibility", eligibility]].each do |label, row|
    errors << "#{label} generationWrite must be +1" unless row[2] == "+1"
    errors << "#{label} sequence must be integer" unless row[3].match?(/\A\d+\z/)
    errors << "#{label} asyncStartSequence must be integer" unless row[4].match?(/\A\d+\z/)
    if row[3].match?(/\A\d+\z/) && row[4].match?(/\A\d+\z/)
      errors << "#{label} write sequence must precede async start" unless row[3].to_i < row[4].to_i
    end
    errors << "#{label} relativeTiming must be before-async-start" unless row[5] == "before-async-start"
    snapshot = normalized(row[6])
    errors << "#{label} immutable successor/prior-write=0 missing" unless
      snapshot.match?(/新的?不可变后继/) && snapshot.include?("旧快照写入=0") && !snapshot.include?("原地修改")
  end

  errors << "callback generationWrite must be 0" unless callback[2] == "0"
  errors << "callback snapshot effect must be gated successor with no generation write" unless
    normalized(callback[6]) == "仅门禁匹配时按已接受意图创建后继;回调不改代次"
  errors << "callback guard must equal exact four-part comparison" unless
    normalized(callback[7]) == "live+ownerId+lifecycleToken+selectionGeneration"
  errors << "callback mismatch must equal discard/write-zero" unless
    normalized(callback[8]) == "selection-result-discarded;selectionWrite=0"
  errors << "operation generationWrite must be 0" unless operation[2] == "0"
  errors << "operation snapshot effect must be captured-match successor/prior-write=0" unless
    normalized(operation[6]) == "仅捕获代次匹配时创建合法后继;旧快照写入=0"
  errors << "operation guard must equal captured/current comparison" unless
    normalized(operation[7]) == "capturedSelectionGeneration===currentSelectionGeneration"
  errors << "operation mismatch must equal owner/write-zero" unless
    normalized(operation[8]) == "operation-result-owner;selectionWrite=0"

  if require_owner_contract
    errors << "owner does not declare structured table authoritative" unless source.match?(/结构化事件表[^。；\n]*(?:唯一权威|权威验收入口)/)
    errors << "owner allows prose to replace structured table" unless source.match?(/自由文本[^。；\n]*不得替代[^。；\n]*结构化事件表/)
  end
  errors
end

owner_path = "references/data-tables.md"
evidence_path = ARGV.find { |arg| !arg.start_with?("--") } || "docs/testing/data-tables/attempt-10-selection-generation-events.md"
owner_errors = audit_document(File.read(owner_path, encoding: "UTF-8"), require_owner_contract: true)
evidence = File.read(evidence_path, encoding: "UTF-8")
evidence_errors = audit_document(evidence)
errors = owner_errors.map { |error| "OWNER #{error}" } + evidence_errors.map { |error| "EVIDENCE #{error}" }

if ARGV.include?("--mutations") && errors.empty?
  mutations = {
    "M1-callback-write-plus-one" => evidence.sub("| async-selection-coordination-callback | selection-coordination-result-arrived | 0 |", "| async-selection-coordination-callback | selection-coordination-result-arrived | +1 |"),
    "M2-intent-write-zero" => evidence.sub("| selection-owner | selection-intent-accepted | +1 |", "| selection-owner | selection-intent-accepted | 0 |"),
    "M3-intent-not-before-start" => evidence.sub("| selection-owner | selection-intent-accepted | +1 | 10 | 20 |", "| selection-owner | selection-intent-accepted | +1 | 20 | 20 |"),
    "M4-remove-callback" => evidence.lines.reject { |line| line.start_with?("| async-selection-coordination-callback |") }.join,
    "M5-duplicate-intent" => evidence.sub(/(\| selection-owner \| selection-intent-accepted \|.*\n)/, "\\1\\1"),
    "M6-callback-actor-increments" => evidence.sub("| async-selection-coordination-callback | selection-coordination-result-arrived | 0 |", "| async-selection-coordination-callback | selection-coordination-result-arrived | +1 |"),
    "M7-intent-in-place-snapshot" => evidence.sub("创建新的不可变后继；旧快照写入=0", "原地修改当前快照"),
    "M8-eligibility-in-place-snapshot" => evidence.sub(/(\| selection-owner-eligibility \|[^\n]*?)创建新的不可变后继；旧快照写入=0/, "\\1原地修改当前快照"),
    "M9-callback-invalid-snapshot" => evidence.sub("仅门禁匹配时按已接受意图创建后继；回调不改代次", "原地修改当前快照；回调改写代次"),
    "M10-operation-invalid-snapshot" => evidence.sub("仅捕获代次匹配时创建合法后继；旧快照写入=0", "直接修改当前快照"),
    "M11-callback-guard-record-only" => evidence.sub("live+ownerId+lifecycleToken+selectionGeneration", "只记录 live+ownerId+lifecycleToken+selectionGeneration，不比较"),
    "M12-callback-guard-extra-field" => evidence.sub("live+ownerId+lifecycleToken+selectionGeneration", "live+ownerId+lifecycleToken+selectionGeneration+garbageField"),
    "M13-callback-mismatch-contradiction" => evidence.sub(/(\| async-selection-coordination-callback \|[^\n]*?)selection-result-discarded; selectionWrite=0/, "\\1selection-result-discarded; selectionWrite=0; selectionWrite=1"),
    "M14-operation-mismatch-contradiction" => evidence.sub("operation-result-owner; selectionWrite=0", "operation-result-owner; selectionWrite=0; selectionWrite=1"),
    "M15-extra-event-row" => evidence.sub(/(\| operation-result-owner \| operation-result-adjust-selection \|.*\n)/, "\\1| extra-owner | extra-event | 0 | 50 | 20 | after-async-start | none | none | none |\n")
  }
  mutations.each do |id, mutated|
    mutation_errors = audit_document(mutated)
    if mutation_errors.empty?
      errors << "#{id} unexpectedly passed"
    else
      puts "MUTATION EXPECTED_FAIL #{id} errors=#{mutation_errors.size}"
    end
  end

  legal = evidence.sub(
    "<!-- LEGAL PROSE CONTROL -->",
    "回调比较其捕获的、在选择意图接受时已经递增的 selectionGeneration，只提交四项匹配结果。"
  )
  legal_errors = audit_document(legal)
  if legal_errors.empty?
    puts "PASS CONTROL legal-prose-does-not-drive-verdict"
  else
    errors << "legal prose control rejected: #{legal_errors.join('; ')}"
  end
end

if errors.empty?
  puts "PASS structured selection-generation event contract"
  exit 0
end

errors.each { |error| warn "ERROR #{error}" }
exit 1
