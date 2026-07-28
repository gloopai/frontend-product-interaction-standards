# Feedback States Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class feedback state and state-surface owner to the frontend product interaction standards Skill.

**Architecture:** Create one focused reference file for loading, empty, error, stale, permission, partial-result, and recovery states. Route it from `SKILL.md`, summarize it from README/HANDOFF, and add a Ruby audit plus RED/GREEN evidence.

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- The new owner must be project-agnostic and must not include business-project-specific pages, modules, routes, frameworks, or component libraries.
- Detailed rules live only in `references/feedback-states.md`; `SKILL.md`, README, and HANDOFF only route or summarize.
- Feedback-state rules are hard acceptance criteria when their route triggers.
- Runtime browser, screen reader, touch-device, and real-component checks must be marked unverified unless actually executed.
- Do not modify business repositories in this plan.

---

### Task 1: Add Feedback States owner

**Files:**
- Create: `references/feedback-states.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-feedback-states-interaction-standards-design.md`
- Produces: rule families `FS-SCOPE-*`, `FS-STATE-*`, `FS-LOAD-*`, `FS-EMPTY-*`, `FS-ERROR-*`, `FS-RECOVERY-*`, `FS-PERM-*`, `FS-A11Y-*`, `FS-RSP-*`

- [ ] **Step 1: Write the owner file**

Create `references/feedback-states.md` with these sections:

```markdown
# 反馈状态与状态承载规范

## 范围
## 与组件 owner 的关系
## 场景与状态模型
## FS-SCOPE 范围和术语
## FS-STATE 状态 owner、模型与优先级
## FS-LOAD Loading、Skeleton 和刷新
## FS-EMPTY Empty、Zero Results 和下一步
## FS-ERROR Error、Stale、Partial 和 Unknown
## FS-RECOVERY 恢复入口
## FS-PERM 权限、安全和敏感信息
## FS-A11Y 可访问性与公告
## FS-RSP 响应式与移动端
## 可执行验收检查
```

- [ ] **Step 2: Include required state contract**

Ensure `feedbackState` contains `ownerId`, `surfaceKind`, `phase`, `dataPresence`, `errorKind`, `permissionScope`, `stale`, `partial`, `messageOwner`, `recoveryActions`, `announcementPolicy`, and `sensitiveBoundary`.

- [ ] **Step 3: Include hard prohibitions**

Owner must prohibit: three-boolean loading/error/empty-only state, skeleton fake actions, “暂无数据” for all empty cases, Toast-only errors/results, refresh failure clearing old content, permission leakage, invalid CTAs for users without ability, duplicate announcements, and mobile deletion of recovery actions.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add references/feedback-states.md
git commit -m "docs: 新增反馈状态与状态承载规范"
```

### Task 2: Route and summarize the new owner

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/feedback-states.md`
- Produces: automatic routing from empty/loading/error/stale/retry keywords to the owner

- [ ] **Step 1: Update `SKILL.md` routing**

Add a route requiring complete reading of `references/feedback-states.md` for Chinese and English feedback-state keywords:

```markdown
- 涉及空状态、空态、暂无数据、无结果、筛选无结果、加载、加载中、骨架屏、placeholder、错误状态、刷新失败、加载失败、重试、过期数据、部分结果、无权限状态、只读状态，或 empty state、zero results、no data、loading state、skeleton、placeholder、error state、refresh error、load error、retry state、stale data、partial result、permission denied state、read-only state 时，必须完整读取 `references/feedback-states.md`。
```

- [ ] **Step 2: Update README summary**

Add one bullet to “当前规范” and include the README link text `反馈状态与状态承载规范` pointing to `references/feedback-states.md` in the complete-rules sentence.

- [ ] **Step 3: Update HANDOFF summary**

Add a short “反馈状态与状态承载” subsection under “已完成规范” and add `references/feedback-states.md` to the current structure.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add SKILL.md README.md HANDOFF.md
git commit -m "docs: 接入反馈状态规范路由"
```

### Task 3: Add audit and evidence

**Files:**
- Create: `docs/testing/feedback-states/feedback-states-audit.rb`
- Create: `docs/testing/feedback-states/red-summary.md`
- Create: `docs/testing/feedback-states/green-summary.md`

**Interfaces:**
- Consumes: `references/feedback-states.md`, `SKILL.md`, `README.md`, `HANDOFF.md`
- Produces: command `ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations`

- [ ] **Step 1: Write the Ruby audit**

The audit must verify:

```ruby
REQUIRED_OWNER_TERMS = [
  "feedbackState",
  "ownerId",
  "surfaceKind",
  "phase",
  "dataPresence",
  "errorKind",
  "permissionScope",
  "stale",
  "partial",
  "messageOwner",
  "recoveryActions",
  "announcementPolicy",
  "sensitiveBoundary",
  "不能只散落在 `loading`、`error`、`empty` 三个布尔值里",
  "Skeleton 不得包含可操作假数据",
  "空状态不能用“暂无数据”糊住所有情况",
  "Toast 不能作为唯一错误或结果回执",
  "刷新失败时保留旧内容",
  "无权状态不得泄露对象名称、数量、字段",
  "移动端不得删除主要恢复入口",
  "未验证"
]
```

It must also verify route and README/HANDOFF links.

- [ ] **Step 2: Add mutation checks**

The `--mutations` mode must fail when removing the state model, skeleton fake-action prohibition, empty-state distinction, Toast-only prohibition, refresh-failure preservation, permission leakage protection, recovery actions, mobile recovery requirement, and runtime unverified disclosure.

- [ ] **Step 3: Add RED/GREEN summaries**

`red-summary.md` lists the negative cases. `green-summary.md` lists the behaviors proved by the current owner and audit.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add docs/testing/feedback-states
git commit -m "test: 增加反馈状态规范审计"
```

### Task 4: Verify final integration

**Files:**
- Inspect all modified files.

**Interfaces:**
- Consumes: all outputs from Tasks 1-3
- Produces: final local verification evidence

- [ ] **Step 1: Run feedback-states audit**

Run:

```bash
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
```

Expected: all mutation checks print expected failures and final pass.

- [ ] **Step 2: Run existing high-overlap audits**

Run:

```bash
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/admin-console/admin-console-audit.rb --mutations
```

Expected: each audit passes with its expected mutation output.

- [ ] **Step 3: Run Markdown link and whitespace checks**

Run repository Markdown relative-link check and:

```bash
git diff --check
```

Expected: both pass.

- [ ] **Step 4: Commit remaining verification-only edits if any**

If Task 4 caused documentation changes, commit them with:

```bash
git add <changed-files>
git commit -m "docs: 完成反馈状态规范验证"
```

If there are no file changes, do not create an empty commit.
