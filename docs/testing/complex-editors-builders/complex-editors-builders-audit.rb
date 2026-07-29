#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/complex-editors-builders.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/complex-editors-builders/green-summary.md")
RED = File.join(ROOT, "docs/testing/complex-editors-builders/red-summary.md")

STATE_FIELDS = %w[
  editorOwnerId sourceSnapshot draftModel validationState previewState
  versionPolicy savePolicy publishPolicy importExportPolicy
  permissionBoundary collaborationPolicy responsivePolicy
].freeze

OWNER_TERMS = [
  "editorBuilderState",
  "草稿、预览、保存、发布、应用、启用、提交审核、回滚、导入、导出和复制必须是不同意图",
  "输入、拖拽、节点连接、格式化、粘贴、AI 生成、导入片段和自动修复只能写入 `draftModel`",
  "保存草稿成功不等于发布成功",
  "预览成功不等于保存成功",
  "发布请求发送不等于发布已生效",
  "发布结果未知不得伪装成成功或失败",
  "复杂编辑器必须校验完整结构，而不是只校验当前可见区域",
  "折叠节点、隐藏面板、未展开分支、不可见字段、禁用节点、孤立节点、断开的边、循环依赖、缺失变量、重复 key、非法表达式、未映射字段、权限不可见引用、旧版本引用和外部资源失效都必须进入 `validationState`",
  "错误必须能定位到具体文本范围、字段、节点、边、条件组、模板片段、变量引用或画布区域",
  "不能只 Toast",
  "预览必须声明它读取的是 `draftModel`、已保存版本还是已发布版本",
  "预览数据必须声明来源、时间、权限过滤、脱敏策略、样本限制和是否代表生产结果",
  "来源版本变化、权限版本变化、租户/工作区变化、远端发布变化、协作锁变化或对象状态变化后，旧草稿、旧预览、旧校验结果、旧保存按钮、旧发布按钮、旧快捷键、旧复制片段、旧导出链接和旧焦点目标必须失效或重新证明安全",
  "无权或未启用时，编辑、预览、保存、发布、导入、导出、复制、回滚、查看差异和测试运行的 DOM、state、handler、request 和快捷键入口为 0",
  "AI 生成、自动补全、批量格式化、导入片段、粘贴 JSON/YAML、模板套用和示例填充都只是草稿来源",
  "移动端不得删除编辑、预览、校验、保存草稿、发布/提交、错误摘要、错误定位、版本/冲突说明、权限原因、恢复路径和离开保护",
  "虚拟键盘、触摸拖拽、缩放、横竖屏切换和低高度视口变化后",
  "未验证"
].freeze

ROUTE_TERMS = [
  "复杂编辑器", "构建器", "编辑器", "富文本编辑器", "Markdown 编辑器",
  "代码编辑器", "JSON 编辑器", "YAML 编辑器", "模板编辑器",
  "规则构建器", "条件构建器", "流程编排器", "工作流编排",
  "节点编辑", "画布编辑", "拖拽构建", "字段映射",
  "表达式编辑", "公式编辑", "可视化配置", "报表构建器",
  "自动化规则", "AI 生成配置",
  "complex editor", "builder", "rich text editor", "markdown editor",
  "code editor", "JSON editor", "YAML editor", "template editor",
  "rule builder", "condition builder", "workflow builder", "flow builder",
  "node editor", "canvas editor", "drag builder", "field mapping",
  "expression editor", "formula editor", "visual builder", "report builder",
  "automation rule", "AI generated config",
  "references/complex-editors-builders.md"
].freeze

README_TERMS = [
  "复杂编辑器和构建器规范",
  "references/complex-editors-builders.md"
].freeze

HANDOFF_TERMS = [
  "### 复杂编辑器和构建器",
  "editorBuilderState",
  "草稿、预览、保存、发布、应用、启用、提交审核、回滚、导入、导出和复制必须是不同意图",
  "复杂编辑器必须校验完整结构，而不是只校验当前可见区域",
  "移动端不得删除编辑、预览、校验、保存草稿、发布/提交、错误摘要、错误定位、版本/冲突说明、权限原因、恢复路径和离开保护",
  "references/complex-editors-builders.md"
].freeze

