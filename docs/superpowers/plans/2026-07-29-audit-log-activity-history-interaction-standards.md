# 审计日志与操作历史交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增审计日志与操作历史交互规范 owner，并接入 Skill 路由、README、HANDOFF、红绿证据和结构化审计。

**Architecture:** `references/audit-log-activity-history.md` 是唯一事实来源；`SKILL.md` 只负责路由；`README.md` 和 `HANDOFF.md` 只提供摘要与链接；`docs/testing/audit-log-activity-history/` 提供可执行结构化审计和红绿证据。该 owner 与表格、查询筛选、日期时间、权限、危险操作、异步任务和管理台治理组合执行，但不替代它们。

**Tech Stack:** Markdown 文档、Ruby 审计脚本、Git。

## Global Constraints

- 所有用户可见文档使用中文。
- 不引入业务项目特定名称、路径或实现细节。
- 新 owner 必须职责单一，不能复制 `data-tables.md`、`query-filters.md`、`date-time-ranges.md`、`risk-actions.md`、`permissions-tenancy-visibility.md` 或 `admin-console.md` 的完整规则。
- 必须保留未验证边界：真实浏览器、键盘、屏幕阅读器、触摸、权限切换、审计导出、时间范围、时区、任务追溯和移动端视口未实际执行时，必须明确标为未验证。
- 必须使用 `apply_patch` 编辑文件。
- 每个提交前运行相关审计或最小可证明检查。

---

## File Structure

- Create `references/audit-log-activity-history.md`：审计证据、操作历史、活动时间线、时间语义、完整性、导出复核、权限无泄露和移动端规则的 owner。
- Modify `SKILL.md`：新增 audit log / activity history 路由。
- Modify `README.md`：加入审计日志与操作历史摘要、链接和目录树。
- Modify `HANDOFF.md`：加入交接摘要。
- Create `docs/testing/audit-log-activity-history/green-summary.md`：正确实现证据。
- Create `docs/testing/audit-log-activity-history/red-summary.md`：错误实现证据。
- Create `docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb`：结构化审计脚本与突变测试。

---

### Task 1: 写 owner 文档

**Files:**
- Create: `references/audit-log-activity-history.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-audit-log-activity-history-interaction-standards-design.md`
- Produces exact owner terms:
  - `auditLogState`
  - `auditOwnerId`, `auditSurface`, `eventIdentity`, `actorSnapshot`, `targetSnapshot`, `actionSnapshot`, `timeSemantics`, `integrityState`, `permissionBoundary`, `filterSnapshot`, `exportState`, `feedbackState`, `a11yPolicy`, `responsivePolicy`
  - `审计记录不是普通列表行，也不是 Toast 成功文案`
  - `缺少证据身份的操作历史只能作为普通活动提示，不能写成审计日志`
  - `审计日志必须区分事件发生时间、审计写入时间、展示时区、存储时区、筛选范围、数据延迟和刷新时间`
  - `无权限审计不得泄露主体名称、目标名称、字段名、旧值、新值、数量、文件名、IP、设备、地理位置、错误明细、内部 ID、请求参数、导出范围、任务结果或旧缓存`
  - `审计缺口、延迟、重复、顺序未决、来源不可用和修正记录必须明确说明，不能伪装成完整日志`
  - `审计导出、复制、跳转、查看详情、查看关联任务、查看风险回执和追溯链路必须复核权限、租户/工作区、筛选快照、时间范围、敏感字段和请求身份`
  - `移动端不得删除筛选、时间范围、时区说明、数据延迟、审计详情、追溯路径、导出权限说明、无权限说明或恢复路径`
  - `未验证`

- [ ] **Step 1: Create owner markdown**

Use `apply_patch` to create `references/audit-log-activity-history.md` with the above terms and a clear relationship section.

- [ ] **Step 2: Run owner sanity check**

Run:

```bash
rg -n "auditLogState|审计记录不是普通列表行|缺少证据身份|审计日志必须区分事件发生时间|无权限审计不得泄露主体名称|审计缺口、延迟、重复、顺序未决|审计导出、复制、跳转|移动端不得删除筛选|未验证" references/audit-log-activity-history.md
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
- 涉及 audit log、activity log、operation history、event log、change history、audit detail、audit export、audit receipt、traceability、operation record、login log、access log、timeline、审计日志、操作历史、活动记录、事件日志、变更记录、审计详情、审计导出、审计回执、追溯链路、操作记录、登录日志、访问日志、时间线 时，必须完整读取 `references/audit-log-activity-history.md`。
```

- [ ] **Step 2: Update README and HANDOFF**

README summary:

```markdown
- 审计日志与操作历史规范约束 audit log、activity log、operation history、事件日志、变更记录和时间线的证据身份、主体/目标/动作快照、时间语义、完整性状态、权限无泄露、审计导出复核和移动端追溯。
```

HANDOFF section must include exact owner clauses from Task 1.

- [ ] **Step 3: Run route sanity check**

Run:

```bash
rg -n "audit-log-activity-history|审计日志与操作历史|audit log|activity log|operation history|追溯链路|时间线" SKILL.md README.md HANDOFF.md
git diff --check
```

---

### Task 3: 新增红绿证据和审计脚本

**Files:**
- Create: `docs/testing/audit-log-activity-history/green-summary.md`
- Create: `docs/testing/audit-log-activity-history/red-summary.md`
- Create: `docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb`

- [ ] **Step 1: Create evidence files**

GREEN covers state model, evidence binding, time semantics, no leakage, integrity states, export recertification, mobile preservation and unverified runtime.

RED covers ordinary table pretending to be audit, missing evidence identity, time confusion, permission leakage, integrity gaps hidden, stale export bypass, mobile removing traceability and false runtime verification.

- [ ] **Step 2: Create audit script**

Use established pattern. Mutations:

- `evidence-identity-required`
- `ordinary-table-not-audit`
- `time-semantics-distinct`
- `permission-no-leakage`
- `integrity-gap-not-complete`
- `export-recertification`
- `mobile-capability-preserved`
- `runtime-boundary-marked-verified`
- `missing-route`
- `project-leak`

- [ ] **Step 3: Run new audit**

Run:

```bash
ruby docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb --mutations
git diff --check
```

---

### Task 4: 全量验证、提交并推送

- [ ] **Step 1: Run full maintained audits**

Run all existing `docs/testing/*/*-audit.rb --mutations`, including the new audit-log audit.

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
git add SKILL.md README.md HANDOFF.md references/audit-log-activity-history.md docs/testing/audit-log-activity-history/green-summary.md docs/testing/audit-log-activity-history/red-summary.md docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb
git commit -m "docs: 新增审计日志交互规范"
```

- [ ] **Step 4: Post-commit verification and push**

Repeat Step 1 and Step 2, then run:

```bash
git push origin main
```

---

## Self-Review

- Spec coverage: state model, evidence identity, time semantics, no leakage, integrity states, export recertification, mobile and verification boundaries are mapped to Tasks 1-4.
- Placeholder scan: plan contains no unresolved placeholders, empty decisions, or deferred requirements.
- Interface consistency: owner terms in Task 1 match audit requirements in Task 3.
- Scope check: one owner category only; no backend audit storage and no business project coupling.
