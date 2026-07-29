# Information Display Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class detail page, information display, description list, readonly field, info card, status badge, and metric card owner to the frontend product interaction standards.

**Architecture:** Create one focused owner file at `references/information-display.md`, route matching tasks from `SKILL.md`, summarize the new owner in `README.md` and `HANDOFF.md`, and protect the contract with a Ruby static audit plus red/green evidence documents.

**Tech Stack:** Markdown documentation, Ruby static audit, Git.

## Global Constraints

- Keep this generic to the interaction standards skill; do not bind rules to `fex-admin`, `gloopai`, `story`, `dev-ops`, `token-api`, or any current project implementation.
- Information display rules cover readonly presentation semantics, not form editing, risk confirmation, routing, query filtering, or chart visualization internals.
- Detail pages must not implement editing by embedding input, textarea, select, editable table, or inline save controls.
- Empty, unknown, not configured, no permission, deleted, unavailable, loading failure, and not applicable values must be distinguishable.
- Status badges, color, icons, avatars, and trend arrows must not be the only semantic source.
- Mobile adaptations may fold or regroup information but must not remove identity, status, risk/error, permission, freshness, primary action, recovery, or audit information.
- Runtime UI checks remain unverified by this documentation task and must be labelled as such.

---

### Task 1: Owner Reference

**Files:**
- Create: `references/information-display.md`

**Interfaces:**
- Consumes: Design from `docs/superpowers/specs/2026-07-29-information-display-interaction-standards-design.md`.
- Produces: An information display owner that `SKILL.md`, `README.md`, `HANDOFF.md`, and the audit can reference.

- [ ] **Step 1: Create the owner file**

Add `references/information-display.md` with sections for scope, required `informationDisplayState`, readonly boundaries, field semantics, status tags, metrics, display-area actions, permission and sensitive information, layout and long content, responsive adaptation, accessibility, lifecycle refresh, owner relationships, and completion checks.

- [ ] **Step 2: Include the required state fields**

Ensure the owner explicitly lists `displayOwnerId`, `subjectIdentity`, `displaySnapshot`, `fieldSemantics`, `visibilityPolicy`, `freshnessState`, `statusSemantics`, `actionBinding`, `copyPolicy`, `responsivePolicy`, `a11yPolicy`, and `auditBinding`.

- [ ] **Step 3: Include hard rules**

Ensure the owner includes these exact contract ideas:

```text
informationDisplayState
详情页不得直接内嵌 input、textarea、select、可编辑表格或行内保存按钮来完成编辑
只读状态不得用 disabled 表单控件充当展示文本
空值、未配置、未知、加载失败、无权限、已删除和不适用必须可区分
状态标签、徽标、颜色、图标和趋势箭头不能是唯一语义来源
指标卡必须声明指标名、口径、单位、时间范围、数据延迟、刷新时间和权限范围
复制操作不得复制脱敏或无权限字段的真实值
无权限展示不得泄露对象名称、字段值、数量、文件名、内部 ID、筛选值或旧缓存
移动端不得删除字段 label、单位、状态说明、错误/权限说明、复制/恢复路径或审计入口
未验证
```

- [ ] **Step 4: Run the owner self-check**

Run:

```bash
rg -n "informationDisplayState|displayOwnerId|subjectIdentity|displaySnapshot|fieldSemantics|visibilityPolicy|freshnessState|statusSemantics|actionBinding|copyPolicy|responsivePolicy|a11yPolicy|auditBinding|disabled 表单控件|唯一语义来源|未验证" references/information-display.md
git diff --check -- references/information-display.md
```

Expected: `rg` prints matching lines and `git diff --check` exits 0.

