# 管理台完整治理交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增管理台跨页面 owner，约束后台系统的信息架构、权限、风险操作、审计、导入导出、异步任务、报表口径和全局反馈。

**Architecture:** `references/admin-console.md` 是完整规则和验收的唯一 owner；`SKILL.md` 只负责路由；`README.md` 和 `HANDOFF.md` 只保留摘要和链接。先用无 owner 的新鲜应用输出建立 RED，再实现 owner 和审计脚本，最后用 fresh 场景证明规则能阻止管理台常见误判。

**Tech Stack:** Markdown、YAML、Ruby 审计脚本、Git、Codex Skill pressure tests。

## Global Constraints

- 管理台规范是跨页面 owner，不重新定义数据表格、表单、Dialog、Drawer、Select 或响应式细节。
- 报表和仪表盘默认只读展示，不自动推导选择列、行操作或批量操作。
- 列表是否支持选择、行操作、批量、导出或跳转必须由产品显式声明。
- 权限是安全边界，不是视觉开关；权限/租户变化后旧数据、旧菜单和敏感导出链接不得继续暴露。
- 风险操作不能只用 Toast 表示结果，必须留下页面内回执或可恢复状态。
- 导入、导出和异步任务必须声明快照、权限、幂等、进度、结果和失败恢复。
- 审计日志必须区分无数据、无权限、筛选无结果、服务不可用和数据延迟。
- Tooltip / Popover 不能承载唯一必读信息、唯一错误、唯一权限原因或唯一操作入口。
- 未执行浏览器、屏幕阅读器、触摸设备或真实组件运行时验证时，必须明确标为未验证。
- `docs/` 允许纳入 Git；`.superpowers/` 和 `.worktrees/` 继续忽略。

---

## File Structure

- Create: `references/admin-console.md`
  - 管理台完整规则、状态模型、验收映射和可执行验收。
- Modify: `SKILL.md`
  - 增加后台/管理台/控制台/SaaS console/internal tool 等中英文触发路由。
- Modify: `README.md`
  - 增加管理台能力摘要和 `references/admin-console.md` 链接。
- Modify: `HANDOFF.md`
  - 增加已完成管理台规范摘要，调整后续优先级。
- Create: `docs/testing/admin-console/red-*.md`
  - 无 owner RED 压力输出和诊断。
- Create: `docs/testing/admin-console/green-*.md`
  - 有 owner GREEN 压力输出和总结。
- Create: `docs/testing/admin-console/admin-console-audit.rb`
  - 静态审计 owner、应用输出和 mutation。
- Create: `docs/testing/admin-console/*-summary.md`
  - 中文记录每轮 RED/GREEN、未验证边界和审计结果。

---

### Task 1: RED 基线与失败诊断

**Files:**
- Create: `docs/testing/admin-console/red-report-dashboard.md`
- Create: `docs/testing/admin-console/red-permission-risk-console.md`
- Create: `docs/testing/admin-console/red-job-audit-console.md`
- Create: `docs/testing/admin-console/red-summary.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-27-admin-console-interaction-standards-design.md`
- Produces: 三份没有 `admin-console` owner 的 fresh 应用输出，供 Task 2 转化为硬规则和验收。

- [ ] **Step 1: 证明 admin-console owner 尚不存在**

Run:

```bash
test ! -f references/admin-console.md
rg -n "admin-console|管理台完整治理|consoleSurface|riskState|auditState|taskState" SKILL.md README.md HANDOFF.md references || true
```

Expected: `references/admin-console.md` 不存在；现有路由没有完整 owner。

- [ ] **Step 2: 运行报表/仪表盘 RED**

向新鲜代理提供此中文任务，并保存完整输出到 `docs/testing/admin-console/red-report-dashboard.md`：

```text
请为一个 SaaS 管理台的收入概览与指标明细页写中文交互方案。它包含 KPI 卡片、趋势图、明细表、时间范围筛选、导出入口和移动端查看。请说明页面能力、导航、权限、数据状态、错误、空态、报表口径、刷新、导出、反馈、键盘、ARIA、响应式和未验证边界。不要读取 admin-console 规范，因为它尚不存在；不要修改文件。
```

