# 导出、下载与结果产物交付交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增导出、下载与结果产物交付交互规范 owner，并接入 Skill 路由、README、HANDOFF、红绿证据和结构化审计。

**Architecture:** `references/exports-downloads-artifacts.md` 是唯一事实来源；`SKILL.md` 只负责路由；`README.md` 和 `HANDOFF.md` 只提供摘要与链接；`docs/testing/exports-downloads-artifacts/` 提供可执行结构化审计和红绿证据。该 owner 与表格、查询筛选、日期时间、权限、危险操作、异步任务、上传导入、审计日志、图表和按钮组合执行，但不替代它们。

**Tech Stack:** Markdown 文档、Ruby 审计脚本、Git。

## Global Constraints

- 所有用户可见文档使用中文。
- 不引入业务项目特定名称、路径或实现细节。
- 新 owner 必须职责单一，不能复制 `data-tables.md`、`query-filters.md`、`date-time-ranges.md`、`permissions-tenancy-visibility.md`、`risk-actions.md`、`async-jobs-task-center.md`、`uploads-imports.md`、`audit-log-activity-history.md`、`charts-visualization.md` 或 `buttons.md` 的完整规则。
- 必须保留未验证边界：真实浏览器下载、键盘、屏幕阅读器、触摸、权限切换、链接过期、任务结果和移动端视口未实际执行时，必须明确标为未验证。
- 必须使用 `apply_patch` 编辑文件。
- 每个提交前运行相关审计或最小可证明检查。

---

## File Structure

- Create `references/exports-downloads-artifacts.md`：导出状态、产物身份、下载意图、范围快照、有效期、权限复核、敏感字段、旧链接失效、Toast 边界、结果恢复和移动端承载的 owner。
- Modify `SKILL.md`：新增 export / download / artifact 路由。
- Modify `README.md`：加入导出、下载与结果产物交付摘要、链接和目录树。
- Modify `HANDOFF.md`：加入交接摘要。
- Create `docs/testing/exports-downloads-artifacts/green-summary.md`：正确实现证据。
- Create `docs/testing/exports-downloads-artifacts/red-summary.md`：错误实现证据。
- Create `docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb`：结构化审计脚本与突变测试。

---

### Task 1: 写 owner 文档

**Files:**
- Create: `references/exports-downloads-artifacts.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-exports-downloads-artifacts-interaction-standards-design.md`
- Produces exact owner terms:
  - `exportState`
  - `artifactState`
  - `downloadIntent`
  - `exportOwnerId`, `artifactOwnerId`, `exportSurface`, `scopeSnapshot`, `artifactIdentity`, `permissionBoundary`, `expiryPolicy`, `sensitiveFieldPolicy`, `deliveryReceipt`, `recoveryPolicy`, `feedbackState`, `a11yPolicy`, `responsivePolicy`
  - `导出范围不得读取筛选草稿、未提交时间范围、Select query、active option、当前页面可见行或旧缓存`
  - `创建导出、生成文件、领取产物和下载文件不得合并成一个含糊状态`
  - `下载链接不得被当作权限证明；每次下载必须复核权限、租户/工作区、有效期、请求身份和产物身份`
  - `旧 Notification、旧任务入口、旧 URL、旧缓存、旧文件名或旧下载链接不得绕过权限复核`
  - `Toast、Snackbar、Notification 或浏览器下载提示不得作为唯一下载入口、唯一结果回执、唯一错误说明或唯一恢复路径`
  - `敏感导出、审计导出、错误明细下载和跨租户/工作区产物必须说明敏感字段、范围、有效期、权限边界和审计回执`
  - `部分成功、未知、过期、无权限和文件不可用不得伪装成成功`
  - `移动端不得删除导出范围、文件状态、格式、有效期、权限说明、敏感字段说明、错误明细、重新生成、任务详情、审计入口或恢复路径`
  - `未验证`

- [ ] **Step 1: Create owner markdown**

Use `apply_patch` to create `references/exports-downloads-artifacts.md` with the above terms and a clear relationship section.

