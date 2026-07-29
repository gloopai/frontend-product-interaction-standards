# 权限、租户与可见性交互规范设计

## 背景

管理台几乎所有页面都依赖权限、角色、租户/工作区、对象状态和能力开关。现有 `admin-console.md`、`buttons.md`、`data-tables.md`、`navigation-routing.md`、`async-jobs-task-center.md` 等文件都包含权限片段，但缺少一个专门 owner 来统一约束：

- 权限、租户/工作区、角色或权限版本变化后，旧数据、旧菜单、旧按钮、旧确认、旧下载和旧任务入口如何收敛。
- 隐藏、禁用、只读、不可用和未启用能力如何区分。
- 无权限状态如何提供恢复路径，同时不泄露对象名称、数量、字段、文件名、路径、内部 ID、旧缓存或旧可访问名称。
- 权限解析和 UI 可见性、请求参数、结果回执、审计和任务中心之间如何保持一致。

这是管理台高频、高风险、横切性的基础能力，适合新增 `references/permissions-tenancy-visibility.md` 作为权限、租户/工作区和可见性的唯一事实来源。

## 目标

新增“权限、租户与可见性”规范 owner，覆盖 RBAC、ABAC、权限矩阵、角色、能力开关、租户切换、工作区切换、权限降级、权限升级、无权限状态、只读状态、禁用原因、隐藏入口、旧缓存清理和安全恢复。

该 owner 的核心目标：

1. 固定权限解析状态模型，避免组件只用 `canEdit`、`disabled`、`hidden` 或后端 403 临时兜底。
2. 明确隐藏、禁用、只读、未启用和无权限的语义差异。
3. 要求权限/租户/工作区/角色变化后原子收敛 UI、state、handler、request、cache、focus 和可访问名称。
4. 防止无权限状态通过 DOM、ARIA、tooltip、搜索结果、错误明细、下载链接、旧缓存或日志泄露敏感信息。
5. 保证移动端折叠和响应式转换不会删除权限说明、申请权限、切换租户/工作区、只读原因或安全恢复路径。

## 非目标

- 不定义后端授权模型、策略引擎、鉴权服务、组织架构或账号体系。
- 不替代按钮、表格、表单、导航、任务、上传、风险确认或全局反馈 owner 的局部交互。
- 不规定某个组件库、RBAC 框架或权限 DSL 的实现方式。
- 不把某个业务项目的角色、菜单或资源命名写入共享规范。

## 推荐方案

采用完整横切 owner 方案：新增 `permissionVisibilityState`，并同步接入 Skill 路由、README、HANDOFF 和结构化审计。

对比其他方案：

- 只增强 `admin-console.md`：改动小，但组件级权限状态仍缺 owner，按钮、表格、导航、下载、任务中心会继续各自解释。
- 只写按钮/菜单权限补充：能挡一部分入口残留，但挡不住旧数据、旧缓存、旧请求、旧下载和旧错误明细泄露。
- 完整 owner：成本略高，但边界最清楚，能作为所有组件 owner 的权限事实来源。

## 状态模型

`permissionVisibilityState` 至少包含：

| 字段 | 语义 |
| --- | --- |
| `permissionOwnerId` | 当前权限解析 owner 稳定身份。 |
| `principalSnapshot` | 当前用户、角色、组织、租户、工作区、权限版本和认证状态快照。 |
| `resourceSnapshot` | 页面、记录、字段、文件、任务、菜单、操作、报表或外部系统目标快照。 |
| `capabilityMatrix` | 查看、创建、编辑、删除、导出、下载、取消、重试、审批、配置等能力解析结果。 |
| `visibilityState` | `visible`、`hidden-by-permission`、`disabled-by-permission`、`read-only`、`not-enabled`、`pending-resolution`、`permission-denied`。 |
| `reasonState` | 可展示原因、安全占位、申请权限路径、切换租户/工作区路径和不可泄露内容。 |
| `dataBoundary` | 可见字段、可见行、可见数量、可见聚合、脱敏规则和旧数据清理策略。 |
| `actionBoundary` | DOM、state、handler、request 和审计的零值证据或可执行请求身份。 |
| `cacheBoundary` | 旧菜单、旧搜索结果、旧下载、旧任务、旧错误、旧表单草稿和旧快照失效策略。 |
| `focusBoundary` | 权限收敛、入口移除、只读转换和恢复路径的焦点迁移规则。 |
| `a11yBoundary` | 可访问名称、描述、公告、禁用原因、只读说明和无泄露 ARIA 策略。 |
| `responsivePolicy` | 移动端权限说明、申请权限、租户/工作区切换、安全占位和恢复路径保留策略。 |

