#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/keyboard-shortcuts-commands.md")
BUTTONS = File.join(ROOT, "references/buttons.md")
SEARCH = File.join(ROOT, "references/search-command-palette.md")
DATA_TABLES = File.join(ROOT, "references/data-tables.md")
DIALOGS = File.join(ROOT, "references/dialogs.md")
OVERLAYS = File.join(ROOT, "references/overlays-menus-tooltips.md")
NAVIGATION = File.join(ROOT, "references/navigation-routing.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/keyboard-shortcuts-commands/green-summary.md")
RED = File.join(ROOT, "docs/testing/keyboard-shortcuts-commands/red-summary.md")

STATE_FIELDS = %w[
  shortcutOwnerId shortcutSurface scopeBinding commandRegistry keyBindingMap
  focusContext inputProtectionPolicy conflictPolicy discoverabilityPolicy
  executionPolicy permissionBoundary responsivePolicy focusAnnouncementPolicy
  lifecycleDisposal runtimeVerification
].freeze

OWNER_TERMS = [
  "keyboardShortcutState",
  "快捷键不是隐藏按钮，也不是绕过焦点、权限、确认、表单输入或浏览器默认行为的后门",
  "未声明作用域的全局 `keydown` 监听失败",
  "最上层 Dialog、Drawer、菜单、Popover、Select、编辑器或表格模式拥有优先权",
  "系统、浏览器、输入法、屏幕阅读器和编辑器保留快捷键不得被强行覆盖",
  "input、textarea、contenteditable、搜索框、Select 搜索、日期输入、富文本、代码编辑器和 IME composition 中，页面级快捷键默认不生效",
  "高风险、删除、提交、权限变更、敏感导出、密钥重置、批量操作和外部系统动作必须进入对应确认 owner",
  "每个快捷键命令必须有按钮、菜单项、命令面板、帮助页、设置项或产品声明的等价可达路径",
  "route/unmount、模态层级变化、权限变化、租户/工作区切换、断点转换、输入法切换、编辑器挂载/卸载或快捷键重注册后，旧监听器、旧命令、旧可访问名称、旧帮助、旧权限、旧焦点目标和旧请求回调必须失效或重算",
  "未验证"
].freeze

ROUTE_TERMS = [
  "快捷键", "键盘命令", "全局快捷键", "页面快捷键", "局部快捷键",
  "命令快捷键", "组合键", "热键", "访问键", "助记键", "键盘入口",
  "快捷键帮助", "快捷键冲突", "输入框快捷键保护", "系统快捷键避让",
  "浏览器快捷键避让", "快捷键禁用", "快捷键作用域",
  "shortcut", "keyboard shortcut", "hotkey", "keybinding", "key binding",
  "accelerator", "access key", "mnemonic", "command shortcut",
  "global shortcut", "scoped shortcut", "keyboard command", "shortcut help",
  "references/keyboard-shortcuts-commands.md"
].freeze

ADJACENT_TERMS = ["references/keyboard-shortcuts-commands.md", "keyboard-shortcuts-commands.md"].freeze
README_TERMS = ["快捷键与键盘命令规范", "references/keyboard-shortcuts-commands.md"].freeze
HANDOFF_TERMS = [
  "### 快捷键与键盘命令",
  "keyboardShortcutState",
  "快捷键不是隐藏按钮",
  "inputProtectionPolicy",
  "references/keyboard-shortcuts-commands.md"
].freeze
EVIDENCE_TERMS = STATE_FIELDS + [
  "keyboardShortcutState", "inputProtectionPolicy", "conflictPolicy",
  "discoverabilityPolicy", "executionPolicy", "未验证"
]
PROJECT_BANNED_TERMS = [
  "fex-admin", "/Users/evanqi/code/", "src/pages", "Ant Design",
  "ant-design", "shadcn", "Next.js", "Vite", "React", "Vue"
].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)
  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  STATE_FIELDS.reject { |field| owner.include?(field) }.map { |field| "owner: keyboardShortcutState missing #{field}" } +
    require_terms(owner, OWNER_TERMS, "owner")
end