Expected RED symptoms to record:

- 报表被误加选择列、批量操作或行操作。
- 指标缺少口径、刷新时间、数据延迟或权限范围。
- 筛选无结果、无权限、数据延迟和服务失败混用同一空态。
- 导出入口缺少权限、敏感字段、快照、过期和下载身份。

- [ ] **Step 3: 运行权限/风险操作 RED**

向新鲜代理提供此中文任务，并保存完整输出到 `docs/testing/admin-console/red-permission-risk-console.md`：

```text
请为一个多租户后台的用户与角色管理页面写中文交互方案。它包含租户切换、RBAC 权限变化、用户列表、角色详情、删除用户、批量停用、权限变更、确认弹窗、结果提示和移动端使用。请说明页面能力、导航、权限降级、危险操作、审计、错误恢复、Toast/Alert、焦点、键盘、ARIA、响应式和未验证边界。不要读取 admin-console 规范，因为它尚不存在；不要修改文件。
```

Expected RED symptoms to record:

- 权限/租户变化后旧数据、旧菜单、旧确认或旧下载继续可见。
- 禁用控件泄露敏感对象名称、数量或字段。
- 危险操作只用 Toast 表示成功/失败，缺页面内回执和审计路径。
- 关闭确认弹窗或离开页面被伪装为服务端取消。

- [ ] **Step 4: 运行导入导出/任务/审计 RED**

向新鲜代理提供此中文任务，并保存完整输出到 `docs/testing/admin-console/red-job-audit-console.md`：

```text
请为一个运营后台的数据导入、导出任务中心和审计日志页面写中文交互方案。它包含 CSV 导入、字段映射、预检查、后台执行、错误文件、敏感导出、下载链接、任务取消、任务重试、审计日志筛选和移动端查看。请说明页面能力、权限、任务状态、审计留痕、错误恢复、全局通知、键盘、ARIA、响应式和未验证边界。不要读取 admin-console 规范，因为它尚不存在；不要修改文件。
```

Expected RED symptoms to record:

- 预检查失败仍创建执行任务。
- 导出链接未绑定权限、快照、请求身份或过期时间。
- 页面关闭被写成取消成功，取消请求被写成服务端已停止。
- 审计日志混淆无权限、无数据、筛选无结果、服务失败和延迟。

- [ ] **Step 5: 写 RED 总结**

Create `docs/testing/admin-console/red-summary.md` with sections:

```markdown
# 管理台完整治理 RED 总结

## 报表/仪表盘

- 报表默认能力：记录是否出现未声明的选择、行操作或批量操作，并标注 `red-report-dashboard.md` 的具体行号。
- 指标口径：记录是否缺少口径、刷新时间、数据延迟或权限范围，并标注 `red-report-dashboard.md` 的具体行号。
- 空态：记录是否混淆筛选无结果、无权限、数据延迟和服务失败，并标注 `red-report-dashboard.md` 的具体行号。
- 导出：记录是否缺少权限、敏感字段、快照、过期或下载身份，并标注 `red-report-dashboard.md` 的具体行号。

## 权限/风险操作

- 权限/租户变化：记录旧数据、旧菜单、旧确认或旧下载是否继续可见，并标注 `red-permission-risk-console.md` 的具体行号。
- 权限不足：记录禁用控件是否泄露敏感对象名称、数量或字段，并标注 `red-permission-risk-console.md` 的具体行号。
- 风险操作：记录是否只用 Toast 表示成功/失败且缺少页面内回执或审计路径，并标注 `red-permission-risk-console.md` 的具体行号。
- 取消边界：记录关闭确认弹窗或离开页面是否被伪装为服务端取消，并标注 `red-permission-risk-console.md` 的具体行号。

## 导入导出/任务/审计

- 导入：记录预检查失败是否仍创建执行任务，并标注 `red-job-audit-console.md` 的具体行号。
- 导出：记录导出链接是否未绑定权限、快照、请求身份或过期时间，并标注 `red-job-audit-console.md` 的具体行号。
- 异步任务：记录页面关闭是否被写成取消成功，或取消请求是否被写成服务端已停止，并标注 `red-job-audit-console.md` 的具体行号。
- 审计日志：记录是否混淆无权限、无数据、筛选无结果、服务失败和延迟，并标注 `red-job-audit-console.md` 的具体行号。

## 需要 owner 关闭的分歧

- 报表默认展示，不自动推导选择或批量。
- 权限和租户变化必须先安全降级再刷新。
- 风险操作必须有页面内回执和审计路径，Toast 不能是唯一结果。
- 导入导出和异步任务必须有快照、权限、进度、结果和恢复。
- 审计日志空态必须区分无权限、无数据、筛选无结果、服务失败和延迟。
```

