# 选择控件与开关交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增选择控件与开关 owner，覆盖 Checkbox、Radio、Switch、Toggle、Toggle Group、Segmented Control、三态 checkbox 的语义、状态、提交边界、风险转交、权限、可访问性和移动端可达性。

**Architecture:** 新建 `references/selection-controls.md` 作为唯一事实来源，并在 `SKILL.md`、`README.md`、`HANDOFF.md` 中建立路由和摘要。新增 `docs/testing/selection-controls/` 下的 GREEN/RED 摘要与 Ruby 静态审计器，沿用现有 owner 的术语覆盖 + mutation 模式。

**Tech Stack:** Markdown 文档；Ruby 标准库静态审计；Git 提交；不引入依赖。

## Global Constraints

- 数据表格行选择、表头全选、全部筛选结果选择和批量范围继续由 `data-tables.md` 负责。
- 危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 `risk-actions.md`。
- `draftValue` 与 `committedValue` 必须分离。
- Hover、focus、active、pressed visual、disabled、indeterminate 和 optimistic preview 不得伪装成已提交业务值。
- Switch/Toggle 只能表达可逆、低风险且文案能明确表达开/关后果的设置。
- 三态 checkbox 的 `indeterminateState` 不能作为可提交业务值。
- 移动端不得删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限切换、异步保存和移动端视口验证在本轮文档工作中必须标为未验证。

---

## File Structure

- Create `references/selection-controls.md`: 选择控件与开关 owner 正文、硬规则和完成前检查。
- Modify `SKILL.md`: 增加 checkbox/radio/switch/toggle/segmented 路由。
- Modify `README.md`: 在当前规范摘要和完整规则链接中加入新 owner。
- Modify `HANDOFF.md`: 在已完成规范与目录树中加入新 owner 摘要。
- Create `docs/testing/selection-controls/green-summary.md`: 正向证据摘要。
- Create `docs/testing/selection-controls/red-summary.md`: 负向失败摘要。
- Create `docs/testing/selection-controls/selection-controls-audit.rb`: 静态审计和 mutation checks。

---

### Task 1: 新增 owner 正文

**Files:**
- Create: `references/selection-controls.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-selection-controls-interaction-standards-design.md`
- Produces: `selectionControlState` 状态模型、完成前检查和可被审计器匹配的稳定术语。

- [ ] **Step 1: 创建 owner 文档**

写入 `references/selection-controls.md`，必须包含以下开头：

```markdown
# 选择控件与开关交互规范

适用于 Checkbox、Checkbox Group、Radio Group、Switch、Toggle、Toggle Group、Segmented Control、三态 checkbox、复选、多选、单选、开关、切换和分段选择控件。本文件是选择控件语义、状态、提交边界、风险转交、权限、安全、可访问性和验收的唯一事实来源。
```

- [ ] **Step 2: 写入 `selectionControlState`**

状态模型必须逐项包含：

```markdown
`controlOwnerId`、`controlKind`、`optionSet`、`draftValue`、`committedValue`、`commitMode`、`indeterminateState`、`permissionState`、`riskPolicy`、`feedbackState`、`a11yPolicy`、`responsivePolicy`
```

- [ ] **Step 3: 写入硬规则**

必须逐字保留以下核心规则，供审计器匹配：

```markdown
`draftValue` 与 `committedValue` 必须分离。
Hover、focus、active、pressed visual、disabled、indeterminate 和 optimistic preview 不得伪装成已提交业务值。
危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 `risk-actions.md`。
确认完成前请求数为 0，且开关状态不得提前翻转为成功。
三态 checkbox 的 `indeterminateState` 不能作为可提交业务值。
Radio Group、Checkbox Group、Toggle Group 和 Segmented Control 必须有组 label 或等价可访问名称。
禁用选项必须保留可发现原因。
移动端不得删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要。
```

- [ ] **Step 4: 写入完成前检查**

检查项必须覆盖：控件选择规则、草稿/提交分离、Switch 风险边界、三态 checkbox、组语义、禁用原因、权限降级、键盘、可访问性、移动端、异步失败/回滚、disposal 和未验证声明。