## 核心规则

### 语义区分

隐藏、禁用、只读、未启用和无权限不是同一件事：

- 隐藏表示当前主体不应知道或不应访问该入口。
- 禁用表示入口可见但当前上下文不可执行，并且原因可安全展示。
- 只读表示信息可见但不可编辑。
- 未启用表示产品或配置没有启用该能力，DOM、state、handler 和 request 入口均为 0。
- 无权限表示权限不足，必须提供安全说明或恢复路径，但不得泄露敏感内容。

### 原子收敛

权限、租户/工作区、角色、认证状态、对象状态、权限版本或资源版本变化后，必须原子重算可见数据、菜单、按钮、表单字段、筛选项、导航、下载、任务入口、确认面板和缓存。无法证明安全的旧内容先隐藏、失效或替换为安全占位。

旧可见数据、旧菜单、旧按钮、旧确认、旧下载链接、旧任务入口、旧错误明细、旧搜索结果、旧表单草稿、旧图表明细和旧 ARIA label 不得继续暴露。

### 无泄露

无权限状态不得泄露对象名称、数量、字段、文件名、路径、父子关系、导出范围、错误明细、任务结果、搜索摘要、内部 ID、图标、排序位置、旧缓存或旧可访问名称。tooltip、popover、disabled reason、DOM 属性、ARIA label、日志和缓存摘要同样受约束。

### 请求和审计

任何会改变数据、读取敏感数据、下载文件、导出、取消任务、重试任务或查看错误明细的操作，都必须绑定当前 `principalSnapshot`、`resourceSnapshot`、`capabilityMatrix` 和权限版本。权限冲突、版本过期、租户/工作区切换或对象状态变化必须进入冲突、重新确认、只读、安全占位或恢复路径，不能继续执行旧请求。

### 移动端

移动端不得删除权限说明、只读原因、禁用原因、申请权限、切换租户/工作区、安全占位、重新认证或恢复路径。低频权限详情可以折叠，但必须可发现、可触达、可键盘/辅助技术访问。

## 路由与集成

`SKILL.md` 需要新增路由，命中词包括：

- 中文：权限、角色、RBAC、ABAC、租户、工作区、权限降级、权限升级、权限版本、无权限、只读、隐藏入口、禁用原因、申请权限、权限矩阵、能力开关、可见性、权限泄露、旧缓存、旧菜单、旧下载链接。
- 英文：permission、permissions、role、RBAC、ABAC、tenant、workspace、permission denied、read only、read-only、hidden by permission、disabled by permission、permission version、capability matrix、feature flag、visibility、access control、stale permission、permission leakage。

`README.md` 和 `HANDOFF.md` 加入摘要与链接；详细规则只维护在 `references/permissions-tenancy-visibility.md`。

## 审计设计

新增 `docs/testing/permissions-tenancy-visibility/`：

- `green-summary.md`：正确证据，覆盖状态模型、语义区分、原子收敛、无泄露、请求权限绑定、移动端能力和未验证边界。
- `red-summary.md`：错误证据，覆盖只靠 `canEdit` / disabled、隐藏/禁用/只读混用、旧菜单残留、旧下载可用、ARIA 泄露、移动端删除权限恢复、运行时误标验证。
- `permissions-tenancy-visibility-audit.rb`：检查 owner、路由、README、HANDOFF、红绿证据和项目名泄露。

## 验证计划

1. 提交设计文档。
2. 编写实施计划并提交。
3. 实现 owner、路由、README、HANDOFF、红绿证据和审计脚本。
4. 运行新增审计突变测试。
5. 运行全量已维护审计、Markdown 链接检查和 `git diff --check`。
6. 提交实现并推送 `main`。

## 自检

- 没有占位项、空白决策或未收束的小尾巴。
- 范围聚焦权限、租户和可见性，不替代后端授权或组件局部交互。
- 原子收敛、无泄露、请求绑定、移动端保留和未验证边界均有明确设计。
