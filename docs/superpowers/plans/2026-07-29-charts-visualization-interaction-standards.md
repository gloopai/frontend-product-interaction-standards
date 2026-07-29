# Charts Visualization Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class chart and data visualization interaction owner to the frontend product interaction standards.

**Architecture:** Create one focused owner file at `references/charts-visualization.md`, route matching tasks from `SKILL.md`, summarize the new owner in `README.md` and `HANDOFF.md`, and protect the contract with a Ruby static audit plus red/green evidence documents.

**Tech Stack:** Markdown documentation, Ruby static audit, Git.

## Global Constraints

- Keep this generic to the interaction standards skill; do not bind rules to `fex-admin`, `gloopai`, `story`, `dev-ops`, `token-api`, or any current project implementation.
- Chart rules cover visual data presentation semantics, not a specific charting library, BI editor, or business metric system.
- Every chart must bind a data snapshot, metric definition, dimensions, encodings, axes, legend, interaction policy, feedback state, responsive policy, and accessibility policy.
- Color, hover tooltip, animation, icon, size, or shape must never be the only semantic source.
- Non-zero baselines, truncated axes, logarithmic scales, dual axes, percent stacking, and normalization must be explicitly marked.
- Chart interactions such as drilldown, brush, zoom, legend toggle, export, and linked filtering must be explicit capabilities.
- Mobile adaptations may substitute a chart with summaries or details but must not remove title, metric definition, unit, legend/series meaning, status, error/permission copy, data latency, refresh time, export/details entry, or recovery.
- Runtime UI checks remain unverified by this documentation task and must be labelled as such.

---

### Task 1: Owner Reference

**Files:**
- Create: `references/charts-visualization.md`

**Interfaces:**
- Consumes: Design from `docs/superpowers/specs/2026-07-29-charts-visualization-interaction-standards-design.md`.
- Produces: A chart visualization owner that `SKILL.md`, `README.md`, `HANDOFF.md`, and the audit can reference.

- [ ] **Step 1: Create the owner file**

Add `references/charts-visualization.md` with sections for scope, required `chartState`, data snapshots, metric and dimension binding, visual encoding, axes, legends, tooltips, interactions, feedback states, export/details, responsive adaptation, accessibility, lifecycle binding, owner relationships, and completion checks.

- [ ] **Step 2: Include the required state fields**

Ensure the owner explicitly lists `chartOwnerId`, `chartKind`, `dataSnapshot`, `metricBinding`, `dimensionBinding`, `encodingPolicy`, `axisPolicy`, `legendPolicy`, `tooltipPolicy`, `interactionPolicy`, `feedbackState`, `responsivePolicy`, and `a11yPolicy`.

- [ ] **Step 3: Include hard rules**

Ensure the owner includes these exact contract ideas:

```text
chartState
每个图表必须声明 `chartState.dataSnapshot` 与 `metricBinding`
图表必须展示或可达地说明指标名、口径、单位、时间范围、时区、数据延迟、刷新时间和权限范围
颜色不得作为唯一语义来源
图表 tooltip 不能承载唯一必读信息
坐标轴必须声明字段、单位、刻度格式和排序规则
非零基线、截断轴、对数轴、双轴、百分比堆叠和归一化必须显式标注
Hover/highlight、legend toggle、drilldown、brush、zoom、联动筛选、导出和查看明细必须在 `interactionPolicy` 中声明
图表必须区分 loading、empty、zero-results、partial、stale、refresh-error、permission-denied 和 metric-unavailable
无权限状态不得泄露 series 名称、数量、对象名、筛选值、内部 ID 或旧缓存
移动端不得删除图表标题、口径、单位、图例/series 含义、状态说明、错误/权限说明、数据延迟、刷新时间、导出/明细入口和恢复路径
未验证
```

- [ ] **Step 4: Run the owner self-check**

Run:

```bash
rg -n "chartState|chartOwnerId|chartKind|dataSnapshot|metricBinding|dimensionBinding|encodingPolicy|axisPolicy|legendPolicy|tooltipPolicy|interactionPolicy|feedbackState|responsivePolicy|a11yPolicy|颜色不得作为唯一语义来源|图表 tooltip 不能承载唯一必读信息|未验证" references/charts-visualization.md
git diff --check -- references/charts-visualization.md
```