EVIDENCE_TERMS = [
  "editorBuilderState", "editorOwnerId", "sourceSnapshot", "draftModel",
  "validationState", "previewState", "versionPolicy", "savePolicy",
  "publishPolicy", "importExportPolicy", "permissionBoundary",
  "collaborationPolicy", "responsivePolicy", "草稿", "预览",
  "保存", "发布", "回滚", "导入", "导出", "复制",
  "AI 生成", "当前可见区域", "折叠节点", "隐藏面板",
  "孤立节点", "循环依赖", "错误定位", "不能只 Toast",
  "来源版本", "权限版本", "协作锁", "DOM、state、handler、request",
  "移动端", "虚拟键盘", "触摸拖拽", "未验证"
].freeze

PROJECT_BANNED_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/",
  "src/pages",
  "Ant Design",
  "ant-design",
  "shadcn",
  "Next.js",
  "Vite"
].freeze

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  failures = []
  STATE_FIELDS.each { |field| failures << "owner: editorBuilderState missing #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(skill, readme, handoff, green, red)
  failures = []
  failures.concat(require_terms(skill, ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(readme, README_TERMS, "README"))
  failures.concat(require_terms(handoff, HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures
end

def project_leak_failures(owner)
  PROJECT_BANNED_TERMS.select { |term| owner.include?(term) }.map do |term|
    "owner: must stay project-agnostic, found #{term.inspect}"
  end
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  owner_failures(owner) +
    integration_failures(skill, readme, handoff, green, red) +
    project_leak_failures(owner)
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

owner = read(OWNER)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  expect_failure("missing-owner-state") do
    audit(owner: owner.gsub("editorBuilderState", "editorState"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("merged-editor-intents") do
    audit(owner: owner.gsub("草稿、预览、保存、发布、应用、启用、提交审核、回滚、导入、导出和复制必须是不同意图", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("draft-writes-production") do
    audit(owner: owner.gsub("输入、拖拽、节点连接、格式化、粘贴、AI 生成、导入片段和自动修复只能写入 `draftModel`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("preview-as-save") do
    audit(owner: owner.gsub("预览成功不等于保存成功", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("publish-request-as-effective") do
    audit(owner: owner.gsub("发布请求发送不等于发布已生效", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("unknown-publish-as-success") do
    audit(owner: owner.gsub("发布结果未知不得伪装成成功或失败", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("visible-only-validation") do
    audit(owner: owner.gsub("复杂编辑器必须校验完整结构，而不是只校验当前可见区域", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("hidden-structure-not-validated") do
    audit(owner: owner.gsub("折叠节点、隐藏面板、未展开分支、不可见字段、禁用节点、孤立节点、断开的边、循环依赖、缺失变量、重复 key、非法表达式、未映射字段、权限不可见引用、旧版本引用和外部资源失效都必须进入 `validationState`", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("error-location-missing") do
    audit(owner: owner.gsub("错误必须能定位到具体文本范围、字段、节点、边、条件组、模板片段、变量引用或画布区域", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-only-editor-receipt") do
    audit(owner: owner.gsub("不能只 Toast", "不能只提示"),
          skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("不能只 Toast", "不能只提示"), red: red.gsub("不能只 Toast", "不能只提示"))
  end

  expect_failure("preview-boundary-missing") do
    audit(owner: owner.gsub("预览必须声明它读取的是 `draftModel`、已保存版本还是已发布版本", "")
                      .gsub("预览数据必须声明来源、时间、权限过滤、脱敏策略、样本限制和是否代表生产结果", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("stale-version-survives") do
    audit(owner: owner.gsub("来源版本变化、权限版本变化、租户/工作区变化、远端发布变化、协作锁变化或对象状态变化后，旧草稿、旧预览、旧校验结果、旧保存按钮、旧发布按钮、旧快捷键、旧复制片段、旧导出链接和旧焦点目标必须失效或重新证明安全", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-ghost-editor-entry") do
    audit(owner: owner.gsub("无权或未启用时，编辑、预览、保存、发布、导入、导出、复制、回滚、查看差异和测试运行的 DOM、state、handler、request 和快捷键入口为 0", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("ai-generation-bypasses-validation") do
    audit(owner: owner.gsub("AI 生成、自动补全、批量格式化、导入片段、粘贴 JSON/YAML、模板套用和示例填充都只是草稿来源", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-core-editor-actions-removed") do
    audit(owner: owner.gsub("移动端不得删除编辑、预览、校验、保存草稿、发布/提交、错误摘要、错误定位、版本/冲突说明、权限原因、恢复路径和离开保护", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"),
          skill: skill, readme: readme, handoff: handoff,
          green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin\n", skill: skill, readme: readme, handoff: handoff,
          green: green, red: red)
  end
end

puts "PASS: 复杂编辑器和构建器 owner、路由、摘要和证据符合结构化审计契约。"
