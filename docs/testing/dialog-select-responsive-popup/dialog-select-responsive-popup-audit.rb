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
  "不得只通过临时提高 `z-index` 解决截图式遮挡",
  "锚点滚出当前内容视窗、Dialog 关闭、路由卸载或更上层模态打开时，该 popup 必须关闭或转换为合法承载形态",
  "确认按钮不得被 Select popup、键盘、Toast 或系统安全区域遮挡",
  "底部 Drawer / Bottom Sheet",
  "左右边距、右边距、顶部圆角或底部安全区域",
  "左右边距或右边距只是视觉外框",
  "截图型问题表现为 Dialog 内 Select options 向下展开后与固定页脚或确认按钮贴边、压盖、被截断",
  "遮罩点击不关闭、拖拽不关闭",
  "未验证"
].freeze

SELECT_TERMS = [
  "Portal 到应用根或当前模态层专用 popup root",
  "空间不足时必须向上翻转、限制最大高度并仅让 options 区滚动",
  "打开、输入筛选、选项高度变化、Dialog 内容滚动、窗口缩放、动态视口变化、虚拟键盘出现和字体缩放后，必须重新计算锚点、可用空间、页脚避让和最大高度",
  "不得用一次性 `z-index` 覆盖截图问题",
  "必须同步移除 popup DOM、定位任务和 `aria-controls` / `aria-activedescendant` 引用",
  "默认不得继续使用非模态 popup",
  "Select Drawer 是字段选项层，不是外层任务承载层的替代提交",
  "不得因为 Select Drawer 打开而隐藏外层任务的关闭路径、提前提交外层表单、重置外层错误、释放外层滚动锁，或让外层确认按钮在视觉上被当作当前 Select 的提交按钮",
  "不得只在原 Dialog 内部铺开 options",
  "不得让 options 与外层固定页脚共享滚动容器",
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
  "任务承载层可从 Dialog 转为 Bottom Sheet，字段选项层可从 popup 转为 Select Drawer",
  "两者不得各自创建互相竞争的遮罩、滚动锁或焦点陷阱",
  "若 Bottom Sheet 内继续使用非模态 Select popup 会遮挡确认按钮或被虚拟键盘挤压，必须优先转 Select Drawer",
  "Bottom Sheet 保留右边距、左右边距、顶部圆角或底部安全区域时",
  "字段选项层的 Select Drawer 不能复用外层底部确认按钮作为选择提交",
  "不能把 options 直接铺在外层 Dialog 内容滚动区中",
  "外层任务承载层的确认、取消、关闭、错误、脏状态和底部操作不被覆盖、不被复用、不被重置",
  "不得改变已提交值、提交草稿、重置搜索、重复请求、重复遮罩、重复焦点陷阱、重复滚动锁或重复动画"
].freeze

EVIDENCE_TERMS = [
  "Dialog 内 Select popup",
  "Dialog 外框滚动",
  "Portal",
  "向上翻转",
  "options 区滚动",
  "Bottom Drawer",
  "Select Drawer",
  "z-index",
  "锚点",
  "确认按钮",
  "虚拟键盘",
  "右边距",
  "左右边距",
  "圆角",
  "Drawer 语义",
  "字段选项层",
  "外层确认按钮",
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

  expect_failure("z-index-only-workaround") do
    audit(dialogs: dialogs.gsub("不得只通过临时提高 `z-index` 解决截图式遮挡", ""),
          selects: selects, responsive: responsive, green: green, red: red)
  end

  expect_failure("anchor-repositioning-rule") do
    audit(dialogs: dialogs,
          selects: selects.gsub("打开、输入筛选、选项高度变化、Dialog 内容滚动、窗口缩放、动态视口变化、虚拟键盘出现和字体缩放后，必须重新计算锚点、可用空间、页脚避让和最大高度", ""),
          responsive: responsive, green: green, red: red)
  end

  expect_failure("mobile-select-drawer-priority") do
    audit(dialogs: dialogs, selects: selects,
          responsive: responsive.gsub("若 Bottom Sheet 内继续使用非模态 Select popup 会遮挡确认按钮或被虚拟键盘挤压，必须优先转 Select Drawer", ""),
          green: green, red: red)
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

  expect_failure("right-margin-visual-frame-not-semantics") do
    audit(dialogs: dialogs.gsub("左右边距或右边距只是视觉外框", ""),
          selects: selects,
          responsive: responsive.gsub("Bottom Sheet 保留右边距、左右边距、顶部圆角或底部安全区域时", ""),
          green: green, red: red)
  end

  expect_failure("screenshot-shaped-footer-clipping") do
    audit(dialogs: dialogs.gsub("截图型问题表现为 Dialog 内 Select options 向下展开后与固定页脚或确认按钮贴边、压盖、被截断", ""),
          selects: selects, responsive: responsive, green: green, red: red)
  end

  expect_failure("select-drawer-field-option-layer") do
    audit(dialogs: dialogs,
          selects: selects.gsub("Select Drawer 是字段选项层，不是外层任务承载层的替代提交", ""),
          responsive: responsive.gsub("字段选项层的 Select Drawer 不能复用外层底部确认按钮作为选择提交", ""),
          green: green, red: red)
  end

  expect_failure("do-not-spread-options-inside-dialog") do
    audit(dialogs: dialogs,
          selects: selects.gsub("不得只在原 Dialog 内部铺开 options", ""),
          responsive: responsive.gsub("不能把 options 直接铺在外层 Dialog 内容滚动区中", ""),
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