### Task 2: Skill Routing and Summaries

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/information-display.md`.
- Produces: Routing and reader-facing summaries for future Codex agents.

- [ ] **Step 1: Add routing to `SKILL.md`**

Add a route that points detail page, details, information display, description list, key value list, readonly detail, read-only field, info card, summary card, metric card, metadata, basic information, status badge, status tag, field display, copy field, masked value, long text display, audit summary, updated at, created by, and operator tasks to `references/information-display.md`.

- [ ] **Step 2: Update `README.md`**

Add the new owner to the high-level summary, complete-rules link list, and file tree. Mention readonly display boundaries, field semantics, empty/unknown/no-permission distinction, status and metric semantics, permissions, copy, audit, and mobile adaptation responsibilities.

- [ ] **Step 3: Update `HANDOFF.md`**

Add a handoff subsection titled `信息展示与详情页` with concise bullets explaining the new owner, key hard rules, and the reference link.

- [ ] **Step 4: Run routing self-check**

Run:

```bash
rg -n "information-display|信息展示与详情页|详情页|描述列表|指标卡|status badge|metric card|read-only field|audit summary" SKILL.md README.md HANDOFF.md
git diff --check -- SKILL.md README.md HANDOFF.md
```

Expected: `rg` prints matching lines and `git diff --check` exits 0.

### Task 3: Static Audit and Evidence

**Files:**
- Create: `docs/testing/information-display/information-display-audit.rb`
- Create: `docs/testing/information-display/red-summary.md`
- Create: `docs/testing/information-display/green-summary.md`

**Interfaces:**
- Consumes: `references/information-display.md`, `SKILL.md`, `README.md`, and `HANDOFF.md`.
- Produces: A repeatable audit command and evidence documents.

- [ ] **Step 1: Add the Ruby audit**

Create `docs/testing/information-display/information-display-audit.rb` that:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/information-display.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/information-display/green-summary.md")
RED = File.join(ROOT, "docs/testing/information-display/red-summary.md")
```

Then define owner, route, README, HANDOFF, evidence, and project-leak checks using exact strings from Task 1 and Task 2. Add `--mutations` mode that removes one required string per mutation and asserts the audit fails.

- [ ] **Step 2: Add red evidence**

Create `docs/testing/information-display/red-summary.md` explaining that deleting required owner strings, route keywords, summary links, or adding project-specific terms makes the audit fail.

- [ ] **Step 3: Add green evidence**

Create `docs/testing/information-display/green-summary.md` explaining that the full owner, route, summaries, mutation checks, Markdown link check, and `git diff --check` pass.

- [ ] **Step 4: Run audit**

Run:

```bash
ruby docs/testing/information-display/information-display-audit.rb --mutations
git diff --check -- docs/testing/information-display/information-display-audit.rb docs/testing/information-display/red-summary.md docs/testing/information-display/green-summary.md
```

Expected: audit exits 0 and `git diff --check` exits 0.

### Task 4: Integration Verification and Commit

**Files:**
- Verify: all files touched in Tasks 1-3.

**Interfaces:**
- Consumes: All generated docs and audits.
- Produces: A committed, pushed update on `main`.

- [ ] **Step 1: Run focused audits**

Run:

```bash
ruby docs/testing/information-display/information-display-audit.rb --mutations
ruby docs/testing/admin-console/admin-console-audit.rb --mutations
ruby docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
ruby docs/testing/buttons/buttons-audit.rb --mutations
```

Expected: all commands exit 0.

- [ ] **Step 2: Run maintained owner audit set**

Run:

```bash
for f in \
  docs/testing/information-display/information-display-audit.rb \
  docs/testing/date-time-ranges/date-time-ranges-audit.rb \
  docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb \
  docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb \
  docs/testing/risk-actions/risk-actions-audit.rb \
  docs/testing/navigation-routing/navigation-routing-audit.rb \
  docs/testing/global-feedback/global-feedback-audit.rb \
  docs/testing/feedback-states/feedback-states-audit.rb \
  docs/testing/query-filters/query-filters-audit.rb \
  docs/testing/uploads-imports/uploads-imports-audit.rb \
  docs/testing/adoption/adoption-audit.rb \
  docs/testing/buttons/buttons-audit.rb \
  docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb \
  docs/testing/admin-console/admin-console-audit.rb
do
  ruby "$f" --mutations
done
```

Expected: all maintained owner audits exit 0. Do not include older `docs/testing/data-tables/attempt-*` audits in this all-owner loop because they are historical failed attempts.

- [ ] **Step 3: Run Markdown and whitespace checks**

Run:

```bash
ruby -e 'Dir["**/*.md"].each { |path| File.readlines(path).each_with_index { |line, idx| line.scan(/\]\(([^)]+)\)/).flatten.each { |href| next if href.start_with?("http", "#", "/"); target = File.expand_path(href.split("#", 2).first, File.dirname(path)); raise "missing link #{path}:#{idx + 1} -> #{href}" unless File.exist?(target) } } }; puts "markdown relative links ok"'
git diff --check
```

Expected: Markdown link command prints `markdown relative links ok` and `git diff --check` exits 0.

- [ ] **Step 4: Commit and push**

Run:

```bash
git add SKILL.md README.md HANDOFF.md references/information-display.md docs/testing/information-display docs/superpowers/plans/2026-07-29-information-display-interaction-standards.md
git commit -m "docs: 新增信息展示交互规范"
git push origin main
```

Expected: commit succeeds and `origin/main` receives the new commits.
