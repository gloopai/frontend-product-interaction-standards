# 详情预览面板交互规范

适用于列表、数据表格、卡片列表、搜索结果、报表明细和管理台主从布局中的详情预览、侧边预览、预览面板、行预览、记录预览、快速查看、只读预览、Master Detail 和 Master-Detail。

本文件是“从列表上下文查看一条记录的只读摘要或详情预览”的唯一 owner。来源列表、分页、排序、选择和结果摘要仍归 `references/data-tables.md` 与 `references/list-result-controls.md`；只读字段展示、复制和状态语义仍归 `references/information-display.md`；新增、编辑、复制创建和批量配置必须转交 `references/record-editing-surfaces.md`；移动端 Bottom Sheet 或全屏预览层若具备模态覆盖关系，还必须执行 `references/drawers.md`；返回、URL 和浏览器历史读取 `references/navigation-routing.md`；权限无泄露读取 `references/permissions-tenancy-visibility.md`；加载、空态、错误和 stale 读取 `references/feedback-states.md`；跨端形态读取 `references/responsive-adaptive.md`。

文件、图片、音视频、文档在线预览的媒体渲染继续归 `references/files-media-assets.md`。本文件只定义列表来源、预览目标、预览快照、权限边界、关闭返回和只读/编辑分界。

## 范围与排除项

详情预览面板用于保持列表上下文的只读查看。它可以展示安全标题、状态、摘要字段、关键指标、审计线索、只读长文本、复制入口、打开完整详情、刷新预览和进入编辑承载面的入口。

详情预览面板不是编辑承载面、不是表格选择、不是 hover tooltip、不是行展开编辑表单，也不是危险确认容器。

| 规则 ID | 规则 |
| --- | --- |
| `PP-SCOPE-01` | 详情预览、侧边预览、预览面板、行预览、记录预览、快速查看、只读预览、Master Detail 和 Master-Detail 必须归属 `previewPaneState`。 |
| `PP-SCOPE-02` | 预览面板只负责只读查看、预览请求、预览关闭、预览切换、预览恢复和来源上下文绑定。 |
| `PP-SCOPE-03` | 预览目标不等于表格选择、不等于 hover、不等于 focus、不等于 active row，也不等于编辑目标。 |
| `PP-SCOPE-04` | 预览面板不得渲染 input、textarea、select、combobox、日期选择器、单元格编辑、行内保存按钮或任何完整字段编辑表单。 |
| `PP-SCOPE-05` | 新增、编辑、复制创建、批量配置、删除确认、停用启用、权限变更和危险操作不得在预览面板内完成；需要入口时只渲染动作按钮并转交对应 owner。 |

## `previewPaneState`

