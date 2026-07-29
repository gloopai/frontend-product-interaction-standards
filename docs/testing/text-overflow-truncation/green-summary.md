# GREEN：文本溢出与截断规范已加固

## 新增能力

- 新增 `references/text-overflow-truncation.md`，成为文本溢出、文本截断、省略号、line clamp、查看全文、展开全文、收起全文、复制全文、长标题、长状态、长错误、长按钮文案、代码、JSON、URL、文件名和路径展示的唯一 owner。
- `textOverflowState` 已结构化声明 `textOwnerId`、`textSurface`、`sourceBinding`、`contentIdentity`、`displayPolicy`、`truncationPolicy`、`fullTextAccessPolicy`、`copyPolicy`、`tooltipPopoverBoundary`、`lineWrapPolicy`、`measurementPolicy`、`permissionBoundary`、`responsivePolicy`、`focusAnnouncementPolicy`、`lifecycleDisposal` 和 `runtimeVerification`。
- 明确文本截断不是内容删除，也不是 hover tooltip 的同义词。
- 明确省略号、line clamp、max-width、title 属性或 Tooltip 不得作为查看完整内容的唯一方式。
- 被截断内容必须声明 `fullTextAccessPolicy`；重要身份、状态、错误、金额、权限原因、主操作文案和恢复路径不得只显示省略号。
- 只有装饰性或已由同屏等价文本完整表达的内容可以无恢复路径截断。
- 长 ID、代码、JSON、URL、邮箱、文件名、路径、错误详情和审计字段必须提供换行、展开、复制或专用查看方式。
- 移动端不得依赖 hover、title 属性或精确指针查看全文。
- 权限降级、语言切换、数据刷新、断点转换、字体放大或 owner 卸载后，旧全文、旧 title、旧 tooltip、旧复制值、旧 aria-label、旧测量结果和旧展开状态必须失效或重算。

## 集成范围

- `SKILL.md` 已加入文本溢出与截断相关路由。
- `README.md` 和 `HANDOFF.md` 已加入使用者可见摘要。
- 信息展示、字段说明、响应式、浮层、表格、卡片、按钮和反馈规范已引用 `references/text-overflow-truncation.md`。

## 验证状态

- 静态结构、路由、相邻引用、README、HANDOFF、RED/GREEN 证据和项目泄露扫描由 `docs/testing/text-overflow-truncation/text-overflow-truncation-audit.rb` 覆盖。
- 真实浏览器、移动端、键盘、读屏、触摸、字体放大、缩放、语言切换、权限变化和真实数据测量仍需在具体项目中验证；当前规范明确标为未验证。
