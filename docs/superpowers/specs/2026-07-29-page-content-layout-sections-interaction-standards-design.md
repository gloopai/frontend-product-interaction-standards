# 页面内容区与 Section 布局交互规范设计

## 背景

已有规范分别覆盖 Page Header、页面工具栏、表格、表单、信息展示、反馈状态、概览仪表盘和响应式适配，但页面正文区域仍缺少统一 owner。实际项目中容易出现卡片随意堆叠、多个区域各自滚动、sticky/fixed 互相遮挡、移动端删除区块、Section 状态归属不清和旧区域状态泄露。

## 目标

- 新增 `references/page-content-layout-sections.md`，作为页面内容区、页面正文、主内容区、Section、区块、卡片区块、内容卡片、分栏布局、主滚动、嵌套滚动、sticky/fixed 避让、内容密度和移动端单列的 owner。
- 明确 `pageContentLayoutState`，要求页面正文绑定当前页面 owner、标题区、工具栏、权限版本和主内容区域。
- 明确 Section/Card 不直接吞业务能力，只负责布局、分组、滚动和 owner 转交。
- 通过审计脚本强制 SKILL 路由、README、HANDOFF、相邻 owner 关系和红绿证据齐全。

## 非目标

- 不定义 CSS 框架、组件库、像素级间距或品牌视觉 token。
- 不重新定义表格、表单、图表、信息展示、反馈状态、Toolbar 或 Page Header 的内部规则。
- 不引入项目专属目录、组件名或技术栈词。

## 关键约束

- 页面内容区不是随意堆卡片，也不是 CSS 网格细节。
- 每个 Section、Card、分栏、列表区、表单区、图表区和信息区必须有明确 `ownerHandoff`。
- 主滚动只能有一个可解释 owner；不得让页面、卡片、表格、Drawer 和 Dialog 形成无声明的嵌套滚动。
- Sticky、fixed、吸顶、底部操作、分页、工具栏、标题区和安全区域不得遮挡当前焦点、错误、状态摘要、主操作或恢复路径。
- 移动端可重排、折叠、分组或转单列，但不得删除页面标题、核心 Section、状态说明、权限原因、主操作、错误恢复和返回路径。

## 验证设计

新增 `docs/testing/page-content-layout-sections/page-content-layout-sections-audit.rb`：

- 检查 owner 文档存在完整 `pageContentLayoutState` 字段。
- 检查关键硬规则、`未验证` 边界和完成前检查。
- 检查 `SKILL.md` 路由覆盖中英文高频词。
- 检查 README、HANDOFF 和相邻 owner 文档引用新 owner。
- 检查 RED/GREEN 证据包含核心字段和未验证声明。
- 运行 mutation，确保删除关键约束、路由、证据或加入项目泄漏都会失败。
