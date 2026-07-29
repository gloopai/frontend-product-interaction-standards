# Wizards Steppers Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class wizard, stepper, multi-step form, configuration flow, review step, draft recovery, and final submission interaction owner to the frontend product interaction standards.

**Architecture:** Create one focused owner file at `references/wizards-steppers.md`, route matching tasks from `SKILL.md`, summarize the new owner in `README.md` and `HANDOFF.md`, and protect the contract with a Ruby static audit plus red/green evidence documents.

**Tech Stack:** Markdown documentation, Ruby static audit, Git.

## Global Constraints

- Keep this generic to the interaction standards skill; do not bind rules to `fex-admin`, `gloopai`, `story`, `dev-ops`, `token-api`, or any current project implementation.
- Wizard rules cover multi-step flow state, not individual field validation, risk confirmation wording, upload internals, or route history internals.
- Every wizard must declare a flow owner, step registry, current step, step states, step drafts, committed step values, cross-step validation, progress policy, review snapshot, submit snapshot, async task binding, exit policy, responsive policy, and accessibility policy.
- Step drafts, committed step values, review snapshots, and submit snapshots must be separate.
- Upstream changes must invalidate or recompute downstream steps, previews, preflight results, costs, permission checks, and summaries.
- Final submission must read only a still-valid review or submit snapshot, never an actively edited draft.
- Mobile adaptations may regroup steps but must not remove progress, step errors, previous/next, save/discard draft, review, cancel, result receipt, or recovery.
- Runtime UI checks remain unverified by this documentation task and must be labelled as such.

---

### Task 1: Owner Reference

**Files:**
- Create: `references/wizards-steppers.md`

**Interfaces:**
- Consumes: Design from `docs/superpowers/specs/2026-07-29-wizards-steppers-interaction-standards-design.md`.
- Produces: A wizard/stepper owner that `SKILL.md`, `README.md`, `HANDOFF.md`, and the audit can reference.

- [ ] **Step 1: Create the owner file**

Add `references/wizards-steppers.md` with sections for scope, required `wizardState`, step states, navigation, drafts and save/resume, cross-step validation, review and final submit, results and recovery, permissions, responsive adaptation, accessibility, lifecycle binding, owner relationships, and completion checks.

- [ ] **Step 2: Include the required state fields**

Ensure the owner explicitly lists `wizardOwnerId`, `flowKind`, `stepRegistry`, `currentStepId`, `stepStates`, `stepDrafts`, `committedStepValues`, `crossStepValidation`, `progressPolicy`, `reviewSnapshot`, `submitSnapshot`, `asyncTaskBinding`, `exitPolicy`, `responsivePolicy`, and `a11yPolicy`.

- [ ] **Step 3: Include hard rules**

Ensure the owner includes these exact contract ideas:

```text
wizardState
每个步骤必须有稳定 ID、标题、进入条件、完成条件和错误归属
上一步、下一步、跳过、直接跳转、保存草稿、取消和完成必须是不同意图
`stepDrafts`、`committedStepValues`、`reviewSnapshot` 和 `submitSnapshot` 必须分离
恢复草稿必须重新校验权限、依赖、选项有效性、文件引用、时间范围和业务版本
上游步骤变化后，依赖它的后续步骤、预检、预览、费用、权限、导出范围和确认摘要必须失效或重算
最终提交只能读取仍有效的 `reviewSnapshot` / `submitSnapshot`，不得读取正在编辑的草稿
完成状态必须区分成功、部分成功、失败、冲突、未知、异步处理中、已取消和过期
取消客户端流程不等于取消服务端任务
移动端不得删除步骤标题、当前进度、步骤错误、上一步、下一步、保存/放弃草稿、复核页、取消路径、结果回执或恢复入口
未验证
```

- [ ] **Step 4: Run the owner self-check**

Run:

```bash
rg -n "wizardState|wizardOwnerId|flowKind|stepRegistry|currentStepId|stepStates|stepDrafts|committedStepValues|crossStepValidation|progressPolicy|reviewSnapshot|submitSnapshot|asyncTaskBinding|exitPolicy|responsivePolicy|a11yPolicy|取消客户端流程不等于取消服务端任务|未验证" references/wizards-steppers.md
git diff --check -- references/wizards-steppers.md
```

