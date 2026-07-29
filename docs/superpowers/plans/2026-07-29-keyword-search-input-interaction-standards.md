# 关键词搜索输入交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增关键词搜索输入 owner，约束搜索输入草稿、已提交关键词、IME composition、防抖提交、清空/重置/取消、URL/历史敏感边界、迟到请求、权限和移动端虚拟键盘承载。

**Architecture:** 采用现有规范仓库模式：先写 Ruby 静态审计并确认 RED，再新增 `references/keyword-search-inputs.md` 作为字段级关键词搜索输入 primary owner，最后补齐 `SKILL.md` 路由、README/HANDOFF 摘要、相邻 owner 关系和 RED/GREEN 证据。审计使用 exact-term contract 与 mutation cases，确保普通列表搜索、筛选栏文本搜索和局部搜索不会被误归到全局搜索、Select 搜索或 query-filters 内部。

**Tech Stack:** Markdown 规范文档、Ruby 静态审计脚本、Git。

## Global Constraints

- 只处理本 skill 仓库内的交互规范，不修改任何业务项目代码。
- 不得引用或依赖 `fex-admin`、`/Users/evanqi/code/`、`src/pages`、`Ant Design`、`ant-design`、`shadcn`、`Next.js`、`Vite`、`React`、`Vue`。
- 新 owner 必须保持框架无关、组件库无关、项目无关。
- 规范、复核文档和证据文档必须使用中文。
- 新 owner 只负责关键词搜索输入字段内部状态；全局搜索/命令面板仍由 `references/search-command-palette.md` 负责，查询条件应用仍由 `references/query-filters.md` 负责，Select option 搜索仍由 `references/selects-comboboxes.md` 负责。
- 真实浏览器、真实 IME、移动端虚拟键盘、权限切换、网络迟到、读屏和触摸检查未执行时，必须标为 `未验证`。
- 实施必须先 RED、后 GREEN；不能把未执行的验证写成已通过。

---

## File Structure

- Create: `references/keyword-search-inputs.md`
  - 关键词搜索输入的 primary owner，覆盖列表搜索、表格搜索、报表搜索、筛选栏文本搜索、局部搜索、页面内搜索、即时搜索、防抖搜索、搜索清空、搜索重置、IME 搜索、搜索建议和移动端搜索输入。
- Create: `docs/testing/keyword-search-inputs/keyword-search-inputs-audit.rb`
  - 新 owner 的 exact-term contract、路由检查、相邻 owner 检查、证据检查、项目泄漏检查和 mutation suite。
- Create: `docs/testing/keyword-search-inputs/red-summary.md`
  - 记录新增 owner 前的 RED 结果，必须覆盖 evidence terms。
- Create: `docs/testing/keyword-search-inputs/green-summary.md`
  - 记录新增 owner 后的 GREEN 结果，必须覆盖 evidence terms。
- Modify: `SKILL.md`
  - 新增关键词搜索输入路由。
- Modify: `README.md`
  - 新增规范总览摘要和 owner 引用。
- Modify: `HANDOFF.md`
  - 新增中文阶段性交接摘要。
- Modify: `references/query-filters.md`
  - 明确关键词搜索输入字段必须执行 `references/keyword-search-inputs.md`；query-filters 只负责已应用条件和查询意图。
- Modify: `references/search-command-palette.md`
  - 明确普通关键词搜索输入不属于全局搜索/命令面板 owner。
- Modify: `references/forms.md`
  - 明确关键词输入作为字段时，只能把 `committedKeyword` 交给表单。
- Modify: `references/data-tables.md`
  - 明确表格读取结果查询快照，不直接读取 `inputDraft`。
- Modify: `references/buttons.md`
  - 明确搜索、清空、取消、重置和重试按钮还要遵循关键词搜索输入的意图区分。
- Modify: `references/responsive-adaptive.md`
  - 明确移动端虚拟键盘和 safe-area 下搜索输入核心能力不得被删除或遮挡。

---

### Task 1: 写失败审计并记录 RED

