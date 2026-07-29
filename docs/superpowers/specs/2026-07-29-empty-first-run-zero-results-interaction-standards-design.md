# 空态、无结果与首次使用引导交互规范设计

## 背景

管理台里“暂无数据”经常混用：真实没有数据、筛选无结果、首次使用、只读报表无数据、权限不可见、未配置、加载失败都会显示同一个空态。这样会误导用户去创建不存在权限的对象，或在报表/筛选场景里给错 CTA，也可能泄露无权对象数量和筛选摘要。

## 设计方案

新增 `references/empty-first-run-zero-results.md` 作为独立 owner。它不替代 `feedback-states.md`，而是专门决定空态原因、优先级、CTA 和恢复路径。

核心状态为 `emptyStateDecision`，包含 `emptyReason`、`dataScopeSnapshot`、`querySnapshot`、`permissionBoundary`、`capabilityPolicy`、`primaryActionPolicy`、`secondaryActionPolicy`、`recoveryPolicy` 和 `runtimeVerification`。

## 关键规则

- 空状态不是“没有数据”的单一文案。
- 必须区分 firstRunEmpty、trueEmpty、zeroResults、permissionEmpty、errorEmpty、loadingEmpty、archivedEmpty、notConfiguredEmpty 和 readOnlyEmpty。
- zeroResults 优先清空筛选、调整关键词、重置时间范围或恢复默认视图。
- 首次使用且有创建权限时才给创建/导入/配置入口。
- 只读报表、权限不足、能力未启用、不可写范围和筛选无结果不得误导用户创建。
- 权限空态不得泄露对象名称、数量、字段、筛选值、归档数量、文件名、金额、内部 ID 或旧可访问名称。

## 非目标

- 不规定品牌插图、营销 onboarding、教程系统或增长实验。
- 不定义后端统计、权限模型或业务对象命名。
- 不替代字段级空值说明。

