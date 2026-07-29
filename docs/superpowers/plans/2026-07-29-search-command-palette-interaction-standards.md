# 搜索与命令面板交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增搜索与命令面板 owner，覆盖全局搜索、站内搜索、命令面板、快速跳转、动作搜索、搜索建议、最近/保存搜索、结果分组、命令执行边界、权限安全、移动端承载和 AI 搜索边界。

**Architecture:** 新建 `references/search-command-palette.md` 作为唯一事实来源，并在 `SKILL.md`、`README.md`、`HANDOFF.md` 中建立路由和摘要。新增 `docs/testing/search-command-palette/` 下的 GREEN/RED 摘要与 Ruby 静态审计器，沿用现有 owner 的术语覆盖 + mutation 模式。

**Tech Stack:** Markdown 文档；Ruby 标准库静态审计；Git 提交；不引入依赖。

## Global Constraints

- 全局搜索、站内搜索、命令面板和快速跳转不得落回 `query-filters.md`；列表/报表筛选仍由 `query-filters.md` 负责。
- `queryDraft`、`activeResult`、hover suggestion 和最近搜索高亮不得触发导航、命令执行或请求副作用。
- 只有明确提交搜索或激活结果后，才能改变导航、执行命令或写入已提交查询。
- 会修改数据、权限、导出、任务、密钥或外部系统的命令必须进入 `risk-actions.md`。
- 无权限结果不得泄露对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存。
- 移动端不得删除查询输入、提交、清空、结果分组、权限/错误说明、最近/保存搜索入口或恢复路径。
- 真实浏览器、触摸、快捷键、搜索服务、AI 服务、权限切换和移动端视口验证在本轮文档工作中必须标为未验证。

---

## File Structure

- Create `references/search-command-palette.md`: 搜索与命令面板 owner 正文、硬规则和完成前检查。
- Modify `SKILL.md`: 增加全局搜索、命令面板、快速跳转和 AI 搜索的路由。
- Modify `README.md`: 在当前规范摘要和完整规则链接中加入新 owner。
- Modify `HANDOFF.md`: 在已完成规范与目录树中加入新 owner 摘要。
- Create `docs/testing/search-command-palette/green-summary.md`: 正向证据摘要。
- Create `docs/testing/search-command-palette/red-summary.md`: 负向失败摘要。
- Create `docs/testing/search-command-palette/search-command-palette-audit.rb`: 静态审计和 mutation checks。

---

### Task 1: 新增 owner 正文

**Files:**
- Create: `references/search-command-palette.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-search-command-palette-interaction-standards-design.md`
- Produces: `searchCommandState` 状态模型、完成前检查和可被审计器匹配的稳定术语。

- [ ] **Step 1: 创建 owner 文档**

写入 `references/search-command-palette.md`，必须包含以下章节：

```markdown
# 搜索与命令面板交互规范

适用于全局搜索、全站搜索、站内搜索、命令面板、快速跳转、快捷搜索、动作搜索、对象搜索、搜索建议、最近搜索、保存搜索、搜索结果、结果分组、搜索预览、AI 搜索和自然语言搜索入口。本文件是搜索与命令面板交互、权限、安全、命令执行和验收的唯一事实来源。

列表、表格、报表或审计日志中的查询条件和筛选继续执行 [查询条件与筛选交互规范](query-filters.md)。字段 Select / Combobox 的内部搜索继续执行 [可搜索单选 Select / Combobox 交互规范](selects-comboboxes.md)。会修改数据、权限、导出、任务、密钥或外部系统的命令必须进入 [危险操作与恢复交互规范](risk-actions.md)。
```

- [ ] **Step 2: 写入 `searchCommandState`**

状态模型必须逐项包含：

```markdown
`searchOwnerId`、`surfaceKind`、`queryDraft`、`submittedQuery`、`resultSnapshot`、`resultGroups`、`activeResult`、`selectionState`、`commandBinding`、`permissionBoundary`、`rankingPolicy`、`historyPolicy`、`shortcutPolicy`、`feedbackState`、`responsivePolicy`、`a11yPolicy`
```

- [ ] **Step 3: 写入硬规则**

必须逐字保留以下核心规则，供审计器匹配：

