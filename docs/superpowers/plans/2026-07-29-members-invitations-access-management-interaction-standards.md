# Members Invitations Access Management Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a dedicated Chinese interaction owner for members, invitations, team/workspace access management, role changes, owner transfer, member disable/remove, stale invitation invalidation, audit safety, and mobile recovery.

**Architecture:** Add one owner document, `references/members-invitations-access.md`, and route it from `SKILL.md`. Add a Ruby static audit and RED/GREEN evidence under `docs/testing/members-invitations-access/`; then update README/HANDOFF summaries so the new owner is discoverable while keeping the full rule set in the owner file.

**Tech Stack:** Markdown reference documentation, Ruby static audit scripts, Git.

## Global Constraints

- Do not define backend organization architecture, account systems, identity providers, directory sync, SCIM, SSO providers, email delivery services, permission DSLs, brand visual tokens, icons, colors, role names, or project-specific permission matrices.
- Do not replace `permissions-tenancy-visibility.md`, `auth-session-reauth.md`, `risk-actions.md`, `audit-log-activity-history.md`, `data-tables.md`, `global-feedback.md`, or `feedback-states.md`; the new owner coordinates with them.
- Members, invitations, role assignments, invitation links, resend/revoke invite, accept/decline invite, expired invite, member remove/disable/enable/restore, owner transfer, external members, membership audit, and stale member state invalidation must be owned by `members-invitations-access.md`.
- Member status, invitation status, role status, permission status, and authentication status must remain distinct.
- Role changes must edit draft role assignment state first; confirmation before request count is 0.
- Remove member, disable member, enable member, restore member, transfer owner, remove last admin/owner, remove self, disable self, batch remove, and batch disable must enter `risk-actions.md`.
- Old invitation links, old email entries, old copied links, old Toast/Notification, old member lists, old role Select controls, old menus, old confirmations, old audit links, old focus targets, and old ARIA references must expire or recompute after permission, session, tenant/workspace, role version, member version, revoke, expiry, or object deletion changes.
- Audit records and feedback must not leak member names, email addresses, roles, invitation status, external identity, member existence, internal IDs, invitation links, or stale cache to unauthorized users.
- Runtime browser, mobile device, screen reader, real invitation email/link, real permission switch, real session expiry, real reauthentication, real member role change, and real audit write checks must be reported as **未验证** unless actually executed.

---

### Task 1: Write the failing members/invitations audit

**Files:**
- Create: `docs/testing/members-invitations-access/members-invitations-access-audit.rb`
- Create: `docs/testing/members-invitations-access/red-summary.md`
- Create: `docs/testing/members-invitations-access/green-summary.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-members-invitations-access-management-interaction-standards-design.md`
- Produces: executable command `ruby docs/testing/members-invitations-access/members-invitations-access-audit.rb --mutations`

- [ ] **Step 1: Create RED evidence summary**

Write `docs/testing/members-invitations-access/red-summary.md` with this content:

```markdown
# 成员、邀请与团队访问管理 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- 成员、邀请和角色被当成普通用户行展示，没有 `membershipAccessState`、成员版本、邀请状态或权限快照。
- `active`、`invited`、`invite-expired`、`invite-revoked`、`disabled`、`removed`、`owner-transfer-required`、`external` 和 `unknown` 被合并成一个普通状态标签或 Switch。
- 邀请成员没有绑定 `invitationState`、目标邮箱/账号、租户/工作区、角色、邀请人、有效期、权限版本或审计身份。
- 旧邀请链接、旧邮件入口、旧复制链接、旧 Toast、旧任务入口或浏览器历史在撤销、过期、角色变更、租户/工作区切换、权限变化、会话过期或重复邀请后仍可用。
- 重新发送邀请创建重复成员，或绕过权限复核。
- 无权限用户可通过邀请错误、搜索结果、邮箱补全、列表数量、Toast、Notification、审计摘要或 DOM/ARIA 推断成员姓名、邮箱、角色、邀请状态、外部身份、成员是否存在或内部 ID。
- 角色 Select 直接改变已生效角色，或在确认前发送真实请求。
- 保存角色变更未绑定当前成员版本、角色版本、权限版本、租户/工作区、操作者身份和目标角色快照。
- 提升管理员、降低管理员、修改外部成员权限、跨租户/工作区授权、批量角色变更、影响自身权限或影响最后 owner 的操作没有进入 `risk-actions.md` 或必要的 `auth-session-reauth.md`。
- 移除成员、禁用成员、启用成员、恢复成员、转移 owner、移除最后管理员、移除自己、禁用自己、批量移除或批量禁用没有进入 `risk-actions.md`。
- 使用 Switch/Toggle 直接启停成员，或点击“移除成员”后直接发送请求。
- 确认前请求数为 0 这条约束缺失，导致确认前已经发起真实请求。
- 权限变化、会话过期、重新认证失败、账号切换、身份切换、租户/工作区切换、角色版本变化、成员版本变化或对象删除后，旧成员列表、旧角色 Select、旧邀请链接、旧菜单、旧按钮、旧确认面板、旧 Toast/Notification、旧审计跳转、旧焦点目标或旧 ARIA 引用继续可用。
- 迟到请求、缓存回放、浏览器 Back、任务中心回调、邮件链接 callback 或审计跳转在 `membershipOwnerId`、租户/工作区、成员版本、权限版本或请求身份失配后仍写回当前界面。
- 未知结果被伪装成角色变更成功、邀请成功、撤销成功、移除成功或禁用成功。
- Toast、Notification 或 Banner 成为唯一结果回执、唯一邀请恢复入口、唯一审计入口、唯一错误说明或唯一权限原因。
- 移动端、低高度、虚拟键盘、安全区域、系统字体放大、浏览器 Back、WebView 返回或触摸长按后，邀请成员、成员状态、角色说明、角色变更确认、撤销邀请、重新发送邀请、禁用原因、移除/恢复路径、转移 owner、审计入口、权限说明或错误恢复消失。
- 真实浏览器、移动端设备、屏幕阅读器、真实邀请邮件/链接、真实权限切换、真实会话过期、真实重新认证、真实成员角色变更或真实审计写入没有执行时，没有标为未验证。
```

- [ ] **Step 2: Create GREEN evidence summary**

Write `docs/testing/members-invitations-access/green-summary.md` with this content:

```markdown
# 成员、邀请与团队访问管理 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `membershipAccessState` 包含 `membershipOwnerId`、`principalSnapshot`、`memberIdentity`、`membershipStatus`、`invitationState`、`roleAssignmentState`、`accessChangeIntent`、`permissionBoundary`、`authBinding`、`riskBinding`、`auditBinding` 和 `resultReceipt`。
- 成员状态、邀请状态、角色状态、权限状态和认证状态分开表达，`active`、`invited`、`invite-expired`、`invite-revoked`、`disabled`、`removed`、`owner-transfer-required`、`external` 和 `unknown` 不合并。
- 邀请成员绑定 `invitationState`、目标邮箱/账号、租户/工作区、角色、邀请人、有效期、权限版本和审计身份。
- 旧邀请链接、旧邮件入口、旧复制链接、旧 Toast、旧任务入口和浏览器历史在撤销、过期、角色变更、租户/工作区切换、权限变化、会话过期或重复邀请后失效或重新证明安全。
- 重新发送邀请不会创建重复成员，也不能绕过权限复核。
- 无权限用户不能通过邀请错误、搜索结果、邮箱补全、列表数量、Toast、Notification、审计摘要或 DOM/ARIA 推断成员姓名、邮箱、角色、邀请状态、外部身份、成员是否存在或内部 ID。
- 角色 Select 只能编辑 `roleAssignmentState` 草稿；确认前不得改变已生效角色，确认前请求数为 0。
- 保存角色变更绑定当前成员版本、角色版本、权限版本、租户/工作区、操作者身份和目标角色快照。
- 提升管理员、降低管理员、修改外部成员权限、跨租户/工作区授权、批量角色变更、影响自身权限或影响最后 owner 的操作进入 `risk-actions.md`，必要时进入 `auth-session-reauth.md`。
- 移除成员、禁用成员、启用成员、恢复成员、转移 owner、移除最后管理员、移除自己、禁用自己、批量移除或批量禁用进入 `risk-actions.md`。
- Switch/Toggle 不能直接启停成员；若保留开关视觉，只能作为打开风险确认承载面的入口。
- 权限、会话、账号、身份、租户/工作区、角色版本、成员版本或对象状态变化后，旧成员列表、旧角色 Select、旧邀请链接、旧菜单、旧按钮、旧确认面板、旧 Toast/Notification、旧审计跳转、旧焦点目标和旧 ARIA 引用失效或重算。
- 迟到请求、缓存回放、浏览器 Back、任务中心回调、邮件链接 callback 和审计跳转只有在 `membershipOwnerId`、租户/工作区、成员版本、权限版本和请求身份仍匹配时才能写回。
- 未知结果不会伪装成角色变更成功、邀请成功、撤销成功、移除成功或禁用成功。
- Toast、Notification 和 Banner 只能辅助提示，不能作为唯一结果回执、唯一邀请恢复入口、唯一审计入口、唯一错误说明或唯一权限原因。
- 移动端保留邀请成员、成员状态、角色说明、角色变更确认、撤销邀请、重新发送邀请、禁用原因、移除/恢复路径、转移 owner、审计入口、权限说明和错误恢复。
- 真实浏览器、移动端设备、屏幕阅读器、真实邀请邮件/链接、真实权限切换、真实会话过期、真实重新认证、真实成员角色变更和真实审计写入检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。
```

