# 穿梭框、分配列表与授权资源选择交互规范设计

## 目标

新增一个高频管理台 owner，约束穿梭框、双列表分配、角色授权、资源授权、成员分组和数据范围授权。目标是阻止这类场景被误当成普通多选、两个表格或树 checked keys，避免出现移动即生效、全选范围混淆、旧候选提交、权限泄露、继承项误删和移动端能力缺失。

## 推荐方案

采用独立 `references/transfer-assignment-lists.md` owner。它不替代 Select、多选、树、对象选择器或批量操作，而是在这些 owner 之上专管“候选集合 ↔ 已分配集合”的授权会话、草稿差异和保存边界。

相邻 owner 职责：

- `entity-resource-pickers.md` 负责候选实体身份和可绑定性。
- `tree-hierarchy.md` 负责树形展开、半选、懒加载和路径。
- `data-tables.md` 负责表格行、分页、排序和可见行语义。
- `bulk-actions-batch-operations.md` 负责批量范围、部分成功和恢复。
- `permissions-tenancy-visibility.md` 负责无泄露和权限收敛。
- `forms.md` 负责 dirty、提交、错误摘要和未保存离开。

## 状态模型

新增 `assignmentTransferState`，强制分离 `initialAssignedSet`、`draftAssignedSet`、`sourceVisibleSet`、`targetVisibleSet`、`selectionBuckets`、`moveIntent`、`eligibilityMap`、`permissionBoundary`、`requestIdentity`、`diffSummary`、`validationBinding`、`savePolicy`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy` 和 `lifecycleDisposal`。

核心原则：移动不等于保存，勾选不等于移动，搜索命中不等于已分配；当前页全选、全部筛选结果、全部候选、跨页选择和排除项必须分别表达。

## 验收边界

新增 Ruby 审计覆盖 owner、SKILL 路由、README、HANDOFF、相邻规范引用、GREEN 合同、负向变异和项目泄漏扫描。真实浏览器、键盘、读屏、触摸、权限切换、迟到请求、批量范围和移动端视口如未执行，必须明确标为未验证。

## 自检

- 无 TBD、TODO 或占位。
- 不修改任何具体业务项目实现。
- 不因组件库 Transfer 默认行为降低规范。
- 与对象选择器、多选、树、表格、批量、表单和权限 owner 职责边界清晰。