```markdown
搜索草稿、active result、hover suggestion 和最近搜索高亮不得触发导航、命令执行或请求副作用。
只有明确提交搜索或激活结果后，才能改变导航、执行命令或写入已提交查询。
结果分组必须声明来源、对象类型、排序依据、权限边界和可执行动作。
无权限结果不得泄露对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存。
搜索结果必须区分 loading、empty、zero-results、partial、stale、error 和 permission-denied。
搜索历史、最近搜索和保存搜索必须声明存储范围、清除路径、权限复核和敏感查询策略。
移动端不得删除查询输入、提交、清空、结果分组、错误/权限说明、最近/保存搜索入口或恢复路径。
AI / 自然语言搜索不得把建议答案、候选结果、可执行命令和已执行结果混为一谈。
```

- [ ] **Step 4: 写入完成前检查**

检查项必须覆盖：草稿/提交分离、建议、结果分组、命令执行、风险命令转交、权限降级、最近/保存搜索清除、URL 安全、键盘、焦点、移动端、AI 边界、disposal 和未验证声明。

- [ ] **Step 5: 本地检查**

Run:

```bash
rg -n "searchCommandState|搜索草稿|无权限结果|移动端不得删除|AI / 自然语言搜索|未验证" references/search-command-palette.md
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
- Consumes: Task 1 的 `references/search-command-palette.md`
- Produces: 用户任务能够路由到新 owner；README/HANDOFF 能让维护者发现新规范。

- [ ] **Step 1: 更新 `SKILL.md` 路由**

在 `query-filters.md` 路由之后或 `navigation-routing.md` 之前加入：

```markdown
- 涉及全局搜索、全站搜索、站内搜索、命令面板、快捷命令、快速跳转、快捷搜索、搜索建议、搜索历史、最近搜索、保存搜索、搜索结果、结果分组、搜索预览、动作搜索、命令执行、自然语言搜索、AI 搜索，或 global search、site search、universal search、command palette、quick switcher、quick search、action search、search suggestions、recent searches、saved searches、search results、result groups、result preview、command execution、natural language search、AI search 时，必须完整读取 `references/search-command-palette.md`。
```

- [ ] **Step 2: 更新 `README.md` 当前规范摘要**

在当前规范列表加入一句：

```markdown
- 搜索与命令面板规范约束全局搜索、站内搜索、命令面板、快速跳转、动作搜索、结果分组、命令执行、权限无泄露、最近/保存搜索、快捷键、移动端承载和 AI 搜索边界。
```

并在完整规则链接列表中加入：

```markdown
[搜索与命令面板交互规范](references/search-command-palette.md)
```

- [ ] **Step 3: 更新 `HANDOFF.md`**

在目录树加入：

```markdown
├── search-command-palette.md
```

在已完成规范中加入：

```markdown
### 搜索与命令面板