- [ ] **Step 2: Run owner sanity check**

Run:

```bash
rg -n "exportState|artifactState|downloadIntent|导出范围不得读取筛选草稿|创建导出、生成文件、领取产物和下载文件|下载链接不得被当作权限证明|旧 Notification、旧任务入口|Toast、Snackbar、Notification|敏感导出、审计导出、错误明细下载|部分成功、未知、过期|移动端不得删除导出范围|未验证" references/exports-downloads-artifacts.md
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
- 涉及 export、download、artifact、result artifact、file delivery、download link、download URL、CSV、Excel、PDF、image export、report export、chart export、audit export、error report、error detail、expiry、expires、导出、下载、结果产物、文件领取、下载链接、下载地址、文件有效期、过期文件、重新生成、错误明细、报表导出、图表导出、审计导出、CSV、Excel、PDF、图片导出 时，必须完整读取 `references/exports-downloads-artifacts.md`。
```

- [ ] **Step 2: Update README and HANDOFF**

README summary:

```markdown
- 导出、下载与结果产物交付规范约束 export、download、artifact、result artifact、报表导出、图表导出、审计导出、错误明细下载和文件领取的范围快照、产物身份、下载意图、权限复核、有效期、敏感字段、旧链接失效、Toast 边界、恢复路径和移动端承载。
```

HANDOFF section must include exact owner clauses from Task 1.

- [ ] **Step 3: Run route sanity check**

Run:

```bash
rg -n "exports-downloads-artifacts|导出、下载与结果产物交付|export|download|artifact|result artifact|报表导出|图表导出|审计导出|错误明细|下载链接|文件有效期" SKILL.md README.md HANDOFF.md
git diff --check
```

---

### Task 3: 新增红绿证据和审计脚本

**Files:**
- Create: `docs/testing/exports-downloads-artifacts/green-summary.md`
- Create: `docs/testing/exports-downloads-artifacts/red-summary.md`
- Create: `docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb`

- [ ] **Step 1: Create evidence files**

GREEN covers state model, scope snapshot, creation/download separation, download permission recertification, old link invalidation, Toast boundary, sensitive field disclosure, result states, mobile preservation and unverified runtime.

RED covers draft filters exported, creation/download merged, old link bypass, permanent URL, Toast-only download, missing sensitive fields, partial success pretending success, mobile removing recovery and false runtime verification.

- [ ] **Step 2: Create audit script**

Use established pattern. Mutations:

- `scope-snapshot-required`
- `creation-download-separated`
- `download-permission-recertification`
- `old-link-invalidated`
- `toast-not-sole-download-owner`
- `sensitive-field-disclosure`
- `result-states-distinct`
- `mobile-capability-preserved`
- `runtime-boundary-marked-verified`
- `missing-route`
- `project-leak`

- [ ] **Step 3: Run new audit**

Run:

```bash
ruby docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb --mutations
git diff --check
```

---

### Task 4: 全量验证、提交并推送

- [ ] **Step 1: Run full maintained audits**

Run all existing `docs/testing/*/*-audit.rb --mutations`, including the new exports/downloads audit.

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
git add SKILL.md README.md HANDOFF.md references/exports-downloads-artifacts.md docs/testing/exports-downloads-artifacts/green-summary.md docs/testing/exports-downloads-artifacts/red-summary.md docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb
git commit -m "docs: 新增导出下载交互规范"
```

- [ ] **Step 4: Post-commit verification and push**

Repeat Step 1 and Step 2, then run:

```bash
git push origin main
```

---

## Self-Review

- Spec coverage: state model, scope snapshot, creation/download separation, download permission recertification, old link invalidation, Toast boundary, sensitive field disclosure, result states, mobile and verification boundaries are mapped to Tasks 1-4.
- Placeholder scan: plan contains no unresolved placeholders, empty decisions, or deferred requirements.
- Interface consistency: owner terms in Task 1 match audit requirements in Task 3.
- Scope check: one owner category only; no backend file storage, object storage, CDN or business project coupling.
