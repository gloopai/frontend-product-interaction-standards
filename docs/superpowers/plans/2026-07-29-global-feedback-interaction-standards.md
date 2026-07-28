# Global Feedback Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class global feedback interaction owner to the frontend product interaction standards Skill.

**Architecture:** Create one focused reference file for Toast, Snackbar, Message, Alert, Banner, Notification, Inline Feedback, and operation/result receipts. Route it from `SKILL.md`, summarize it from README/HANDOFF, and add a Ruby audit plus RED/GREEN evidence.

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- The new owner must be project-agnostic and must not include business-project-specific pages, modules, routes, frameworks, or component libraries.
- Detailed rules live only in `references/global-feedback.md`; `SKILL.md`, README, and HANDOFF only route or summarize.
- Global-feedback rules are hard acceptance criteria when their route triggers.
- Runtime browser, screen reader, touch-device, and real-component checks must be marked unverified unless actually executed.
- Do not modify business repositories in this plan.

---

### Task 1: Add Global Feedback owner

**Files:**
- Create: `references/global-feedback.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-global-feedback-interaction-standards-design.md`
- Produces: rule families `GF-SCOPE-*`, `GF-STATE-*`, `GF-CHANNEL-*`, `GF-TOAST-*`, `GF-LIFE-*`, `GF-STACK-*`, `GF-RECOVERY-*`, `GF-PERM-*`, `GF-A11Y-*`

- [ ] **Step 1: Write the owner file**

Create `references/global-feedback.md` with these sections:

```markdown
# 全局反馈与通知交互规范

## 范围
## 与组件 owner 的关系
## 场景与状态模型
## GF-SCOPE 范围和术语
## GF-STATE 消息状态与结果绑定
## GF-CHANNEL 通道选择
## GF-TOAST Toast 红线
## GF-LIFE 生命周期、关闭和持久性
## GF-STACK 去重、堆叠和迟到结果
## GF-RECOVERY 恢复入口
## GF-PERM 权限、安全和敏感信息
## GF-A11Y 可访问性与移动端
## 可执行验收检查
```

- [ ] **Step 2: Include required state contract**

Ensure `feedbackMessageState` contains `messageId`, `channel`, `severity`, `sourceOwner`, `resultBinding`, `durationPolicy`, `dismissPolicy`, `announcementPolicy`, `dedupeKey`, `sensitiveBoundary`, and `recoveryActions`.

- [ ] **Step 3: Include hard prohibitions**

Owner must prohibit: `showToast(text)` as the model, Toast-only dangerous operations, Toast-only partial success, Toast-only permission failure, auto-disappearing task receipts, closing Toast as server cancellation, missing dedupe/stacking, sensitive leakage, and mobile obstruction of core actions.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add references/global-feedback.md
git commit -m "docs: 新增全局反馈交互规范"
```

### Task 2: Route and summarize the new owner

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/global-feedback.md`
- Produces: automatic routing from toast/alert/notification keywords to the owner

- [ ] **Step 1: Update `SKILL.md` routing**

Add a route requiring complete reading of `references/global-feedback.md` for Chinese and English global feedback keywords.

- [ ] **Step 2: Update README summary**

Add one bullet to “当前规范” and include the README link text `全局反馈与通知交互规范` pointing to `references/global-feedback.md` in the complete-rules sentence.

- [ ] **Step 3: Update HANDOFF summary**

Add a short “全局反馈与通知” subsection under “已完成规范” and add `references/global-feedback.md` to the current structure.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add SKILL.md README.md HANDOFF.md
git commit -m "docs: 接入全局反馈规范路由"
```

### Task 3: Add audit and evidence

**Files:**
- Create: `docs/testing/global-feedback/global-feedback-audit.rb`
- Create: `docs/testing/global-feedback/red-summary.md`
- Create: `docs/testing/global-feedback/green-summary.md`

**Interfaces:**
- Consumes: `references/global-feedback.md`, `SKILL.md`, `README.md`, `HANDOFF.md`
- Produces: command `ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations`

- [ ] **Step 1: Write the Ruby audit**

The audit must verify required state fields, route terms, summary links, Toast-only prohibitions, result binding, recovery actions, sensitive boundary, mobile obstruction rules, and unverified runtime disclosure.

- [ ] **Step 2: Add mutation checks**

The `--mutations` mode must fail when removing the message state model, result binding, Toast-only danger/partial/permission/task prohibitions, close-as-cancel boundary, dedupe/stacking, sensitive protection, mobile safe-area rule, and runtime unverified disclosure.

- [ ] **Step 3: Add RED/GREEN summaries**

`red-summary.md` lists the negative cases. `green-summary.md` lists the behaviors proved by the current owner and audit.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add docs/testing/global-feedback
git commit -m "test: 增加全局反馈规范审计"
```

### Task 4: Verify final integration

**Files:**
- Inspect all modified files.

**Interfaces:**
- Consumes: all outputs from Tasks 1-3
- Produces: final local verification evidence

- [ ] **Step 1: Run global-feedback audit**

Run:

```bash
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
```

Expected: all mutation checks print expected failures and final pass.

- [ ] **Step 2: Run existing high-overlap audits**

Run:

```bash
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
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
git commit -m "docs: 完成全局反馈规范验证"
```

If there are no file changes, do not create an empty commit.
