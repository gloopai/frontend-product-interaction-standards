#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)

SNIPPET_PATH = File.join(ROOT, "docs/adoption/project-agents-snippet.md")
CHECKLIST_PATH = File.join(ROOT, "docs/adoption/checklist.md")
README_PATH = File.join(ROOT, "README.md")
HANDOFF_PATH = File.join(ROOT, "HANDOFF.md")

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path)
end

def require_includes!(text, checks, label)
  failures = checks.reject { |needle, _message| text.include?(needle) }
  return [] if failures.empty?

  failures.map { |_needle, message| "#{label}: #{message}" }
end

def snippet_failures(text)
  require_includes!(
    text,
    {
      "~/.codex/skills/frontend-product-interaction-standards/SKILL.md" => "must require the local Skill path",
      "references/*.md" => "must require routed reference files",
      "hard acceptance criteria" => "must make loaded rules hard acceptance criteria",
      "stop the affected work" => "must stop when required standards are unavailable",
      "Do not continue from memory" => "must forbid memory-based continuation",
      "stricter compatible rule" => "must prefer stricter compatible rules",
      "stop on conflicts" => "must stop on project/Skill conflicts",
      "Final responses must list loaded standard files" => "must require final disclosure",
      "must not be copied back into the shared Skill" => "must isolate project exceptions"
    },
    "snippet"
  )
end

def checklist_failures(text)
  require_includes!(
    text,
    {
      "AGENTS.md" => "must audit project AGENTS.md",
      "~/.codex/skills/frontend-product-interaction-standards/SKILL.md" => "must audit local Skill path",
      "references/*.md" => "must audit routed reference loading",
      "停止受影响工作" => "must audit stop-on-unavailable behavior",
      "禁止凭记忆" => "must audit memory-bypass prohibition",
      "冲突时停止并请用户裁决" => "must audit conflict escalation",
      "已读取规范、实际运行检查和未验证运行时检查" => "must audit final disclosure",
      "不得复制回共享 Skill" => "must audit project exception isolation",
      "完整通用规范复制为新的长期事实来源" => "must reject copied full standards"
    },
    "checklist"
  )
end

def genericity_failures(path, text)
  banned_terms = [
    "fex-admin",
    "/Users/evanqi/code/",
    "src/pages",
    "src/app",
    "ant-design",
    "Ant Design",
    "shadcn",
    "Next.js",
    "Vite"
  ]

  banned_terms.select { |term| text.include?(term) }.map do |term|
    "#{File.basename(path)}: must stay project-agnostic, found #{term.inspect}"
  end
end

def link_failures(readme, handoff)
  failures = []
  failures << "README: must link project-agents-snippet.md" unless readme.include?("docs/adoption/project-agents-snippet.md")
  failures << "README: must link checklist.md" unless readme.include?("docs/adoption/checklist.md")
  failures << "HANDOFF: must mention project adoption docs" unless handoff.include?("docs/adoption/project-agents-snippet.md")
  failures << "HANDOFF: must mention adoption checklist" unless handoff.include?("docs/adoption/checklist.md")
  failures
end

def audit(snippet_text, checklist_text, readme_text, handoff_text)
  snippet_failures(snippet_text) +
    checklist_failures(checklist_text) +
    genericity_failures(SNIPPET_PATH, snippet_text) +
    genericity_failures(CHECKLIST_PATH, checklist_text) +
    link_failures(readme_text, handoff_text)
end

def expect_failure(name)
  failures = yield
  if failures.empty?
    abort("mutation did not fail: #{name}")
  end

  puts "MUTATION PASS: #{name}"
end

snippet = read(SNIPPET_PATH)
checklist = read(CHECKLIST_PATH)
readme = read(README_PATH)
handoff = read(HANDOFF_PATH)

failures = audit(snippet, checklist, readme, handoff)
if failures.any?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  expect_failure("missing Skill path") do
    audit(snippet.gsub("~/.codex/skills/frontend-product-interaction-standards/SKILL.md", ""), checklist, readme, handoff)
  end

  expect_failure("missing reference routing") do
    audit(snippet.gsub("references/*.md", ""), checklist, readme, handoff)
  end

  expect_failure("missing stop rule") do
    audit(snippet.gsub("stop the affected work", ""), checklist, readme, handoff)
  end

  expect_failure("project-specific leakage") do
    audit("#{snippet}\nfex-admin\n", checklist, readme, handoff)
  end
end

puts "ADOPTION AUDIT PASS"
