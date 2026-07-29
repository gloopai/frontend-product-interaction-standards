# 文本溢出与截断交互规范设计

## 背景

管理台、报表、卡片、表格和详情页里经常出现“省略号 + hover Tooltip”式处理。它短期看起来干净，但会在移动端、键盘、读屏、权限降级、长 ID/URL/错误详情和复制场景中失效：用户看不到完整信息、复制到旧值、确认了被截断的风险，或者只能在桌面 hover 时才能理解内容。

## 目标

1. 新增独立 owner `references/text-overflow-truncation.md`，覆盖文本溢出、截断、省略号、line clamp、查看全文、展开全文和复制全文。
2. 明确 `textOverflowState`，把内容身份、截断策略、全文恢复、复制权限、移动端替代、测量重算和生命周期清理结构化。
3. 禁止把省略号、line clamp、`title` 属性或 Tooltip 当成唯一全文路径。
4. 将表格、卡片、详情、字段说明、按钮、浮层、反馈和响应式规范与该 owner 互相引用。
5. 增加 RED/GREEN 证据和可执行审计，避免规则只停留在文案。

## 非目标

- 不重写表格列宽、卡片布局、按钮语义、字段说明语义或 Tooltip/Popover 触发机制。
- 不规定具体组件库、CSS class、框架实现或项目目录结构。
- 不把所有长文本都强制展开；装饰性或同屏已有完整等价文本的内容可以声明无恢复路径。

## Owner 边界

`text-overflow-truncation.md` 负责“空间受限时文本如何仍然可理解、可恢复、可复制、可访问且不泄露”。相邻 owner 继续负责自己的结构语义：

- 信息展示负责字段和值的语义。
- 字段说明负责 label/help/placeholder/error 的说明层级。
- 表格负责列、行、选择、分页和 ARIA Grid。
- 卡片负责字段映射、交互区域和卡片能力档位。
- 按钮负责动作语义、主次和防重复。
- 浮层负责触发、定位、关闭和层级。
- 反馈负责错误、空态、loading 和恢复承载。
- 响应式负责断点、触摸、虚拟键盘、安全区域和跨端一致性。

## 风险

- 规则过严会让所有列表都显得很重，所以允许装饰性文本或已同屏完整表达的内容声明无恢复路径。
- Tooltip 不能一刀切禁用，因为桌面端辅助查看全文仍有价值；规范只禁止 Tooltip-only。
- 长代码/JSON/URL 一味折行会破坏阅读，所以允许专用查看器、复制全文或 Drawer/Dialog。

## 验收

- `SKILL.md` 可以自动路由文本截断相关任务。
- `README.md` 和 `HANDOFF.md` 有使用者可见摘要。
- 相邻规范提到 `references/text-overflow-truncation.md` 的 owner 边界。
- RED/GREEN 文档包含 `textOverflowState`、`truncationPolicy`、`fullTextAccessPolicy`、`tooltipPopoverBoundary` 和“未验证”边界。
- 审计脚本能发现 owner、路由、README、HANDOFF、相邻引用和项目泄露问题。
