#!/usr/bin/env ruby
# frozen_string_literal: true

owner = File.read("references/data-tables.md", encoding: "UTF-8")
report_rule = owner.lines.find { |line| line.start_with?("| `DT-REPORT-05` |") }.to_s.gsub(/\s+/, "")
a25 = owner[/### `A25`.*?(?=\n### `A26`)/m].to_s.gsub(/\s+/, "")

errors = []
errors << "DT-REPORT-05.d missing intent-accept +1 before async start" unless
  report_rule.match?(/(?:选择)?意图(?:被)?接受.*selectionGeneration(?:恰好)?\+1.*(?:再|然后|之后)启动异步/)
errors << "DT-REPORT-05.d missing callback generationWrite=0" unless
  report_rule.match?(/异步(?:选择协调)?回调.*(?:不得递增|代次写入为?0|generationWrite=0)/i)
errors << "A25 missing accepted-intent +1 before async-start event assertion" unless
  a25.match?(/选择意图(?:被)?接受.*selectionGeneration(?:恰好)?\+1.*(?:严格)?发生在.*异步.*启动前/)
errors << "A25 missing callback generation-write=0 assertion" unless
  a25.match?(/回调.*(?:selectionGeneration写入|generation写入|代次写入)(?:数)?(?:为|=)0/i)

def audit_output(output)
  errors = []
  table = output[/\|\s*路径\s*\|\s*`?generationEffect`?.*?(?=\n\s*\n|\z)/m].to_s
  row = table.lines.find { |line| line.match?(/^\|\s*异步选择协调回调\s*\|/) }.to_s.gsub(/\s+/, "")
  errors << "fresh output missing async selection coordination row" if row.empty?
  errors << "fresh output increments after callback/result" if row.match?(/(?:回调|结果).*(?:接受|返回|提交)后.*(?:递增|\+1)/)
  errors << "fresh output missing intent-accept +1 before async start" unless
    row.match?(/(?:选择)?意图(?:被)?接受.*selectionGeneration(?:恰好)?\+1.*(?:再|然后|之后)启动异步/)
  errors << "fresh output missing callback generationWrite=0" unless
    row.match?(/(?:回调不得递增|回调.*代次写入为?0|generationWrite=0)/i)
  contradictory_clauses = output
    .gsub(/\r\n?/, "\n")
    .split(/(?:但是|但回调|[。；\n])/)
    .map { |clause| clause.gsub(/[`\s]/, "") }
    .select do |clause|
      next false if clause.match?(/(?:不得|不能|不应|不会)递增|(?:generation|代次)写入(?:为|=)?0/i)
      prior_intent_increment = clause.match?(
        /选择意图(?:被)?接受[^，,。；]{0,32}(?:selectionGeneration[^，,。；]{0,12}(?:递增|\+1)|(?:递增|\+1)[^，,。；]{0,12}selectionGeneration)/i
      ) || clause.match?(
        /selectionGeneration[^，,。；]{0,24}选择意图(?:被)?接受[^，,。；]{0,12}(?:递增|\+1)/i
      )
      next false if prior_intent_increment

      callback_as_actor = clause.match?(
        /(?:选择协调)?回调(?:本身|随后|接着|之后|再|返回后|返回时|结束后|结束时|提交后|提交时)?[^，,。；]{0,24}(?:递增|\+1)[^，,。；]{0,16}selectionGeneration/i
      ) || clause.match?(
        /(?:选择协调)?回调(?:本身|随后|接着|之后|再|返回后|返回时|结束后|结束时|提交后|提交时)?[^，,。；]{0,24}(?:令|使|将|把)selectionGeneration[^，,。；]{0,12}(?:递增|\+1)/i
      )
      callback_time_increment = clause.match?(
        /(?:选择协调)?回调(?:返回|结束|提交|接受)(?:后|时)[^，,。；]{0,24}selectionGeneration[^，,。；]{0,12}(?:递增|\+1)/i
      )
      callback_as_actor || callback_time_increment
    end
  errors << "fresh output contradicts callback generationWrite=0" unless contradictory_clauses.empty?
  errors
end

if ARGV[0]
  output = File.read(ARGV[0], encoding: "UTF-8")
  errors.concat(audit_output(output))

  if ARGV.include?("--mutations")
    mutations = {
      "M9-late-generation" => output.sub(
        /选择意图被接受时先同步令 `selectionGeneration \+1`，再启动异步工作；回调不得递增代次，回调代次写入为 `0`/,
        "异步结果被接受后令 `selectionGeneration +1`；回调递增代次"
      ),
      "M10-row-appended-contradiction" => output.sub(
        "回调不得递增代次，回调代次写入为 `0`",
        "回调不得递增代次，回调代次写入为 `0`；但是回调随后递增 `selectionGeneration`"
      ),
      "M11-body-contradiction" => output.sub(
        "## 11. 批量停用生命周期",
        "异步选择协调回调结束时递增 `selectionGeneration`。\n\n## 11. 批量停用生命周期"
      )
    }
    mutations.each do |id, mutation|
      mutation_errors = audit_output(mutation)
      if mutation_errors.empty?
        errors << "#{id} mutation unexpectedly passed"
      else
        puts "MUTATION EXPECTED_FAIL #{id} errors=#{mutation_errors.size}"
      end
    end

    pass_controls = {
      "C1-callback-compares-prior-generation" => output.sub(
        "## 11. 批量停用生命周期",
        "异步选择协调回调只比较其捕获的、在选择意图接受时已经递增的 `selectionGeneration`，匹配时提交结果。\n\n## 11. 批量停用生命周期"
      ),
      "C2-callback-submits-after-prior-generation" => output.sub(
        "## 11. 批量停用生命周期",
        "协调回调提交前校验 `selectionGeneration` 已在选择意图接受时递增；回调本身只比较当前代次。\n\n## 11. 批量停用生命周期"
      )
    }
    pass_controls.each do |id, control|
      control_errors = audit_output(control)
      if control_errors.empty?
        puts "PASS CONTROL #{id}"
      else
        errors << "#{id} legal control rejected: #{control_errors.join('; ')}"
      end
    end
  end
end

if errors.empty?
  puts "PASS selection timing owner contract"
  exit 0
end

errors.each { |error| warn "ERROR #{error}" }
exit 1