**Files:**
- Create: `docs/testing/keyword-search-inputs/keyword-search-inputs-audit.rb`
- Create: `docs/testing/keyword-search-inputs/red-summary.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-keyword-search-input-interaction-standards-design.md`
- Produces: command `ruby docs/testing/keyword-search-inputs/keyword-search-inputs-audit.rb`

- [ ] **Step 1: 创建审计脚本目录**

Run:

```sh
mkdir -p docs/testing/keyword-search-inputs
```

- [ ] **Step 2: 写入审计脚本骨架**

Create `docs/testing/keyword-search-inputs/keyword-search-inputs-audit.rb` with:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/keyword-search-inputs.md")
QUERY_FILTERS = File.join(ROOT, "references/query-filters.md")
SEARCH_COMMAND = File.join(ROOT, "references/search-command-palette.md")
FORMS = File.join(ROOT, "references/forms.md")
DATA_TABLES = File.join(ROOT, "references/data-tables.md")
BUTTONS = File.join(ROOT, "references/buttons.md")
RESPONSIVE = File.join(ROOT, "references/responsive-adaptive.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/keyword-search-inputs/green-summary.md")
RED = File.join(ROOT, "docs/testing/keyword-search-inputs/red-summary.md")

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end
```

- [ ] **Step 3: 定义状态字段 contract**

Add:

```ruby
STATE_FIELDS = %w[
  keywordOwnerId surfaceKind inputDraft normalizedDraft committedKeyword
  compositionState submitPolicy debounceState clearPolicy requestBinding
  historyBinding permissionBoundary feedbackBinding responsivePolicy
].freeze
```

Every field must appear in `references/keyword-search-inputs.md` and `docs/testing/keyword-search-inputs/green-summary.md`.

- [ ] **Step 4: 定义 owner exact terms**

Add:

```ruby
OWNER_TERMS = [
  "keywordSearchInputState",
  "输入草稿不等于已提交关键词",
  "normalizedDraft 不等于 committedKeyword",
  "composition 未结束时 Enter 不得提交",
  "没有声明时默认 `explicit`，不得输入即请求",
  "普通输入只更新 `inputDraft` 和 `normalizedDraft`",
  "IME 输入法是硬边界",
  "compositionstart 到 compositionend 之间，Enter、Space、方向键和候选选择优先归输入法",
  "不得触发搜索提交、表格请求、URL 写入、历史写入、结果清空或按钮 loading",
  "防抖请求必须绑定 `keywordOwnerId`、normalized query、权限版本、租户/工作区、route、surfaceKind 和请求代次",
  "迟到结果只能写回仍 live 且身份匹配的 owner",
  "清空草稿、清空已提交关键词、重置默认关键词、取消输入必须是不同意图",
  "清空按钮不能靠一个 `onClear` 同时猜测四种意图",
  "`inputDraft`、composition 文本、未提交 normalizedDraft、敏感自由文本、邮箱、手机号、内部 ID、令牌、密钥、个人识别信息和权限范围不得写入 URL、页面标题、日志、analytics、最近搜索或保存视图",
  "placeholder 不能是唯一 label",
  "loading、too-short、invalid、error、permission-denied、cleared 和 submitted 只能由一个 primary owner 完整播报",
  "移动端不得删除输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径",
  "虚拟键盘打开时，当前输入、清空、提交、取消、错误和结果摘要不能被固定 toolbar、底部按钮、安全区域或键盘完全遮挡",
  "未验证"
].freeze
```

- [ ] **Step 5: 定义路由 terms**

Add:

```ruby
ROUTE_TERMS = [
  "关键词搜索", "搜索输入", "搜索框", "文本搜索", "列表搜索", "表格搜索",
  "报表搜索", "局部搜索", "页面内搜索", "筛选搜索", "即时搜索", "防抖搜索",
  "搜索清空", "清空搜索", "搜索重置", "输入法搜索", "中文输入法搜索",
  "IME 搜索", "搜索建议", "搜索历史", "最近关键词", "搜索 URL",
  "keyword search", "search input", "search box", "text search", "list search",
  "table search", "report search", "local search", "in-page search",
  "filter search", "instant search", "debounced search", "search clear",
  "clear search", "reset search", "IME search", "composition search",
  "search suggestion", "search history", "recent keyword", "search URL",
  "references/keyword-search-inputs.md"
].freeze
```

The audit must require all route terms in `SKILL.md`.

- [ ] **Step 6: 定义相邻 owner、README 和 HANDOFF terms**

Add:

```ruby
RELATIONSHIP_TERMS = [
  "references/keyword-search-inputs.md",
  "keyword-search-inputs.md"
].freeze

