# 复杂编辑器和构建器交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增复杂编辑器、构建器、规则构建器、流程编排器、代码/JSON/YAML/Markdown 编辑器、画布编辑、字段映射和 AI 生成配置的独立交互 owner，并用静态审计防止草稿污染正式配置、预览/保存/发布混用、只校验可见区域、权限幽灵入口、旧版本提交、自动保存误导和移动端能力删减。

**Architecture:** 以 `references/complex-editors-builders.md` 作为唯一 owner，`SKILL.md` 负责触发路由，`README.md` 与 `HANDOFF.md` 只保留中文摘要和 owner 链接。`docs/testing/complex-editors-builders/complex-editors-builders-audit.rb` 检查 owner、路由、摘要、RED/GREEN 证据和 mutation；它不替代 Forms、Page Form Action Bar、Buttons、Navigation、Risk、Permissions、Uploads、Exports、Feedback 或 Responsive，而是定义复杂编辑工作台的状态模型和跨 owner 交接边界。

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- 每个复杂编辑器或构建器必须声明 `editorBuilderState`，并包含 `editorOwnerId`、`sourceSnapshot`、`draftModel`、`validationState`、`previewState`、`versionPolicy`、`savePolicy`、`publishPolicy`、`importExportPolicy`、`permissionBoundary`、`collaborationPolicy` 和 `responsivePolicy`。
- 草稿、预览、保存、发布、应用、启用、提交审核、回滚、导入、导出和复制必须是不同意图。
- 输入、拖拽、节点连接、格式化、粘贴、AI 生成、导入片段和自动修复只能写入 `draftModel`，不能静默写入已保存版本、已发布版本、生产配置或外部系统。
- 保存草稿成功不等于发布成功；预览成功不等于保存成功；发布请求发送不等于发布已生效。
- 发布结果未知不得伪装成成功或失败，必须提供刷新版本、查看发布状态、查看审计、重试或回滚路径。
- 复杂编辑器必须校验完整结构，而不是只校验当前可见区域。
- 折叠节点、隐藏面板、未展开分支、不可见字段、禁用节点、孤立节点、断开的边、循环依赖、缺失变量、重复 key、非法表达式、未映射字段、权限不可见引用、旧版本引用和外部资源失效都必须进入 `validationState`。
- 错误必须能定位到具体文本范围、字段、节点、边、条件组、模板片段、变量引用或画布区域；无法定位到具体位置时，必须在错误摘要中说明影响范围和下一步，不能只 Toast。
- 预览必须声明它读取的是 `draftModel`、已保存版本还是已发布版本；预览数据必须声明来源、时间、权限过滤、脱敏策略、样本限制和是否代表生产结果。
- 来源版本变化、权限版本变化、租户/工作区变化、远端发布变化、协作锁变化或对象状态变化后，旧草稿、旧预览、旧校验结果、旧保存按钮、旧发布按钮、旧快捷键、旧复制片段、旧导出链接和旧焦点目标必须失效或重新证明安全。
- 无权或未启用时，编辑、预览、保存、发布、导入、导出、复制、回滚、查看差异和测试运行的 DOM、state、handler、request 和快捷键入口为 0。
- 移动端不得删除编辑、预览、校验、保存草稿、发布/提交、错误摘要、错误定位、版本/冲突说明、权限原因、恢复路径和离开保护。
- 真实浏览器、屏幕阅读器、触控设备、真实拖拽、真实虚拟键盘、真实编辑器运行时、真实协作锁、真实保存/发布请求和真实权限切换未执行时，必须标为“未验证”。

---

## File Structure

- Create: `references/complex-editors-builders.md`  
  独立 owner，定义适用范围、`editorBuilderState`、草稿/预览/保存/发布分层、结构完整性、错误定位、版本冲突、权限边界、自动保存、AI 生成、外部输入、移动端承载和完成前检查。
