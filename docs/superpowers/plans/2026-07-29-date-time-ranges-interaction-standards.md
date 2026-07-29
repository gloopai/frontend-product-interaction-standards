# Date Time Ranges Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class date, time, date range, preset range, and timezone interaction owner to the frontend product interaction standards.

**Architecture:** Create one focused owner file at `references/date-time-ranges.md`, route matching tasks from `SKILL.md`, summarize the new owner in `README.md` and `HANDOFF.md`, and protect the contract with a Ruby static audit plus red/green evidence documents.

**Tech Stack:** Markdown documentation, Ruby static audit, Git.

## Global Constraints

- Keep this generic to the interaction standards skill; do not bind rules to `fex-admin`, `gloopai`, `story`, `dev-ops`, `token-api`, or any current project implementation.
- Date/time values must declare display timezone, storage/request timezone, boundary semantics, and granularity.
- Date/time ranges should use `[start, end)` unless a stricter owner explicitly declares another boundary.
- Preset ranges such as today, yesterday, this week, this month, last 7 days, and last 30 days must freeze their application anchor.
- Mobile adaptations may change the surface but must not delete clear, reset, presets, error copy, timezone copy, or submit boundaries.
- Runtime UI checks remain unverified by this documentation task and must be labelled as such.

---

### Task 1: Owner Reference

**Files:**
- Create: `references/date-time-ranges.md`

**Interfaces:**
- Consumes: Design from `docs/superpowers/specs/2026-07-29-date-time-ranges-interaction-standards-design.md`.
- Produces: A date-time owner that `SKILL.md`, `README.md`, `HANDOFF.md`, and the audit can reference.

- [ ] **Step 1: Create the owner file**

Add `references/date-time-ranges.md` with sections for scope, required `dateTimeState`, state separation, range boundaries, presets, timezone and DST, validation, URL serialization, report/export/audit snapshots, accessibility, mobile adaptation, lifecycle binding, interaction with existing owners, and verification scenarios.

- [ ] **Step 2: Include the required state fields**

Ensure the owner explicitly lists `dateTimeOwnerId`, `valueKind`, `inputMode`, `displayTimezone`, `storageTimezone`, `rangeBoundary`, `granularity`, `presetPolicy`, `relativeAnchor`, `validationState`, `urlSerialization`, `requestBinding`, and `localePolicy`.

- [ ] **Step 3: Include hard rules**

Ensure the owner includes these exact contract ideas:

```text
日期时间值必须声明展示时区、存储/请求时区、边界语义和粒度
不得使用含糊本地字符串
范围推荐使用 `[start, end)`
快捷范围必须冻结应用时的 `relativeAnchor`
今天、昨天、本周、本月、近 7 天和近 30 天不得在同一已应用查询中随时间漂移
部分范围不得触发查询
只有明确 `urlSafe` 的日期时间值可以进入 URL
报表、导出和审计必须携带范围快照、时区、数据延迟和刷新时间
移动端不得删除清空、重置、快捷范围、错误说明或时区说明
未验证
```

- [ ] **Step 4: Run the owner self-check**

Run:

```bash
rg -n "dateTimeState|displayTimezone|storageTimezone|relativeAnchor|\\[start, end\\)|DST|urlSafe|未验证" references/date-time-ranges.md
git diff --check -- references/date-time-ranges.md
```

Expected: `rg` prints matching lines and `git diff --check` exits 0.

### Task 2: Skill Routing and Summaries

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/date-time-ranges.md`.
- Produces: Routing and reader-facing summaries for future Codex agents.

- [ ] **Step 1: Add routing to `SKILL.md`**

Add a route that points date, time, date range, datetime, timezone, preset range, relative range, today, yesterday, this week, this month, last 7 days, last 30 days, start date, end date, expiry, refresh time, data latency, audit time, and export range tasks to `references/date-time-ranges.md`.

- [ ] **Step 2: Update `README.md`**

Add the new owner to the high-level summary, complete-rules link list, and file tree. Mention the snapshot, timezone, boundary, preset anchor, URL, report/export/audit, and mobile adaptation responsibilities.

- [ ] **Step 3: Update `HANDOFF.md`**

Add a handoff subsection titled `日期时间与时区` with concise bullets explaining the new owner, key hard rules, and the reference link.

- [ ] **Step 4: Run routing self-check**

Run:

```bash
rg -n "date-time-ranges|日期时间与时区|时间范围|timezone|last 7 days|data latency|export range" SKILL.md README.md HANDOFF.md
git diff --check -- SKILL.md README.md HANDOFF.md
```

Expected: `rg` prints matching lines and `git diff --check` exits 0.

### Task 3: Static Audit and Evidence

**Files:**
- Create: `docs/testing/date-time-ranges/date-time-ranges-audit.rb`
- Create: `docs/testing/date-time-ranges/red-summary.md`
- Create: `docs/testing/date-time-ranges/green-summary.md`

**Interfaces:**
- Consumes: `references/date-time-ranges.md`, `SKILL.md`, `README.md`, and `HANDOFF.md`.
- Produces: A repeatable audit command and evidence documents.

- [ ] **Step 1: Add the Ruby audit**

Create `docs/testing/date-time-ranges/date-time-ranges-audit.rb` that:

```ruby
require "tmpdir"
require "fileutils"

ROOT = File.expand_path("../../..", __dir__)

def read(path)
  File.read(File.join(ROOT, path))
end

def assert_includes!(content, needle, label)
  raise "missing #{label}: #{needle}" unless content.include?(needle)
end

def assert_not_includes!(content, needle, label)
  raise "forbidden #{label}: #{needle}" if content.include?(needle)
end
```

Then define owner, route, README, HANDOFF, and project-leak checks using exact strings from Task 1 and Task 2. Add `--mutations` mode that copies the repo to a temporary directory, removes one required string per mutation, and asserts the audit fails.

- [ ] **Step 2: Add red evidence**

Create `docs/testing/date-time-ranges/red-summary.md` explaining that deleting required owner strings, route keywords, summary links, or adding project-specific terms makes the audit fail.

- [ ] **Step 3: Add green evidence**

Create `docs/testing/date-time-ranges/green-summary.md` explaining that the full owner, route, summaries, mutation checks, Markdown link check, and `git diff --check` pass.

- [ ] **Step 4: Run audit**

Run:

```bash
ruby docs/testing/date-time-ranges/date-time-ranges-audit.rb --mutations
git diff --check -- docs/testing/date-time-ranges/date-time-ranges-audit.rb docs/testing/date-time-ranges/red-summary.md docs/testing/date-time-ranges/green-summary.md
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
ruby docs/testing/date-time-ranges/date-time-ranges-audit.rb --mutations
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
ruby docs/testing/admin-console/admin-console-audit.rb --mutations
ruby docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb --mutations
ruby docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb --mutations
```

Expected: all commands exit 0.

- [ ] **Step 2: Run maintained owner audit set**

Run:

```bash
for f in \
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
git add SKILL.md README.md HANDOFF.md references/date-time-ranges.md docs/testing/date-time-ranges docs/superpowers/plans/2026-07-29-date-time-ranges-interaction-standards.md
git commit -m "docs: 新增日期时间与时区交互规范"
git push origin main
```

Expected: commit succeeds and `origin/main` receives the new commits.
