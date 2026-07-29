# 多选、标签输入与 Tokenized Input 交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增多选、标签输入与 Tokenized Input owner，约束多选 Select、标签输入、收件人 chips、可创建标签、自由文本 token、批量粘贴、删除/清空/重排、异步搜索、权限和移动端承载。

**Architecture:** 采用现有规范仓库模式：先写 Ruby 静态审计并确认 RED，再新增 `references/multi-select-tag-inputs.md` 作为唯一 owner，最后补齐 `SKILL.md` 路由、README/HANDOFF 摘要、相邻 owner 关系和 RED/GREEN 证据。审计使用 exact-term contract 与 mutation cases，保证新增规范不会被宽松文案绕过。

**Tech Stack:** Markdown 规范文档、Ruby 静态审计脚本、Git。

## Global Constraints

- 只处理本 skill 仓库内的交互规范，不修改任何项目代码。
- 不得引用或依赖 `fex-admin`、`/Users/evanqi/code/`、`src/pages`、`Ant Design`、`ant-design`、`shadcn`、`Next.js`、`Vite`、`React`、`Vue`。
- 新 owner 必须保持框架无关、组件库无关、项目无关。
- 规范、复核文档和证据文档必须使用中文。
- 新增规范必须能被 `SKILL.md` 路由命中，且相邻 owner 必须明确边界，避免多选 Select 被单选 Select、筛选、成员或固定选择控件规则吞掉。
- 实施必须先 RED、后 GREEN；不能把未执行的验证写成已通过。

---

## File Structure

- Create: `references/multi-select-tag-inputs.md`
  - 多选 Select、标签输入、Tokenized Input、chips input、收件人输入、成员多选、标签创建、自由文本 token、批量粘贴和异步多值检索的 primary owner。
- Create: `docs/testing/multi-select-tag-inputs/multi-select-tag-inputs-audit.rb`
  - 新 owner 的 exact-term contract、路由检查、相邻 owner 检查、证据检查、项目泄漏检查和 mutation suite。
- Create: `docs/testing/multi-select-tag-inputs/red-summary.md`
  - 记录新增 owner 前的 RED 结果，必须覆盖所有 evidence terms。
- Create: `docs/testing/multi-select-tag-inputs/green-summary.md`
  - 记录新增 owner 后的 GREEN 结果，必须覆盖所有 evidence terms。
- Modify: `SKILL.md`
  - 新增多选、标签输入与 Tokenized Input 路由。
- Modify: `README.md`
  - 新增规范总览摘要和 owner 链接。
- Modify: `HANDOFF.md`
  - 新增中文阶段性交接摘要。
- Modify: `references/selects-comboboxes.md`
  - 明确单选 Select / Combobox 与多值输入 owner 的边界。
- Modify: `references/selection-controls.md`
  - 明确少量固定选择控件与多值输入 owner 的边界。
- Modify: `references/query-filters.md`
  - 明确多值筛选、标签筛选、批量粘贴筛选值需要同时执行新 owner。
- Modify: `references/members-invitations-access.md`
  - 明确成员多选、角色多选、收件人 chips 和批量粘贴成员候选需要同时执行新 owner。

---

### Task 1: 写失败审计并记录 RED

**Files:**
- Create: `docs/testing/multi-select-tag-inputs/multi-select-tag-inputs-audit.rb`
- Create: `docs/testing/multi-select-tag-inputs/red-summary.md`

**Interfaces:**
- Consumes: 现有仓库目录结构和 Markdown 文档约定。
- Produces: 可执行 Ruby 审计脚本；后续 task 必须让该脚本在正常模式和 `--mutations` 模式均通过。

- [ ] **Step 1: 新建审计脚本骨架**

