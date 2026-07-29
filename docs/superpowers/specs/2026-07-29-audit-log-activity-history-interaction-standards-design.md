# 审计日志与操作历史交互规范设计

## 背景

管理台常见审计日志、操作历史、活动时间线、对象变更记录和任务回执。现有 `admin-console.md`、`risk-actions.md`、`date-time-ranges.md`、`information-display.md` 和 `data-tables.md` 都包含审计片段，但缺少一个独立 owner 来统一约束：

- 审计记录和普通业务列表、消息通知、任务结果、操作回执之间的边界。
- 事件发生时间、写入时间、展示时区、数据延迟和筛选范围如何说明。
- 审计记录的主体、目标、动作、请求身份、结果、来源和证据快照如何绑定。
- 无权限用户是否能看到对象名称、字段、文件名、数量、旧值、新值、IP、设备、错误明细或内部 ID。
- 审计导出、复制、跳转、查看详情和追溯链路如何复核权限。

审计日志是管理台安全可信度的基础，适合新增 `references/audit-log-activity-history.md`，作为审计证据、操作历史和活动时间线的唯一事实来源。

## 目标

新增“审计日志与操作历史”规范 owner，覆盖 audit log、activity log、operation history、event log、change history、timeline、审计日志、操作历史、活动记录、事件日志、变更记录、时间线、审计详情、审计导出、追溯链路和操作回执。

核心目标：

1. 固定 `auditLogState`，避免把审计日志当成普通表格或普通详情页。
2. 明确审计证据必须绑定主体、目标、动作、时间、请求身份、结果、权限版本和来源 owner。
3. 区分事件发生时间、写入时间、展示时区、筛选范围、数据延迟和审计可用性。
4. 防止无权限状态通过日志内容、筛选选项、数量、导出文件、ARIA、旧缓存或错误详情泄露敏感信息。
5. 保证移动端不删除筛选、时间语义、审计详情、追溯路径、导出权限说明和恢复路径。

## 非目标

- 不定义后端审计存储、签名、不可篡改账本、日志采集、SIEM 或合规制度。
- 不替代表格、查询筛选、日期时间、权限、危险操作、异步任务或全局反馈 owner。
- 不规定某个业务项目的审计字段、角色名称或资源类型。

## 推荐方案

采用完整 owner 方案：新增 `auditLogState`，并接入 Skill 路由、README、HANDOFF 和结构化审计。

对比其他方案：

- 只增强 `admin-console.md`：能补页面级要求，但审计详情、操作历史、对象时间线和导出仍缺统一证据模型。
- 只补 `data-tables.md`：能约束审计日志表格，但无法覆盖审计详情、时间线、追溯链、导出和结果回执。
- 完整 owner：边界最清楚，能和权限、时间、表格、任务、危险操作组合执行。

## 状态模型

`auditLogState` 至少包含：

| 字段 | 语义 |
| --- | --- |
| `auditOwnerId` | 当前审计日志、操作历史或时间线 owner 稳定身份。 |
| `auditSurface` | `audit-log`、`activity-log`、`operation-history`、`change-history`、`timeline`、`audit-detail`、`audit-export`。 |
| `eventIdentity` | 审计事件 ID、事件类型、来源系统、幂等键或请求身份。 |
| `actorSnapshot` | 操作主体、主体类型、租户/工作区、角色和脱敏策略。 |
| `targetSnapshot` | 目标对象、对象类型、字段、范围、旧值/新值和脱敏策略。 |
| `actionSnapshot` | 动作、风险等级、来源 owner、请求身份、任务身份和结果。 |
| `timeSemantics` | 事件发生时间、写入时间、展示时区、存储时区、数据延迟和筛选范围。 |
| `integrityState` | 审计可用性、延迟、缺口、修正、重复、顺序未决和来源可信度说明。 |
| `permissionBoundary` | 查看列表、查看详情、查看字段、复制、导出、跳转和追溯的权限版本。 |
| `filterSnapshot` | 已应用筛选、搜索、时间范围、主体、动作、目标、结果和 URL 安全策略。 |
| `exportState` | 审计导出范围、权限复核、敏感字段、文件有效期、下载身份和审计导出回执。 |
| `feedbackState` | loading、empty、zero-results、partial、stale、permission-denied、error、recovery。 |
| `a11yPolicy` | 表格/时间线/详情语义、公告、焦点、可访问名称和无泄露描述。 |
| `responsivePolicy` | 移动端筛选、时间线、详情、导出、追溯路径和恢复路径保留策略。 |