Replace bracketed evidence placeholders with concrete line references from the three RED files before committing.

- [ ] **Step 6: Verify and commit**

Run:

```bash
rg -n "报表默认展示|权限和租户变化|风险操作|导入导出|审计日志空态" docs/testing/admin-console/red-summary.md
git diff --check -- docs/testing/admin-console
git add docs/testing/admin-console/red-report-dashboard.md docs/testing/admin-console/red-permission-risk-console.md docs/testing/admin-console/red-job-audit-console.md docs/testing/admin-console/red-summary.md
git commit -m "docs: 添加管理台规范 RED 基线"
```

Expected: RED 总结含具体证据；提交只包含 `docs/testing/admin-console/red-*`。

---

### Task 2: 建立 admin-console owner

**Files:**
- Create: `references/admin-console.md`

**Interfaces:**
- Consumes: Task 1 RED 症状与设计 spec。
- Produces: 管理台规则 ID、状态模型和 A1-A12 验收，供 Task 3 路由和 Task 4 审计使用。

- [ ] **Step 1: 写入会失败的 owner 断言**

Run:

```bash
test -f references/admin-console.md
rg -n "consoleSurface|navigationState|permissionState|riskState|auditState|taskState|feedbackState" references/admin-console.md
rg -n "报表默认只读|Toast.*唯一|权限.*安全边界|下载链接.*过期|审计日志.*无权限" references/admin-console.md
```

Expected: owner 不存在，命令失败。

- [ ] **Step 2: 创建范围、场景和状态模型**

Create `references/admin-console.md` with these top sections:

```markdown
# 管理台完整治理交互规范

## 范围

适用于后台、管理台、控制台、运营后台、SaaS console 和内部工具的跨页面产品治理。本文件是管理台页面级场景、权限、风险、审计、任务、报表和全局反馈的唯一事实来源。

## 与组件 owner 的关系

表格、报表、列表、分页、筛选、排序、选择和批量操作读取 `data-tables.md`；表单、设置页、编辑页和提交失败恢复读取 `forms.md`；确认、详情、编辑或结果弹窗读取 `dialogs.md` / `drawers.md`；选择器读取 `selects-comboboxes.md`；跨端布局、导航折叠和安全区域读取 `responsive-adaptive.md`。当 `admin-console` 与组件 owner 都适用时，两者都执行；冲突时停止并请用户裁决。

## 场景与状态模型

每个页面声明一个或多个 `consoleSurface`：`overview-dashboard`、`report`、`record-list`、`record-detail`、`record-editor`、`settings`、`job-center`、`audit-log`。页面级状态至少包含 `navigationState`、`permissionState`、`surfaceState`、`riskState`、`auditState`、`taskState`、`feedbackState`；组件 owner 的局部状态不得替代这些页面级 owner。
```

Use exact `consoleSurface` values from the design spec: `overview-dashboard`、`report`、`record-list`、`record-detail`、`record-editor`、`settings`、`job-center`、`audit-log`。

- [ ] **Step 3: 写 AC-IA 信息架构规则**

Add rule table with IDs:

- `AC-IA-01`: 页面标题、主内容和当前导航项必须稳定可定位。
- `AC-IA-02`: 面包屑和返回路径必须声明，返回恢复必须重校验权限、版本和范围。
- `AC-IA-03`: Tabs 只用于同一资源或任务上下文，不隐藏互不相关页面。
- `AC-IA-04`: Dirty 表单、未完成导入、危险确认和不可安全中断任务在离开前必须确认或安全中止。