在 `docs/testing/multi-select-tag-inputs/multi-select-tag-inputs-audit.rb` 写入以下常量和读取函数：

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/multi-select-tag-inputs.md")
SELECTS = File.join(ROOT, "references/selects-comboboxes.md")
SELECTION = File.join(ROOT, "references/selection-controls.md")
FILTERS = File.join(ROOT, "references/query-filters.md")
MEMBERS = File.join(ROOT, "references/members-invitations-access.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/multi-select-tag-inputs/green-summary.md")
RED = File.join(ROOT, "docs/testing/multi-select-tag-inputs/red-summary.md")

def read(path)
  File.exist?(path) ? File.read(path, encoding: "UTF-8") : ""
end

def assert_includes(text, term, context)
  return if text.include?(term)

  abort("FAIL: #{context} missing #{term.inspect}")
end
```

- [ ] **Step 2: 加入 owner 状态字段 contract**

在脚本中加入：

```ruby
STATE_FIELDS = %w[
  multiValueOwnerId valueKind committedValues draftTokens queryState
  candidateOptions creationPolicy pastePolicy commitPolicy
  validationState permissionBoundary feedbackBinding responsivePolicy
].freeze
```

每个字段都必须出现在 `references/multi-select-tag-inputs.md` 和 `docs/testing/multi-select-tag-inputs/green-summary.md`。

- [ ] **Step 3: 加入 owner exact terms**

在脚本中加入 `OWNER_TERMS`：

```ruby
OWNER_TERMS = [
  "multiValueInputState",
  "多值输入不能只维护一个数组",
  "已提交值、当前草稿 tokens、输入 query、active option、候选列表、创建候选和粘贴候选必须分别可观察",
  "只有符合 `commitPolicy` 的明确提交动作，才允许把合法 `draftTokens` 写入已提交值",
  "不得因为按 Enter 就把任意 query 提交为业务值",
  "创建标签不等于已提交字段",
  "服务端创建成功不等于表单保存、筛选应用或设置生效",
  "Backspace 在 query 非空时只编辑 query",
  "第一次 Backspace 只能高亮最后一个可删除 token，第二次明确删除该 token",
  "批量粘贴不能直接提交",
  "重复判断必须基于稳定业务键，而不是显示标签",
  "迟到结果只能写回仍 live 且身份匹配的 `multiValueOwnerId` 和草稿代次",
  "旧搜索结果、旧创建结果、旧校验错误、旧 active option、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全",
  "无权或未启用时，搜索、候选列表、选择、创建、粘贴、删除、清空、重排、提交、快捷键和请求入口的 DOM、state、handler、request 和快捷键入口为 0",
  "orphaned invalid",
  "同一完整消息不能同时由字段、chip、Toast 和全局 live region 重复播报",
  "移动端不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护",
  "未验证"
].freeze
```

- [ ] **Step 4: 加入路由 terms**

在脚本中加入：

```ruby
ROUTE_TERMS = [
  "多选 Select", "多选选择器", "多选下拉", "标签输入", "标签选择", "标签创建", "创建标签",
  "可创建选项", "自由文本标签", "Token 输入", "收件人输入", "邮箱标签", "手机号标签",
  "成员多选", "角色多选", "用户多选", "分类标签", "批量粘贴", "粘贴多个值",
  "已选标签", "删除标签", "清空标签", "拖拽排序标签", "chip", "chips", "tokenized input",
  "multi-select", "multiselect", "multiple select", "multi select dropdown", "tag input",
  "tags input", "tag selector", "create tag", "creatable option", "free text tag",
  "token input", "tokenized input", "chips input", "recipient input", "email chips",
  "phone chips", "member multi-select", "user multi-select", "role multi-select",
  "category tags", "paste tokens", "bulk paste", "selected chips", "remove chip",
  "clear tags", "reorder tags"
].freeze
```

脚本必须断言这些词全部出现在 `SKILL.md` 的新路由中。

- [ ] **Step 5: 加入相邻 owner 和 README/HANDOFF terms**

在脚本中加入：

```ruby
RELATIONSHIP_TERMS = [
  "references/multi-select-tag-inputs.md",
  "multi-select-tag-inputs.md"
].freeze

