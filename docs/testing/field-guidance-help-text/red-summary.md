# 字段说明、帮助文本与占位提示规范 RED 复核

当前规范缺少专门 owner 来约束字段说明、帮助文本、占位提示、必填/选填、单位、格式、空值说明和权限原因。

必须新增 `fieldGuidanceState`，并覆盖 `guidanceOwnerId`、`guidanceSurface`、`fieldIdentity`、`labelPolicy`、`requirementPolicy`、`descriptionPolicy`、`placeholderPolicy`、`helpDisclosurePolicy`、`unitAndFormatPolicy`、`emptyValuePolicy`、`permissionReasonPolicy`、`errorRelationship`、`responsivePolicy`、`lifecycleDisposal` 和 `runtimeVerification`。

审计必须能识别 placeholder 代替 label、Tooltip 承载唯一帮助、必填/选填混淆、错误覆盖帮助、旧 `aria-describedby` 未清理、移动端帮助不可达和真实交互未验证等缺口。

本轮 RED 阶段的真实浏览器、键盘、读屏、触摸、移动端、语言切换、权限降级、字段隐藏、字段重排和断点切换均未执行，必须标为未验证。
