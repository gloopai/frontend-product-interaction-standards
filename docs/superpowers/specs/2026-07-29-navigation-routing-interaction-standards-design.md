# 导航与路由交互规范设计

## 背景

当前规范已经覆盖管理台治理中的导航状态、未保存离开保护和返回重校验，但还缺少一个职责单一的导航 owner。业务项目里常见高频问题包括：从列表进入详情后返回丢失筛选和页码；浏览器 Back 绕过未保存确认；面包屑跳到错误层级；Tabs 被当作跨资源导航；权限或租户变化后仍能返回旧对象；Dialog/Drawer 关闭和页面返回语义混用；移动端返回按钮、系统手势和应用内返回不一致。

这些问题横跨列表、详情、编辑页、设置页、任务中心、报表和管理台。它们不是某个按钮或表格能单独负责的，而是“用户如何理解当前位置、如何安全离开、如何回到来源上下文”的页面级交互。

本设计新增 `references/navigation-routing.md`，作为导航入口、返回策略、面包屑、Tabs、浏览器历史、路由离开保护、来源上下文恢复和权限重校验的唯一事实来源。

## 目标

- 新增 `references/navigation-routing.md`，覆盖导航入口、应用内返回、浏览器 Back/Forward、面包屑、Tabs、路由切换、离开保护、来源上下文和焦点恢复。
- 定义 `navigationState`：当前位置、来源、返回策略、历史意图、可恢复查询上下文、权限版本、dirty blockers、focusRestoreTarget 和 disposal 记录。
- 明确列表→详情→编辑→返回的上下文恢复：筛选、排序、分页、选择、滚动、焦点、权限和数据版本必须有边界。
- 防止浏览器 Back、面包屑、Tabs、关闭按钮和路由跳转绕过未保存更改、危险确认或不可安全中断任务。
- 与 Query Filter、Data Table、Record Editing Surfaces、Form、Dialog/Drawer、Admin Console、Feedback States 和 Responsive owner 组合。
- 建立 RED/GREEN 文档压力测试和结构化审计，确保常见导航违规形态可被抓住。

## 非目标

- 不定义信息架构全量菜单、权限菜单树、路由库 API、URL 设计规范或 SEO。
- 不替代 Dialog/Drawer 的关闭生命周期、Form 的 dirty 保护、Data Table 的查询快照、Query Filter 的 URL 同步或 Admin Console 的权限安全收敛。
- 不覆盖营销站导航、公共官网导航、复杂图形编辑器画布导航或移动原生 App 深层导航。
- 不规定具体框架、router、history 库或组件库实现。

## 推荐方案

采用独立 Navigation / Routing owner，聚焦“当前位置、离开、返回和上下文恢复”。

### 方案对比

| 方案 | 优点 | 缺点 | 结论 |
| --- | --- | --- | --- |
| 独立 `navigation-routing.md` owner | 能统一返回、面包屑、Tabs、Back、离开保护和权限重校验；适用于管理台高频页面。 | 需要新增路由、摘要和审计，并写清与现有 owner 边界。 | 推荐。 |
| 继续只放在 Admin Console | 管理台语境直接。 | 列表/详情/编辑返回和浏览器历史也适用于非管理台业务页面；Admin 文件会继续膨胀。 | 不采用。 |
| 分散到 Button/Form/Table | 不新增文件。 | 返回语义和路由历史跨 owner，分散后容易互相绕过。 | 不采用。 |

## 首版范围

首版覆盖：

- 侧边导航、顶部导航、页面标题返回、面包屑、Tabs、详情页返回、编辑页取消/保存后返回、浏览器 Back/Forward。
- 列表、详情、编辑、设置、报表、任务中心、审计日志和管理台记录页。
- 来源上下文恢复：筛选、排序、分页、滚动、焦点、来源记录、来源任务、权限版本和数据版本。
- 未保存更改、上传/导入任务、危险确认、异步任务、权限/租户变化和 route/unmount disposal。
- PC、移动端、触摸返回、系统手势、虚拟键盘、安全区域和可访问焦点。

暂不覆盖：

- 全站信息架构设计、菜单权限配置系统、URL 风格指南、SEO、站点地图。
- 原生移动 App 深链和系统级导航栈。
- 复杂编辑器画布、地图或游戏的内部视图导航。

## 核心设计

### 1. 导航状态模型

每个页面级 owner 维护 `navigationState`：