README_TERMS = [
  "关键词搜索输入规范",
  "references/keyword-search-inputs.md"
].freeze

HANDOFF_TERMS = [
  "### 关键词搜索输入",
  "keywordSearchInputState",
  "输入草稿不等于已提交关键词",
  "composition 未结束时 Enter 不得提交",
  "清空草稿、清空已提交关键词、重置默认关键词、取消输入必须是不同意图",
  "移动端不得删除输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径",
  "references/keyword-search-inputs.md"
].freeze
```

The audit must require relationship terms in `query-filters.md`, `search-command-palette.md`, `forms.md`, `data-tables.md`, `buttons.md`, and `responsive-adaptive.md`.

- [ ] **Step 7: 定义 evidence 和项目泄漏 terms**

Add:

```ruby
EVIDENCE_TERMS = STATE_FIELDS + [
  "keywordSearchInputState",
  "输入草稿",
  "已提交关键词",
  "normalizedDraft",
  "committedKeyword",
  "IME",
  "composition",
  "Enter",
  "debounce",
  "防抖",
  "清空草稿",
  "清空已提交关键词",
  "重置默认关键词",
  "取消输入",
  "URL",
  "搜索历史",
  "最近关键词",
  "迟到结果",
  "primary owner",
  "虚拟键盘",
  "移动端",
  "未验证"
].freeze

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

- [ ] **Step 8: 实现 audit 函数和 mutation suite**

The script must implement:

```ruby
def owner_failures(owner)
  failures = []
  STATE_FIELDS.each do |field|
    failures << "owner: keywordSearchInputState missing #{field}" unless owner.include?(field)
  end
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(query_filters:, search_command:, forms:, data_tables:, buttons:, responsive:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(query_filters, RELATIONSHIP_TERMS, "query filters relationship"))
  failures.concat(require_terms(search_command, RELATIONSHIP_TERMS, "search command relationship"))
  failures.concat(require_terms(forms, RELATIONSHIP_TERMS, "forms relationship"))
  failures.concat(require_terms(data_tables, RELATIONSHIP_TERMS, "data tables relationship"))
  failures.concat(require_terms(buttons, RELATIONSHIP_TERMS, "buttons relationship"))
  failures.concat(require_terms(responsive, RELATIONSHIP_TERMS, "responsive relationship"))
  failures.concat(require_terms(skill, ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(readme, README_TERMS, "README"))
  failures.concat(require_terms(handoff, HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures
end

def project_leak_failures(texts)
  PROJECT_BANNED_TERMS.flat_map do |term|
    texts.select { |label, text| text.include?(term) }.map { |label, _text| "#{label}: forbidden project-specific term #{term}" }
  end
end

def audit(owner:, query_filters:, search_command:, forms:, data_tables:, buttons:, responsive:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(owner_failures(owner))
  failures.concat(integration_failures(query_filters: query_filters, search_command: search_command, forms: forms,
                                       data_tables: data_tables, buttons: buttons, responsive: responsive,
                                       skill: skill, readme: readme, handoff: handoff, green: green, red: red))
  failures.concat(project_leak_failures("owner" => owner, "green" => green, "red" => red))
  failures
end
```

Add mutation cases named:

```ruby
%w[
  missing-owner-state
  draft-as-committed-keyword
  normalized-as-committed-keyword
  composition-enter-submits
  implicit-input-request
  ime-boundary-missing
  debounce-binding-missing
  late-result-writes-new-owner
  clear-intents-merged
  onclear-guesses-intent
  sensitive-draft-written-to-url
  placeholder-only-label
  duplicate-announcement-owner
  mobile-core-search-actions-removed
  virtual-keyboard-obscures-search
  runtime-boundary-marked-verified
  missing-route
  missing-adjacent-owner-link
  project-specific-leakage
]
```

- [ ] **Step 9: 运行 RED**

Run:

```sh
ruby docs/testing/keyword-search-inputs/keyword-search-inputs-audit.rb
```

Expected: FAIL because `references/keyword-search-inputs.md`, route, adjacent owner text and GREEN evidence do not exist yet.

- [ ] **Step 10: 记录 RED 摘要**

Create `docs/testing/keyword-search-inputs/red-summary.md` with Chinese evidence that includes all `EVIDENCE_TERMS`, especially:

```text
keywordSearchInputState
keywordOwnerId surfaceKind inputDraft normalizedDraft committedKeyword compositionState submitPolicy debounceState clearPolicy requestBinding historyBinding permissionBoundary feedbackBinding responsivePolicy
输入草稿
已提交关键词
normalizedDraft
committedKeyword
IME
composition
Enter
debounce
防抖
清空草稿
清空已提交关键词
重置默认关键词
取消输入
URL
搜索历史
最近关键词
迟到结果
primary owner
虚拟键盘
移动端
未验证
```

- [ ] **Step 11: 提交 Task 1**

Run:

```sh
git add docs/testing/keyword-search-inputs/keyword-search-inputs-audit.rb docs/testing/keyword-search-inputs/red-summary.md
git commit -m "test: 增加关键词搜索输入规范审计"
```

---

### Task 2: 新增 primary owner 和相邻 owner 边界

**Files:**
- Create: `references/keyword-search-inputs.md`
- Modify: `references/query-filters.md`
- Modify: `references/search-command-palette.md`
- Modify: `references/forms.md`
- Modify: `references/data-tables.md`
- Modify: `references/buttons.md`
- Modify: `references/responsive-adaptive.md`

**Interfaces:**
- Consumes: Task 1 audit constants.
- Produces: 新 owner 与相邻 owner 边界文本；Task 3 依赖这些文本通过路由和摘要审计。

- [ ] **Step 1: 新建 owner 标题和范围**

Create `references/keyword-search-inputs.md` starting with:

```md
# 关键词搜索输入交互规范

## 适用范围

本文件是关键词搜索、搜索输入、搜索框、文本搜索、列表搜索、表格搜索、报表搜索、局部搜索、页面内搜索、筛选搜索、即时搜索、防抖搜索、搜索清空、清空搜索、搜索重置、输入法搜索、中文输入法搜索、IME 搜索、搜索建议、搜索历史、最近关键词、搜索 URL、keyword search、search input、search box、text search、list search、table search、report search、local search、in-page search、filter search、instant search、debounced search、search clear、clear search、reset search、IME search、composition search、search suggestion、search history、recent keyword 和 search URL 的 primary owner。
```

- [ ] **Step 2: 写清 owner 边界**

Add `## 与其他 owner 的关系` explaining:

- 全局搜索、站内搜索页、命令面板、快速跳转、动作搜索和 AI 搜索继续执行 `references/search-command-palette.md`。
- Select / Combobox option 搜索继续执行 `references/selects-comboboxes.md`。
- 多选标签和 tokenized input 继续执行 `references/multi-select-tag-inputs.md`。
- 关键词作为筛选条件时，本 owner 只输出 `committedKeyword`，`references/query-filters.md` 决定何时写入 `filterDraft`、`appliedFilters` 和 URL。
- 表单字段、按钮、表格结果和响应式承载同时执行对应 owner。

- [ ] **Step 3: 定义 `keywordSearchInputState`**

Add a table for every field:

