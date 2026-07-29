# RED：文本溢出与截断规范缺口

## 当前失败点

- 缺少独立 `textOverflowState`，长文本、长标题、长字段、长状态、长错误、长按钮文案、代码、JSON、URL、文件名和路径容易散落在表格、卡片、详情或按钮 owner 中。
- 缺少 `textOwnerId`、`textSurface`、`sourceBinding`、`contentIdentity`、`displayPolicy`、`lineWrapPolicy`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy` 和 `runtimeVerification` 等基础状态字段时，无法证明文本身份、承载面、来源、权限、响应式和验证边界。
- `truncationPolicy`、`fullTextAccessPolicy`、`tooltipPopoverBoundary`、`copyPolicy`、`measurementPolicy` 和 `lifecycleDisposal` 没有统一字段，导致省略号、line clamp、`title` 属性或 Tooltip 被误用成唯一全文路径。
- 文本截断不是内容删除，也不是 hover tooltip 的同义词；当前缺口会让移动端、键盘、读屏、触摸、字体放大、语言切换和权限降级场景处于未验证状态。
- 被截断内容未强制声明 `fullTextAccessPolicy`；重要身份、状态、错误、金额、权限原因、主操作文案和恢复路径可能只显示省略号。
- 长 ID、代码、JSON、URL、邮箱、文件名、路径、错误详情和审计字段没有稳定的换行、展开、复制或专用查看方式。
- 权限降级、语言切换、数据刷新、断点转换、字体放大或 owner 卸载后，旧全文、旧 title、旧 tooltip、旧复制值、旧 aria-label、旧测量结果和旧展开状态可能没有失效或重算。

## 预期失败检测

审计应能在以下突变中失败：

- 删除 `textOverflowState` 或任一关键字段。
- 删除“文本截断不是内容删除，也不是 hover tooltip 的同义词”。
- 删除 Tooltip-only 禁止。
- 删除 `fullTextAccessPolicy` 要求。
- 删除装饰性内容例外边界。
- 删除长 ID/代码/JSON/URL/文件名/路径恢复要求。
- 删除生命周期清理要求。
- 将运行时未验证边界写成已验证。
- 删除 `SKILL.md` 路由、README 链接、HANDOFF 小节或相邻 owner 引用。
