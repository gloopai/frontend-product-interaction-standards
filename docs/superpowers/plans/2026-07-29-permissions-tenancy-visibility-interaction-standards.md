# 权限、租户与可见性交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增权限、租户与可见性交互规范 owner，并接入 Skill 路由、README、HANDOFF、红绿证据和结构化审计。

**Architecture:** `references/permissions-tenancy-visibility.md` 是唯一事实来源；`SKILL.md` 只负责路由；`README.md` 和 `HANDOFF.md` 只提供摘要与链接；`docs/testing/permissions-tenancy-visibility/` 提供可执行结构化审计和红绿证据。该 owner 与按钮、表格、表单、导航、任务、上传、危险操作和管理台治理组合执行，但不替代它们。

**Tech Stack:** Markdown 文档、Ruby 审计脚本、Git。

## Global Constraints

- 所有用户可见文档使用中文。
- 不引入业务项目特定名称、路径或实现细节。
- 新 owner 必须职责单一，不能复制 `buttons.md`、`data-tables.md`、`navigation-routing.md`、`async-jobs-task-center.md` 或 `admin-console.md` 的完整规则。
- 必须保留未验证边界：真实浏览器、键盘、屏幕阅读器、触摸、租户/工作区切换、权限降级、权限升级、缓存失效和移动端视口未实际执行时，必须明确标为未验证。
- 必须使用 `apply_patch` 编辑文件。
- 每个提交前运行相关审计或最小可证明检查。

---

## File Structure

- Create `references/permissions-tenancy-visibility.md`：权限解析、租户/工作区切换、可见性语义、无泄露、旧状态清理、请求绑定、可访问性和移动端规则的 owner。
- Modify `SKILL.md`：新增 permission / tenant / visibility 路由。
- Modify `README.md`：在当前规范摘要、完整链接和目录结构中加入权限、租户与可见性。
- Modify `HANDOFF.md`：在当前结构和已完成规范中加入交接摘要。
- Create `docs/testing/permissions-tenancy-visibility/green-summary.md`：正确实现证据。
- Create `docs/testing/permissions-tenancy-visibility/red-summary.md`：错误实现证据。
- Create `docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb`：结构化审计脚本与突变测试。

---

### Task 1: 写 owner 文档

**Files:**
- Create: `references/permissions-tenancy-visibility.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-permissions-tenancy-visibility-interaction-standards-design.md`
- Produces: owner terms consumed by Task 3 audit:
  - `permissionVisibilityState`
  - `permissionOwnerId`, `principalSnapshot`, `resourceSnapshot`, `capabilityMatrix`, `visibilityState`, `reasonState`, `dataBoundary`, `actionBoundary`, `cacheBoundary`, `focusBoundary`, `a11yBoundary`, `responsivePolicy`
  - `隐藏、禁用、只读、未启用和无权限不是同一件事`
  - `未启用表示产品或配置没有启用该能力，DOM、state、handler 和 request 入口均为 0`
  - `权限、租户/工作区、角色、认证状态、对象状态、权限版本或资源版本变化后，必须原子重算`
  - `旧可见数据、旧菜单、旧按钮、旧确认、旧下载链接、旧任务入口、旧错误明细、旧搜索结果、旧表单草稿、旧图表明细和旧 ARIA label 不得继续暴露`
  - `无权限状态不得泄露对象名称、数量、字段、文件名、路径、父子关系、导出范围、错误明细、任务结果、搜索摘要、内部 ID、图标、排序位置、旧缓存或旧可访问名称`
  - `移动端不得删除权限说明、只读原因、禁用原因、申请权限、切换租户/工作区、安全占位、重新认证或恢复路径`
  - `未验证`

- [ ] **Step 1: Create owner markdown**

Use `apply_patch` to create `references/permissions-tenancy-visibility.md` with this opening:

```markdown
# 权限、租户与可见性交互规范

适用于 permission、permissions、role、RBAC、ABAC、tenant、workspace、权限、角色、权限矩阵、能力开关、租户、工作区、权限降级、权限升级、权限版本、无权限、只读、隐藏入口、禁用原因、申请权限、可见性、权限泄露、旧缓存、旧菜单和旧下载链接。本文件是权限解析、租户/工作区切换、可见性语义、权限收敛、无泄露、请求绑定、可访问性和验收的唯一事实来源。
```

- [ ] **Step 2: Add relationship boundaries**

Route local interactions to existing owners: buttons, data tables, forms, navigation, async jobs, uploads, risk actions, global feedback and admin console.

- [ ] **Step 3: Add state table**

Add `permissionVisibilityState` with all fields from Interfaces.

- [ ] **Step 4: Add semantic distinction and convergence rules**

Include exact clauses from Interfaces for hidden/disabled/read-only/not-enabled/no-permission and atomic recomputation.

- [ ] **Step 5: Add leakage, request, a11y, mobile and disposal rules**

Cover:

- No leakage exact clause.
- Requests bind principal/resource/capability/permission version.
- Permission conflicts enter conflict, re-confirm, read-only, safe placeholder or recovery.
- A11y label/description/announcement cannot leak.
- Mobile exact clause.
- Disposal clears old menus, downloads, tasks, search results, form drafts, ARIA labels and focus.

- [ ] **Step 6: Run owner sanity check**

Run:

```bash
rg -n "permissionVisibilityState|隐藏、禁用、只读、未启用和无权限不是同一件事|DOM、state、handler 和 request 入口均为 0|必须原子重算|旧可见数据、旧菜单、旧按钮|无权限状态不得泄露对象名称|移动端不得删除权限说明|未验证" references/permissions-tenancy-visibility.md
git diff --check
```