```md
- `keywordOwnerId`
- `surfaceKind`
- `inputDraft`
- `normalizedDraft`
- `committedKeyword`
- `compositionState`
- `submitPolicy`
- `debounceState`
- `clearPolicy`
- `requestBinding`
- `historyBinding`
- `permissionBoundary`
- `feedbackBinding`
- `responsivePolicy`
```

Add exact invariant lines:

```md
输入草稿不等于已提交关键词。
normalizedDraft 不等于 committedKeyword。
composition 未结束时 Enter 不得提交。
debounce 到期不等于用户明确提交，除非 `submitPolicy` 明确声明即时策略。
清空草稿、清空已提交关键词、重置默认关键词、取消输入必须是不同意图。
```

- [ ] **Step 4: 写输入、提交和 IME 规则**

Add exact terms:

```md
普通输入只更新 `inputDraft` 和 `normalizedDraft`。
IME 输入法是硬边界。
compositionstart 到 compositionend 之间，Enter、Space、方向键和候选选择优先归输入法。
不得触发搜索提交、表格请求、URL 写入、历史写入、结果清空或按钮 loading。
```

Also explain valid submit sources: search button, Enter after composition ends, explicit empty keyword apply, valid blur for `on-blur`, or declared `debounced-immediate`.

- [ ] **Step 5: 写防抖、最小长度和迟到请求规则**

Add exact terms:

```md
没有声明时默认 `explicit`，不得输入即请求。
防抖请求必须绑定 `keywordOwnerId`、normalized query、权限版本、租户/工作区、route、surfaceKind 和请求代次。
迟到结果只能写回仍 live 且身份匹配的 owner。
```

Also require min length, empty value policy, max request frequency, request cancellation, stale handling and duplicate value coalescing.

- [ ] **Step 6: 写清空、重置和取消规则**

Add exact terms:

```md
清空按钮不能靠一个 `onClear` 同时猜测四种意图。
```

Define:

- 清空草稿 only clears `inputDraft`.
- 清空已提交关键词 submits empty keyword or removes keyword condition.
- 重置默认关键词 restores declared default keyword.
- 取消输入 discards draft and restores committed keyword display.

- [ ] **Step 7: 写 URL、历史和敏感词规则**

Add exact term:

```md
`inputDraft`、composition 文本、未提交 normalizedDraft、敏感自由文本、邮箱、手机号、内部 ID、令牌、密钥、个人识别信息和权限范围不得写入 URL、页面标题、日志、analytics、最近搜索或保存视图。
```

Also require URL restoration to validate version, permission, tenant/workspace and sensitivity policy before showing or applying keyword.

- [ ] **Step 8: 写可访问性和反馈规则**

Add exact terms:

```md
placeholder 不能是唯一 label。
loading、too-short、invalid、error、permission-denied、cleared 和 submitted 只能由一个 primary owner 完整播报。
```

Also require accessible names for search, clear, cancel, reset and retry buttons.

- [ ] **Step 9: 写移动端和虚拟键盘规则**

Add exact terms:

```md
移动端不得删除输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径。
虚拟键盘打开时，当前输入、清空、提交、取消、错误和结果摘要不能被固定 toolbar、底部按钮、安全区域或键盘完全遮挡。
```

Also require mobile back gesture/system back/route back to declare whether it cancels draft, preserves draft or leaves committed keyword unchanged.

- [ ] **Step 10: 写完成前检查**

Add `## 完成前检查` requiring verification of:

- `keywordSearchInputState` completeness.
- Draft/committed/normalized/composition separation.
- IME Enter boundary.
- Debounce/request binding and stale result handling.
- Clear/reset/cancel separation.
- URL/history sensitivity.
- Placeholder not being sole label.
- Single primary owner announcement.
- Mobile keyboard accessibility.
- `未验证` when runtime checks are not executed.

- [ ] **Step 11: 更新相邻 owner**

Add exact relationship sentence to `references/query-filters.md`:

```md
关键词搜索、搜索输入、搜索框、文本搜索、列表搜索、表格搜索、报表搜索、局部搜索、页面内搜索、筛选搜索、即时搜索、防抖搜索、搜索清空、搜索重置、IME 搜索和搜索 URL 必须执行 `references/keyword-search-inputs.md`；本文件继续负责筛选草稿、已应用条件、URL 安全、重置和查询意图。
```