每个预览实例必须声明 `previewPaneState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `previewOwnerId` | 当前预览实例稳定 owner；不得复用表格 owner、行 ID、详情页 owner 或编辑 surface ID。 |
| `surfaceKind` | 当前承载形态：`side-pane`、`split-pane`、`bottom-sheet`、`full-screen-preview` 或 `inline-region`。 |
| `sourceBinding` | 来源列表/表格/卡片/搜索结果、已应用筛选、排序、分页/游标、滚动锚点、触发焦点、来源 owner 和能力档位快照。 |
| `activePreviewTarget` | 已提交预览对象：稳定记录 ID、对象类型、安全可见名称、租户/工作区、权限版本、资源版本和来源位置。 |
| `pendingPreviewIntent` | 等待提交或请求中的预览意图；只由明确点击、键盘激活、打开预览按钮或恢复策略创建。 |
| `previewSnapshot` | 当前可见预览字段、状态、摘要、审计线索、数据版本、刷新时间、stale、partial 和来源说明。 |
| `requestBinding` | 预览请求代次、请求快照 ID、捕获的 owner live、目标、权限版本、租户/工作区和迟到响应门禁。 |
| `permissionBoundary` | 无权限、只读、脱敏、旧缓存清理、错误明细、对象名、数量、文件名和内部 ID 的安全边界。 |
| `displayBinding` | 字段 label/value、空值、长文本、复制、状态标签、只读组件和展示 owner 的绑定。 |
| `actionBoundary` | 打开完整详情、编辑、复制、刷新、导出和危险操作入口的对象快照、权限和结果 owner。 |
| `urlHistoryBinding` | URL 是否表达当前预览、哪些字段可序列化、浏览器 Back/Forward、刷新恢复和敏感参数禁止项。 |
| `focusReturnPolicy` | 打开、切换记录、关闭、返回列表、权限收敛和来源失效时的焦点目标。 |
| `responsivePolicy` | 桌面侧边/分栏、平板、移动端底部 Drawer、全屏 Drawer 或独立详情页转换规则。 |
| `runtimeVerification` | 浏览器、键盘、读屏、触摸、断点、真实数据竞态和权限切换验证状态；未执行时必须标为未验证。 |

不得只用 `selectedRow`、`expandedRow`、`currentRecord`、`drawerOpen`、`detailData` 或路由参数替代 `previewPaneState`。

## 预览目标与来源列表

预览目标必须来自用户明确意图，不能把任何“看起来当前”的列表状态自动当成目标。

| 规则 ID | 规则 |
| --- | --- |
| `PP-TARGET-01` | 打开预览必须由行详情按钮、行键盘激活、预览入口或安全恢复策略创建 `pendingPreviewIntent`；单纯 hover、focus、active row、checkbox 选择、批量选择或滚动到某行不得打开或切换预览。 |
| `PP-TARGET-02` | `activePreviewTarget` 提交前必须冻结来源 owner、记录 ID、对象类型、租户/工作区、权限版本、资源版本和来源位置。 |
| `PP-TARGET-03` | 来源列表刷新、翻页、排序、筛选、权限降级或记录消失时，预览必须重新证明目标仍在当前允许范围内；不能用旧行索引、旧 DOM 或旧标题维持当前预览。 |
| `PP-TARGET-04` | 预览打开或切换不得清空表格选择、改变分页、应用筛选、提交搜索、改变排序、取消批量范围或启动编辑会话。 |
| `PP-TARGET-05` | 同页多个列表或多个预览实例必须以 `previewOwnerId` 和来源 owner 隔离；一个列表的预览切换不得写入另一个列表的预览面板。 |

## 只读展示与编辑边界

预览面板必须保持只读，不能成为“更方便的列表内编辑”。

| 规则 ID | 规则 |
| --- | --- |
| `PP-READONLY-01` | 预览字段使用文本、描述列表、状态标签、代码块、只读卡片、缩略图或专用只读组件展示，不得用 disabled 表单控件伪装展示文本。 |
| `PP-READONLY-02` | 预览面板不得渲染 input、textarea、select、combobox、日期选择器、单元格编辑、行内保存按钮或任何完整字段编辑表单。 |
| `PP-READONLY-03` | 排序、状态、分类、标签、标题和描述等小字段也不得在预览面板里直接可改；需要修改时只能提供“编辑”“调整状态”“编辑标签”等入口。 |
| `PP-READONLY-04` | 编辑入口只能转交记录编辑承载面，并创建独立 `editSurfaceState`；不得复用 `previewSnapshot` 作为表单草稿。 |
| `PP-READONLY-05` | 打开完整详情读取 `navigation-routing.md`；完整详情页读取 `information-display.md`，不得让预览面板承担详情页的 URL、刷新恢复和长期引用义务。 |

## 请求、迟到响应与状态承载

预览请求必须与目标快照和权限版本绑定。关闭预览只是停止当前 UI 等待，不代表服务端任务或请求结果已经结束。

| 规则 ID | 规则 |
| --- | --- |
| `PP-REQ-01` | 每次接受预览意图时建立不可变请求快照，包含 `previewOwnerId`、owner live、请求代次、预览目标、来源 owner、租户/工作区、权限版本、资源版本和展示字段范围。 |
| `PP-REQ-02` | 迟到预览响应只有同时匹配 `previewOwnerId`、owner live、请求代次、预览目标、租户/工作区和权限版本时才可提交；任一失配只记录 `preview-response-discarded`，DOM、状态、焦点和公告写入均为 0。 |
| `PP-REQ-03` | 取消旧请求只用于节省资源，不能替代 `PP-REQ-02` 门禁；已取消但迟到的响应仍需经过同一判断。 |
| `PP-REQ-04` | 初次加载、刷新失败、stale、partial、empty、permission-denied 和恢复入口必须由反馈状态 owner 承载；Toast 不能作为唯一状态或错误回执。 |
| `PP-REQ-05` | 切换预览目标时，旧目标的 loading、错误、复制回执、长文本展开、媒体预览状态和公告必须失效或隔离，不得写入新目标。 |

## 权限、脱敏与无泄露

预览往往靠近列表和搜索结果，必须比完整详情更严格地处理旧缓存和安全标题。

| 规则 ID | 规则 |
| --- | --- |
| `PP-PERM-01` | 无权限、权限降级、租户切换、记录删除或来源范围失效时，不得泄露对象名称、字段、数量、文件名、内部 ID、旧标题、旧错误或旧复制内容。 |
| `PP-PERM-02` | 权限待解析时只显示安全骨架或泛化说明；不得短暂闪现旧预览字段、旧状态、旧缩略图、旧路径或旧 ARIA label。 |
| `PP-PERM-03` | 脱敏字段必须标注脱敏状态；复制、导出、打开详情和编辑入口都必须基于当前 `permissionBoundary` 复核。 |
| `PP-PERM-04` | 无权限预览可以提供申请权限、切换工作区、返回列表或重新认证路径，但原因文案不得包含未授权对象的具体名称、数量、字段或内部 ID。 |
| `PP-PERM-05` | 来源列表仍可见不等于预览字段可见；列表行字段、预览字段、完整详情字段和导出字段必须分别证明权限。 |

## 关闭、返回与 URL

关闭预览、返回列表、浏览器返回、打开完整详情和编辑返回是不同导航意图。

| 规则 ID | 规则 |
| --- | --- |
| `PP-NAV-01` | 关闭预览不等于清空表格选择、不等于取消服务端任务、不等于提交表单、不等于路由返回。 |
| `PP-NAV-02` | 关闭预览只关闭当前 `previewOwnerId`，清理其请求、回执、展开、复制、焦点任务和临时预览状态；不得清理来源列表的查询、选择、分页或批量范围。 |
| `PP-NAV-03` | 如果 URL 表达当前预览，`urlHistoryBinding` 必须声明 push、replace、restore 和 close 语义；敏感字段、自由文本、无权对象名和内部 ID 不得进入 URL。 |
| `PP-NAV-04` | 浏览器 Back/Forward、返回列表、关闭预览和打开完整详情都必须经过 `navigation-routing.md` 的来源恢复、权限复核、焦点恢复和兜底策略。 |
| `PP-NAV-05` | 关闭后焦点优先回到仍存在、仍有权限且语义未变的触发入口；否则迁移到来源列表标题、结果摘要或安全说明，不能落到 body、页面根或已移除节点。 |

## 响应式与移动端承载

桌面侧边预览可以是非模态 split pane，也可以是模态 Drawer；移动端转换必须保留同一业务语义和状态边界。

| 规则 ID | 规则 |
| --- | --- |
| `PP-RSP-01` | 移动端可以把桌面侧边预览转换为底部 Drawer、全屏 Drawer 或独立详情页；转换规则必须由 `responsivePolicy` 声明。 |
| `PP-RSP-02` | 移动端不得删除返回列表、当前预览目标、安全标题、权限原因、错误状态、主要只读信息和恢复入口。 |
| `PP-RSP-03` | Bottom Sheet 或全屏预览层具备模态覆盖关系时，必须执行 Drawer 的遮罩、背景隔离、页面滚动锁、焦点陷阱、固定标题/关闭、内容区滚动、底部安全区域和 disposal 规则。 |
| `PP-RSP-04` | 断点转换保持同一 `previewOwnerId`、`activePreviewTarget`、`previewSnapshot`、请求门禁、权限版本和焦点意图；不得重建请求、重复公告、丢失 stale/error 或把预览转换成编辑表单。 |
| `PP-RSP-05` | 低高度、虚拟键盘、动态 viewport、四向 safe area、200% 缩放、字体放大和触摸输入下，标题、关闭、返回、错误/权限说明、主要字段和恢复入口必须可达。 |

## 可访问性与公告

| 规则 ID | 规则 |
| --- | --- |
| `PP-A11Y-01` | 预览区域必须有可访问名称，名称说明当前是预览而不是编辑或完整详情。 |
| `PP-A11Y-02` | 打开、切换、关闭、刷新失败、权限失效和 stale 状态由唯一 owner 简短公告；不得同时由列表、预览、Toast 和 live region 重复播报同一完整消息。 |
| `PP-A11Y-03` | 打开预览、切换记录、关闭预览、打开完整详情、复制和进入编辑承载面都必须有键盘路径和明确动作对象。 |
| `PP-A11Y-04` | 当前预览目标、字段 label/value、状态说明、权限原因和恢复入口不能只靠颜色、图标、hover 或位置表达。 |

## 生命周期与清理

| 规则 ID | 规则 |
| --- | --- |
| `PP-LIFE-01` | 来源列表卸载、路由离开、预览关闭、权限收敛或断点转换为独立页时，当前预览实例必须进入幂等 disposal 或受控迁移。 |
| `PP-LIFE-02` | disposal 失效预览请求、刷新重试、防抖、复制回执、长文本展开、媒体临时状态、焦点任务、公告回调和 DOM/ARIA 引用。 |
| `PP-LIFE-03` | 旧预览实例的迟到回调不得清理新实例、来源列表、完整详情页或编辑承载面的状态。 |
| `PP-LIFE-04` | 多实例场景中，每个资源释放都必须携带 `previewOwnerId`；重复关闭只释放一次自己的资源。 |
| `PP-LIFE-05` | 未实际执行浏览器、键盘、读屏、触摸、断点、真实数据竞态和权限切换检查时，必须标为未验证。 |

## 可执行验收检查

1. **状态模型与 owner 边界**：记录 `previewPaneState` 全字段，断言它不复用表格选择、hover/focus、详情页 owner 或编辑 surface ID。
2. **预览目标提交**：分别触发 hover、focus、active row、checkbox 选择、行详情按钮和键盘激活；只有明确预览意图创建或切换 `activePreviewTarget`。
3. **只读与编辑禁止**：扫描预览面板 DOM，断言 input、textarea、select、combobox、日期选择器、单元格编辑、行内保存按钮和完整字段编辑表单数量均为 0；编辑入口转交 `record-editing-surfaces.md`。
4. **请求门禁与迟到响应**：构造快速切换记录、关闭后响应、租户切换后响应、权限版本变化后响应和来源 owner 卸载后响应；只有完整门禁匹配时写入，失配时 DOM、状态、焦点和公告写入均为 0。
5. **权限无泄露**：在无权限、权限降级、记录删除和来源范围失效时，断言对象名称、字段、数量、文件名、内部 ID、旧标题、旧错误、旧复制内容和旧 ARIA label 均不暴露。
6. **关闭和返回**：关闭预览后来源列表查询、分页、排序、选择和批量范围不变；焦点只迁移一次到安全目标。浏览器 Back/Forward 与 URL 恢复执行导航 owner。
7. **反馈状态**：首次加载、刷新失败、stale、partial、empty 和 permission-denied 均有区域内状态、恢复入口和公告去重；Toast 不作为唯一反馈。
8. **响应式转换**：桌面侧边预览、分栏预览、平板和移动端 Bottom Sheet/全屏预览保持同一目标、快照、权限和请求门禁；移动端不删除返回列表、当前预览目标、安全标题、权限原因、错误状态、主要只读信息和恢复入口。
9. **多实例与 disposal**：两个列表各自打开预览、交错请求和关闭；断言 owner 隔离、资源释放计数为 1、旧回调不写新实例。
10. **运行时报告边界**：真实浏览器、键盘、读屏、触摸、断点、权限切换、真实数据竞态和真实组件运行时未执行时，最终报告必须逐项标为未验证。

## 完成前检查

- 是否声明 `previewPaneState` 及全部必要字段。
- 是否证明预览目标不等于表格选择、不等于 hover、不等于 focus、不等于 active row，也不等于编辑目标。
- 是否确认预览面板没有 input、textarea、select、combobox、日期选择器、单元格编辑、行内保存按钮或完整字段编辑表单。
- 是否把编辑、危险操作、完整详情、复制、文件媒体预览、反馈状态、权限和导航恢复转交对应 owner。
- 是否实现迟到响应完整门禁，并在失配时保证 DOM、状态、焦点和公告写入均为 0。
- 是否保证无权限、权限降级、租户切换、记录删除和来源范围失效时无泄露。
- 是否在移动端保留返回列表、当前预览目标、安全标题、权限原因、错误状态、主要只读信息和恢复入口。
- 未实际执行运行时检查时，是否明确标为未验证，并列出所需验证。
