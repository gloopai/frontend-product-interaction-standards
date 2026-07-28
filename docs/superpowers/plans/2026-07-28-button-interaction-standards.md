# Button Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-version Button owner for admin-console and business-operation buttons, with routing, summaries, RED/GREEN evidence, and structural audit coverage.

**Architecture:** Add `references/buttons.md` as the single source of truth for button semantics, labels, hierarchy, state, disabled behavior, async requests, dangerous actions, icon buttons, groups, keyboard, and responsive behavior. Keep existing owners authoritative for form submit lifecycle, Dialog/Drawer containment, data-table operation snapshots, admin risk/audit, record editing surfaces, and responsive layout. Add a focused Ruby audit plus one GREEN report and summaries to make the key anti-patterns executable.

**Tech Stack:** Markdown reference docs; Ruby audit scripts; existing repository docs under `docs/testing`; no new runtime dependencies.

## Global Constraints

- The Button owner first version focuses on management-console and business-operation buttons.
- Do not define visual design tokens such as exact colors, radius, font size, shadows, spacing scale, or theme variables.
- Do not replace Form, Dialog, Drawer, Data Table, Admin Console, Record Editing Surfaces, or Responsive owner responsibilities.
- `README.md`, `HANDOFF.md`, and `SKILL.md` must contain only summaries and routing, not duplicated owner detail.
- All evidence that does not execute browser, screen reader, touch-device, real-component, or responsive runtime checks must remain marked as unverified.
- Preserve existing user changes and keep commits scoped to the Button owner work.

---

## File Structure

- Create `references/buttons.md`: complete Button owner rules, state model, owner boundaries, and executable acceptance scenarios.
- Modify `SKILL.md`: add routing for Chinese and English button-related keywords.
- Modify `README.md`: add a short Button owner summary and link.
- Modify `HANDOFF.md`: add a short Button owner handoff section and reference path.
- Create `docs/testing/buttons/buttons-audit.rb`: structural audit for owner, routing, GREEN contract, and mutation controls.
- Create `docs/testing/buttons/green-business-buttons.md`: GREEN application output with a JSON audit contract.
- Create `docs/testing/buttons/green-summary.md`: summary of GREEN evidence and command.
- Create `docs/testing/buttons/red-summary.md`: RED baseline summary of expected pre-owner failure modes.

---

### Task 1: Create Button Owner Reference

**Files:**
- Create: `references/buttons.md`

**Interfaces:**
- Consumes: approved design at `docs/superpowers/specs/2026-07-28-button-interaction-standards-design.md`
- Produces: rule IDs `BTN-SCOPE-*`, `BTN-LABEL-*`, `BTN-HIER-*`, `BTN-STATE-*`, `BTN-ASYNC-*`, `BTN-DANGER-*`, `BTN-PERM-*`, `BTN-GROUP-*`, `BTN-A11Y-*`, `BTN-RSP-*`; state model `buttonActionState`

- [ ] **Step 1: Write `references/buttons.md`**

Create a Markdown owner with these exact top-level sections:

```markdown
# 按钮交互规范

适用于后台、管理台、控制台、SaaS console 和内部工具中的业务操作按钮。本文件是按钮语义、文案、层级、状态、禁用、异步、防重复、危险操作、图标按钮、按钮组、键盘和响应式行为的唯一事实来源。

## 范围与术语

## 与现有 owner 的关系

## BTN-SCOPE 按钮语义与原生优先

## BTN-LABEL 文案与可访问名称

## BTN-HIER 层级、主按钮和按钮组

## BTN-STATE 状态模型、禁用和隐藏

## BTN-ASYNC 异步、防重复和请求身份

## BTN-DANGER 危险按钮与风险操作

## BTN-PERM 权限、泄露防护和禁用原因

## BTN-GROUP 图标按钮、更多菜单和工具栏

## BTN-A11Y 键盘、焦点和公告

## BTN-RSP 响应式、触摸和安全区域

## 可执行验收场景

## 完成前检查
```

- [ ] **Step 2: Add rule tables**

Within the section bodies, include rule IDs and these mandatory rules:

```markdown
| 规则 ID | 规则 |
| --- | --- |
| `BTN-SCOPE-01` | 按钮必须代表明确动作，优先使用原生 `<button>`；使用非原生元素时必须提供等价角色、键盘触发、焦点、禁用和可访问名称。 |
| `BTN-SCOPE-02` | 触发导航且不执行命令的入口优先使用链接；既执行命令又导航时必须声明命令 owner、结果 owner 和导航时机。 |
| `BTN-SCOPE-03` | 按钮不得作为装饰、状态标签或 tooltip 触发器的伪装；没有动作的元素不得使用按钮语义。 |
| `BTN-LABEL-01` | 按钮文案必须描述动作和对象，例如“保存模板”“删除用户”“导出当前筛选结果”。 |
| `BTN-LABEL-02` | 禁止脱离上下文的裸词按钮，如“确定”“提交”“操作”“更多”“处理”；只有容器标题和任务区已经唯一说明对象时才可使用短文案。 |
| `BTN-LABEL-03` | 图标按钮必须有可访问名称，名称包含动作和对象，且不能只依赖 tooltip。 |
| `BTN-HIER-01` | 同一任务区同一时刻最多一个 `primary` 按钮；多个主按钮并列时必须拆分任务区或降级层级。 |
| `BTN-HIER-02` | 危险动作不得与普通主操作共用同一主视觉层级；必须显式表达风险并进入对应风险 owner。 |
| `BTN-STATE-01` | 每个业务按钮声明 `buttonActionState`，包含 `buttonId`、`actionKind`、`hierarchy`、`availability`、`disabledReasonOwner`、`asyncPhase`、`requestIdentity`、`resultOwner` 和 `accessibleName`。 |
| `BTN-STATE-02` | 禁用按钮不得触发请求；禁用原因必须可发现、可访问，且不能只存在于 hover tooltip。 |
| `BTN-ASYNC-01` | 接受按钮意图时必须冻结请求身份；点击、Enter、Space、触摸和事件重放必须进入同一去重门禁。 |
| `BTN-ASYNC-02` | loading 中按钮必须保留动作对象的可访问名称，例如“正在保存模板”，不能只剩 spinner 或“加载中”。 |
| `BTN-DANGER-01` | 删除、停用、清空、权限变更、敏感导出、批量修改、取消任务、重跑任务和不可逆配置变更默认是危险或高风险按钮。 |
| `BTN-DANGER-02` | 危险按钮不能只靠颜色表达风险，也不能只靠 Toast 表达结果；必须声明影响范围、确认策略、请求身份、结果回执和恢复路径。 |
| `BTN-PERM-01` | 禁用不是安全边界；权限不足、租户变化或敏感对象不可见时必须执行对应权限 owner 的隐藏、失效或安全说明策略。 |
| `BTN-PERM-02` | 若显示禁用按钮会泄露敏感对象名称、数量或字段，应隐藏按钮或替换为安全说明。 |
| `BTN-GROUP-01` | 更多菜单可收纳低频操作，但触发按钮必须说明对象，例如“更多用户操作”。 |
| `BTN-GROUP-02` | 危险操作进入菜单后仍保留风险标记、确认、请求身份和结果回执。 |
| `BTN-A11Y-01` | 真实按钮支持 Enter 和 Space；焦点样式必须可见；鼠标、触摸和键盘触发同一业务意图时使用同一状态转换。 |
| `BTN-A11Y-02` | 完整错误、成功、冲突或未知结果消息只能由一个 primary owner 公告；按钮不得重复播报完整消息。 |
| `BTN-RSP-01` | 移动端可折叠次要按钮，但核心操作、危险确认、错误恢复和审计回执不能消失。 |
| `BTN-RSP-02` | 低高度、虚拟键盘、200% 缩放和安全区域下，提交、取消、重试、危险确认和恢复按钮必须可达。 |
```

- [ ] **Step 3: Add `buttonActionState` table**

Include this exact state table:

```markdown
| 字段 | 语义 |
| --- | --- |
| `buttonId` | 稳定按钮身份。 |
| `actionKind` | `command`、`submit`、`navigation`、`disclosure`、`toggle-command` 或 `composite-trigger`。 |
| `hierarchy` | `primary`、`secondary`、`tertiary`、`danger`、`link-like` 或 `icon-only`。 |
| `availability` | `enabled`、`disabled`、`read-only`、`hidden-by-permission` 或 `not-instantiated`。 |
| `disabledReasonOwner` | 禁用原因 owner，例如权限、数据状态、选择状态、表单校验、任务状态或业务规则。 |
| `asyncPhase` | `idle`、`validating`、`request-in-flight`、`succeeded`、`failed` 或 `unknown`。 |
| `requestIdentity` | 触发请求时的幂等键、权限版本、目标快照和来源按钮身份。 |
| `resultOwner` | 成功、失败、冲突、未知结果和恢复入口的 primary owner。 |
| `accessibleName` | 当前可访问名称；loading、图标态和折叠态也必须保留。 |
```

- [ ] **Step 4: Add executable acceptance scenarios**

Add acceptance sections `BTN-A1` through `BTN-A8`:

```markdown
### BTN-A1：按钮语义与键盘
### BTN-A2：文案、对象和图标按钮名称
### BTN-A3：主按钮唯一和按钮组层级
### BTN-A4：禁用、隐藏和权限泄露
### BTN-A5：loading、防重复和请求身份
### BTN-A6：危险按钮确认与回执
### BTN-A7：批量、导出和任务按钮
### BTN-A8：响应式折叠与运行时验证边界
```

Each scenario must include these five bullets: `初始状态`、`事件序列`、`预期状态`、`DOM/ARIA`、`事件日志`.

- [ ] **Step 5: Verify owner text locally**

Run:

```bash
rg -n "BTN-SCOPE-01|BTN-LABEL-03|BTN-HIER-01|BTN-STATE-01|BTN-ASYNC-01|BTN-DANGER-02|BTN-PERM-02|BTN-A11Y-01|BTN-RSP-02|buttonActionState" references/buttons.md
```

Expected: each searched rule or term appears at least once.

---

### Task 2: Add Routing, README, and Handoff Summaries

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/buttons.md`
- Produces: Button routing and public summaries that point to `references/buttons.md`

- [ ] **Step 1: Update `SKILL.md` routing**

Add this route after the record editing surfaces route and before responsive route:

```markdown
- 涉及按钮、主按钮、次按钮、图标按钮、保存按钮、提交按钮、取消按钮、确认按钮、删除按钮、导出按钮、批量按钮、行操作按钮、危险按钮、禁用按钮、loading 按钮、按钮组、工具栏按钮，或 button、primary button、secondary button、icon button、submit button、save button、cancel button、confirm button、delete button、export button、bulk action button、row action button、danger button、disabled button、loading button、button group、toolbar action 时，必须完整读取 `references/buttons.md`。
```

- [ ] **Step 2: Update `README.md` current-spec summary**

Change the introductory list sentence to include `按钮`, and add this bullet after the record editing surfaces bullet:

```markdown
- 按钮规范首版聚焦管理台和业务操作按钮，约束按钮语义、文案、主次层级、禁用、loading、防重复、危险操作、图标按钮、按钮组和响应式可达性。
```

Also add a README complete-rule link whose label is `按钮交互规范` and target is `references/buttons.md`; add `buttons.md` to the directory tree.

- [ ] **Step 3: Update `HANDOFF.md` current structure**

Add `buttons.md` to the `references/` tree.

- [ ] **Step 4: Update `HANDOFF.md` completed standards**

Add this section after “记录新增/编辑承载面” and before “管理台完整治理”:

```markdown
### 按钮

- 已定义管理台和业务操作按钮的首版 owner。
- 按钮必须具备明确动作语义、文案对象、主次层级、可访问名称、禁用原因、loading 名称、防重复门禁、危险操作确认和响应式可达性。
- 图标按钮、更多菜单、批量按钮、导出按钮和任务按钮均需保留动作对象、权限边界、请求身份和结果 owner。
- 详细规则和可执行验收仅维护在 `按钮交互规范`（目标路径 `references/buttons.md`），本交接不重复其状态模型或检查项。
```

- [ ] **Step 5: Verify routing and summaries**

Run:

```bash
rg -n "references/buttons.md|按钮交互规范|loading 按钮|button group|按钮规范首版|### 按钮" SKILL.md README.md HANDOFF.md
```

Expected: route, README summary, README link, HANDOFF tree, and HANDOFF section appear.

---

### Task 3: Add Button RED/GREEN Evidence and Audit

**Files:**
- Create: `docs/testing/buttons/buttons-audit.rb`
- Create: `docs/testing/buttons/green-business-buttons.md`
- Create: `docs/testing/buttons/green-summary.md`
- Create: `docs/testing/buttons/red-summary.md`

**Interfaces:**
- Consumes: `references/buttons.md`, `SKILL.md`, `README.md`, `HANDOFF.md`
- Produces: command `ruby docs/testing/buttons/buttons-audit.rb --mutations`

- [ ] **Step 1: Create GREEN output with audit contract**

Create `docs/testing/buttons/green-business-buttons.md` containing:

```markdown
# 按钮规范 GREEN 应用输出