- [ ] **Step 3: Write Ruby audit script**

Create `docs/testing/members-invitations-access/members-invitations-access-audit.rb`. It must:

- read `references/members-invitations-access.md`, `SKILL.md`, `README.md`, `HANDOFF.md`, and both evidence summaries;
- require owner terms including `membershipAccessState`, every state field, every membership status value, draft role semantics, invitation invalidation, risk owner transfer, stale state cleanup, no-leakage, Toast boundary, mobile recovery, and `未验证`;
- require route terms in `SKILL.md`;
- require summary terms in `README.md` and `HANDOFF.md`;
- require evidence terms in RED/GREEN;
- support `--mutations` with deletions for at least:
  - `missing-owner-state`
  - `ordinary-user-row`
  - `status-merged`
  - `invitation-binding-missing`
  - `old-invite-link-survives`
  - `resend-duplicates-member`
  - `permission-leaks-member`
  - `role-select-direct-submit`
  - `role-save-binding-missing`
  - `admin-role-change-bypasses-risk`
  - `member-remove-bypasses-risk`
  - `switch-directly-toggles-member`
  - `request-before-confirm`
  - `stale-member-state-survives`
  - `late-callback-writes-back`
  - `unknown-result-as-success`
  - `toast-only-receipt`
  - `mobile-recovery-removed`
  - `runtime-boundary-marked-verified`
  - `missing-skill-route`

- [ ] **Step 4: Run audit to verify RED failure**

Run:

```bash
ruby docs/testing/members-invitations-access/members-invitations-access-audit.rb --mutations
```

Expected: FAIL before `references/members-invitations-access.md`, route, README, and HANDOFF updates exist. The failure should include missing `references/members-invitations-access.md`.

### Task 2: Implement the owner and route

**Files:**
- Create: `references/members-invitations-access.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: audit contract from Task 1 and design spec `docs/superpowers/specs/2026-07-29-members-invitations-access-management-interaction-standards-design.md`
- Produces: routed owner document and discoverable Chinese summaries

- [ ] **Step 1: Create owner document**

Write `references/members-invitations-access.md` in Chinese. It must include sections:

- `# 成员、邀请与团队访问管理交互规范`
- `## 范围`
- `## Owner State`
- `## 成员不是普通用户行`
- `## 邀请链接和身份边界`
- `## 角色变更`
- `## 移除、禁用、启用和转移 Owner`
- `## 权限、会话和租户收敛`
- `## 审计与反馈不泄露`
- `## 移动端与可访问性`
- `## 完成前检查`

The owner must include the exact audit anchor phrases:

- `成员、邀请和角色不能只按普通用户行展示`
- `成员状态、邀请状态、角色状态、权限状态和认证状态必须分开表达`
- `邀请成员必须绑定 `invitationState`、目标邮箱/账号、租户/工作区、角色、邀请人、有效期、权限版本和审计身份`
- `旧邀请链接、旧邮件入口、旧复制链接、旧 Toast、旧任务入口和浏览器历史`
- `必须在撤销、过期、角色变更、租户/工作区切换、权限变化、会话过期或重复邀请后失效或重新证明安全`
- `重新发送邀请不得创建重复成员或绕过权限复核`
- `无权限用户不得通过邀请错误、搜索结果、邮箱补全、列表数量或审计摘要推断成员是否存在`
- `角色 Select 只能编辑 `roleAssignmentState` 草稿`
- `确认前不得改变已生效角色，不得发起真实请求`
- `保存角色变更必须读取当前成员版本、角色版本、权限版本、租户/工作区、操作者身份和目标角色快照`
- `提升为管理员、降低管理员、修改外部成员权限、跨租户/工作区授权、批量角色变更、影响自身权限或影响最后 owner 的操作必须进入 `risk-actions.md``
- `移除成员、禁用成员、启用成员、恢复成员、转移 owner、移除最后管理员、移除自己、禁用自己、批量移除或批量禁用都必须进入 `risk-actions.md``
- `不能用 Switch/Toggle 直接启停成员`
- `确认前请求数为 0`
- `旧成员列表、旧角色 Select、旧邀请链接、旧菜单、旧按钮、旧确认面板、旧 Toast/Notification、旧审计跳转、旧焦点目标和旧 ARIA 引用必须失效或重算`
- `迟到请求、缓存回放、浏览器 Back、任务中心回调、邮件链接 callback 和审计跳转只有在 `membershipOwnerId`、租户/工作区、成员版本、权限版本和请求身份仍匹配时才能写回`
- `未知结果不能伪装成角色变更成功、邀请成功、撤销成功、移除成功或禁用成功`
- `Toast、Notification、Banner 只能辅助提示`
- `不能作为唯一结果回执、唯一邀请恢复入口、唯一审计入口、唯一错误说明或唯一权限原因`
- `移动端不得删除邀请成员、成员状态、角色说明、角色变更确认、撤销邀请、重新发送邀请、禁用原因、移除/恢复路径、转移 owner、审计入口、权限说明和错误恢复`
- `未验证`