- Modify: `SKILL.md`  
  增加复杂编辑器、构建器、富文本/Markdown/代码/JSON/YAML 编辑器、规则构建器、条件构建器、流程编排器、画布编辑、字段映射、表达式/公式编辑、AI 生成配置等中英文路由。
- Modify: `README.md`  
  增加中文摘要与 `references/complex-editors-builders.md` 链接，目录结构中列出新 owner。
- Modify: `HANDOFF.md`  
  增加中文交接摘要，说明 owner 边界、状态字段、意图分层、结构校验、权限清理、移动端和未验证边界，并调整后续建议。
- Create: `docs/testing/complex-editors-builders/complex-editors-builders-audit.rb`  
  静态审计 owner、路由、摘要、RED/GREEN 证据和 mutation。
- Create: `docs/testing/complex-editors-builders/red-summary.md`  
  记录应被审计识别为失败的负向场景。
- Create: `docs/testing/complex-editors-builders/green-summary.md`  
  记录当前规范已经证明的结构性行为。

---

### Task 1: Write the failing complex editors/builders audit

**Files:**
- Create: `docs/testing/complex-editors-builders/complex-editors-builders-audit.rb`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-complex-editors-builders-interaction-standards-design.md`
- Produces: command `ruby docs/testing/complex-editors-builders/complex-editors-builders-audit.rb`

- [ ] **Step 1: Add the audit skeleton**

Create the Ruby audit with these paths:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/complex-editors-builders.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/complex-editors-builders/green-summary.md")
RED = File.join(ROOT, "docs/testing/complex-editors-builders/red-summary.md")
```

- [ ] **Step 2: Define required state fields**

The audit must require these `editorBuilderState` fields:

```ruby
STATE_FIELDS = %w[
  editorOwnerId sourceSnapshot draftModel validationState previewState
  versionPolicy savePolicy publishPolicy importExportPolicy
  permissionBoundary collaborationPolicy responsivePolicy
].freeze
```

- [ ] **Step 3: Define required owner terms**

The audit must fail unless the owner includes all of these terms:

```ruby
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
```

- [ ] **Step 4: Define route and summary terms**

The audit must require `SKILL.md` to route at least these terms:

```ruby
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
```

The audit must require README and HANDOFF to include:

```ruby
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
```

- [ ] **Step 5: Define evidence and leakage terms**

The audit must require both evidence files to contain:

```ruby
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
```

- [ ] **Step 6: Implement audit helpers and mutations**

Use the same helper shape as existing audits:

```ruby
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
```

Then add `--mutations` cases named exactly:

```ruby
missing-owner-state
merged-editor-intents
draft-writes-production
preview-as-save
publish-request-as-effective
unknown-publish-as-success
visible-only-validation
hidden-structure-not-validated
error-location-missing
toast-only-editor-receipt
preview-boundary-missing
stale-version-survives
permission-ghost-editor-entry
ai-generation-bypasses-validation
mobile-core-editor-actions-removed
runtime-boundary-marked-verified
project-specific-leakage
```

- [ ] **Step 7: Run audit to verify RED**

Run:

```bash
ruby docs/testing/complex-editors-builders/complex-editors-builders-audit.rb
```

Expected: FAIL because `references/complex-editors-builders.md`, RED/GREEN evidence, route, README, and HANDOFF integration do not yet satisfy the new contract.

### Task 2: Implement the owner and integration

**Files:**
- Create: `references/complex-editors-builders.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/complex-editors-builders/red-summary.md`
- Create: `docs/testing/complex-editors-builders/green-summary.md`

**Interfaces:**
- Consumes: failing audit from Task 1
- Produces: passing owner, route, README/HANDOFF summaries, and evidence files

- [ ] **Step 1: Add `references/complex-editors-builders.md`**

The owner must include these sections:

```markdown
# 复杂编辑器和构建器交互规范

## 范围与非目标
## `editorBuilderState`
## 草稿、保存、发布和意图分层
## 结构完整性与错误定位
## 预览可信边界
## 版本、冲突、协作和回滚
## 权限、敏感信息与旧入口清理
## 自动保存、AI 生成和外部输入
## 移动端、虚拟键盘和触摸承载
## 与其他 owner 的关系
## 完成前检查
## 参考资料
```

The file must include the exact state field names and exact owner sentences from Task 1.

- [ ] **Step 2: Add route in `SKILL.md`**

Insert a routing bullet near Forms / Wizards / Uploads / Charts routes:

```markdown
- 涉及复杂编辑器、构建器、编辑器、富文本编辑器、Markdown 编辑器、代码编辑器、JSON 编辑器、YAML 编辑器、模板编辑器、规则构建器、条件构建器、流程编排器、工作流编排、节点编辑、画布编辑、拖拽构建、字段映射、表达式编辑、公式编辑、可视化配置、报表构建器、自动化规则、AI 生成配置，或 complex editor、builder、rich text editor、markdown editor、code editor、JSON editor、YAML editor、template editor、rule builder、condition builder、workflow builder、flow builder、node editor、canvas editor、drag builder、field mapping、expression editor、formula editor、visual builder、report builder、automation rule、AI generated config 时，必须完整读取 `references/complex-editors-builders.md`。
```

- [ ] **Step 3: Update README summary and owner link**

Add one summary bullet:

```markdown
- 复杂编辑器和构建器规范约束 editorBuilderState、草稿/预览/保存/发布分层、完整结构校验、错误定位、预览可信边界、版本冲突、权限清理、自动保存、AI 生成、导入导出和移动端触摸承载，避免草稿污染正式配置、预览即保存、只校验可见区域、Toast-only 回执和权限幽灵入口。
```

Add the full rules link:

```markdown
复杂编辑器和构建器交互规范：`references/complex-editors-builders.md`
```

Add `complex-editors-builders.md` to the `references/` tree.

- [ ] **Step 4: Update HANDOFF summary**

Add a section:

```markdown
### 复杂编辑器和构建器

- 已定义复杂编辑器、构建器、富文本编辑器、Markdown 编辑器、代码编辑器、JSON/YAML 编辑器、模板编辑器、规则构建器、流程编排器、节点编辑、画布编辑、字段映射、表达式编辑、报表构建器和 AI 生成配置的首版 owner。
- `editorBuilderState` 必须声明 `editorOwnerId`、`sourceSnapshot`、`draftModel`、`validationState`、`previewState`、`versionPolicy`、`savePolicy`、`publishPolicy`、`importExportPolicy`、`permissionBoundary`、`collaborationPolicy` 和 `responsivePolicy`。
- 草稿、预览、保存、发布、应用、启用、提交审核、回滚、导入、导出和复制必须是不同意图；输入、拖拽、节点连接、格式化、粘贴、AI 生成、导入片段和自动修复只能写入 `draftModel`。
- 复杂编辑器必须校验完整结构，而不是只校验当前可见区域；折叠节点、隐藏面板、未展开分支、不可见字段、禁用节点、孤立节点、断开的边、循环依赖、缺失变量、重复 key、非法表达式、未映射字段、权限不可见引用、旧版本引用和外部资源失效都必须进入 `validationState`。
- 移动端不得删除编辑、预览、校验、保存草稿、发布/提交、错误摘要、错误定位、版本/冲突说明、权限原因、恢复路径和离开保护。
- 详细规则和可执行验收仅维护在 `references/complex-editors-builders.md`，本交接不重复其状态模型或检查项。
```

Add `complex-editors-builders.md` to the top structure tree and remove or adjust the “复杂编辑器和构建器” item from future recommendations once the owner is implemented.

- [ ] **Step 5: Add RED evidence**

Create `docs/testing/complex-editors-builders/red-summary.md` with these negative cases:

```markdown
# 复杂编辑器和构建器 RED 证据摘要

- 缺少 `editorBuilderState`，或者缺少 `editorOwnerId`、`sourceSnapshot`、`draftModel`、`validationState`、`previewState`、`versionPolicy`、`savePolicy`、`publishPolicy`、`importExportPolicy`、`permissionBoundary`、`collaborationPolicy`、`responsivePolicy`。
- 草稿、预览、保存、发布、应用、启用、提交审核、回滚、导入、导出和复制混用同一个意图。
- 输入、拖拽、节点连接、格式化、粘贴、AI 生成、导入片段或自动修复绕过 `draftModel`，直接写入已保存版本、已发布版本、生产配置或外部系统。
- 预览成功被当成保存成功，保存草稿成功被当成发布成功，发布请求发送被当成发布已生效。
- 发布结果未知被写成成功或失败，没有刷新版本、查看发布状态、查看审计、重试或回滚路径。
- 只校验当前可见区域，折叠节点、隐藏面板、未展开分支、不可见字段、禁用节点、孤立节点、断开的边、循环依赖、缺失变量、重复 key、非法表达式、未映射字段、权限不可见引用、旧版本引用或外部资源失效没有进入 `validationState`。
- 错误无法定位到具体文本范围、字段、节点、边、条件组、模板片段、变量引用或画布区域，且没有错误摘要说明影响范围和下一步。
- 保存、发布、预览、自动保存或导入导出只显示 Toast，没有页面内结果回执、状态更新、错误定位、版本状态或恢复路径。
- 预览没有声明读取 `draftModel`、已保存版本还是已发布版本，没有说明数据来源、时间、权限过滤、脱敏策略、样本限制或生产一致性。
- 来源版本、权限版本、租户/工作区、远端发布、协作锁或对象状态变化后，旧草稿、旧预览、旧校验结果、旧保存按钮、旧发布按钮、旧快捷键、旧复制片段、旧导出链接或旧焦点目标继续生效。
- 无权或未启用时仍保留编辑、预览、保存、发布、导入、导出、复制、回滚、查看差异或测试运行入口，且 DOM、state、handler、request 或快捷键入口不是 0。
- AI 生成、自动补全、批量格式化、导入片段、粘贴 JSON/YAML、模板套用或示例填充绕过校验、差异说明、权限复核或保存/发布门禁。
- 移动端删除编辑、预览、校验、保存草稿、发布/提交、错误摘要、错误定位、版本/冲突说明、权限原因、恢复路径或离开保护。
- 虚拟键盘、触摸拖拽、缩放、横竖屏切换或低高度视口变化后，当前编辑位置、错误定位、预览入口、保存入口、发布入口、撤销/恢复入口或离开保护不可见且不可滚动到达。
- 真实浏览器、屏幕阅读器、触控设备、真实拖拽、真实虚拟键盘、真实编辑器运行时、真实协作锁、真实保存/发布请求和真实权限切换未执行时，不能写成已验证，必须标为未验证。
```

- [ ] **Step 6: Add GREEN evidence**

Create `docs/testing/complex-editors-builders/green-summary.md` with the positive evidence corresponding to every RED case and this command line:

```markdown
对应静态审计入口：`ruby docs/testing/complex-editors-builders/complex-editors-builders-audit.rb --mutations`。
```

- [ ] **Step 7: Run focused audit to verify GREEN**

Run:

```bash
ruby docs/testing/complex-editors-builders/complex-editors-builders-audit.rb --mutations
```

Expected: every named mutation prints `EXPECTED_FAIL: <name>`, then the audit prints a PASS line for complex editors/builders.

### Task 3: Verify adjacent owner boundaries and repository health

**Files:**
- No new files.
- Read and verify: `references/forms.md`, `references/page-form-action-bars.md`, `references/buttons.md`, `references/navigation-routing.md`, `references/risk-actions.md`, `references/permissions-tenancy-visibility.md`, `references/uploads-imports.md`, `references/exports-downloads-artifacts.md`, `references/feedback-states.md`, `references/global-feedback.md`, `references/responsive-adaptive.md`