<!-- buttons-audit:start -->
```json
{
  "schemaVersion": 1,
  "buttonOwnerApplied": true,
  "nativeButtonRequired": true,
  "fakeButtonForbidden": true,
  "iconButtonAccessibleNameRequired": true,
  "loadingNamePreserved": true,
  "singlePrimaryPerTaskArea": true,
  "tooltipOnlyDisabledReasonForbidden": true,
  "dangerRequiresConfirmationAndReceipt": true,
  "bulkButtonRequiresSnapshotAndPermission": true,
  "sentTaskCancelNotClientOnly": true,
  "mobileCoreActionsReachable": true,
  "buttonActionState": {
    "buttonId": true,
    "actionKind": true,
    "hierarchy": true,
    "availability": true,
    "disabledReasonOwner": true,
    "asyncPhase": true,
    "requestIdentity": true,
    "resultOwner": true,
    "accessibleName": true
  },
  "componentOwners": {
    "forms": true,
    "dialogs": true,
    "drawers": true,
    "data-tables": true,
    "admin-console": true,
    "record-editing-surfaces": true,
    "responsive-adaptive": true
  },
  "negativeCases": [
    "div-fake-button",
    "icon-button-no-accessible-name",
    "loading-spinner-only",
    "two-primary-buttons-one-task",
    "danger-color-only",
    "disabled-reason-tooltip-only",
    "bulk-action-no-selection-snapshot",
    "cancel-sent-task-as-client-only",
    "mobile-core-action-removed"
  ],
  "runtimeVerification": {
    "browser": false,
    "screenReader": false,
    "touch": false,
    "realComponent": false
  }
}
```
<!-- buttons-audit:end -->

## 场景

后台用户列表和模板编辑表单同时包含保存、取消、删除用户、导出当前筛选结果、批量停用、重试任务和图标行操作按钮。所有业务操作使用真实按钮语义；图标按钮具有包含动作对象的可访问名称；loading 中保留动作对象；每个任务区只有一个主按钮。

`buttonActionState` 记录 `buttonId`、`actionKind`、`hierarchy`、`availability`、`disabledReasonOwner`、`asyncPhase`、`requestIdentity`、`resultOwner` 和 `accessibleName`。批量按钮绑定选择快照和权限版本；危险按钮声明影响范围、确认策略、请求身份、结果回执和恢复路径。运行时验证边界保持未验证。
```

- [ ] **Step 2: Create RED summary**

Create `docs/testing/buttons/red-summary.md` with these bullets:

```markdown
# 按钮规范 RED 基线总结

没有 Button owner 时，常见失败包括：

- 用 `div`、`span` 或图标伪装按钮，缺少原生键盘语义。
- 图标按钮没有可访问名称，或名称只来自 tooltip。
- loading 后按钮只剩 spinner，动作对象消失。
- 同一任务区并列多个主按钮。
- 删除、停用、敏感导出或批量修改只靠红色表达风险。
- 禁用原因只藏在 hover tooltip。
- 批量按钮不绑定选择快照、权限版本和影响范围。
- 将已发送任务的“取消”写成客户端关闭即服务端已取消。
- 移动端折叠后删除核心按钮、危险确认或错误恢复入口。
```

- [ ] **Step 3: Create GREEN summary**

Create `docs/testing/buttons/green-summary.md` with:

```markdown
# 按钮规范 GREEN 总结

GREEN 输出证明业务按钮被建模为独立 Button owner，而不是散落在 Form、Dialog、Table 或 Admin 文本中。审计命令：

```bash
ruby docs/testing/buttons/buttons-audit.rb --mutations
```