- [ ] **Step 5: 本地检查**

Run:

```bash
rg -n "selectionControlState|draftValue|committedValue|危险启停|indeterminateState|移动端不得删除|未验证" references/selection-controls.md
git diff --check
```

Expected: `rg` 找到对应术语；`git diff --check` 无输出且 exit 0。

---

### Task 2: 接入路由与摘要

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: Task 1 的 `references/selection-controls.md`
- Produces: 用户任务能够路由到新 owner；README/HANDOFF 能让维护者发现新规范。

- [ ] **Step 1: 更新 `SKILL.md` 路由**

在 Select 路由之后或 forms 路由之前加入：

```markdown
- 涉及 Checkbox、Checkbox Group、Radio、Radio Group、Switch、Toggle、Toggle Group、Segmented Control、三态 checkbox、复选框、复选组、多选、单选组、单选按钮、开关、切换、分段控件、选择控件、布尔设置、偏好开关，或 checkbox、checkbox group、radio、radio group、switch、toggle、toggle group、segmented control、tri-state checkbox、boolean setting、preference toggle 时，必须完整读取 `references/selection-controls.md`。
```

- [ ] **Step 2: 更新 `README.md` 当前规范摘要**

在当前规范列表加入一句：

```markdown
- 选择控件与开关规范约束 Checkbox、Radio、Switch、Toggle、Segmented Control、三态 checkbox 的草稿/提交分离、组语义、风险转交、禁用原因、权限安全、键盘可达和移动端承载。
```

并在完整规则链接列表中加入纯文本计划提示：

```markdown
搜索与命令面板交互规范后加入：`[选择控件与开关交互规范](references/selection-controls.md)`
```

- [ ] **Step 3: 更新 `HANDOFF.md`**

在目录树加入：

```markdown
├── selection-controls.md
```

在已完成规范中加入：

```markdown
### 选择控件与开关

- 已定义 Checkbox、Radio Group、Switch、Toggle、Toggle Group、Segmented Control 和三态 checkbox 的首版 owner。
- `draftValue` 与 `committedValue` 必须分离；hover、focus、active、pressed visual、disabled、indeterminate 和 optimistic preview 不得伪装成已提交业务值。
- 危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 `risk-actions.md`；确认完成前请求数为 0。
- 三态 checkbox 的 `indeterminateState` 不能作为可提交业务值；移动端不得删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要。
```

- [ ] **Step 4: 本地检查**

Run:

```bash
rg -n "selection-controls.md|Checkbox|Radio Group|Switch|Toggle|Segmented Control|tri-state checkbox" SKILL.md README.md HANDOFF.md
git diff --check
```

Expected: 三个文档都命中新 owner；`git diff --check` 通过。

---

### Task 3: 新增审计证据和静态审计器

**Files:**
- Create: `docs/testing/selection-controls/green-summary.md`
- Create: `docs/testing/selection-controls/red-summary.md`
- Create: `docs/testing/selection-controls/selection-controls-audit.rb`

**Interfaces:**
- Consumes: Task 1 owner 和 Task 2 路由摘要
- Produces: `ruby docs/testing/selection-controls/selection-controls-audit.rb --mutations`

- [ ] **Step 1: 写 GREEN 摘要**

`green-summary.md` 必须覆盖：

```markdown
- `selectionControlState` 固定包含 owner、控件类型、选项集、草稿值、已提交值、提交模式、三态、权限、风险、反馈、可访问性和响应式策略。
- `draftValue` 与 `committedValue` 必须分离。
- Hover、focus、active、pressed visual、disabled、indeterminate 和 optimistic preview 不得伪装成已提交业务值。
- 危险启停、权限变更、敏感导出、任务取消/重跑、密钥、外部系统影响和不可逆状态必须进入 `risk-actions.md`。
- 确认完成前请求数为 0，且开关状态不得提前翻转为成功。
- 三态 checkbox 的 `indeterminateState` 不能作为可提交业务值。
- Radio Group、Checkbox Group、Toggle Group 和 Segmented Control 必须有组 label 或等价可访问名称。
- 禁用选项必须保留可发现原因。
- 移动端不得删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限切换、异步保存和移动端视口仍是未验证。
```