- 已定义全局搜索、站内搜索、命令面板、快速跳转、动作搜索、搜索建议、最近/保存搜索、结果分组、命令执行和 AI 搜索边界。
- 搜索草稿、active result、hover suggestion 和最近搜索高亮不得触发导航、命令执行或请求副作用；只有明确提交搜索或激活结果后才能改变导航或执行命令。
- 会修改数据、权限、导出、任务、密钥或外部系统的命令必须进入 `risk-actions.md`；无权限结果不得泄露对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存。
- 移动端不得删除查询输入、提交、清空、结果分组、错误/权限说明、最近/保存搜索入口或恢复路径。
```

- [ ] **Step 4: 本地检查**

Run:

```bash
rg -n "search-command-palette.md|全局搜索|命令面板|quick switcher|AI search" SKILL.md README.md HANDOFF.md
git diff --check
```

Expected: 三个文档都命中新 owner；`git diff --check` 通过。

---

### Task 3: 新增审计证据和静态审计器

**Files:**
- Create: `docs/testing/search-command-palette/green-summary.md`
- Create: `docs/testing/search-command-palette/red-summary.md`
- Create: `docs/testing/search-command-palette/search-command-palette-audit.rb`

**Interfaces:**
- Consumes: Task 1 owner 和 Task 2 路由摘要
- Produces: `ruby docs/testing/search-command-palette/search-command-palette-audit.rb --mutations`

- [ ] **Step 1: 写 GREEN 摘要**

`green-summary.md` 必须覆盖：

```markdown
- `searchCommandState` 固定包含 owner、草稿、已提交查询、结果快照、分组、active、命令绑定、权限、历史、快捷键、反馈、响应式和可访问性。
- 搜索草稿、active result、hover suggestion 和最近搜索高亮不得触发导航、命令执行或请求副作用。
- 结果分组必须声明来源、对象类型、排序依据、权限边界和可执行动作。
- 风险命令必须进入 `risk-actions.md`。
- 无权限结果不得泄露对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存。
- 移动端不得删除查询输入、提交、清空、结果分组、错误/权限说明、最近/保存搜索入口或恢复路径。
- AI search 不得把建议答案、候选结果、可执行命令和已执行结果混为一谈。
- 真实浏览器、触摸、快捷键、搜索服务、AI 服务、权限切换和移动端视口仍是未验证。
```

- [ ] **Step 2: 写 RED 摘要**

`red-summary.md` 必须覆盖：

```markdown
- 输入搜索草稿、hover suggestion、active result 或最近搜索高亮时直接导航或执行命令。
- 结果分组没有来源、对象类型、排序依据、权限边界或可执行动作。
- 会修改数据、权限、导出、任务、密钥或外部系统的命令绕过 `risk-actions.md`。
- 无权限结果显示对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存。
- loading、empty、zero-results、partial、stale、error 和 permission-denied 被合并成一个模糊状态。
- 最近搜索和保存搜索没有清除路径、权限复核或敏感查询策略。
- 移动端删除查询输入、提交、清空、结果分组、错误/权限说明、最近/保存搜索入口或恢复路径。
- AI search 把建议答案、候选结果、可执行命令和已执行结果混为一谈。
```

- [ ] **Step 3: 写 Ruby 审计器**

审计器结构沿用现有 owner：

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/search-command-palette.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/search-command-palette/green-summary.md")
RED = File.join(ROOT, "docs/testing/search-command-palette/red-summary.md")

OWNER_TERMS = [
  "searchCommandState",
  "searchOwnerId", "surfaceKind", "queryDraft", "submittedQuery", "resultSnapshot",
  "resultGroups", "activeResult", "selectionState", "commandBinding", "permissionBoundary",
  "rankingPolicy", "historyPolicy", "shortcutPolicy", "feedbackState", "responsivePolicy", "a11yPolicy",
  "搜索草稿、active result、hover suggestion 和最近搜索高亮不得触发导航、命令执行或请求副作用",
  "只有明确提交搜索或激活结果后，才能改变导航、执行命令或写入已提交查询",
  "会修改数据、权限、导出、任务、密钥或外部系统的命令必须进入 `risk-actions.md`",
  "结果分组必须声明来源、对象类型、排序依据、权限边界和可执行动作",
  "无权限结果不得泄露对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存",
  "搜索结果必须区分 loading、empty、zero-results、partial、stale、error 和 permission-denied",
  "搜索历史、最近搜索和保存搜索必须声明存储范围、清除路径、权限复核和敏感查询策略",
  "移动端不得删除查询输入、提交、清空、结果分组、错误/权限说明、最近/保存搜索入口或恢复路径",
  "AI / 自然语言搜索不得把建议答案、候选结果、可执行命令和已执行结果混为一谈",
  "未验证"
].freeze
```

Mutation checks 至少删除以下术语并期望失败：

```ruby
"draft-active-no-side-effect"
"submit-before-navigation-command"
"risk-command-owner"
"permission-no-leakage"
"result-states-distinct"
"history-sensitive-policy"
"mobile-capability-preserved"
"ai-boundary"
"runtime-boundary-marked-verified"
"missing-route"
"project-leak"
```

- [ ] **Step 4: 运行专项审计**

Run:

```bash
ruby docs/testing/search-command-palette/search-command-palette-audit.rb --mutations
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
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
ruby docs/testing/wizards-steppers/wizards-steppers-audit.rb --mutations
ruby docs/testing/search-command-palette/search-command-palette-audit.rb --mutations
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
git add SKILL.md README.md HANDOFF.md references/search-command-palette.md docs/testing/search-command-palette/green-summary.md docs/testing/search-command-palette/red-summary.md docs/testing/search-command-palette/search-command-palette-audit.rb
git commit -m "docs: 新增搜索与命令面板交互规范"
```

Expected: commit succeeds.

- [ ] **Step 5: 提交后复验并推送**

Run the maintained owner audit list again, then:

```bash
git push origin main
git status --short --branch
```

Expected: `main` pushed to origin and worktree clean.
