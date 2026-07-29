# 字段说明、帮助文本与占位提示交互规范设计

## 背景

管理台里几乎每个表单、筛选、设置页、详情页和配置向导都会出现字段 label、必填/选填、placeholder、帮助说明、单位、格式示例、来源说明、空值说明、权限原因和错误文本。现在这些要求散在 `forms.md`、`information-display.md`、`overlays-menus-tooltips.md`、`responsive-adaptive.md` 和 `permissions-tenancy-visibility.md` 中，容易出现一个典型问题：实现者把说明放进 placeholder 或 hover-only Tooltip，然后移动端、键盘、读屏、校验错误、权限降级或语言切换时就丢失语义。

## 推荐方案

新增 `references/field-guidance-help-text.md` 作为字段说明信息 owner。它不替代表单值、错误、权限或浮层 owner，只负责字段说明本身的状态模型、语义分层、可访问关联、移动端等价路径和旧引用清理。

## 范围

- 覆盖 label、字段标题、必填/选填、条件必填、placeholder、help text、description、hint、tooltip help、单位、格式、示例、来源说明、空值说明、权限原因、只读原因和禁用原因。
- 覆盖表单字段、筛选字段、设置项、详情只读字段、配置向导字段和移动端字段说明。
- 排除字段业务值、校验时机、提交、后端权限模型、浮层定位和视觉 token；这些仍归各自 owner。

## 状态模型

新增 `fieldGuidanceState`，至少包含 `guidanceOwnerId`、`guidanceSurface`、`fieldIdentity`、`labelPolicy`、`requirementPolicy`、`descriptionPolicy`、`placeholderPolicy`、`helpDisclosurePolicy`、`unitAndFormatPolicy`、`emptyValuePolicy`、`permissionReasonPolicy`、`errorRelationship`、`responsivePolicy`、`lifecycleDisposal` 和 `runtimeVerification`。

## 核心规则

1. 字段说明不是 Tooltip，也不是 placeholder；placeholder 不能替代 label、默认值、帮助说明、错误说明或空值状态。
2. 必填、选填、条件必填、系统自动生成、继承默认和不可编辑必须可区分。
3. 帮助说明、单位、格式、示例、来源说明、权限原因和空值原因必须有稳定 owner，并与当前字段身份、权限版本和语言版本绑定。
4. Hover-only 帮助在移动端、触摸、键盘和读屏下必须有等价路径。
5. 错误文本不得覆盖帮助文本的唯一含义；错误出现时说明仍需可达，过时的 `aria-describedby`、Tooltip 和 DOM 引用必须清理。

## 验收

本轮只新增规范、路由、相邻引用和可执行审计。真实浏览器、键盘、读屏、触摸、移动端、语言切换、权限降级和断点切换必须在具体项目落地时继续标为未验证。