Map to acceptance `AC-A1` and `AC-A2`.

- [ ] **Step 4: 写 AC-PERM 权限和租户规则**

Add rule table with IDs:

- `AC-PERM-01`: 权限/租户/工作区/角色/权限版本变化后原子计算 `resolvedSurface`、可见范围、可执行操作和可导出范围。
- `AC-PERM-02`: 无法同步证明仍可见的数据、字段、操作和导出入口先隐藏或替换安全占位。
- `AC-PERM-03`: 权限不足状态解释原因和恢复路径，但不得泄露敏感对象名称、数量或字段。
- `AC-PERM-04`: 权限降级清理选择、菜单、确认、操作快照、导入导出入口和敏感下载，焦点只迁移一次。

Map to acceptance `AC-A3` and `AC-A4`.

- [ ] **Step 5: 写 AC-RISK 风险操作规则**

Add rule table with IDs:

- `AC-RISK-01`: 风险操作必须声明 `riskLevel`、`impactScope`、`confirmationPolicy`、`requestIdentity`、`resultReceipt`。
- `AC-RISK-02`: 删除、停用、权限变更、批量修改、敏感导出、重跑、取消、清空和不可逆配置变更默认是风险操作。
- `AC-RISK-03`: 风险操作结果不能只靠 Toast，必须有页面内回执或可恢复状态。
- `AC-RISK-04`: 未知结果不得伪装成成功或失败，必须提供检查最新状态或进入任务中心路径。

Map to acceptance `AC-A5` and `AC-A6`.

- [ ] **Step 6: 写 AC-AUDIT 审计规则**

Add rule table with IDs:

- `AC-AUDIT-01`: 变更操作必须能追踪主体、时间、租户/工作区、目标、请求身份和结果。
- `AC-AUDIT-02`: 页面必须说明审计可用性、回执位置和审计失败恢复。
- `AC-AUDIT-03`: 审计日志区分无数据、无权限、筛选无结果、审计服务不可用和数据延迟。
- `AC-AUDIT-04`: 审计查询和导出不得泄露无权访问主体、对象或租户名称。

Map to acceptance `AC-A7`.

- [ ] **Step 7: 写 AC-JOB 导入导出和任务规则**

Add rule table with IDs:

- `AC-JOB-01`: 导入声明文件类型、大小、字段映射、预检查、提交快照、幂等键、部分成功、错误文件和重试。
- `AC-JOB-02`: 预检查失败不得创建执行任务；执行失败保留错误文件、行号和下一步。
- `AC-JOB-03`: 导出声明范围、筛选快照、权限范围、敏感字段、生成方式、过期时间和下载身份。
- `AC-JOB-04`: 下载链接绑定权限和请求身份，过期或权限变化后失效。
- `AC-JOB-05`: 异步任务区分排队、运行中、成功、部分成功、失败、取消中、已取消、未知结果和过期。
- `AC-JOB-06`: 关闭页面不能伪装成取消任务，取消请求不能伪装成服务端已停止。

Map to acceptance `AC-A8` and `AC-A9`.

- [ ] **Step 8: 写 AC-REPORT 和 AC-FEEDBACK 规则**

Add rule tables:

- `AC-REPORT-01`: 报表和仪表盘默认只读展示，不自动推导选择、行操作或批量。
- `AC-REPORT-02`: 指标声明口径、时间范围、刷新时间、数据延迟、权限范围和过滤条件。
- `AC-REPORT-03`: 报表空态区分当前权限无数据、筛选无结果、指标尚未产生、服务失败、数据延迟和口径不可用。
- `AC-REPORT-04`: 图表、指标卡和明细共享同一筛选/权限快照；不同范围必须说明。
- `AC-REPORT-05`: 钻取、导出和订阅是可选能力，启用时执行相关 owner，关闭时入口为 0。
- `AC-FB-01`: Toast 只能辅助反馈，不能是唯一错误、成功回执、审计凭证或恢复入口。
- `AC-FB-02`: Alert 用于页面内持续状态、阻断问题和重要恢复；Notification 用于跨页面异步任务和系统消息。
- `AC-FB-03`: Popover / Tooltip 不能承载唯一必读权限原因、错误、确认后果或操作入口。
- `AC-FB-04`: 同一完整消息只有一个 primary owner，不重复播报。