Add exact relationship sentence to `references/search-command-palette.md`:

```md
普通列表关键词搜索、筛选栏搜索输入、局部搜索、页面内搜索、防抖搜索、搜索清空、搜索重置和 IME 搜索必须执行 `references/keyword-search-inputs.md`；本文件继续负责全局搜索、站内搜索页、命令面板、快速跳转、动作搜索、结果分组、命令执行和 AI 搜索。
```

Add exact relationship sentence to `references/forms.md`:

```md
关键词搜索输入作为表单字段时必须执行 `references/keyword-search-inputs.md`；表单只接收已提交的 `committedKeyword`，不得把 `inputDraft`、`normalizedDraft` 或 `compositionState` 当作字段业务值、dirty 或 submit payload。
```

Add exact relationship sentence to `references/data-tables.md`:

```md
表格工具栏、列表顶部或报表区域里的关键词搜索输入必须执行 `references/keyword-search-inputs.md`；表格结果、分页、排序、选择和批量范围只能读取上层 owner 的已应用查询快照，不得直接读取 `inputDraft`。
```

Add exact relationship sentence to `references/buttons.md`:

```md
搜索、清空、取消、重置和重试按钮若作用于关键词搜索输入，必须同时执行 `references/keyword-search-inputs.md`，并保留清空草稿、清空已提交关键词、重置默认关键词和取消输入的意图区分。
```

Add exact relationship sentence to `references/responsive-adaptive.md`:

```md
移动端关键词搜索输入、搜索框、筛选搜索、防抖搜索和 IME 搜索必须同时执行 `references/keyword-search-inputs.md`；虚拟键盘、safe-area、动态 viewport、缩放和断点转换不得删除或遮挡输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径。
```

- [ ] **Step 12: 运行阶段审计**

Run:

```sh
ruby docs/testing/keyword-search-inputs/keyword-search-inputs-audit.rb
```

Expected: FAIL only because `SKILL.md`, `README.md`, `HANDOFF.md` or GREEN evidence remain incomplete.

- [ ] **Step 13: 提交 Task 2**

Run:

```sh
git add references/keyword-search-inputs.md references/query-filters.md references/search-command-palette.md references/forms.md references/data-tables.md references/buttons.md references/responsive-adaptive.md
git commit -m "docs: 新增关键词搜索输入规范"
```

---

### Task 3: 补齐路由、摘要和 GREEN 证据

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/keyword-search-inputs/green-summary.md`

**Interfaces:**
- Consumes: Task 1 audit constants and Task 2 owner.
- Produces: 完整可路由规范和 GREEN evidence.

- [ ] **Step 1: 更新 `SKILL.md` 路由**

Add near query/search routes:

```md
- 涉及关键词搜索、搜索输入、搜索框、文本搜索、列表搜索、表格搜索、报表搜索、局部搜索、页面内搜索、筛选搜索、即时搜索、防抖搜索、搜索清空、清空搜索、搜索重置、输入法搜索、中文输入法搜索、IME 搜索、搜索建议、搜索历史、最近关键词、搜索 URL，或 keyword search、search input、search box、text search、list search、table search、report search、local search、in-page search、filter search、instant search、debounced search、search clear、clear search、reset search、IME search、composition search、search suggestion、search history、recent keyword、search URL 时，必须完整读取 `references/keyword-search-inputs.md`。
```

- [ ] **Step 2: 更新 `README.md`**

Add a summary bullet:

```md
- 关键词搜索输入规范：见 `references/keyword-search-inputs.md`。约束 keywordSearchInputState、输入草稿/normalizedDraft/已提交关键词分离、IME composition Enter 边界、防抖提交、最小长度、迟到请求、清空草稿/清空已提交关键词/重置默认关键词/取消输入意图区分、URL/历史敏感边界、单 owner 播报和移动端虚拟键盘承载。
```

Also add `references/keyword-search-inputs.md` to the complete references list as code text rather than a Markdown link if the file is being created in the same task.

- [ ] **Step 3: 更新 `HANDOFF.md`**

Add:

```md
### 关键词搜索输入