Expected: `rg` prints matching lines and `git diff --check` exits 0.

### Task 2: Skill Routing and Summaries

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/wizards-steppers.md`.
- Produces: Routing and reader-facing summaries for future Codex agents.

- [ ] **Step 1: Add routing to `SKILL.md`**

Add a route that points wizard, stepper, multi-step form, setup wizard, create wizard, import wizard, publish flow, previous step, next step, skip step, save draft, resume draft, review step, confirmation step, preview step, finish step, flow result, cross-step validation, and step error tasks to `references/wizards-steppers.md`.

- [ ] **Step 2: Update `README.md`**

Add the new owner to the high-level summary, complete-rules link list, and file tree. Mention step state, navigation intent, draft/review/submit snapshots, cross-step invalidation, final submission, async results, permissions, accessibility, and mobile adaptation responsibilities.

- [ ] **Step 3: Update `HANDOFF.md`**

Add a handoff subsection titled `分步流程与配置向导` with concise bullets explaining the new owner, key hard rules, and the reference link.

- [ ] **Step 4: Run routing self-check**

Run:

```bash
rg -n "wizards-steppers|分步流程与配置向导|配置向导|步骤条|保存草稿|复核页|wizard|stepper|multi-step form|save draft|resume draft|cross-step validation" SKILL.md README.md HANDOFF.md
git diff --check -- SKILL.md README.md HANDOFF.md
```

Expected: `rg` prints matching lines and `git diff --check` exits 0.

### Task 3: Static Audit and Evidence

**Files:**
- Create: `docs/testing/wizards-steppers/wizards-steppers-audit.rb`
- Create: `docs/testing/wizards-steppers/red-summary.md`
- Create: `docs/testing/wizards-steppers/green-summary.md`

**Interfaces:**
- Consumes: `references/wizards-steppers.md`, `SKILL.md`, `README.md`, and `HANDOFF.md`.
- Produces: A repeatable audit command and evidence documents.

- [ ] **Step 1: Add the Ruby audit**

Create `docs/testing/wizards-steppers/wizards-steppers-audit.rb` that defines owner, route, README, HANDOFF, evidence, and project-leak checks using exact strings from Task 1 and Task 2. Add `--mutations` mode that removes one required string per mutation and asserts the audit fails.

- [ ] **Step 2: Add red evidence**

Create `docs/testing/wizards-steppers/red-summary.md` explaining that deleting required owner strings, route keywords, summary links, or adding project-specific terms makes the audit fail.

- [ ] **Step 3: Add green evidence**

Create `docs/testing/wizards-steppers/green-summary.md` explaining that the full owner, route, summaries, mutation checks, Markdown link check, and `git diff --check` pass.

- [ ] **Step 4: Run audit**

Run:

```bash
ruby docs/testing/wizards-steppers/wizards-steppers-audit.rb --mutations
git diff --check -- docs/testing/wizards-steppers/wizards-steppers-audit.rb docs/testing/wizards-steppers/red-summary.md docs/testing/wizards-steppers/green-summary.md
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
ruby docs/testing/wizards-steppers/wizards-steppers-audit.rb --mutations
ruby docs/testing/forms/forms-audit.rb --mutations || true
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations
```

Expected: the wizard audit and maintained adjacent audits exit 0. If no maintained forms audit exists, the command reports that absence and is not counted as pass.

- [ ] **Step 2: Run maintained owner audit set**

Run:

```bash
for f in \
  docs/testing/wizards-steppers/wizards-steppers-audit.rb \
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
git add SKILL.md README.md HANDOFF.md references/wizards-steppers.md docs/testing/wizards-steppers docs/superpowers/plans/2026-07-29-wizards-steppers-interaction-standards.md
git commit -m "docs: 新增分步流程交互规范"
git push origin main
```

Expected: commit succeeds and `origin/main` receives the new commits.
