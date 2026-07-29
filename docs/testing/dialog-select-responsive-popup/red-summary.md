# Dialog 内浮层与移动端转换 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- Dialog 内 Select popup 被 Dialog 内容区、外框、固定页脚、局部容器、`overflow` 或 `transform` 裁切。
- 为了让 popup 展开而让 Dialog 外框滚动，导致标题、关闭按钮或底部操作不稳定。
- popup 遮挡 Dialog 主要确认按钮，而没有 Portal、向上翻转、最大高度限制或 options 区滚动。
- 只用临时 `z-index` 把 Select popup 压到 Dialog 页脚之上，却没有处理锚点、collision、虚拟键盘、滚动重算和层级归属。
- PC popup 没有 Portal 到应用根或当前模态层专用 popup root，层级与更上层 Dialog/Drawer 混乱。
- Dialog 内容滚动、窗口缩放、字体放大、虚拟键盘、锚点移除或更上层模态打开后，popup 悬空、穿透上层模态或留下失效 ARIA 引用。
- 移动端复杂 Dialog 没有转 Bottom Drawer，却在虚拟键盘、低高度或窄屏中挤压内容和操作。
- Bottom Drawer 虽有左右边距和圆角，却没有执行 Drawer 语义，例如遮罩、背景隔离、滚动锁、焦点陷阱和固定底部操作。
- Select 转 Drawer 后丢失 `selectedValue`、`query` 或 `activeOption`，或者重复请求、重复遮罩、重复焦点陷阱、重复滚动锁、重复动画。
- Bottom Sheet 内继续使用非模态 Select popup，导致确认按钮、错误信息或取消/关闭路径被遮挡；这种场景应转 Select Drawer、全屏 Drawer 或独立页。
- 浏览器、触摸设备、真实组件和真实视口没有执行时，不能写成已验证，必须标为未验证。

对应静态审计入口：`ruby docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb --mutations`。