| 字段 | 语义 |
| --- | --- |
| `routeOwnerId` | 当前页面或路由 owner。 |
| `currentLocation` | 当前路由、资源、租户/工作区、参数和 hash。 |
| `sourceContext` | 来源页面、查询条件、排序、分页、滚动、焦点、来源操作和来源记录。 |
| `returnPolicy` | `restore-source`、`go-parent`、`go-list-default`、`stay-after-save`、`explicit-target`、`blocked`。 |
| `historyIntent` | push、replace、back、forward、redirect、close-container 或 external-link。 |
| `permissionVersion` | 进入、返回和恢复时使用的权限/租户/工作区版本。 |
| `dirtyBlockers` | 表单 dirty、上传中、危险确认、不可安全中断任务等离开阻塞。 |
| `focusRestoreTarget` | 返回或切换后的焦点目标。 |
| `disposalLog` | route/unmount 时本 owner 释放或失效的资源。 |

返回不是简单 `history.back()`。每个返回入口必须声明返回目标和恢复策略；如果来源不可恢复、权限变化或数据版本失效，必须进入安全替代路径。

### 2. 返回与来源恢复

从列表、报表、任务中心或审计日志进入详情/编辑时，必须冻结来源上下文。返回时先重校验权限、租户/工作区、查询条件可用性和数据版本；可恢复时恢复来源列表、筛选、排序、分页、滚动和焦点。不可恢复时进入安全 fallback，例如父级列表默认条件、权限说明或页面标题。

保存成功后的返回、取消编辑、关闭详情 Drawer、浏览器 Back 和面包屑跳转是不同意图，不能都映射成同一个动作。编辑页取消必须处理 dirty；保存成功后返回必须明确是否恢复来源、留在当前记录、进入详情页或跳转列表。

### 3. 离开保护

路由跳转、浏览器 Back/Forward、面包屑、Tabs、菜单导航、关闭容器和外部链接都必须经过同一离开保护管线。dirty 表单、上传中、导入预检候选、危险确认、发送中的请求和不可安全中断任务不能被浏览器 Back 或 Tabs 绕过。

离开确认只关闭客户端意图，不取消已发送服务端任务。若任务已发送，导航后必须提供任务中心、结果页或状态检查路径。

### 4. 面包屑、Tabs 和导航入口

面包屑表示层级路径，不表示最近历史；点击面包屑进入父级或明确目标，不能伪装成“返回来源”。Tabs 只用于同一资源或同一任务上下文的平级视图，不应用来隐藏互不相关页面；跨资源导航必须使用导航菜单、链接或明确的页面入口。

导航入口必须有明确可访问名称和当前状态。当前导航项、当前 Tab、当前面包屑末项和页面标题必须一致，不得出现多个互相矛盾的当前位置。

### 5. 权限、安全和迟到结果

权限、租户/工作区、角色或数据范围变化后，旧导航上下文、旧面包屑标签、旧记录名、旧返回目标、旧 URL 参数和旧焦点目标都必须重新证明安全。无法证明时隐藏或替换安全说明，不得泄露旧对象名称、数量、字段或路径。

route/unmount 时必须失效当前 owner 的异步查询、延迟 focus、Toast/反馈更新、上传候选和表单回调。迟到结果只有 routeOwnerId、navigation generation、权限版本和 owner 仍匹配时才可写回。

### 6. 响应式与可访问性

移动端可折叠导航菜单、面包屑和次要入口，但不能删除返回、当前位置、未保存保护、权限说明或恢复路径。系统返回手势、浏览器 Back、应用内返回按钮和顶部返回应经过同一导航守卫。

返回后的焦点必须可预测：优先回到来源触发器、来源记录、列表摘要或页面标题；目标不存在时仅一次迁移到安全 fallback。状态变化需要可感知公告，但不得重复播报完整路由标题。

## 与现有 owner 的关系