README_TERMS = [
  "多选、标签输入与 Tokenized Input 规范",
  "references/multi-select-tag-inputs.md"
].freeze

HANDOFF_TERMS = [
  "### 多选、标签输入与 Tokenized Input",
  "multiValueInputState",
  "创建标签不等于已提交字段",
  "服务端创建成功不等于表单保存、筛选应用或设置生效",
  "移动端不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护",
  "references/multi-select-tag-inputs.md"
].freeze
```

脚本必须断言四个相邻 owner 都包含 `RELATIONSHIP_TERMS`，`README.md` 包含 `README_TERMS`，`HANDOFF.md` 包含 `HANDOFF_TERMS`。

- [ ] **Step 6: 加入证据和项目泄漏检查**

在脚本中加入：

```ruby
EVIDENCE_TERMS = STATE_FIELDS + [
  "query",
  "active option",
  "创建标签",
  "服务端创建成功",
  "Backspace",
  "批量粘贴",
  "稳定业务键",
  "迟到结果",
  "旧搜索结果",
  "orphaned invalid",
  "DOM、state、handler、request 和快捷键入口为 0",
  "primary owner",
  "移动端",
  "未验证"
]

PROJECT_BANNED_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/",
  "src/pages",
  "Ant Design",
  "ant-design",
  "shadcn",
  "Next.js",
  "Vite",
  "React",
  "Vue"
].freeze
```

脚本必须断言 `red-summary.md` 和 `green-summary.md` 均包含 `EVIDENCE_TERMS`，且新增 owner 与 evidence 文件不包含 `PROJECT_BANNED_TERMS`。

- [ ] **Step 7: 加入 mutation suite**

在脚本中加入 `MUTATIONS`，每个 mutation 都复制内存中的文本并删除对应关键语句，随后断言审计失败：

```ruby
MUTATIONS = {
  "missing-owner-state" => "multiValueInputState",
  "query-as-committed-value" => "多值输入不能只维护一个数组",
  "enter-commits-arbitrary-query" => "不得因为按 Enter 就把任意 query 提交为业务值",
  "create-tag-as-field-submit" => "创建标签不等于已提交字段",
  "server-create-as-save" => "服务端创建成功不等于表单保存、筛选应用或设置生效",
  "backspace-deletes-token-immediately" => "第一次 Backspace 只能高亮最后一个可删除 token，第二次明确删除该 token",
  "bulk-paste-direct-submit" => "批量粘贴不能直接提交",
  "duplicate-by-label-only" => "重复判断必须基于稳定业务键，而不是显示标签",
  "late-result-writes-new-draft" => "迟到结果只能写回仍 live 且身份匹配的 `multiValueOwnerId` 和草稿代次",
  "stale-async-state-survives" => "旧搜索结果、旧创建结果、旧校验错误、旧 active option、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全",
  "permission-zero-entry-missing" => "DOM、state、handler、request 和快捷键入口为 0",
  "orphaned-invalid-silently-cleared" => "orphaned invalid",
  "duplicate-announcement-owner" => "同一完整消息不能同时由字段、chip、Toast 和全局 live region 重复播报",
  "mobile-core-multivalue-actions-removed" => "移动端不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护",
  "runtime-boundary-marked-verified" => "未验证",
  "missing-route" => "multi-select",
  "missing-adjacent-owner-link" => "references/multi-select-tag-inputs.md",
  "project-specific-leakage" => "fex-admin"
}.freeze
```

- [ ] **Step 8: 运行 RED**

Run:

```sh
ruby docs/testing/multi-select-tag-inputs/multi-select-tag-inputs-audit.rb
```

Expected: FAIL，因为 `references/multi-select-tag-inputs.md`、README/HANDOFF 路由和 GREEN 证据尚不存在。

- [ ] **Step 9: 记录 RED 摘要**

在 `docs/testing/multi-select-tag-inputs/red-summary.md` 写入中文摘要，必须包含：

- `primary owner`
- `multiValueOwnerId valueKind committedValues draftTokens queryState candidateOptions creationPolicy pastePolicy commitPolicy validationState permissionBoundary feedbackBinding responsivePolicy`
- `query`
- `active option`
- `创建标签`
- `服务端创建成功`
- `Backspace`
- `批量粘贴`
- `稳定业务键`
- `迟到结果`
- `旧搜索结果`
- `orphaned invalid`
- `DOM、state、handler、request 和快捷键入口为 0`
- `移动端`
- `未验证`

- [ ] **Step 10: 提交 Task 1**

Run:

```sh
git add docs/testing/multi-select-tag-inputs/multi-select-tag-inputs-audit.rb docs/testing/multi-select-tag-inputs/red-summary.md
git commit -m "test: 增加多选标签输入规范审计"
```

---

### Task 2: 新增 primary owner 和相邻 owner 边界

**Files:**
- Create: `references/multi-select-tag-inputs.md`
- Modify: `references/selects-comboboxes.md`
- Modify: `references/selection-controls.md`
- Modify: `references/query-filters.md`
- Modify: `references/members-invitations-access.md`

**Interfaces:**
- Consumes: Task 1 的 audit constants。
- Produces: 新 owner 与相邻 owner 边界文本；Task 3 依赖该 owner 路由。

- [ ] **Step 1: 新建 owner 文档标题和范围**

`references/multi-select-tag-inputs.md` 必须以以下结构开头：

```md
# 多选、标签输入与 Tokenized Input 交互规范

