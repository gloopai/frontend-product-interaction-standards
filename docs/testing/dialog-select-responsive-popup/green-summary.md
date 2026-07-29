# Dialog 内浮层与移动端转换 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- Dialog 内 Select popup 不得被内容区、外框、固定页脚、局部容器、`overflow` 或 `transform` 裁切。
- 不得为了 Select popup 展开而让 Dialog 外框滚动。
- PC popup 应通过 Portal、当前模态层专用 popup root、向上翻转、最大高度限制和 options 区滚动解决空间问题。
- popup 不得遮挡 Dialog 主要确认按钮；空间不足时必须翻转、限高或转换为 Drawer。
- 不能只靠临时提高 `z-index` 修截图问题；popup 必须绑定当前模态层、锚点、collision、页脚避让和清理责任。
- Dialog 内容滚动、窗口缩放、字体放大、虚拟键盘、锚点移除或更上层模态打开时，popup 必须重算位置、安全关闭或转换为 Select Drawer。
- 移动端复杂 Dialog 可转 Bottom Drawer，并允许左右边距、圆角和安全区域适配。
- Bottom Drawer 的视觉边距不改变 Drawer 语义，仍需遮罩、背景隔离、滚动锁、焦点陷阱、固定标题/关闭和固定底部操作。
- 移动端 Select 可转 Select Drawer，并保持 `selectedValue`、`query`、`activeOption`、loading、error、orphaned invalid 和请求身份。
- Bottom Sheet 内 Select 若会遮挡确认按钮、受虚拟键盘挤压或造成悬空 popup，应优先转 Select Drawer；任务本身无法承载时再升级为全屏 Drawer 或独立页。
- 已打开实例断点转换不得产生重复遮罩、重复焦点陷阱、重复滚动锁、重复请求或重复动画。
- 浏览器、触摸设备、真实组件和真实视口检查在本轮文档工作中仍是未验证，需要在具体页面实现时补充。

对应静态审计入口：`ruby docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb --mutations`。
