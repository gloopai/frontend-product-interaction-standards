#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
DIALOGS = File.join(ROOT, "references/dialogs.md")
SELECTS = File.join(ROOT, "references/selects-comboboxes.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
GREEN = File.join(ROOT, "docs/testing/dialog-select-responsive-popup/green-summary.md")
RED = File.join(ROOT, "docs/testing/dialog-select-responsive-popup/red-summary.md")

DIALOG_TERMS = [
  "Dialog 内 Select / Combobox / Dropdown popup 不得被 Dialog 内容滚动区、Dialog 外框、固定页脚、局部容器、`overflow` 或 `transform` 裁切",
  "不得为了 Select popup 展开而让 Dialog 外框滚动",
  "popup 不得遮挡 Dialog 主要确认按钮",
  "底部 Drawer / Bottom Sheet",
  "左右边距、顶部圆角或底部安全区域",
  "遮罩点击不关闭、拖拽不关闭",
  "未验证"
].freeze

SELECT_TERMS = [
  "Portal 到应用根或当前模态层专用 popup root",
  "空间不足时必须向上翻转、限制最大高度并仅让 options 区滚动",
  "不得要求 Dialog 外框滚动",
  "移动端、窄屏、低高度、虚拟键盘明显影响布局",
  "`auto` 应优先解析为 `drawer`",
  "`selectedValue`、会话 `query`、`activeOption`、loading、error、orphaned invalid 和请求身份必须保持",
  "不得触发值变化回调、重复请求或重复动画"
].freeze

RESPONSIVE_TERMS = [
  "底部 Drawer / Bottom Sheet 可以保留左右边距、顶部圆角和底部安全区域适配",
  "这些视觉差异不改变它的模态 Drawer 语义",
  "Dialog 内 Select / Combobox / Dropdown popup",
  "应转换为 Select Drawer",
  "不得改变已提交值、提交草稿、重置搜索、重复请求、重复遮罩、重复焦点陷阱、重复滚动锁或重复动画"
].freeze

EVIDENCE_TERMS = [
  "Dialog 内 Select popup",
  "Dialog 外框滚动",
  "Portal",
  "向上翻转",
  "options 区滚动",
  "Bottom Drawer",
  "左右边距",
  "圆角",
  "Drawer 语义",
  "selectedValue",
  "query",
  "activeOption",
  "重复遮罩",
  "未验证"
].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def audit(dialogs:, selects:, responsive:, green:, red:)
  failures = []
  failures.concat(require_terms(dialogs, DIALOG_TERMS, "dialogs"))
  failures.concat(require_terms(selects, SELECT_TERMS, "selects"))
  failures.concat(require_terms(responsive, RESPONSIVE_TERMS, "responsive"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

dialogs = read(DIALOGS)
selects = read(SELECTS)
responsive = read(RESPONSIVE)
green = read(GREEN)
red = read(RED)

failures = audit(dialogs: dialogs, selects: selects, responsive: responsive, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  expect_failure("dialog-popup-clipping-rule") do
    audit(dialogs: dialogs.gsub("Dialog 内 Select / Combobox / Dropdown popup 不得被 Dialog 内容滚动区、Dialog 外框、固定页脚、局部容器、`overflow` 或 `transform` 裁切", ""),
          selects: selects, responsive: responsive, green: green, red: red)
  end

  expect_failure("dialog-outer-scroll-workaround") do
    audit(dialogs: dialogs.gsub("不得为了 Select popup 展开而让 Dialog 外框滚动", ""),
          selects: selects, responsive: responsive, green: green, red: red)
  end

  expect_failure("portal-root-rule") do
    audit(dialogs: dialogs, selects: selects.gsub("Portal 到应用根或当前模态层专用 popup root", ""),
          responsive: responsive, green: green, red: red)
  end

  expect_failure("flip-max-height-options-scroll") do
    audit(dialogs: dialogs, selects: selects.gsub("空间不足时必须向上翻转、限制最大高度并仅让 options 区滚动", ""),
          responsive: responsive, green: green, red: red)
  end

  expect_failure("mobile-bottom-drawer") do
    audit(dialogs: dialogs, selects: selects,
          responsive: responsive.gsub("底部 Drawer / Bottom Sheet 可以保留左右边距、顶部圆角和底部安全区域适配", ""),
          green: green, red: red)
  end

  expect_failure("drawer-semantics-despite-visual-shape") do
    audit(dialogs: dialogs, selects: selects,
          responsive: responsive.gsub("这些视觉差异不改变它的模态 Drawer 语义", ""),
          green: green, red: red)
  end

  expect_failure("select-state-continuity") do
    audit(dialogs: dialogs,
          selects: selects.gsub("`selectedValue`、会话 `query`、`activeOption`、loading、error、orphaned invalid 和请求身份必须保持", ""),
          responsive: responsive, green: green, red: red)
  end

  expect_failure("duplicate-overlay-protection") do
    audit(dialogs: dialogs, selects: selects,
          responsive: responsive.gsub("不得改变已提交值、提交草稿、重置搜索、重复请求、重复遮罩、重复焦点陷阱、重复滚动锁或重复动画", ""),
          green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(dialogs: dialogs.gsub("未验证", "已验证"), selects: selects.gsub("未验证", "已验证"),
          responsive: responsive.gsub("未验证", "已验证"), green: green, red: red)
  end
end

puts "PASS: Dialog 内浮层与移动端转换规范符合结构化审计契约。"