## 适用范围

本文件是多选 Select、多选选择器、多选下拉、标签输入、标签选择、标签创建、创建标签、可创建选项、自由文本标签、Token 输入、tokenized input、chips input、收件人输入、邮箱标签、手机号标签、成员多选、角色多选、用户多选、分类标签、批量粘贴、粘贴多个值、已选标签、删除标签、清空标签、拖拽排序标签、异步多值检索和 bulk paste 的 primary owner。
```

- [ ] **Step 2: 写清与其他 owner 的关系**

添加 `## 与其他 owner 的关系`，必须说明：

- 单选 Select / Combobox 继续由 `references/selects-comboboxes.md` 负责。
- 少量固定 Checkbox Group、Radio Group、Toggle Group、Segmented Control 继续由 `references/selection-controls.md` 负责。
- 多值筛选同时执行 `references/query-filters.md`。
- 成员、角色、邀请相关业务动作同时执行 `references/members-invitations-access.md`。
- 权限可见性同时执行 `references/permissions-tenancy-visibility.md`。
- 移动端承载同时执行 `references/responsive-adaptive.md`。

- [ ] **Step 3: 定义 `multiValueInputState`**

添加 `## multiValueInputState`，必须逐项定义：

```md
- `multiValueOwnerId`
- `valueKind`
- `committedValues`
- `draftTokens`
- `queryState`
- `candidateOptions`
- `creationPolicy`
- `pastePolicy`
- `commitPolicy`
- `validationState`
- `permissionBoundary`
- `feedbackBinding`
- `responsivePolicy`
```

并写入精确句子：

```md
多值输入不能只维护一个数组；已提交值、当前草稿 tokens、输入 query、active option、候选列表、创建候选和粘贴候选必须分别可观察。
```

- [ ] **Step 4: 写已提交值、草稿 tokens 和 query 分层**

添加规则：

```md
只有符合 `commitPolicy` 的明确提交动作，才允许把合法 `draftTokens` 写入已提交值；不得因为按 Enter 就把任意 query 提交为业务值。
```

必须说明 active option 只代表候选高亮，不代表已选中；query 清空不等于清空 committedValues。

- [ ] **Step 5: 写选择、创建和自由文本 token 规则**

添加规则：

```md
创建标签不等于已提交字段；服务端创建成功不等于表单保存、筛选应用或设置生效。
```

