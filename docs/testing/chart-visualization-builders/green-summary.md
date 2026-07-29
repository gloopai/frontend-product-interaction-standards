# 图表与可视化创作配置 GREEN 证据摘要

- 已补齐 `chartBuilderState`，并要求每个图表配置器声明 `chartBuilderOwnerId`、`sourceConfigSnapshot`、`dataSourceBinding`、`metricDraft`、`dimensionDraft`、`encodingDraft`、`interactionDraft`、`filterBindingDraft`、`previewState`、`validationState`、`savePolicy`、`publishPolicy`、`permissionBoundary` 和 `responsivePolicy`。
- 指标、维度、聚合、图形类型、编码、筛选绑定、钻取、导出和明细能力先写入草稿；只有通过完整校验与明确保存/发布意图后，才允许进入已保存配置、发布配置或完整配置。
- 预览成功不得被当成保存成功；保存成功不得被当成发布成功；发布请求发送不得被当成仪表盘或外部嵌入已生效；加入仪表盘请求发送不得被当成仪表盘已更新。
- 图形类型必须声明指标数量、维度数量、字段类型、时间轴、多 series、堆叠、百分比、双轴和分母兼容规则；预览能画出来仍不能绕过图表配置合法性校验。
- 切换图形类型不能静默删除不兼容配置，必须展示迁移摘要、待修复项、保留项、丢弃项和撤销/取消路径。
- 数据源字段列表必须绑定数据集版本、权限范围、字段类型和刷新时间；预览必须声明读取当前草稿、已保存配置还是已发布配置，并说明样本/全量/聚合/权限过滤边界。
- 保存不得读取 Select query、active option、筛选草稿、hover 字段、预览高亮、当前可见结果或旧缓存。
- 预览图表必须继续执行 `charts-visualization.md` 的展示规则，避免构建器 owner 绕过图表展示 owner。
- 完整校验必须覆盖当前可见面板、折叠面板、隐藏字段、高级配置、钻取目标、导出范围、tooltip 字段、颜色映射、双轴、Top N、权限不可见字段、旧数据源字段和旧图表类型残留。
- 权限、租户/工作区、数据源版本、字段版本、指标口径、来源配置版本、发布版本、仪表盘版本或会话状态变化后，旧字段列表、旧预览、旧保存按钮、旧发布按钮、旧导出配置、旧钻取目标、旧颜色映射、旧复制内容、旧焦点目标和旧 ARIA 引用必须失效。
- 无权或未启用时，数据源选择、字段选择、指标选择、预览、保存、发布、复制、导出、钻取配置、加入仪表盘和查看明细配置的 DOM、state、handler、request 和快捷键入口为 0。
- 移动端必须保留数据源说明、指标配置、维度配置、图形类型、预览、完整校验、错误定位、保存草稿、发布/加入仪表盘、权限原因、版本冲突、恢复路径和离开保护。
- 真实浏览器、真实图表库、真实数据源、真实预览、真实权限切换、键盘、触摸、读屏和移动端视口未执行时，必须标为未验证。

对应静态审计入口：`ruby docs/testing/chart-visualization-builders/chart-visualization-builders-audit.rb --mutations`。