- [ ] **Step 2: Add route in `SKILL.md`**

Insert near permissions/auth/risk or data-table routes:

```markdown
- 涉及成员、团队成员、工作区成员、组织成员、用户管理、账号管理、邀请成员、邀请链接、重新发送邀请、撤销邀请、接受邀请、拒绝邀请、邀请过期、角色、角色变更、权限角色、成员角色、Owner、转移 Owner、管理员、外部成员、访客、移除成员、禁用成员、启用成员、恢复成员、成员状态、成员审计，或 member、members、team member、workspace member、organization member、user management、account management、invite member、invitation、invite link、resend invite、revoke invite、accept invite、decline invite、expired invite、role、role change、member role、owner、transfer owner、admin、external member、guest、remove member、disable member、enable member、restore member、member status、membership audit 时，必须完整读取 `references/members-invitations-access.md`。
```

- [ ] **Step 3: Update README summary**

In `README.md`, add `成员、邀请与团队访问管理` to the current standards sentence, add a summary bullet:

```markdown
- 成员、邀请与团队访问管理规范约束成员列表、邀请成员、邀请链接、重新发送/撤销邀请、角色变更、移除/禁用/启用成员、转移 Owner、外部成员、旧邀请链接失效、权限/会话/租户收敛、审计不泄露、Toast 边界和移动端恢复路径。
```

Also add a Markdown link for `成员、邀请与团队访问管理交互规范` pointing to `references/members-invitations-access.md` in the complete rules list and add `members-invitations-access.md` to the directory tree.

- [ ] **Step 4: Update HANDOFF summary**

In `HANDOFF.md`, add a Chinese section near permissions/auth/risk:

```markdown
### 成员、邀请与团队访问管理

- 已定义成员列表、邀请成员、重新发送邀请、撤销邀请、接受/拒绝邀请、邀请过期、角色变更、移除成员、禁用/启用成员、恢复成员、转移 Owner、外部成员和成员审计的 owner。
- 成员状态、邀请状态、角色状态、权限状态和认证状态必须分开表达；待邀请、邀请过期、已撤销、已禁用、已移除、外部成员、需要转移 Owner 和未知结果不得合并成普通状态标签或 Switch。
- 邀请成员必须绑定目标邮箱/账号、租户/工作区、角色、邀请人、有效期、权限版本和审计身份；旧邀请链接、旧邮件入口、旧复制链接、旧 Toast、旧任务入口和浏览器历史在撤销、过期、角色变更、租户/工作区切换、权限变化、会话过期或重复邀请后失效。
- 角色 Select 只能编辑 `roleAssignmentState` 草稿；确认前不得改变已生效角色，确认前请求数为 0。
- 管理员升降级、外部成员权限、跨租户/工作区授权、批量角色变更、影响自身权限或影响最后 Owner 的操作必须进入 `risk-actions.md`，必要时进入 `auth-session-reauth.md`。
- 移除、禁用、启用、恢复、转移 Owner、移除最后管理员、移除自己、禁用自己、批量移除或批量禁用必须进入 `risk-actions.md`；不能用 Switch/Toggle 直接启停成员。
- 权限、会话、账号、身份、租户/工作区、角色版本、成员版本或对象状态变化后，旧成员列表、旧角色 Select、旧邀请链接、旧菜单、旧确认面板、旧 Toast/Notification、旧审计跳转、旧焦点目标和旧 ARIA 引用必须失效或重算。
- 审计和反馈不得向无权限用户泄露成员姓名、邮箱、角色、邀请状态、外部身份、成员是否存在、内部 ID、邀请链接或旧缓存。
- 移动端不得删除邀请成员、成员状态、角色说明、角色变更确认、撤销邀请、重新发送邀请、禁用原因、移除/恢复路径、转移 Owner、审计入口、权限说明和错误恢复。
- 详细规则和可执行验收仅维护在 `references/members-invitations-access.md`，本交接不重复其状态模型或检查项。
```