def integration_failures(texts)
  failures = []
  %w[buttons search data_tables dialogs overlays navigation responsive].each do |key|
    failures.concat(require_terms(texts.fetch(key), ADJACENT_TERMS, "#{key} relationship"))
  end
  failures.concat(require_terms(texts.fetch("skill"), ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(texts.fetch("readme"), README_TERMS, "README"))
  failures.concat(require_terms(texts.fetch("handoff"), HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(texts.fetch("green"), EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(texts.fetch("red"), EVIDENCE_TERMS, "RED evidence"))
  failures
end

def project_leak_failures(texts)
  PROJECT_BANNED_TERMS.flat_map do |term|
    texts.select { |_label, text| text.include?(term) }.map { |label, _text| "#{label}: forbidden project-specific term #{term}" }
  end
end

def audit(texts)
  owner_failures(texts.fetch("owner")) +
    integration_failures(texts) +
    project_leak_failures("owner" => texts.fetch("owner"), "green" => texts.fetch("green"), "red" => texts.fetch("red"))
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?
  puts "EXPECTED_FAIL: #{name}"
end

texts = {
  "owner" => read(OWNER),
  "buttons" => read(BUTTONS),
  "search" => read(SEARCH),
  "data_tables" => read(DATA_TABLES),
  "dialogs" => read(DIALOGS),
  "overlays" => read(OVERLAYS),
  "navigation" => read(NAVIGATION),
  "responsive" => read(RESPONSIVE),
  "skill" => read(SKILL),
  "readme" => read(README),
  "handoff" => read(HANDOFF),
  "green" => read(GREEN),
  "red" => read(RED)
}

failures = audit(texts)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  {
    "missing-owner-state" => texts.fetch("owner").gsub("keyboardShortcutState", "keyboard-state"),
    "hidden-button-boundary-removed" => texts.fetch("owner").gsub("快捷键不是隐藏按钮，也不是绕过焦点、权限、确认、表单输入或浏览器默认行为的后门", ""),
    "global-keydown-ban-removed" => texts.fetch("owner").gsub("未声明作用域的全局 `keydown` 监听失败", ""),
    "top-layer-priority-removed" => texts.fetch("owner").gsub("最上层 Dialog、Drawer、菜单、Popover、Select、编辑器或表格模式拥有优先权", ""),
    "reserved-shortcut-removed" => texts.fetch("owner").gsub("系统、浏览器、输入法、屏幕阅读器和编辑器保留快捷键不得被强行覆盖", ""),
    "input-protection-removed" => texts.fetch("owner").gsub("input、textarea、contenteditable、搜索框、Select 搜索、日期输入、富文本、代码编辑器和 IME composition 中，页面级快捷键默认不生效", ""),
    "confirmation-owner-removed" => texts.fetch("owner").gsub("高风险、删除、提交、权限变更、敏感导出、密钥重置、批量操作和外部系统动作必须进入对应确认 owner", ""),
    "discoverability-removed" => texts.fetch("owner").gsub("每个快捷键命令必须有按钮、菜单项、命令面板、帮助页、设置项或产品声明的等价可达路径", ""),
    "disposal-removed" => texts.fetch("owner").gsub("route/unmount、模态层级变化、权限变化、租户/工作区切换、断点转换、输入法切换、编辑器挂载/卸载或快捷键重注册后，旧监听器、旧命令、旧可访问名称、旧帮助、旧权限、旧焦点目标和旧请求回调必须失效或重算", ""),
    "runtime-boundary-marked-verified" => texts.fetch("owner").gsub("未验证", "已验证")
  }.each do |name, mutated_owner|
    expect_failure(name) { audit(texts.merge("owner" => mutated_owner)) }
  end

  expect_failure("missing-skill-route") do
    audit(texts.merge("skill" => texts.fetch("skill").gsub("references/keyboard-shortcuts-commands.md", "references/missing.md")))
  end

  expect_failure("missing-readme-link") do
    audit(texts.merge("readme" => texts.fetch("readme").gsub("references/keyboard-shortcuts-commands.md", "references/missing.md")))
  end

  expect_failure("missing-handoff-section") do
    audit(texts.merge("handoff" => texts.fetch("handoff").gsub("### 快捷键与键盘命令", "### 快捷键")))
  end

  expect_failure("project-leak") do
    audit(texts.merge("owner" => "#{texts.fetch("owner")}\nfex-admin\n"))
  end
end

puts "PASS: 快捷键与键盘命令 owner、路由和证据符合结构化审计契约。"