审计覆盖真实按钮语义、图标按钮名称、loading 名称、主按钮唯一、禁用原因、危险确认与回执、批量按钮快照、任务取消边界和移动端核心按钮可达性。

浏览器、屏幕阅读器、触摸设备和真实组件运行时未执行，保持未验证。
```

- [ ] **Step 4: Create Ruby audit**

Create `docs/testing/buttons/buttons-audit.rb` using this structure:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

ROOT = File.expand_path('../../..', __dir__)
OWNER = File.join(ROOT, 'references/buttons.md')
SKILL = File.join(ROOT, 'SKILL.md')
README = File.join(ROOT, 'README.md')
HANDOFF = File.join(ROOT, 'HANDOFF.md')
DEFAULT_OUTPUTS = [
  'docs/testing/buttons/green-business-buttons.md'
].map { |path| File.join(ROOT, path) }.freeze

RULE_IDS = %w[
  BTN-SCOPE-01 BTN-SCOPE-02 BTN-SCOPE-03
  BTN-LABEL-01 BTN-LABEL-02 BTN-LABEL-03
  BTN-HIER-01 BTN-HIER-02
  BTN-STATE-01 BTN-STATE-02
  BTN-ASYNC-01 BTN-ASYNC-02
  BTN-DANGER-01 BTN-DANGER-02
  BTN-PERM-01 BTN-PERM-02
  BTN-GROUP-01 BTN-GROUP-02
  BTN-A11Y-01 BTN-A11Y-02
  BTN-RSP-01 BTN-RSP-02
].freeze

STATE_FIELDS = %w[
  buttonId actionKind hierarchy availability disabledReasonOwner asyncPhase requestIdentity resultOwner accessibleName
].freeze

NEGATIVE_CASES = %w[
  div-fake-button icon-button-no-accessible-name loading-spinner-only two-primary-buttons-one-task
  danger-color-only disabled-reason-tooltip-only bulk-action-no-selection-snapshot
  cancel-sent-task-as-client-only mobile-core-action-removed
].freeze

CONTRACT_PATTERN = /<!-- buttons-audit:start -->\s*```json\s*(.*?)\s*```\s*<!-- buttons-audit:end -->/m

def extract_contract(text)
  match = text.match(CONTRACT_PATTERN)
  raise JSON::ParserError, '缺少 buttons-audit JSON 契约区块' unless match

  JSON.parse(match[1])
end

def replace_contract(text, contract)
  replacement = "<!-- buttons-audit:start -->\n```json\n#{JSON.pretty_generate(contract)}\n```\n<!-- buttons-audit:end -->"
  text.sub(CONTRACT_PATTERN, replacement)
end

def owner_failures
  failures = []
  owner = File.exist?(OWNER) ? File.read(OWNER, encoding: 'UTF-8') : ''
  skill = File.exist?(SKILL) ? File.read(SKILL, encoding: 'UTF-8') : ''
  readme = File.exist?(README) ? File.read(README, encoding: 'UTF-8') : ''
  handoff = File.exist?(HANDOFF) ? File.read(HANDOFF, encoding: 'UTF-8') : ''

  failures << '缺少按钮 owner：references/buttons.md' if owner.empty?
  RULE_IDS.each { |id| failures << "owner 缺少规则 ID #{id}" unless owner.include?(id) }
  STATE_FIELDS.each { |field| failures << "owner 缺少 buttonActionState 字段 #{field}" unless owner.include?(field) }
  %w[原生 `<button>` 图标按钮 loading 危险 权限 tooltip buttonActionState].each do |term|
    failures << "owner 缺少按钮关键术语 #{term}" unless owner.include?(term)
  end
  %w[按钮 图标按钮 保存按钮 删除按钮 loading\ 按钮 button group references/buttons.md].each do |term|
    failures << "SKILL 路由缺少 #{term}" unless skill.include?(term)
  end
  failures << 'README 缺少按钮摘要' unless readme.include?('按钮规范首版')
  failures << 'README 缺少按钮链接' unless readme.include?('references/buttons.md')
  failures << 'HANDOFF 缺少按钮交接' unless handoff.include?('### 按钮')
  failures
end

