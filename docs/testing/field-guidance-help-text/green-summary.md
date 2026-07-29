# 字段说明、帮助文本与占位提示规范 GREEN 复核

本轮 GREEN 复核确认新增 `references/field-guidance-help-text.md` 作为字段 label、字段标题、必填/选填、条件必填、placeholder、帮助文本、辅助说明、单位、格式示例、来源说明、空值说明、权限原因、只读原因、禁用原因、Tooltip 帮助和移动端字段说明的 owner。

## 状态模型覆盖

`fieldGuidanceState` 已要求声明以下字段：

- `guidanceOwnerId`
- `guidanceSurface`
- `fieldIdentity`
- `labelPolicy`
- `requirementPolicy`
- `descriptionPolicy`
- `placeholderPolicy`
- `helpDisclosurePolicy`
- `unitAndFormatPolicy`
- `emptyValuePolicy`
- `permissionReasonPolicy`
- `errorRelationship`
- `responsivePolicy`
- `lifecycleDisposal`
- `runtimeVerification`

其中 `placeholderPolicy`、`helpDisclosurePolicy` 和 `errorRelationship` 是本轮重点：它们分别约束 placeholder 不替代说明、hover-only 帮助必须有等价路径，以及错误文本不得覆盖唯一帮助含义。

## 集成关系覆盖

字段说明 owner 已与以下相邻规范建立关系：

- `references/forms.md`
- `references/information-display.md`
- `references/overlays-menus-tooltips.md`
- `references/responsive-adaptive.md`
- `references/permissions-tenancy-visibility.md`

## 入口与交接覆盖

`SKILL.md` 已补充字段说明、帮助文本、辅助说明、placeholder、字段 label、必填、选填、条件必填、单位、格式示例、来源说明、空值说明、权限原因、只读原因、禁用原因、Tooltip 帮助和英文 help text / placeholder text 关键词的路由。

`README.md` 已补充“字段说明、帮助文本与占位提示规范”和 `references/field-guidance-help-text.md` 的入口说明。

`HANDOFF.md` 已补充“字段说明、帮助文本与占位提示”交接摘要，并链接 `references/field-guidance-help-text.md`。

## 验证边界

本轮 GREEN 复核只验证规范结构、路由、交叉引用和可执行审计契约；真实浏览器、键盘、读屏、触摸、移动端、语言切换、权限降级、字段隐藏、字段重排、断点转换、校验变化和真实视口未执行，仍必须在具体项目落地时标为未验证。
