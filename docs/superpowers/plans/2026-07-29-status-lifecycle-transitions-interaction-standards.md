# 状态流转与记录生命周期交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增状态流转与记录生命周期交互规范 owner，并接入 Skill 路由、README、HANDOFF、红绿证据和结构化审计。

**Architecture:** `references/status-lifecycle-transitions.md` 是唯一事实来源；`SKILL.md` 只负责路由；`README.md` 和 `HANDOFF.md` 只提供摘要与链接；`docs/testing/status-lifecycle-transitions/` 提供可执行结构化审计和红绿证据。该 owner 与按钮、危险操作、权限、审计日志、异步任务、表格和信息展示组合执行，但不替代它们。

**Tech Stack:** Markdown 文档、Ruby 审计脚本、Git。

## Global Constraints

- 所有用户可见文档使用中文。
- 不引入业务项目特定名称、路径或实现细节。
- 新 owner 必须职责单一，不能复制 `buttons.md`、`risk-actions.md`、`permissions-tenancy-visibility.md`、`audit-log-activity-history.md`、`async-jobs-task-center.md`、`data-tables.md` 或 `information-display.md` 的完整规则。
- 必须保留未验证边界：真实浏览器、键盘、屏幕阅读器、触摸、权限切换、版本冲突、异步任务和移动端视口未实际执行时，必须明确标为未验证。
- 必须使用 `apply_patch` 编辑文件。
- 每个提交前运行相关审计或最小可证明检查。

---

## File Structure

- Create `references/status-lifecycle-transitions.md`：状态展示、状态流转、版本快照、转换意图、结果状态、冲突恢复、权限无泄露、审计回执、批量生命周期变更和移动端承载的 owner。
- Modify `SKILL.md`：新增 status lifecycle / transition 路由。
- Modify `README.md`：加入状态流转与记录生命周期摘要、链接和目录树。
- Modify `HANDOFF.md`：加入交接摘要。
- Create `docs/testing/status-lifecycle-transitions/green-summary.md`：正确实现证据。
- Create `docs/testing/status-lifecycle-transitions/red-summary.md`：错误实现证据。
- Create `docs/testing/status-lifecycle-transitions/status-lifecycle-transitions-audit.rb`：结构化审计脚本与突变测试。

---

### Task 1: 写 owner 文档

**Files:**
- Create: `references/status-lifecycle-transitions.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-status-lifecycle-transitions-interaction-standards-design.md`
- Produces exact owner terms:
  - `lifecycleState`
  - `lifecycleOwnerId`, `lifecycleSurface`, `currentStatus`, `targetStatus`, `statusSource`, `versionSnapshot`, `transitionIntent`, `transitionPolicy`, `transitionResult`, `permissionBoundary`, `auditReceipt`, `recoveryPolicy`, `feedbackState`, `a11yPolicy`, `responsivePolicy`
  - `状态 badge、按钮 loading、乐观 UI、Toast 文案或本地缓存不得伪装成已完成状态流转`
  - `状态展示和状态变更不得共用一个含糊 status 字段`
  - `没有冻结对象版本、权限版本、当前状态、目标状态、租户/工作区和请求身份，不得提交状态变更`
  - `版本冲突、权限变化、租户切换、对象删除、状态已变化或业务限制变化时，旧意图必须失效`
  - `transitionResult 必须区分 success、failure、partial-success、conflict、stale、unknown、queued、processing 和 cancelled-client-only`
  - `无权限状态流转不得泄露当前状态、下一步动作、不可见原因、对象数量、批量影响范围、审批意见、拒绝原因、内部状态码、任务结果或旧缓存`
  - `批量状态变更不得用当前页面可见行替代选择快照、筛选快照、权限版本和目标摘要`
  - `移动端不得删除当前状态、状态原因、可用动作、禁用原因、确认、结果回执、审计入口或恢复路径`
  - `未验证`

- [ ] **Step 1: Create owner markdown**

Use `apply_patch` to create `references/status-lifecycle-transitions.md` with the above terms and a clear relationship section.

- [ ] **Step 2: Run owner sanity check**

Run:

```bash
rg -n "lifecycleState|状态 badge、按钮 loading|状态展示和状态变更|没有冻结对象版本|版本冲突、权限变化|transitionResult 必须区分|无权限状态流转不得泄露|批量状态变更不得用当前页面可见行|移动端不得删除当前状态|未验证" references/status-lifecycle-transitions.md
git diff --check
```

---

### Task 2: 接入路由、README 和 HANDOFF

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

- [ ] **Step 1: Add Skill route**

Add:

```markdown
- 涉及 status lifecycle、status transition、record lifecycle、state machine、publish、unpublish、approve、reject、enable、disable、activate、deactivate、archive、restore、freeze、unfreeze、lock、unlock、draft、published、状态流转、生命周期、记录生命周期、状态机、发布、下线、审批、审核、驳回、启用、停用、激活、归档、恢复、冻结、解冻、锁定、解锁、草稿、已发布 时，必须完整读取 `references/status-lifecycle-transitions.md`。
```

- [ ] **Step 2: Update README and HANDOFF**

README summary:

```markdown
- 状态流转与记录生命周期规范约束 status lifecycle、status transition、record lifecycle、发布/下线、审批/驳回、启停、归档/恢复、冻结/解冻、锁定/解锁的状态模型、转换意图、版本快照、结果状态、冲突恢复、权限无泄露、审计回执、批量快照和移动端承载。
```

HANDOFF section must include exact owner clauses from Task 1.

- [ ] **Step 3: Run route sanity check**

Run:

```bash
rg -n "status-lifecycle-transitions|状态流转与记录生命周期|status lifecycle|status transition|record lifecycle|发布|审批|启用|停用|归档|恢复|冻结|锁定" SKILL.md README.md HANDOFF.md
git diff --check
```

---

### Task 3: 新增红绿证据和审计脚本

**Files:**
- Create: `docs/testing/status-lifecycle-transitions/green-summary.md`
- Create: `docs/testing/status-lifecycle-transitions/red-summary.md`
- Create: `docs/testing/status-lifecycle-transitions/status-lifecycle-transitions-audit.rb`

- [ ] **Step 1: Create evidence files**

GREEN covers state model, display/change separation, frozen transition intent, version conflict invalidation, result states, permission no-leakage, batch snapshots, audit receipt, mobile preservation and unverified runtime.

RED covers badge pretending to be state machine, loading pretending success, missing version snapshot, conflict overwritten by stale optimistic UI, Toast-only result, permission leakage, batch visible rows as target set, mobile removing recovery and false runtime verification.

- [ ] **Step 2: Create audit script**

Use established pattern. Mutations:

- `badge-not-transition`
- `status-field-not-enough`
- `version-snapshot-required`
- `stale-intent-invalidated`
- `result-states-distinct`
- `permission-no-leakage`
- `batch-snapshot-required`
- `mobile-capability-preserved`
- `runtime-boundary-marked-verified`
- `missing-route`
- `project-leak`

- [ ] **Step 3: Run new audit**

Run:

```bash
ruby docs/testing/status-lifecycle-transitions/status-lifecycle-transitions-audit.rb --mutations
git diff --check
```

---

### Task 4: 全量验证、提交并推送

- [ ] **Step 1: Run full maintained audits**

Run all existing `docs/testing/*/*-audit.rb --mutations`, including the new status lifecycle audit.

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
git add SKILL.md README.md HANDOFF.md references/status-lifecycle-transitions.md docs/testing/status-lifecycle-transitions/green-summary.md docs/testing/status-lifecycle-transitions/red-summary.md docs/testing/status-lifecycle-transitions/status-lifecycle-transitions-audit.rb
git commit -m "docs: 新增状态生命周期交互规范"
```

- [ ] **Step 4: Post-commit verification and push**

Repeat Step 1 and Step 2, then run:

```bash
git push origin main
```

---

## Self-Review

- Spec coverage: state model, display/change separation, transition intent, version conflict, result states, permission safety, batch snapshots, audit receipt, mobile and verification boundaries are mapped to Tasks 1-4.
- Placeholder scan: plan contains no unresolved placeholders, empty decisions, or deferred requirements.
- Interface consistency: owner terms in Task 1 match audit requirements in Task 3.
- Scope check: one owner category only; no backend state machine, workflow engine or business project coupling.