- `query-filters.md`：来源筛选、URL 同步和默认条件由 Query Filter 管；Navigation 管来源上下文冻结和返回恢复。
- `data-tables.md`：分页、排序、选择和表格焦点由 Data Table 管；Navigation 管跨页面返回时是否恢复或失效这些状态。
- `record-editing-surfaces.md`：新增/编辑承载面和返回策略读取 Record Editing Surfaces；Navigation 补充路由级返回和历史意图。
- `forms.md`：dirty、未保存确认和提交状态由 Form 管；Navigation 保证所有离开入口经过同一 blocker。
- `dialogs.md` / `drawers.md`：容器关闭由容器 owner 管；Navigation 只在关闭导致路由变化或返回时参与。
- `admin-console.md`：权限、租户、审计和任务安全收敛归 Admin；Navigation 不得绕过这些安全边界。
- `feedback-states.md` / `global-feedback.md`：返回失败、权限 fallback 和任务继续查看的状态/消息由反馈 owner 呈现。
- `responsive-adaptive.md`：移动端手势、折叠菜单、安全区域和焦点可达由 Responsive 管。

## 新 owner 草案结构

计划新增 `references/navigation-routing.md`：

1. 范围与术语
2. 与组件 owner 的关系
3. `navigationState` 状态模型
4. 返回策略与来源上下文
5. 路由离开保护和 blockers
6. 面包屑、Tabs 和导航入口
7. 浏览器历史、URL 和外部链接
8. 权限、安全和迟到结果
9. 焦点、公告和响应式
10. 可执行验收

稳定规则族建议：

- `NAV-SCOPE-*`：范围、术语和非目标。
- `NAV-STATE-*`：navigationState、sourceContext、returnPolicy。
- `NAV-RETURN-*`：返回目标、来源恢复、fallback。
- `NAV-BLOCK-*`：离开保护、dirty、任务和危险确认。
- `NAV-STRUCT-*`：面包屑、Tabs、当前位置。
- `NAV-HISTORY-*`：browser back/forward、URL、external link。
- `NAV-PERM-*`：权限、租户、安全上下文。
- `NAV-A11Y-*`：焦点、公告、可访问名称。
- `NAV-RSP-*`：移动端、手势、安全区域。

## 路由更新

`SKILL.md` 增加触发：

- 中文：导航、返回、面包屑、路径导航、浏览器返回、路由、路由切换、离开页面、未保存离开、返回列表、详情返回、Tabs、标签页、侧边导航、顶部导航、外部链接。
- 英文：navigation、back、breadcrumb、browser back、route change、routing、leave page、unsaved leave、return to list、detail back、tabs、side navigation、top navigation、external link。

`README.md` 与 `HANDOFF.md` 增加摘要和链接，但不复制 owner 细节。

## 测试与验证策略

采用 RED/GREEN 文档压力测试：

- RED：没有 Navigation owner 时，让 fresh 输出列表详情返回、编辑页取消、面包屑、Tabs、浏览器 Back、权限变化和移动端返回设计，记录是否出现 `history.back()` 滥用、返回丢筛选、Back 绕过 dirty、Tabs 跨资源、面包屑泄露旧对象、迟到回调抢焦点等问题。
- GREEN：启用 owner 后，同样任务必须声明 `navigationState`、sourceContext、returnPolicy、dirtyBlockers、permissionVersion、focusRestoreTarget、统一离开保护、fallback 和运行时验证边界。
- 审计脚本：检查 owner 规则、路由、状态字段、history.back 禁止、来源恢复、离开保护、面包屑/Tabs 边界、权限重校验、迟到结果、移动端返回和未验证边界。

关键 mutation：

- 把返回写成直接 `history.back()`，必须失败。
- 删除 sourceContext，必须失败。
- 删除 returnPolicy，必须失败。
- 浏览器 Back 绕过 dirtyBlockers，必须失败。
- 面包屑被当作最近历史返回，必须失败。
- Tabs 用于互不相关页面，必须失败。
- 权限变化后继续显示旧对象名或旧返回目标，必须失败。
- route/unmount 后迟到回调仍写回，必须失败。
- 移动端删除返回或离开保护，必须失败。
- 把浏览器/移动端/辅助技术运行时写成已验证，必须失败。

## 验收标准

- Navigation owner 首版范围清晰，覆盖返回、面包屑、Tabs、浏览器历史、路由离开和来源恢复。
- 与 Query Filter、Data Table、Record Editing Surfaces、Form、Dialog/Drawer、Admin Console、Feedback States 和 Responsive owner 边界不冲突。
- README/HANDOFF/SKILL 只做摘要和路由，不复制 owner 细节。
- RED/GREEN 输出和审计 mutation 能覆盖核心反例。
- 未执行浏览器、屏幕阅读器、触摸设备或真实组件运行时时，所有证据必须标为未验证。