Expected: `rg` prints matching lines and `git diff --check` exits 0.

### Task 2: Skill Routing and Summaries

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/charts-visualization.md`.
- Produces: Routing and reader-facing summaries for future Codex agents.

- [ ] **Step 1: Add routing to `SKILL.md`**

Add a route that points chart, visualization, data visualization, dashboard chart, report chart, line chart, bar chart, column chart, area chart, pie chart, donut chart, scatter plot, bubble chart, funnel chart, ranking chart, heatmap, combo chart, sparkline, legend, axis, data label, reference line, threshold line, chart tooltip, chart drilldown, chart interaction, chart export, and view details tasks to `references/charts-visualization.md`.

- [ ] **Step 2: Update `README.md`**

Add the new owner to the high-level summary, complete-rules link list, and file tree. Mention chart data snapshots, metrics, dimensions, encodings, axes, legends, tooltips, interactions, empty/error states, permissions, export/details, accessibility, and mobile adaptation responsibilities.

- [ ] **Step 3: Update `HANDOFF.md`**

Add a handoff subsection titled `图表与可视化` with concise bullets explaining the new owner, key hard rules, and the reference link.

- [ ] **Step 4: Run routing self-check**

Run:

```bash
rg -n "charts-visualization|图表与可视化|图表|可视化|图例|坐标轴|chart tooltip|chart drilldown|chart export|data visualization" SKILL.md README.md HANDOFF.md
git diff --check -- SKILL.md README.md HANDOFF.md
```

Expected: `rg` prints matching lines and `git diff --check` exits 0.

### Task 3: Static Audit and Evidence

**Files:**
- Create: `docs/testing/charts-visualization/charts-visualization-audit.rb`
- Create: `docs/testing/charts-visualization/red-summary.md`
- Create: `docs/testing/charts-visualization/green-summary.md`

**Interfaces:**
- Consumes: `references/charts-visualization.md`, `SKILL.md`, `README.md`, and `HANDOFF.md`.
- Produces: A repeatable audit command and evidence documents.

- [ ] **Step 1: Add the Ruby audit**

Create `docs/testing/charts-visualization/charts-visualization-audit.rb` that:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/charts-visualization.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/charts-visualization/green-summary.md")
RED = File.join(ROOT, "docs/testing/charts-visualization/red-summary.md")
```

Then define owner, route, README, HANDOFF, evidence, and project-leak checks using exact strings from Task 1 and Task 2. Add `--mutations` mode that removes one required string per mutation and asserts the audit fails.

- [ ] **Step 2: Add red evidence**

Create `docs/testing/charts-visualization/red-summary.md` explaining that deleting required owner strings, route keywords, summary links, or adding project-specific terms makes the audit fail.

- [ ] **Step 3: Add green evidence**

Create `docs/testing/charts-visualization/green-summary.md` explaining that the full owner, route, summaries, mutation checks, Markdown link check, and `git diff --check` pass.

- [ ] **Step 4: Run audit**

Run:

```bash
ruby docs/testing/charts-visualization/charts-visualization-audit.rb --mutations
git diff --check -- docs/testing/charts-visualization/charts-visualization-audit.rb docs/testing/charts-visualization/red-summary.md docs/testing/charts-visualization/green-summary.md
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
ruby docs/testing/charts-visualization/charts-visualization-audit.rb --mutations
ruby docs/testing/admin-console/admin-console-audit.rb --mutations
ruby docs/testing/information-display/information-display-audit.rb --mutations
ruby docs/testing/date-time-ranges/date-time-ranges-audit.rb --mutations
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
```

Expected: all commands exit 0.

- [ ] **Step 2: Run maintained owner audit set**

Run:

```bash
for f in \
  docs/testing/charts-visualization/charts-visualization-audit.rb \
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
git add SKILL.md README.md HANDOFF.md references/charts-visualization.md docs/testing/charts-visualization docs/superpowers/plans/2026-07-29-charts-visualization-interaction-standards.md
git commit -m "docs: 新增图表可视化交互规范"
git push origin main
```

Expected: commit succeeds and `origin/main` receives the new commits.