Map to acceptance `AC-A10` and `AC-A11`.

- [ ] **Step 9: 写响应式、报告契约和验收**

Add:

- `AC-RSP-01`: 移动端可折叠低频导航、筛选、列和次要操作，但核心任务、权限、错误恢复、审计回执和危险确认不能消失。
- `AC-RSP-02`: 后台页面优先扫描、比较和重复操作，不使用营销式 hero 或装饰性大卡片承载主要工作区。
- `AC-REPORTING-01`: 应用报告必须声明 `consoleSurface`、权限/租户、页面级状态 owner、风险操作、导入导出、审计、报表能力和未验证边界。
- `AC-REPORTING-02`: 不适用能力必须给出 DOM、state、handler/event、request 四类零值证据。

Add acceptance sections `AC-A1` through `AC-A12`; each has 初始状态、事件序列、预期状态、DOM/ARIA、事件日志。

- [ ] **Step 10: Verify and commit**

Run:

```bash
rg -n "AC-IA-01|AC-PERM-01|AC-RISK-01|AC-AUDIT-01|AC-JOB-01|AC-REPORT-01|AC-FB-01|AC-RSP-01|AC-REPORTING-01|AC-A12" references/admin-console.md
rg -n "consoleSurface|navigationState|permissionState|surfaceState|riskState|auditState|taskState|feedbackState" references/admin-console.md
git diff --check -- references/admin-console.md
git add references/admin-console.md
git commit -m "docs: 添加管理台完整治理规范"
```

Expected: owner 可检索所有规则族和验收；提交只包含 `references/admin-console.md`。

---

### Task 3: 路由、摘要和交接更新

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: Task 2 `references/admin-console.md`
- Produces: 自动触发路由和使用者摘要，供 Task 4 fresh agents 正确加载 owner。

- [ ] **Step 1: 写入会失败的路由断言**

Run:

```bash
rg -n "管理台|后台|控制台|console|admin|RBAC|租户|工作区|审计|导入|导出|异步任务" SKILL.md
rg -n "管理台完整治理交互规范|admin-console.md" README.md HANDOFF.md
```

Expected: 修改前缺少完整 admin-console 路由和摘要。

- [ ] **Step 2: 更新 SKILL 路由**

Add one route bullet under `## 规范路由`:

```markdown
- 涉及后台、管理台、控制台、运营后台、内部工具、SaaS console、RBAC、权限降级、租户/工作区切换、危险操作、审计日志、导入、导出、异步任务、任务中心、报表仪表盘或全局反馈，或 admin、console、dashboard、RBAC、tenant、workspace、audit log、import、export、async job、job center、notification、toast、alert、popover、tooltip 时，必须完整读取 `references/admin-console.md`。
```

- [ ] **Step 3: 更新 README 摘要**

Add management-console summary to `## 当前规范`:

```markdown
- 管理台完整治理覆盖导航、权限/租户、危险操作、审计、导入导出、异步任务、报表口径和全局反馈，并规定报表默认只读、能力显式声明、Toast 不得作为唯一回执。
```

Add `references/admin-console.md` to the complete rules link list.

- [ ] **Step 4: 更新 HANDOFF**

Update tree to include `references/admin-console.md` and add completed section:

```markdown
### 管理台完整治理

- 已定义后台、管理台、控制台、SaaS console 和内部工具的跨页面 owner。
- 报表和仪表盘默认只读展示；选择、行操作、批量、导出和钻取均需显式声明。
- 权限、租户/工作区、危险操作、审计、导入导出、异步任务、全局反馈和移动端折叠均有页面级约束。
- 详细规则和可执行验收仅维护在 [管理台完整治理交互规范](references/admin-console.md)，本交接不重复其状态模型或检查项。
```

Move future priority so Toast/Alert/Notification/Popover/Tooltip is no longer listed as wholly missing; next suggestions should become uploads beyond admin scope, complex editors/builders, charts/visualization authoring, and file/media management.

- [ ] **Step 5: Verify and commit**