## 核心规则

### 证据边界

审计记录不是普通列表行，也不是 Toast 成功文案。每条可展示审计记录必须绑定 `eventIdentity`、`actorSnapshot`、`targetSnapshot`、`actionSnapshot`、`timeSemantics`、`permissionBoundary` 和来源 owner。缺少证据身份的操作历史只能作为普通活动提示，不能写成审计日志。

### 时间语义

审计日志必须区分事件发生时间、审计写入时间、展示时区、存储时区、筛选范围、数据延迟和刷新时间。用户可见“今天”“昨天”“近 7 天”等相对时间时，审计回执、导出和离线阅读上下文必须补充绝对日期。

### 权限与无泄露

无权限审计不得泄露主体名称、目标名称、字段名、旧值、新值、数量、文件名、IP、设备、地理位置、错误明细、内部 ID、请求参数、导出范围、任务结果或旧缓存。无权限可以显示安全泛化说明和申请权限路径，但不能通过筛选候选、数量、排序位置、空态文案、导出文件名、ARIA label 或日志详情泄露。

### 完整性和结果

审计列表必须区分 loading、empty、zero-results、partial、stale、permission-denied、error 和 audit-unavailable。审计缺口、延迟、重复、顺序未决、来源不可用和修正记录必须明确说明，不能伪装成完整日志。

### 导出和追溯

审计导出、复制、跳转、查看详情、查看关联任务、查看风险回执和追溯链路必须复核权限、租户/工作区、筛选快照、时间范围、敏感字段和请求身份。旧导出链接、旧详情页、旧查询 URL 和旧缓存不得绕过权限复核。

### 移动端

移动端不得删除筛选、时间范围、时区说明、数据延迟、审计详情、追溯路径、导出权限说明、无权限说明或恢复路径。时间线可以折叠字段，但必须保留主体、动作、目标安全摘要、结果、时间语义和查看详情路径。

## 路由与集成

`SKILL.md` 需要新增路由，命中词包括：

- 中文：审计日志、操作历史、活动记录、事件日志、变更记录、审计详情、审计导出、审计回执、追溯链路、操作记录、登录日志、访问日志、时间线。
- 英文：audit log、activity log、operation history、event log、change history、audit detail、audit export、audit receipt、traceability、operation record、login log、access log、timeline。

## 审计设计

新增 `docs/testing/audit-log-activity-history/`：

- GREEN 证据覆盖状态模型、证据绑定、时间语义、无泄露、完整性状态、导出复核、移动端保留和未验证边界。
- RED 证据覆盖普通表格伪装审计、缺证据身份、混淆发生/写入时间、无权限泄露、旧导出绕过、缺口伪装完整、移动端删详情、运行时误标验证。
- Ruby 审计检查 owner、路由、README、HANDOFF、红绿证据和项目名泄露。

## 验证计划

1. 提交设计文档。
2. 编写实施计划并提交。
3. 实现 owner、路由、README、HANDOFF、红绿证据和审计脚本。
4. 运行新增审计突变测试。
5. 运行全量已维护审计、Markdown 链接检查和 `git diff --check`。
6. 提交实现并推送 `main`。

## 自检

- 没有占位项、空白决策或未收束的小尾巴。
- 范围聚焦审计证据与操作历史，不替代后端审计系统或其他局部 owner。
- 证据身份、时间语义、无泄露、完整性状态、导出复核、移动端保留和未验证边界均已明确。