- [ ] **Step 2: 写 RED 摘要**

`red-summary.md` 必须覆盖：

```markdown
- Switch 点击后直接启停危险业务状态，绕过 `risk-actions.md`。
- `draftValue` 与 `committedValue` 混用，筛选结果、表单提交或设置状态读取未提交草稿。
- Hover、focus、active、pressed visual、disabled、indeterminate 或 optimistic preview 被写成已提交业务值。
- 三态 checkbox 的 `indeterminateState` 被提交给后端。
- Radio Group、Checkbox Group、Toggle Group 或 Segmented Control 没有组 label 或等价可访问名称。
- 禁用选项只靠灰色或 hover tooltip 表达原因。
- 移动端删除选项、禁用原因、错误说明、保存/取消、恢复路径或当前已选摘要。
```

- [ ] **Step 3: 写 Ruby 审计器**

审计器必须检查 owner、路由、README、HANDOFF、GREEN、RED 和项目泄露。Mutation checks 至少包含：

```ruby
"draft-committed-separation"
"visual-state-not-committed"
"risk-switch-owner"
"request-before-confirmation"
"indeterminate-not-committed"
"group-label-required"
"disabled-reason-required"
"mobile-capability-preserved"
"runtime-boundary-marked-verified"
"missing-route"
"project-leak"
```

- [ ] **Step 4: 运行专项审计**

Run:

```bash
ruby docs/testing/selection-controls/selection-controls-audit.rb --mutations
```

Expected: baseline PASS；所有 mutation 输出 `EXPECTED_FAIL`。

---

### Task 4: 全量验证、提交和推送

**Files:**
- All files modified by Tasks 1-3

**Interfaces:**
- Consumes: 完整 owner、路由、摘要和审计器
- Produces: pushed commit on `main`

- [ ] **Step 1: 运行维护 owner 审计**

Run:

```bash
ruby docs/testing/admin-console/admin-console-audit.rb --mutations
ruby docs/testing/adoption/adoption-audit.rb --mutations
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/charts-visualization/charts-visualization-audit.rb --mutations
ruby docs/testing/date-time-ranges/date-time-ranges-audit.rb --mutations
ruby docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
ruby docs/testing/information-display/information-display-audit.rb --mutations
ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations
ruby docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb --mutations
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
ruby docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/search-command-palette/search-command-palette-audit.rb --mutations
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
ruby docs/testing/wizards-steppers/wizards-steppers-audit.rb --mutations
ruby docs/testing/selection-controls/selection-controls-audit.rb --mutations
```

Expected: all commands exit 0. Do not use historical `docs/testing/data-tables/attempt-*` scripts as maintained owner gates.

- [ ] **Step 2: 运行 Markdown 链接检查**

Run:

```bash
ruby -e 'files = Dir["README.md", "HANDOFF.md", "SKILL.md", "references/*.md", "docs/**/*.md"]; missing = []; files.each do |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |href| next if href =~ /\Ahttps?:/; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target); end; end; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
```

Expected: `PASS: markdown links resolve`

- [ ] **Step 3: 运行 diff 检查**

Run:

```bash
git diff --check
git status --short --branch
```

Expected: diff check exit 0；只包含本计划相关修改。

- [ ] **Step 4: 提交实现**

Run:

```bash
git add SKILL.md README.md HANDOFF.md references/selection-controls.md docs/testing/selection-controls/green-summary.md docs/testing/selection-controls/red-summary.md docs/testing/selection-controls/selection-controls-audit.rb
git commit -m "docs: 新增选择控件交互规范"
```

Expected: commit succeeds.

- [ ] **Step 5: 提交后复验并推送**

Run the maintained owner audit list again, then:

```bash
git push origin main
git status --short --branch
```

Expected: `main` pushed to origin and worktree clean.