- 已定义关键词搜索、搜索输入、搜索框、文本搜索、列表搜索、表格搜索、报表搜索、局部搜索、页面内搜索、筛选搜索、即时搜索、防抖搜索、搜索清空、搜索重置、IME 搜索、搜索建议、搜索历史、最近关键词和搜索 URL 的首版 owner。
- `keywordSearchInputState` 必须声明 `keywordOwnerId`、`surfaceKind`、`inputDraft`、`normalizedDraft`、`committedKeyword`、`compositionState`、`submitPolicy`、`debounceState`、`clearPolicy`、`requestBinding`、`historyBinding`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。
- 输入草稿不等于已提交关键词；normalizedDraft 不等于 committedKeyword；composition 未结束时 Enter 不得提交。
- 清空草稿、清空已提交关键词、重置默认关键词、取消输入必须是不同意图。
- 移动端不得删除输入、清空、提交、取消/返回、错误说明、权限原因、loading、结果摘要和恢复路径。
- 详细规则和可执行验收仅维护在 `references/keyword-search-inputs.md`，本交接不重复其状态模型或检查项。
```

- [ ] **Step 4: 写 GREEN evidence**

Create `docs/testing/keyword-search-inputs/green-summary.md` in Chinese and include all `EVIDENCE_TERMS`.

- [ ] **Step 5: 运行 focused audit**

Run:

```sh
ruby docs/testing/keyword-search-inputs/keyword-search-inputs-audit.rb --mutations
```

Expected: PASS and every mutation prints `EXPECTED_FAIL`.

- [ ] **Step 6: 提交 Task 3**

Run:

```sh
git add SKILL.md README.md HANDOFF.md docs/testing/keyword-search-inputs/green-summary.md
git commit -m "docs: 补齐关键词搜索输入规范路由"
```

---

### Task 4: 全量验证、复核和推送

**Files:**
- Verify only; edit any file that fails a gate.

**Interfaces:**
- Consumes: Tasks 1–3 deliverables.
- Produces: pushed clean `main`.

- [ ] **Step 1: 运行 focused audit**

Run:

```sh
ruby docs/testing/keyword-search-inputs/keyword-search-inputs-audit.rb --mutations
```

Expected: PASS.

- [ ] **Step 2: 运行相邻 owner 审计**

Run:

```sh
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
ruby docs/testing/data-tables/attempt-10-selection-event-audit.rb
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/search-command-palette/search-command-palette-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
```

Expected: PASS.

- [ ] **Step 3: 运行全量 audit**

Run:

```sh
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
```

Expected: PASS.

- [ ] **Step 4: 运行 Markdown 链接检查**

Run:

```sh
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
```

Expected: PASS.

- [ ] **Step 5: 运行 diff 和项目泄漏检查**

Run:

```sh
git diff --check
rg -n "fex-admin|/Users/evanqi/code/|src/pages|Ant Design|ant-design|shadcn|Next.js|Vite|React|Vue" references/keyword-search-inputs.md docs/testing/keyword-search-inputs/red-summary.md docs/testing/keyword-search-inputs/green-summary.md README.md || true
```

Expected: `git diff --check` PASS; project leakage scan has no matches.

- [ ] **Step 6: 自我复核覆盖**

Verify:

- Spec coverage: state model, IME, debounce, clear/reset/cancel, URL/history, a11y, mobile keyboard and adjacent owner boundaries are all covered by owner text and audit terms.
- Placeholder scan: no vague or delayed-work placeholders.
- Type consistency: `STATE_FIELDS`, owner, GREEN evidence and HANDOFF use exactly the same field names.

- [ ] **Step 7: 最终推送**

Run:

```sh
git status --short --branch
git push origin main
git status --short --branch
git log --oneline -1
```

Expected: `main...origin/main` clean after push.