def contract_failures(path, contract, text)
  failures = []
  failures << "#{path}: schemaVersion 必须为 1" unless contract['schemaVersion'] == 1
  %w[
    buttonOwnerApplied nativeButtonRequired fakeButtonForbidden iconButtonAccessibleNameRequired loadingNamePreserved
    singlePrimaryPerTaskArea tooltipOnlyDisabledReasonForbidden dangerRequiresConfirmationAndReceipt
    bulkButtonRequiresSnapshotAndPermission sentTaskCancelNotClientOnly mobileCoreActionsReachable
  ].each do |key|
    failures << "#{path}: #{key} 必须为 true" unless contract[key] == true
  end
  STATE_FIELDS.each { |field| failures << "#{path}: buttonActionState 缺少 #{field}" unless contract.dig('buttonActionState', field) == true }
  %w[forms dialogs drawers data-tables admin-console record-editing-surfaces responsive-adaptive].each do |owner|
    failures << "#{path}: 未应用组件 owner #{owner}" unless contract.dig('componentOwners', owner) == true
  end
  NEGATIVE_CASES.each { |name| failures << "#{path}: 缺少负向用例 #{name}" unless Array(contract['negativeCases']).include?(name) }
  %w[browser screenReader touch realComponent].each do |environment|
    failures << "#{path}: #{environment} 必须明确为未验证" unless contract.dig('runtimeVerification', environment) == false
  end
  %w[buttonActionState requestIdentity resultOwner 运行时验证边界].each do |term|
    failures << "#{path}: 正文缺少 #{term}" unless text.include?(term)
  end
  failures
end

def output_failures(path, text)
  contract_failures(path, extract_contract(text), text)
rescue JSON::ParserError => e
  ["#{path}: JSON 审计契约无效：#{e.message}"]
end

def audit(outputs)
  failures = owner_failures
  outputs.each do |path|
    unless File.file?(path)
      failures << "缺少 GREEN 应用输出：#{path}"
      next
    end
    failures.concat(output_failures(path, File.read(path, encoding: 'UTF-8')))
  end
  failures
end

def contract_control(name, source)
  text = File.read(source, encoding: 'UTF-8')
  contract = extract_contract(text)
  yield(contract)
  failures = output_failures(source, replace_contract(text, contract))
  if failures.empty?
    puts "UNEXPECTED_PASS: #{name}"
    false
  else
    puts "EXPECTED_FAIL: #{name}"
    true
  end
end

mutations = ARGV.delete('--mutations')
outputs = ARGV.empty? ? DEFAULT_OUTPUTS : ARGV.map { |path| File.expand_path(path) }
failures = audit(outputs)
unless failures.empty?
  puts "FAIL: #{failures.length} 项"
  failures.each { |failure| puts "- #{failure}" }
  exit 1
end
puts 'PASS: Button owner 与 GREEN 应用输出符合结构化审计契约。'

if mutations
  source = DEFAULT_OUTPUTS.first
  checks = [
    ['fake-button-allowed', ->(c) { c['fakeButtonForbidden'] = false }],
    ['icon-name-missing', ->(c) { c['iconButtonAccessibleNameRequired'] = false }],
    ['loading-name-lost', ->(c) { c['loadingNamePreserved'] = false }],
    ['multiple-primary-allowed', ->(c) { c['singlePrimaryPerTaskArea'] = false }],
    ['tooltip-only-disabled-reason', ->(c) { c['tooltipOnlyDisabledReasonForbidden'] = false }],
    ['danger-receipt-missing', ->(c) { c['dangerRequiresConfirmationAndReceipt'] = false }],
    ['bulk-snapshot-missing', ->(c) { c['bulkButtonRequiresSnapshotAndPermission'] = false }],
    ['sent-task-client-cancel', ->(c) { c['sentTaskCancelNotClientOnly'] = false }],
    ['mobile-core-action-removed', ->(c) { c['mobileCoreActionsReachable'] = false }],
    ['runtime-browser-marked-verified', ->(c) { c['runtimeVerification']['browser'] = true }]
  ]
  all_expected = checks.all? { |name, mutation| contract_control(name, source, &mutation) }
  exit(all_expected ? 0 : 1)