必须说明可创建选项需要显式文案、去重、格式校验、失败恢复和待提交状态；自由文本 token 必须声明是否允许、允许类型、最大数量和非法 token 保留策略。

- [ ] **Step 6: 写删除、清空、重排和撤销规则**

添加规则：

```md
Backspace 在 query 非空时只编辑 query；第一次 Backspace 只能高亮最后一个可删除 token，第二次明确删除该 token。
```

必须说明清空全部需要可见入口、危险程度判断、撤销或二次确认条件；拖拽排序标签必须保留键盘排序路径。

- [ ] **Step 7: 写批量粘贴、重复和冲突规则**

添加规则：

```md
批量粘贴不能直接提交；重复判断必须基于稳定业务键，而不是显示标签。
```

必须说明粘贴解析结果需要展示新增、重复、无效、无权限、待创建和冲突项，用户确认后才进入 draftTokens 或 committedValues。

- [ ] **Step 8: 写异步搜索、创建和迟到结果规则**

添加规则：

```md
迟到结果只能写回仍 live 且身份匹配的 `multiValueOwnerId` 和草稿代次。
旧搜索结果、旧创建结果、旧校验错误、旧 active option、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全。
```

必须说明 loading、empty、error、retry、分页加载、远程去重和取消请求的状态归属。

- [ ] **Step 9: 写权限、失效和安全规则**

添加规则：

```md
无权或未启用时，搜索、候选列表、选择、创建、粘贴、删除、清空、重排、提交、快捷键和请求入口的 DOM、state、handler、request 和快捷键入口为 0。
```

必须说明旧权限缓存和租户切换后需要清理候选、草稿、错误、请求和 ARIA 引用。

- [ ] **Step 10: 写 invalid/orphaned invalid 规则**

添加规则：

```md
orphaned invalid
```

必须说明已经提交但后来失效、被删除、无权限或无法解析的 token 不得静默删除；必须以 orphaned invalid 状态展示原因、影响和处理入口。

- [ ] **Step 11: 写可访问性和反馈规则**

添加规则：

```md
同一完整消息不能同时由字段、chip、Toast 和全局 live region 重复播报。
```

必须说明 combobox/listbox ARIA、chip 删除按钮名称、键盘导航、Esc 行为、Enter 行为、live region 粒度和错误归属。

- [ ] **Step 12: 写移动端承载规则**

添加规则：

```md
移动端不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护。
```

必须说明移动端可以改为底部抽屉、全屏选择页或紧凑面板，但功能、状态、权限和恢复能力不能缩水。

- [ ] **Step 13: 写完成前检查和验证边界**

添加 `## 完成前检查`，必须包含：

- 是否声明完整 `multiValueInputState`。
- 是否能区分 committedValues、draftTokens、query、active option 和 candidateOptions。
- 是否验证创建标签、服务端创建成功、Backspace、批量粘贴、稳定业务键、迟到结果、旧搜索结果、orphaned invalid、权限 0 入口和移动端承载。
- 未实际执行点击、键盘、粘贴、权限切换、网络迟到和移动端视口检查时，必须标记 `未验证`。

- [ ] **Step 14: 更新 `references/selects-comboboxes.md`**

在范围或 owner 关系附近加入：

```md
多选 Select、标签输入、Tokenized Input、可创建选项、收件人 chips、批量粘贴和多值远程检索必须执行 `references/multi-select-tag-inputs.md`；本文件继续只负责单选且业务值必须来自已有选项的 Select / Combobox。
```

- [ ] **Step 15: 更新 `references/selection-controls.md`**

在范围或 owner 关系附近加入：

```md
多选 Select、标签输入、Tokenized Input、可创建选项、收件人 chips、批量粘贴和多值远程检索必须执行 `references/multi-select-tag-inputs.md`；本文件继续负责少量固定 Checkbox Group、Radio Group、Toggle Group 和 Segmented Control。
```

- [ ] **Step 16: 更新 `references/query-filters.md`**

在范围或 owner 关系附近加入：

