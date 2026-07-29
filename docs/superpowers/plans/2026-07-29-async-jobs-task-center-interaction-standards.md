# 异步任务与任务中心交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增异步任务与任务中心交互规范 owner，并接入 Skill 路由、README、HANDOFF、红绿证据和结构化审计。

**Architecture:** `references/async-jobs-task-center.md` 是唯一事实来源；`SKILL.md` 只负责路由；`README.md` 和 `HANDOFF.md` 只提供摘要与链接；`docs/testing/async-jobs-task-center/` 提供可执行结构化审计和红绿证据。该 owner 与 `uploads-imports.md`、`risk-actions.md`、`global-feedback.md`、`admin-console.md` 组合执行，但不替代它们。

**Tech Stack:** Markdown 文档、Ruby 审计脚本、Git。

## Global Constraints

- 所有用户可见文档使用中文。
- 不引入业务项目特定名称、路径或实现细节。
- 新 owner 必须职责单一，不能复制 `uploads-imports.md`、`risk-actions.md`、`global-feedback.md`、`data-tables.md` 或 `admin-console.md` 的完整规则。
- 必须保留未验证边界：真实浏览器、触摸、键盘、屏幕阅读器、权限变化、轮询/订阅、下载、任务中心和移动端视口未实际执行时，必须明确标为未验证。
- 必须使用 `apply_patch` 编辑文件。
- 每个提交前运行相关审计或最小可证明检查。

---

## File Structure

- Create `references/async-jobs-task-center.md`：异步任务生命周期、任务中心、结果产物、权限复核、取消/重试/未知结果、可访问性和移动端规则的 owner。
- Modify `SKILL.md`：新增 async job / task center 路由。
- Modify `README.md`：在当前规范摘要、完整链接和目录结构中加入异步任务与任务中心。
- Modify `HANDOFF.md`：在当前结构和已完成规范中加入异步任务与任务中心交接摘要。
- Create `docs/testing/async-jobs-task-center/green-summary.md`：正确实现证据。
- Create `docs/testing/async-jobs-task-center/red-summary.md`：错误实现证据。
- Create `docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb`：结构化审计脚本与突变测试。

---

### Task 1: 写 owner 文档

**Files:**
- Create: `references/async-jobs-task-center.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-async-jobs-task-center-interaction-standards-design.md`
- Produces: owner terms consumed by Task 3 audit:
  - `asyncJobState`
  - `jobOwnerId`, `jobId`, `jobKind`, `sourceSurface`, `requestIdentity`, `inputSnapshot`, `jobPhase`, `progressState`, `resultState`, `cancelPolicy`, `retryPolicy`, `artifactState`, `notificationBinding`, `auditBinding`, `permissionBoundary`, `responsivePolicy`
  - `关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回，只能表达客户端关闭或停止等待，不得伪装成服务端任务已取消`
  - `取消请求已发送不等于任务已取消`
  - `未知结果不得伪装成成功或失败`
  - `Toast 和 Notification 只能辅助提醒，不能作为唯一状态、唯一错误、唯一下载入口或唯一恢复路径`
  - `领取、下载、复制、重试和分享前必须复核任务身份、权限版本、租户/工作区、有效期和请求身份`
  - `移动端不得删除任务中心入口、任务状态、进度、取消中、重试、结果领取、错误明细、未知结果说明、权限说明或恢复路径`
  - `未验证`

- [ ] **Step 1: Create owner markdown**

Use `apply_patch` to create `references/async-jobs-task-center.md` with this opening:

```markdown
# 异步任务与任务中心交互规范

适用于 async job、background task、job center、task center、异步任务、后台任务、任务中心、任务详情、任务进度、导入任务、导出任务、批量任务、报表生成、AI 生成、同步任务、取消任务、重跑任务、任务重试、结果领取、错误明细、未知结果和过期任务。本文件是异步任务生命周期、任务中心恢复、跨页面任务状态、任务产物领取、取消/重试语义、权限安全、可访问性和验收的唯一事实来源。
```

- [ ] **Step 2: Add relationship boundaries**

Add a paragraph that routes:

```markdown
文件选择、上传队列、导入预检、字段映射和文件级错误继续执行 [上传与导入交互规范](../../../references/uploads-imports.md)。危险操作确认、风险分级、撤销窗口、取消任务和重跑任务的风险确认继续执行 [危险操作与恢复交互规范](../../../references/risk-actions.md)。Toast、Notification、Alert、Banner 和消息去重继续执行 [全局反馈与通知交互规范](../../../references/global-feedback.md)。表格选择和批量范围继续执行 [数据表格交互规范](../../../references/data-tables.md)。管理台跨页面权限、审计和治理继续执行 [管理台完整治理交互规范](../../../references/admin-console.md)。
```

- [ ] **Step 3: Add `asyncJobState` table**

Include all fields from the Interfaces block. State explicitly:

```markdown
任务状态不能只绑定到按钮 loading、Toast 文案、Notification 标题、表格行文案、局部 `loading` 布尔值或任务中心的一行文本。
```

- [ ] **Step 4: Add lifecycle rules**

Include exact clauses:

```markdown
关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回，只能表达客户端关闭或停止等待，不得伪装成服务端任务已取消。

取消请求已发送不等于任务已取消。必须区分不可取消、可请求取消、取消请求已发送、取消中、服务端已取消、取消失败、已完成无法取消和未知结果。

未知结果不得伪装成成功或失败。
```

- [ ] **Step 5: Add task center, artifacts, permissions, a11y, mobile, disposal**

Cover:

- Task center list/detail required for cross-page or long-running tasks.
- `Toast 和 Notification 只能辅助提醒，不能作为唯一状态、唯一错误、唯一下载入口或唯一恢复路径`.
- Result artifacts and permission recertification using exact phrase from Interfaces.
- Partial success ranges: success, failed, skipped, conflict, unknown.
- Permission no leakage for object names, counts, filenames, error details, IDs, old links.
- A11y: visible text/live region, no color/spinner-only.
- Mobile exact clause from Interfaces.
- Disposal: polling, subscription, timers, late callbacks, focus restoration.

- [ ] **Step 6: Add completion checklist and references**

Checklist must include every exact owner term from Interfaces and require `未验证` for unrun browser/device/permission/download checks.

- [ ] **Step 7: Run owner sanity check**

Run:

```bash
rg -n "asyncJobState|关闭 Dialog、Drawer、Toast、Notification|取消请求已发送不等于任务已取消|未知结果不得伪装成成功或失败|Toast 和 Notification 只能辅助提醒|领取、下载、复制、重试和分享前必须复核|移动端不得删除任务中心入口|未验证" references/async-jobs-task-center.md
git diff --check
```

Expected: all required terms appear; `git diff --check` exits 0.

---

### Task 2: 接入路由、README 和 HANDOFF

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/async-jobs-task-center.md`
- Produces: route and summaries consumed by Task 3 audit.

- [ ] **Step 1: Add Skill route**

Add this route before `uploads-imports.md` or near `admin-console.md`:

```markdown
- 涉及 async job、background task、job center、task center、异步任务、后台任务、任务中心、任务详情、任务进度、任务取消、取消中、重跑任务、任务重试、导入任务、导出任务、批量任务、报表生成、AI 生成、同步任务、结果领取、错误明细、未知结果、过期任务，或 job detail、job progress、cancel job、cancelling、rerun job、retry job、import job、export job、bulk job、report generation、AI generation、sync job、result artifact、error report、unknown result、expired job 时，必须完整读取 `references/async-jobs-task-center.md`。
```

- [ ] **Step 2: Update README current list and summary**

Add “异步任务与任务中心” to the current standards sentence.

Add summary bullet:

```markdown
- 异步任务与任务中心规范约束 async job、导入导出任务、批量任务、报表生成、AI 生成、同步任务的任务身份、进度、取消/重试、未知结果、任务中心恢复、结果产物、权限复核和移动端承载。
```

Add link:

```markdown
[异步任务与任务中心交互规范](../../../references/async-jobs-task-center.md)
```

Add `async-jobs-task-center.md` to the references directory tree.

- [ ] **Step 3: Update HANDOFF**

Add `async-jobs-task-center.md` to the tree.

Add a section:

```markdown
### 异步任务与任务中心