- [ ] **Step 5: Run audit to verify GREEN**

Run:

```bash
ruby docs/testing/members-invitations-access/members-invitations-access-audit.rb --mutations
```

Expected: all mutation checks print `EXPECTED_FAIL`, then final PASS.

### Task 3: Verify integration and commit

**Files:**
- Inspect: all files modified by Tasks 1-2
- Modify only if checks reveal gaps: `docs/testing/members-invitations-access/members-invitations-access-audit.rb`, `references/members-invitations-access.md`, `SKILL.md`, `README.md`, `HANDOFF.md`

**Interfaces:**
- Consumes: outputs from Tasks 1-2
- Produces: pushed `main` commit containing the new owner

- [ ] **Step 1: Run focused and adjacent audits**

Run:

```bash
ruby docs/testing/members-invitations-access/members-invitations-access-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/auth-session-reauth/auth-session-reauth-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb --mutations
ruby docs/testing/data-tables/data-tables-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
```

Expected: all commands exit 0. If `docs/testing/data-tables/data-tables-audit.rb` does not exist, use the admin-console/data-table audit command already present in the repository and document the exact substitute in the final response.

- [ ] **Step 2: Run the full audit suite**

Run:

```bash
for f in docs/testing/admin-console/admin-console-audit.rb docs/testing/adoption/adoption-audit.rb docs/testing/buttons/buttons-audit.rb docs/testing/charts-visualization/charts-visualization-audit.rb docs/testing/date-time-ranges/date-time-ranges-audit.rb docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb docs/testing/feedback-states/feedback-states-audit.rb docs/testing/global-feedback/global-feedback-audit.rb docs/testing/information-display/information-display-audit.rb docs/testing/navigation-routing/navigation-routing-audit.rb docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb docs/testing/query-filters/query-filters-audit.rb docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb docs/testing/risk-actions/risk-actions-audit.rb docs/testing/search-command-palette/search-command-palette-audit.rb docs/testing/selection-controls/selection-controls-audit.rb docs/testing/tree-hierarchy/tree-hierarchy-audit.rb docs/testing/uploads-imports/uploads-imports-audit.rb docs/testing/wizards-steppers/wizards-steppers-audit.rb docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb docs/testing/audit-log-activity-history/audit-log-activity-history-audit.rb docs/testing/status-lifecycle-transitions/status-lifecycle-transitions-audit.rb docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb docs/testing/settings-preferences-configuration/settings-preferences-configuration-audit.rb docs/testing/auth-session-reauth/auth-session-reauth-audit.rb docs/testing/secrets-credentials/secrets-credentials-audit.rb docs/testing/members-invitations-access/members-invitations-access-audit.rb; do ruby "$f" --mutations || exit 1; done
```

Expected: all commands exit 0.

- [ ] **Step 3: Run Markdown link and diff checks**

Run:

```bash
ruby -e 'files = Dir["README.md", "HANDOFF.md", "SKILL.md", "references/*.md", "docs/**/*.md"]; missing = []; files.each do |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |href| next if href =~ /\Ahttps?:/; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target); end; end; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
git diff --check
```

Expected: both commands exit 0.

- [ ] **Step 4: Review diff and commit**

Run:

```bash
git diff -- references/members-invitations-access.md SKILL.md README.md HANDOFF.md docs/testing/members-invitations-access/members-invitations-access-audit.rb docs/testing/members-invitations-access/green-summary.md docs/testing/members-invitations-access/red-summary.md
git status --short
```

Expected: only the owner, route, summaries, and audit files are modified or newly added.

Commit:

```bash
git add references/members-invitations-access.md SKILL.md README.md HANDOFF.md docs/testing/members-invitations-access/members-invitations-access-audit.rb docs/testing/members-invitations-access/green-summary.md docs/testing/members-invitations-access/red-summary.md
git commit -m "docs: 新增成员邀请访问管理规范"
```

- [ ] **Step 5: Push to main**

Run:

```bash
git status --short --branch
git push origin main
git status --short --branch
git log --oneline -3
```

Expected: branch `main` is aligned with `origin/main`, and latest commit is `docs: 新增成员邀请访问管理规范`.
