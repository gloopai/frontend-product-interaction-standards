# 数字输入规范 RED 复核

在新增 `references/numeric-amount-inputs.md` 之前，管理台数字字段只能分散依赖表单、字段说明、计费、权限和按钮规范，无法强制表达以下问题：

- 没有 `numericInputState`，无法证明 `draftText`、`parsedValue` 和 `committedValue` 已分离。
- `Number(value)`、`parseFloat` 或 `input[type=number]` 可能把空值、0、负数和非法值混用。
- 金额、百分比、容量、时长和配额没有统一要求声明单位、币种、倍率或计量周期。
- 精度、舍入、截断和前端浮点误差没有独立验收。
- `-`、`.`、`0.`、`10%`、`1,000`、全角数字、货币符号、单位后缀和 IME composition 可能被静默改写。
- 滚轮、Stepper、长按和移动端数字键盘可能误触改值或无法输入合法字符。
- Toast、placeholder、Tooltip 或后端最终校验可能成为唯一说明。
- 无权限时可能泄露金额、余额、额度、阈值、历史值、旧 aria-label 或错误明细。
- 真实浏览器、键盘、读屏、移动端、输入法、粘贴、缩放、权限切换和服务端回填未执行时，容易被误写成已验证，而不是标为未验证。

