# 数字输入规范 GREEN 复核

新增 `references/numeric-amount-inputs.md` 后，数字、金额、比例与配额输入具备独立 owner：

- `numericInputState` 要求声明 `numericOwnerId`、`fieldIdentity`、`valueKind`、`draftText`、`parsedValue`、`committedValue`、`displayFormat`、`unitBinding`、`precisionPolicy`、`rangePolicy`、`stepperPolicy`、`normalizationPolicy`、`validationBinding`、`submitSnapshotPolicy`、`permissionBoundary`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 明确禁止只用 `Number(value)`、`parseFloat`、`input[type=number]`、正则替换、展示字符串、placeholder、后端最终校验或组件库默认 formatter 替代 owner。
- `draftText`、`parsedValue` 和 `committedValue` 分离，非法草稿不会静默提交成 0 或旧值。
- 金额声明币种，百分比声明提交倍率，容量/时长/配额声明单位和计量周期。
- 精度、舍入、截断、硬边界、软边界、滚轮和长按步进都有验收边界。
- 粘贴、全角数字、本地化小数点、货币符号、百分号、单位后缀和 IME composition 有明确策略。
- 无权限不得泄露金额、余额、额度、用量、阈值、单价、套餐限制、历史值、旧 aria-label 或错误明细。
- 移动端不得删除单位、币种、错误、边界说明、保存/取消、恢复或权限说明。
- 真实浏览器、键盘、读屏、移动端、输入法、粘贴、缩放、权限切换和服务端回填未执行时必须标为未验证。