Run:

```bash
rg -n "references/admin-console.md|管理台完整治理|admin|console|RBAC|audit log|async job" SKILL.md README.md HANDOFF.md
git diff --check -- SKILL.md README.md HANDOFF.md
git add SKILL.md README.md HANDOFF.md
git commit -m "docs: 路由管理台治理规范"
```

Expected: route and summaries are present; commit only touches `SKILL.md`、`README.md`、`HANDOFF.md`。

---

### Task 4: 应用审计脚本与 GREEN 压力测试

**Files:**
- Create: `docs/testing/admin-console/admin-console-audit.rb`
- Create: `docs/testing/admin-console/green-report-dashboard.md`
- Create: `docs/testing/admin-console/green-permission-risk-console.md`
- Create: `docs/testing/admin-console/green-job-audit-console.md`
- Create: `docs/testing/admin-console/green-summary.md`

**Interfaces:**
- Consumes: Task 2 owner and Task 3 route.
- Produces: 可重复审计脚本和 fresh GREEN 证据。

- [ ] **Step 1: 写审计器 RED**

Create initial `docs/testing/admin-console/admin-console-audit.rb` that reads `references/admin-console.md` and optional output files, then fails if required rule IDs, state owners, report contract, and key application clauses are missing.

Minimum constants:

```ruby
RULE_IDS = %w[
  AC-IA-01 AC-IA-02 AC-IA-03 AC-IA-04
  AC-PERM-01 AC-PERM-02 AC-PERM-03 AC-PERM-04
  AC-RISK-01 AC-RISK-02 AC-RISK-03 AC-RISK-04
  AC-AUDIT-01 AC-AUDIT-02 AC-AUDIT-03 AC-AUDIT-04
  AC-JOB-01 AC-JOB-02 AC-JOB-03 AC-JOB-04 AC-JOB-05 AC-JOB-06
  AC-REPORT-01 AC-REPORT-02 AC-REPORT-03 AC-REPORT-04 AC-REPORT-05
  AC-FB-01 AC-FB-02 AC-FB-03 AC-FB-04
  AC-RSP-01 AC-RSP-02 AC-REPORTING-01 AC-REPORTING-02
]
STATE_KEYS = %w[navigationState permissionState surfaceState riskState auditState taskState feedbackState]
SURFACES = %w[overview-dashboard report record-list record-detail record-editor settings job-center audit-log]
```

Run before GREEN outputs:

```bash
ruby docs/testing/admin-console/admin-console-audit.rb
```

Expected: owner checks pass after Task 2; application output checks fail because GREEN files do not exist.

- [ ] **Step 2: 运行三份 GREEN fresh 应用**

Use fresh agents with `SKILL.md` and the new route. Save full outputs:

- `docs/testing/admin-console/green-report-dashboard.md`
- `docs/testing/admin-console/green-permission-risk-console.md`
- `docs/testing/admin-console/green-job-audit-console.md`

Use the same user tasks as Task 1, but require agents to use `$frontend-product-interaction-standards` and read the relevant owner files. They must return only the Chinese application report and must not read prior RED/GREEN evidence.

- [ ] **Step 3: 完成审计器应用输出检查**

Extend `admin-console-audit.rb` to assert each GREEN output includes:

- `consoleSurface` declaration.
- Seven state owners.
- Explicit permission/tenant boundary or zero evidence.
- Risk operation declaration or four-class zero evidence.
- Audit availability and receipt location or zero evidence.
- Import/export/task capability or zero evidence.
- Report/dashboard read-only handling for the report scenario.
- Toast not as unique receipt/error/recovery.
- Runtime verification boundary marked unverified where not run.

For non-applicable capabilities, require DOM/state/handler/request four-class zero evidence.

- [ ] **Step 4: Add mutations**

In `--mutations`, mutate one GREEN report at a time:

- Add selection/bulk to report default without explicit capability.
- Remove metric口径 or refresh/delay.
- Change permission update to keep old data visible.
- Make dangerous operation result Toast-only.
- Make import precheck failure create job.
- Keep export link valid after permission change.
- Make page close equal task cancellation.
- Merge audit no-permission/no-data/filter-empty/service-error into one empty state.
- Put唯一权限原因 or唯一错误 only in Tooltip.
- Remove runtime verification boundary.