```md
多值筛选、标签筛选、可创建标签筛选、收件人/成员筛选和批量粘贴筛选值必须同时执行 `references/multi-select-tag-inputs.md`；本文件继续负责筛选草稿、已应用条件、URL 安全、重置和应用边界。
```

- [ ] **Step 17: 更新 `references/members-invitations-access.md`**

在范围或 owner 关系附近加入：

```md
成员多选、用户多选、角色多选、收件人 chips 和批量粘贴成员候选必须同时执行 `references/multi-select-tag-inputs.md`；本文件继续负责邀请、角色变更、成员生命周期和访问管理业务动作。
```

- [ ] **Step 18: 运行 owner 审计**

Run:

```sh
ruby docs/testing/multi-select-tag-inputs/multi-select-tag-inputs-audit.rb
```

Expected: 仍可能 FAIL，因为 Task 3 尚未补齐 SKILL/README/HANDOFF/GREEN，但 owner 和 adjacent owner 缺失项应减少。

- [ ] **Step 19: 提交 Task 2**

Run:

```sh
git add references/multi-select-tag-inputs.md references/selects-comboboxes.md references/selection-controls.md references/query-filters.md references/members-invitations-access.md
git commit -m "docs: 新增多选标签输入规范"
```

---

### Task 3: 补齐路由、摘要和 GREEN 证据

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/multi-select-tag-inputs/green-summary.md`

**Interfaces:**
- Consumes: Task 1 的 route/evidence terms 和 Task 2 的 owner。
- Produces: 完整可路由规范和 GREEN 证据。

- [ ] **Step 1: 更新 `SKILL.md` 路由**

在 Select / selection controls 相关路由附近新增：

```md
- 涉及多选 Select、多选选择器、多选下拉、标签输入、标签选择、标签创建、创建标签、可创建选项、自由文本标签、Token 输入、收件人输入、邮箱标签、手机号标签、成员多选、角色多选、用户多选、分类标签、批量粘贴、粘贴多个值、已选标签、删除标签、清空标签、拖拽排序标签、chip、chips、tokenized input，或 multi-select、multiselect、multiple select、multi select dropdown、tag input、tags input、tag selector、create tag、creatable option、free text tag、token input、tokenized input、chips input、recipient input、email chips、phone chips、member multi-select、user multi-select、role multi-select、category tags、paste tokens、bulk paste、selected chips、remove chip、clear tags、reorder tags 时，必须完整读取 `references/multi-select-tag-inputs.md`。
```

- [ ] **Step 2: 更新 `README.md` 总览**

加入条目：

```md
- 多选、标签输入与 Tokenized Input 规范：见 `references/multi-select-tag-inputs.md`。约束 multiValueInputState、已提交值/草稿 token/query/active option 分层、创建标签、自由文本 token、批量粘贴、Backspace 删除、重复冲突、异步迟到结果、权限无泄露、ARIA 和移动端承载，避免 query 即提交、active 即选中、创建即保存、批量粘贴直接提交和 orphaned invalid 静默丢失。
```

- [ ] **Step 3: 更新 `HANDOFF.md`**

加入以下中文交接段落：

```md
### 多选、标签输入与 Tokenized Input

