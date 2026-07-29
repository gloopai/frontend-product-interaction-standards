# 表单布局、字段分组与响应式排列 RED 摘要

本 RED 摘要记录本轮新增审计覆盖的失败类型：

- 只用 CSS Grid、span、labelCol/wrapperCol、组件库 Form.Item 或截图伪装完整布局 owner。
- 视觉顺序、DOM 顺序、Tab 顺序和读屏顺序不一致且没有补偿。
- 字段组没有标题或语义，只靠空白距离暗示归属。
- placeholder、tooltip-only 或相邻文本替代字段 label。
- 长 label、长帮助、长错误或组合字段挤压相邻字段。
- 移动端保留需要横向滚动才能填写的两列/三列表单。
- sticky/fixed 保存栏、Dialog footer、Drawer footer 或虚拟键盘遮挡字段、帮助、错误或聚焦目标。
- 条件字段显示/隐藏后，Tab 顺序、错误摘要、滚动锚点或焦点目标仍指向旧布局。