- 已定义 async job、导入导出任务、批量任务、报表生成、AI 生成、同步任务、任务取消、重跑任务和任务中心的首版 owner。
- 关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回，只能表达客户端关闭或停止等待，不得伪装成服务端任务已取消。
- 取消请求已发送不等于任务已取消；未知结果不得伪装成成功或失败。
- Toast 和 Notification 只能辅助提醒，不能作为唯一状态、唯一错误、唯一下载入口或唯一恢复路径。
- 领取、下载、复制、重试和分享前必须复核任务身份、权限版本、租户/工作区、有效期和请求身份。
- 移动端不得删除任务中心入口、任务状态、进度、取消中、重试、结果领取、错误明细、未知结果说明、权限说明或恢复路径。
- 详细规则和可执行验收仅维护在 [异步任务与任务中心交互规范](../../../references/async-jobs-task-center.md)，本交接不重复其状态模型或检查项。
```

- [ ] **Step 4: Run routing sanity check**

Run:

```bash
rg -n "async-jobs-task-center|异步任务与任务中心|async job|任务中心|unknown result" SKILL.md README.md HANDOFF.md
git diff --check
```

Expected: all files show the new owner; `git diff --check` exits 0.

---

### Task 3: 新增红绿证据和审计脚本

**Files:**
- Create: `docs/testing/async-jobs-task-center/green-summary.md`
- Create: `docs/testing/async-jobs-task-center/red-summary.md`
- Create: `docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb`

**Interfaces:**
- Consumes: owner terms from Task 1 and route/summary terms from Task 2.
- Produces: `ruby docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb --mutations`

- [ ] **Step 1: Create GREEN evidence**

Include:

- `asyncJobState` fixed fields.
- Close/leave does not cancel server job.
- Cancel request is not cancelled.
- Unknown result is not success/failure.
- Toast/Notification not sole owner.
- Artifact permission recertification.
- Partial success ranges.
- Mobile capability preserved.
- Runtime unverified.

- [ ] **Step 2: Create RED evidence**

Include failures:

- Business task represented only by `loading`, Toast, Notification or table row text.
- Closing Dialog/Drawer/page/browser treated as service cancelled.
- Cancel request treated as cancelled.
- Unknown result treated as success or failure.
- Toast-only / Notification-only result.
- Old download/error-report link bypasses permission/version/expiry.
- Partial success lacks success/failed/skipped/conflict/unknown ranges.
- Mobile deletes task center/status/progress/retry/artifacts/recovery.
- Runtime checks claimed verified without running.

- [ ] **Step 3: Create Ruby audit**

Use the established audit pattern with constants:

```ruby
OWNER_TERMS = [
  "asyncJobState",
  "jobOwnerId", "jobId", "jobKind", "sourceSurface", "requestIdentity", "inputSnapshot",
  "jobPhase", "progressState", "resultState", "cancelPolicy", "retryPolicy", "artifactState",
  "notificationBinding", "auditBinding", "permissionBoundary", "responsivePolicy",
  "关闭 Dialog、Drawer、Toast、Notification、来源页面、浏览器 Tab 或移动端系统返回，只能表达客户端关闭或停止等待，不得伪装成服务端任务已取消",
  "取消请求已发送不等于任务已取消",
  "未知结果不得伪装成成功或失败",
  "Toast 和 Notification 只能辅助提醒，不能作为唯一状态、唯一错误、唯一下载入口或唯一恢复路径",
  "领取、下载、复制、重试和分享前必须复核任务身份、权限版本、租户/工作区、有效期和请求身份",
  "移动端不得删除任务中心入口、任务状态、进度、取消中、重试、结果领取、错误明细、未知结果说明、权限说明或恢复路径",
  "未验证"
]
```

Route terms:

```ruby
ROUTE_TERMS = [
  "async job", "background task", "job center", "task center", "异步任务", "后台任务",
  "任务中心", "任务详情", "任务进度", "任务取消", "取消中", "重跑任务", "任务重试",
  "导入任务", "导出任务", "批量任务", "报表生成", "AI 生成", "同步任务",
  "结果领取", "错误明细", "未知结果", "过期任务", "job detail", "job progress",
  "cancel job", "cancelling", "rerun job", "retry job", "import job", "export job",
  "bulk job", "report generation", "AI generation", "sync job", "result artifact",
  "error report", "unknown result", "expired job", "references/async-jobs-task-center.md"
]
```

Project leak forbidden terms:

```ruby
PROJECT_LEAK_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/fex-admin",
  "gloopai/story",
  "/Users/evanqi/code/gloopai/story"
]
```

Mutations:

- `close-does-not-cancel-server-job`
- `cancel-request-not-cancelled`
- `unknown-not-success-or-failure`
- `toast-not-sole-owner`
- `artifact-permission-recertification`
- `mobile-capability-preserved`
- `runtime-boundary-marked-verified`
- `missing-route`
- `project-leak`

- [ ] **Step 4: Run new audit**

Run:

```bash
ruby docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb --mutations
git diff --check
```

Expected: all mutations print `EXPECTED_FAIL`, audit prints PASS, diff check exits 0.

---

### Task 4: 全量验证、提交并推送

**Files:**
- Verify all changed files.

**Interfaces:**
- Consumes: all previous tasks.
- Produces: committed and pushed `main`.

- [ ] **Step 1: Run full maintained audits**

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
ruby docs/testing/selection-controls/selection-controls-audit.rb --mutations
ruby docs/testing/tree-hierarchy/tree-hierarchy-audit.rb --mutations
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
ruby docs/testing/wizards-steppers/wizards-steppers-audit.rb --mutations
ruby docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb --mutations
```

- [ ] **Step 2: Run markdown link and whitespace checks**

Run:

```bash
ruby -e 'files = Dir["README.md", "HANDOFF.md", "SKILL.md", "references/*.md", "docs/**/*.md"]; missing = []; files.each do |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |href| next if href =~ /\Ahttps?:/; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target); end; end; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
git diff --check
git status --short --branch
```

- [ ] **Step 3: Commit implementation**

Run:

```bash
git add SKILL.md README.md HANDOFF.md references/async-jobs-task-center.md docs/testing/async-jobs-task-center/green-summary.md docs/testing/async-jobs-task-center/red-summary.md docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb
git commit -m "docs: 新增异步任务交互规范"
```

- [ ] **Step 4: Post-commit verification**

Repeat Step 1 and Step 2. Expected: all pass and worktree clean.

- [ ] **Step 5: Push main**

Run:

```bash
git push origin main
```

Expected: `main -> main`.

---

## Self-Review

- Spec coverage: owner lifecycle, task center, cancellation, retry, unknown result, artifacts, permissions, notifications, audit, mobile and verification boundaries are mapped to Tasks 1-4.
- Placeholder scan: plan contains no unresolved placeholders, empty decisions, or deferred requirements.
- Interface consistency: owner terms in Task 1 match audit constants in Task 3.
- Scope check: one owner category only; no backend queue implementation and no business project coupling.