**Interfaces:**
- Consumes: implemented owner and audit from Task 2
- Produces: verified working tree ready to commit

- [ ] **Step 1: Run adjacent executable audits**

Run:

```bash
ruby docs/testing/page-form-action-bars/page-form-action-bars-audit.rb --mutations
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
ruby docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
```

Expected: all listed audits exit 0. If a path does not exist, inspect `docs/testing` with `rg --files docs/testing | rg '<owner-name>'` and run the actual matching audit; record any owner without an executable audit as “无独立可执行审计”.

- [ ] **Step 2: Run full owner audit collection**

Run the known-good collection command that skips historical data-table attempts:

```bash
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
```

Expected: exit 0 and includes the new complex editors/builders audit PASS line.

- [ ] **Step 3: Verify Markdown links**

Run:

```bash
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
```

Expected: `PASS: markdown links resolve`.

- [ ] **Step 4: Verify formatting and project-agnostic boundaries**

Run:

```bash
git diff --check
rg -n "fex-admin|/Users/evanqi/code/|src/pages|Ant Design|ant-design|shadcn|Next.js|Vite" references/complex-editors-builders.md docs/testing/complex-editors-builders SKILL.md README.md HANDOFF.md || true
```

Expected: `git diff --check` exits 0. The project-specific scan must not find those terms in the new owner or evidence files. Existing `HANDOFF.md` historical relationship notes may still mention the original business project; do not copy those terms into the new owner.

- [ ] **Step 5: Inspect final diff**

Run:

```bash
git diff --stat
git diff -- references/complex-editors-builders.md docs/testing/complex-editors-builders SKILL.md README.md HANDOFF.md | sed -n '1,260p'
```

Expected: diff contains only this owner, routing, summaries, evidence and audit changes.

### Task 4: Commit and push implementation

**Files:**
- Stage: `SKILL.md`, `README.md`, `HANDOFF.md`, `references/complex-editors-builders.md`, `docs/testing/complex-editors-builders`

**Interfaces:**
- Consumes: verified green state from Task 3
- Produces: pushed `main` commit

- [ ] **Step 1: Read completion skills before claiming done**

Read and follow:

```bash
sed -n '1,220p' /Users/evanqi/.codex/plugins/cache/openai-curated-remote/superpowers/6.2.0/skills/verification-before-completion/SKILL.md
sed -n '1,260p' /Users/evanqi/.codex/plugins/cache/openai-curated-remote/superpowers/6.2.0/skills/finishing-a-development-branch/SKILL.md
```

- [ ] **Step 2: Stage files**

Run:

```bash
git add SKILL.md README.md HANDOFF.md references/complex-editors-builders.md docs/testing/complex-editors-builders
```

- [ ] **Step 3: Commit**

Run:

```bash
git commit -m "docs: 新增复杂编辑器构建器规范"
```

- [ ] **Step 4: Push**

Run:

```bash
git push origin main
```

- [ ] **Step 5: Confirm final state**

Run:

```bash
git status --short --branch
git log --oneline -1
```

Expected: `main...origin/main` with no uncommitted files and the latest commit is `docs: 新增复杂编辑器构建器规范`.

## Self-Review

- Spec coverage: Task 1 covers executable audit design; Task 2 covers owner, routing, README, HANDOFF and RED/GREEN evidence; Task 3 covers adjacent owner boundaries, full owner collection, Markdown links, formatting and project-agnostic constraints; Task 4 covers verified commit and push.
- Scope check: This plan implements one owner only: complex editors/builders. It does not implement runtime UI components or business-project adoption.
- Type/name consistency: The plan uses one owner file name `references/complex-editors-builders.md`, one audit directory `docs/testing/complex-editors-builders`, one state name `editorBuilderState`, and the same twelve state fields in Global Constraints, Task 1 and Task 2.