end
```

- [ ] **Step 5: Run Button audit with mutations**

Run:

```bash
ruby docs/testing/buttons/buttons-audit.rb --mutations
```

Expected:

```text
PASS: Button owner 与 GREEN 应用输出符合结构化审计契约。
EXPECTED_FAIL: fake-button-allowed
EXPECTED_FAIL: icon-name-missing
EXPECTED_FAIL: loading-name-lost
EXPECTED_FAIL: multiple-primary-allowed
EXPECTED_FAIL: tooltip-only-disabled-reason
EXPECTED_FAIL: danger-receipt-missing
EXPECTED_FAIL: bulk-snapshot-missing
EXPECTED_FAIL: sent-task-client-cancel
EXPECTED_FAIL: mobile-core-action-removed
EXPECTED_FAIL: runtime-browser-marked-verified
```

---

### Task 4: Final Verification and Commit

**Files:**
- Verify all files from Tasks 1 through 3

**Interfaces:**
- Consumes: completed Button owner, routing, summaries, audit, and evidence
- Produces: a clean commit ready for push

- [ ] **Step 1: Run Button audit**

Run:

```bash
ruby docs/testing/buttons/buttons-audit.rb --mutations
```

Expected: command exits `0`, with baseline `PASS` and ten `EXPECTED_FAIL` mutation lines.

- [ ] **Step 2: Run existing admin-console audit**

Run:

```bash
ruby docs/testing/admin-console/admin-console-audit.rb docs/testing/admin-console/green-report-dashboard.md docs/testing/admin-console/green-permission-risk-console.md docs/testing/admin-console/green-job-audit-console.md --mutations
```

Expected: command exits `0`, with `PASS` and `MUTATIONS PASS`.

- [ ] **Step 3: Run existing record-editing-surfaces audit**

Run:

```bash
ruby docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb --mutations
```

Expected: command exits `0`, with baseline `PASS` and expected mutation failures.

- [ ] **Step 4: Run placeholder scan**

Run:

```bash
ruby -e 'patterns = [[84,66,68], [84,79,68,79], [24453,23450], [21344,20301], [63,63]].map { |codes| codes.pack("U*") }; files = ARGV; bad = []; files.each { |file| File.readlines(file, chomp: true).each_with_index { |line, index| bad << "#{file}:#{index + 1}:#{line}" if patterns.any? { |pattern| line.include?(pattern) } } }; if bad.empty? then puts "PLACEHOLDERS PASS" else puts bad; exit 1 end' references/buttons.md docs/testing/buttons/green-business-buttons.md docs/testing/buttons/green-summary.md docs/testing/buttons/red-summary.md SKILL.md README.md HANDOFF.md
```

Expected: `PLACEHOLDERS PASS`.

- [ ] **Step 5: Run Markdown link check**

Run:

```bash
ruby -e 'root = Dir.pwd; files = Dir.glob("**/*.md"); missing = []; files.each do |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |link| target = link.split(/[ \t]/, 2).first; next if target.start_with?("http://", "https://", "mailto:", "#"); path = target.split("#", 2).first; next if path.empty?; resolved = File.expand_path(path, File.dirname(File.join(root, file))); missing << "#{file}: #{link}" unless File.exist?(resolved); end; end; if missing.empty? then puts "LINKS PASS" else puts "LINKS FAIL"; puts missing; exit 1 end'
```

Expected: `LINKS PASS`.

- [ ] **Step 6: Run whitespace check**

Run:

```bash
git diff --check
```

Expected: no output and exit `0`.

- [ ] **Step 7: Run quick validate if dependency is available**

Run:

```bash
python3 /Users/evanqi/.codex/skills/.system/skill-creator/scripts/quick_validate.py .
```

Expected if PyYAML is still missing: fail with `ModuleNotFoundError: No module named 'yaml'`; record as not passed and do not install dependencies unless the user separately approves. Expected if PyYAML is available: exit `0`.

- [ ] **Step 8: Review git diff**

Run:

```bash
git status --short --branch
git diff --stat
```

Expected: only Button owner files, routing summaries, audit evidence, and this implementation plan are modified or added.

- [ ] **Step 9: Commit implementation**

Run:

```bash
git add SKILL.md README.md HANDOFF.md references/buttons.md docs/testing/buttons docs/superpowers/plans/2026-07-28-button-interaction-standards.md
git commit -m "docs: 新增按钮交互规范"
```

Expected: commit succeeds with a focused docs change.
