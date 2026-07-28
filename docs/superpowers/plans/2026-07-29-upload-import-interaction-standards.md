# Upload Import Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class upload and import interaction owner to the frontend product interaction standards Skill.

**Architecture:** Create one focused reference file for upload/import behavior, route it from `SKILL.md`, summarize it from README/HANDOFF, and add a Ruby audit plus RED/GREEN evidence. The owner defines observable product behavior and composes with existing Form, Button, Dialog/Drawer, Data Table, Admin Console, and Responsive owners instead of duplicating them.

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- The new owner must be project-agnostic and must not include business-project-specific pages, modules, routes, frameworks, or component libraries.
- Detailed rules live only in `references/uploads-imports.md`; `SKILL.md`, README, and HANDOFF only route or summarize.
- Upload/import rules are hard acceptance criteria when their route triggers.
- Runtime browser, screen reader, touch-device, and real-component checks must be marked unverified unless actually executed.
- Do not modify business repositories in this plan.

---

### Task 1: Add Upload / Import owner

**Files:**
- Create: `references/uploads-imports.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-28-upload-import-interaction-standards-design.md`
- Produces: rule families `UPL-SCOPE-*`, `UPL-PICK-*`, `UPL-STATE-*`, `UPL-ASYNC-*`, `UPL-FORM-*`, `IMP-FLOW-*`, `IMP-RESULT-*`, `UPL-PERM-*`, `UPL-A11Y-*`, `UPL-RSP-*`

- [ ] **Step 1: Write the owner file**

Create `references/uploads-imports.md` with these sections:

```markdown
# 上传与导入交互规范

## 范围
## 与组件 owner 的关系
## 场景与状态模型
## UPL-SCOPE 范围和术语
## UPL-PICK 文件选择、拖拽与本地校验
## UPL-STATE 上传会话、队列与进度
## UPL-ASYNC 取消、重试、防重复与迟到结果
## UPL-FORM 表单内上传
## IMP-FLOW 导入模板、预检、映射与确认
## IMP-RESULT 任务结果、部分成功与错误明细
## UPL-PERM 权限、安全和审计
## UPL-A11Y 可访问性
## UPL-RSP 响应式与移动端
## 可执行验收检查
```

- [ ] **Step 2: Include required state contract**

Ensure `uploadSessionState` contains `sessionId`, `sourceOwner`, `acceptedPolicy`, `fileItems`, `queuePhase`, `requestIdentity`, and `resultOwner`.

- [ ] **Step 3: Include hard prohibitions**

Owner must prohibit: `accept` as the only validation, invalid files entering request queue, duplicate upload/import from repeated activation, treating client close as server cancellation, skipping import preflight, Toast-only partial success, stale error-detail links, and drag-only upload entry.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add references/uploads-imports.md
git commit -m "docs: 新增上传与导入交互规范"
```

### Task 2: Route and summarize the new owner

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/uploads-imports.md`
- Produces: automatic routing from upload/import keywords to the owner

- [ ] **Step 1: Update `SKILL.md` routing**

Add a route requiring complete reading of `references/uploads-imports.md` for Chinese and English upload/import keywords:

```markdown
- 涉及上传、文件上传、附件、拖拽上传、导入、批量导入、模板下载、导入预检、字段映射、错误明细、上传进度、取消上传、重试上传，或 upload、file upload、attachment、drag upload、dropzone、import、bulk import、template download、preflight import、field mapping、error report、upload progress、cancel upload、retry upload 时，必须完整读取 `references/uploads-imports.md`。
```

- [ ] **Step 2: Update README summary**

Add one bullet to “当前规范” and include `[上传与导入交互规范](references/uploads-imports.md)` in the complete-rules sentence.

- [ ] **Step 3: Update HANDOFF summary**

Add a short “上传与导入” subsection under “已完成规范” and add `references/uploads-imports.md` to the current structure.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add SKILL.md README.md HANDOFF.md
git commit -m "docs: 接入上传与导入规范路由"
```

### Task 3: Add audit and evidence

**Files:**
- Create: `docs/testing/uploads-imports/uploads-imports-audit.rb`
- Create: `docs/testing/uploads-imports/red-summary.md`
- Create: `docs/testing/uploads-imports/green-summary.md`

**Interfaces:**
- Consumes: `references/uploads-imports.md`, `SKILL.md`, `README.md`, `HANDOFF.md`
- Produces: command `ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations`

- [ ] **Step 1: Write the Ruby audit**

The audit must verify:

```ruby
REQUIRED_OWNER_TERMS = [
  "uploadSessionState",
  "sessionId",
  "acceptedPolicy",
  "fileItems",
  "queuePhase",
  "requestIdentity",
  "resultOwner",
  "accept` 只能作为选择器提示，不能作为唯一校验",
  "无效文件不得进入待上传请求队列",
  "不得直接把服务端任务写成已取消",
  "重复点击、Enter、Space、触摸或事件重放",
  "预检结果必须区分",
  "部分成功不能只用 Toast 表示",
  "下载前必须复核权限",
  "拖拽上传不能是唯一入口",
  "未验证"
]
```

It must also verify route and README/HANDOFF links.

- [ ] **Step 2: Add mutation checks**

The `--mutations` mode must fail when removing local validation, session identity, duplicate-trigger protection, cancellation semantics, import preflight, Toast-only prohibition, download permission review, drag alternative, and runtime unverified disclosure.

- [ ] **Step 3: Add RED/GREEN summaries**

`red-summary.md` lists the negative cases. `green-summary.md` lists the behaviors proved by the current owner and audit.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add docs/testing/uploads-imports
git commit -m "test: 增加上传与导入规范审计"
```

### Task 4: Verify final integration

**Files:**
- Inspect all modified files.

**Interfaces:**
- Consumes: all outputs from Tasks 1-3
- Produces: final local verification evidence

- [ ] **Step 1: Run upload/import audit**

Run:

```bash
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
```

Expected: all mutation checks print expected failures and final pass.

- [ ] **Step 2: Run existing high-overlap audits**

Run:

```bash
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb --mutations
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
git commit -m "docs: 完成上传与导入规范验证"
```

If there are no file changes, do not create an empty commit.