- 已定义多选 Select、标签输入、Tokenized Input、chips input、收件人输入、成员多选、标签创建、自由文本 token、批量粘贴和异步多值检索的首版 owner。
- `multiValueInputState` 必须声明 `multiValueOwnerId`、`valueKind`、`committedValues`、`draftTokens`、`queryState`、`candidateOptions`、`creationPolicy`、`pastePolicy`、`commitPolicy`、`validationState`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。
- 多值输入不能只维护一个数组；已提交值、当前草稿 tokens、输入 query、active option、候选列表、创建候选和粘贴候选必须分别可观察。
- 创建标签不等于已提交字段；服务端创建成功不等于表单保存、筛选应用或设置生效。
- 移动端不得删除已选摘要、搜索、候选列表、创建入口、粘贴解析、重复/无效项说明、删除 token、清空、应用/取消、字段错误、权限原因、重试、恢复和离开保护。
- 详细规则和可执行验收仅维护在 `references/multi-select-tag-inputs.md`，本交接不重复其状态模型或检查项。
```

- [ ] **Step 4: 写 GREEN 证据**

在 `docs/testing/multi-select-tag-inputs/green-summary.md` 写中文验证摘要，必须包含：

- `primary owner`
- `multiValueOwnerId valueKind committedValues draftTokens queryState candidateOptions creationPolicy pastePolicy commitPolicy validationState permissionBoundary feedbackBinding responsivePolicy`
- `query`
- `active option`
- `创建标签`
- `服务端创建成功`
- `Backspace`
- `批量粘贴`
- `稳定业务键`
- `迟到结果`
- `旧搜索结果`
- `orphaned invalid`
- `DOM、state、handler、request 和快捷键入口为 0`
- `移动端`
- `未验证`

- [ ] **Step 5: 运行 focused audit**

Run:

```sh
ruby docs/testing/multi-select-tag-inputs/multi-select-tag-inputs-audit.rb --mutations
```

Expected: PASS，且每个 mutation 都被审计捕获。

- [ ] **Step 6: 提交 Task 3**

Run:

```sh
git add SKILL.md README.md HANDOFF.md docs/testing/multi-select-tag-inputs/green-summary.md
git commit -m "docs: 补齐多选标签输入规范路由"
```

---

### Task 4: 全量验证、复核和推送

**Files:**
- Verify only; no expected file edits unless verification exposes gaps.

**Interfaces:**
- Consumes: Tasks 1–3 的 owner、audit、evidence 和路由。
- Produces: 可推送的干净 `main`。

- [ ] **Step 1: 运行相邻 owner 审计**

Run:

```sh
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
ruby docs/testing/members-invitations-access/members-invitations-access-audit.rb --mutations
ruby docs/testing/selection-controls/selection-controls-audit.rb --mutations
ruby docs/testing/tree-hierarchy/tree-hierarchy-audit.rb --mutations
ruby docs/testing/data-tables/attempt-10-selection-event-audit.rb
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb --mutations
```

Expected: PASS。

- [ ] **Step 2: 运行全量 audit**

Run:

```sh
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
```

Expected: PASS。

- [ ] **Step 3: 运行 Markdown 链接检查**

Run:

```sh
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
```

Expected: PASS。

- [ ] **Step 4: 运行 diff 和项目泄漏检查**

Run:

```sh
git diff --check
rg -n "fex-admin|/Users/evanqi/code/|src/pages|Ant Design|ant-design|shadcn|Next.js|Vite|React|Vue" references/multi-select-tag-inputs.md docs/testing/multi-select-tag-inputs/red-summary.md docs/testing/multi-select-tag-inputs/green-summary.md README.md || true
```

Expected: `git diff --check` PASS；项目泄漏检查没有命中新 owner、evidence 或 README。若 `HANDOFF.md` 命中历史 `fex-admin`，只能作为既有历史说明，不得写入新增段落。

- [ ] **Step 5: 自我复核计划覆盖**

检查以下事项并在提交前修正：

- Spec coverage：设计稿中的 multiValueInputState、选择/创建/free-text、批量粘贴、Backspace、重复冲突、异步迟到、权限 0 入口、orphaned invalid、ARIA、移动端承载是否都有 owner 文本和 audit terms。
- Placeholder scan：按 writing-plans skill 的 No Placeholders 列表检查本文，确认没有占位表达或延后补充表达。
- Type consistency：`STATE_FIELDS`、owner、GREEN 证据、HANDOFF 中的字段名完全一致。

- [ ] **Step 6: 最终提交和推送**

Run:

```sh
git status --short --branch
git push origin main
git status --short --branch
git log --oneline -1
```

Expected: `main...origin/main` 干净，最新提交已推送。