Each mutation must produce `EXPECTED_FAIL`.

- [ ] **Step 5: 写 GREEN 总结**

Create `green-summary.md` with:

- Three fresh output file names.
- Audit command and mutation result.
- Known unverified runtime boundaries.
- Explicit note that browser、AT、touch and real component runtime were not executed.

- [ ] **Step 6: Verify and commit**

Run:

```bash
ruby -c docs/testing/admin-console/admin-console-audit.rb
ruby docs/testing/admin-console/admin-console-audit.rb docs/testing/admin-console/green-report-dashboard.md docs/testing/admin-console/green-permission-risk-console.md docs/testing/admin-console/green-job-audit-console.md --mutations
git diff --check -- docs/testing/admin-console
git add docs/testing/admin-console/admin-console-audit.rb docs/testing/admin-console/green-report-dashboard.md docs/testing/admin-console/green-permission-risk-console.md docs/testing/admin-console/green-job-audit-console.md docs/testing/admin-console/green-summary.md
git commit -m "docs: 验证管理台治理规范应用"
```

Expected: syntax OK; audit PASS; all mutations expected-fail; commit only contains GREEN evidence and audit script.

---

### Task 5: 最终静态验证、独立复核与发布准备

**Files:**
- Modify only if verification or review finds issues:
  - `references/admin-console.md`
  - `SKILL.md`
  - `README.md`
  - `HANDOFF.md`
  - `docs/testing/admin-console/*`

**Interfaces:**
- Consumes: Tasks 1-4.
- Produces: Final reviewed branch ready for push/PR or merge decision.

- [ ] **Step 1: Run full local verification**

Run:

```bash
ruby -c docs/testing/admin-console/admin-console-audit.rb
ruby docs/testing/admin-console/admin-console-audit.rb docs/testing/admin-console/green-report-dashboard.md docs/testing/admin-console/green-permission-risk-console.md docs/testing/admin-console/green-job-audit-console.md --mutations
ruby -e 'base=Dir.pwd; bad=[]; Dir.glob("**/*.md", File::FNM_DOTMATCH).each do |f| next if f.start_with?(".git/"); text=File.read(f, encoding:"UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |href| next if href =~ /\A(?:https?:|mailto:|#)/; path=href.split("#",2)[0]; next if path.empty?; target=File.expand_path(path, File.dirname(File.join(base,f))); bad << "#{f} -> #{href}" unless File.exist?(target); end; end; if bad.empty?; puts "LINKS PASS"; else; puts bad; exit 1; end'
git diff --check
```

Expected: all pass.

- [ ] **Step 2: Run official skill validation if available**

Run:

```bash
/Users/evanqi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3 /Users/evanqi/.codex/skills/.system/skill-creator/scripts/quick_validate.py .
```

Expected: PASS if PyYAML exists. If it fails with `ModuleNotFoundError: No module named 'yaml'`, record this exact environment limitation in final summary; do not install dependencies without user approval.

- [ ] **Step 3: Independent review**

Request a reviewer to inspect:

- Owner coverage against design spec.
- Route trigger accuracy in `SKILL.md`.
- README/HANDOFF avoiding duplicated owner detail.
- RED/GREEN evidence quality.
- Audit script mutation strength and false-positive risk.
- No accidental edits to unrelated data-table evidence.

Fix Critical and Important issues; rerun Step 1 after each fix.

- [ ] **Step 4: Final commit if review fixes were made**

If Step 3 changed files, run:

```bash
git status --short
git add references/admin-console.md SKILL.md README.md HANDOFF.md docs/testing/admin-console
git commit -m "docs: 完成管理台治理规范复核"
```

Expected: no commit if no changes; otherwise commit only review fixes.

- [ ] **Step 5: Prepare integration decision**

Run:

```bash
git status --short --branch
git log --oneline origin/main..HEAD
```

Report commits, verification results and known unverified runtime boundaries. Then use `superpowers:finishing-a-development-branch` for merge/push/PR choice.