Expected: all terms appear; diff check exits 0.

---

### Task 2: 接入路由、README 和 HANDOFF

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/permissions-tenancy-visibility.md`
- Produces: route and summaries consumed by Task 3 audit.

- [ ] **Step 1: Add Skill route**

Add route:

```markdown
- 涉及 permission、permissions、role、RBAC、ABAC、tenant、workspace、权限、角色、权限矩阵、能力开关、租户、工作区、权限降级、权限升级、权限版本、无权限、只读、隐藏入口、禁用原因、申请权限、可见性、权限泄露、旧缓存、旧菜单、旧下载链接，或 permission denied、read only、read-only、hidden by permission、disabled by permission、permission version、capability matrix、feature flag、visibility、access control、stale permission、permission leakage 时，必须完整读取 `references/permissions-tenancy-visibility.md`。
```

- [ ] **Step 2: Update README**

Add summary:

```markdown
- 权限、租户与可见性规范约束 RBAC、ABAC、角色、能力开关、租户/工作区切换、权限降级、隐藏/禁用/只读/未启用语义、原子收敛、无泄露、请求绑定和移动端权限恢复。
```

Add link and directory tree entry.

- [ ] **Step 3: Update HANDOFF**

Add section:

```markdown
### 权限、租户与可见性

- 已定义 RBAC、ABAC、角色、能力开关、租户/工作区切换、权限降级、权限升级、隐藏入口、禁用原因、只读、无权限和权限泄露防护的首版 owner。
- 隐藏、禁用、只读、未启用和无权限不是同一件事；未启用表示产品或配置没有启用该能力，DOM、state、handler 和 request 入口均为 0。
- 权限、租户/工作区、角色、认证状态、对象状态、权限版本或资源版本变化后，必须原子重算可见数据、菜单、按钮、表单字段、筛选项、导航、下载、任务入口、确认面板和缓存。
- 旧可见数据、旧菜单、旧按钮、旧确认、旧下载链接、旧任务入口、旧错误明细、旧搜索结果、旧表单草稿、旧图表明细和旧 ARIA label 不得继续暴露。
- 无权限状态不得泄露对象名称、数量、字段、文件名、路径、父子关系、导出范围、错误明细、任务结果、搜索摘要、内部 ID、图标、排序位置、旧缓存或旧可访问名称。
- 移动端不得删除权限说明、只读原因、禁用原因、申请权限、切换租户/工作区、安全占位、重新认证或恢复路径。
- 详细规则和可执行验收仅维护在 [权限、租户与可见性交互规范](../../../references/permissions-tenancy-visibility.md)，本交接不重复其状态模型或检查项。
```

- [ ] **Step 4: Run routing sanity check**

Run:

```bash
rg -n "permissions-tenancy-visibility|权限、租户与可见性|permission|RBAC|租户|权限降级|permission leakage" SKILL.md README.md HANDOFF.md
git diff --check
```

---

### Task 3: 新增红绿证据和审计脚本

**Files:**
- Create: `docs/testing/permissions-tenancy-visibility/green-summary.md`
- Create: `docs/testing/permissions-tenancy-visibility/red-summary.md`
- Create: `docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb`

**Interfaces:**
- Consumes: owner terms from Task 1 and route/summary terms from Task 2.
- Produces: `ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations`

- [ ] **Step 1: Create GREEN and RED evidence**

GREEN covers state model, semantic distinction, not-enabled zero evidence, atomic convergence, stale exposure cleanup, no leakage, mobile preservation and unverified runtime.

RED covers `canEdit` only, disabled as security, hidden/disabled/read-only merged, old menu/download/search/form/ARIA leaking, stale request using old permission version, mobile removing recovery, runtime falsely verified.

- [ ] **Step 2: Create Ruby audit**

Use established pattern. Include mutation names:

- `semantic-distinction`
- `not-enabled-zero-evidence`
- `atomic-recomputation`
- `stale-exposure-cleanup`
- `permission-no-leakage`
- `mobile-capability-preserved`
- `runtime-boundary-marked-verified`
- `missing-route`
- `project-leak`

Project leak terms:

```ruby
["fex-admin", "/Users/evanqi/code/fex-admin", "gloopai/story", "/Users/evanqi/code/gloopai/story"]
```

- [ ] **Step 3: Run new audit**

Run:

```bash
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
git diff --check
```

---

### Task 4: 全量验证、提交并推送

- [ ] **Step 1: Run full maintained audits**

Run all existing `docs/testing/*/*-audit.rb --mutations`, including the new permissions audit.

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
git add SKILL.md README.md HANDOFF.md references/permissions-tenancy-visibility.md docs/testing/permissions-tenancy-visibility/green-summary.md docs/testing/permissions-tenancy-visibility/red-summary.md docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb
git commit -m "docs: 新增权限可见性交互规范"
```

- [ ] **Step 4: Post-commit verification and push**

Repeat Step 1 and Step 2, then run:

```bash
git push origin main
```

---

## Self-Review

- Spec coverage: state model, semantic distinction, atomic convergence, no leakage, request binding, a11y, mobile and verification boundaries are mapped to Tasks 1-4.
- Placeholder scan: plan contains no unresolved placeholders, empty decisions, or deferred requirements.
- Interface consistency: owner terms in Task 1 match audit requirements in Task 3.
- Scope check: one owner category only; no backend permission engine and no business project coupling.
