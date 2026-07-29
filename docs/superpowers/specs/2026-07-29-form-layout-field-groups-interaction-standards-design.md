# 表单布局、字段分组与响应式排列交互规范设计

## 目标

新增一个纯 UI/交互 owner，约束管理台高频表单布局问题：字段分组混乱、两列/三列挤压、label/帮助/错误归属不清、底部保存栏遮挡、动态字段重排、移动端顺序错乱和虚拟键盘覆盖。

## 推荐方案

采用独立 `references/form-layout-field-groups.md` owner。它不处理字段业务值、校验规则、权限策略或后端模型，只负责字段如何排列、分组、跨列、响应式转换、错误定位和焦点恢复。

相邻 owner 职责：

- `forms.md` 负责字段状态、dirty/touched、校验、错误摘要和提交。
- `field-guidance-help-text.md` 负责 label、placeholder、帮助、单位和错误描述关系。
- `page-content-layout-sections.md` 负责页面 Section/Card、主滚动和 sticky/fixed 避让。
- `page-form-action-bars.md` 负责保存栏与底部操作。
- `dialogs.md` / `drawers.md` 负责弹层承载面。
- `responsive-adaptive.md` 负责断点、触摸、虚拟键盘、安全区域和缩放。

## 状态模型

新增 `formLayoutState`，强制分离 `fieldRegistry`、`groupRegistry`、`layoutMode`、`breakpointPolicy`、`fieldOrder`、`alignmentPolicy`、`spanPolicy`、`densityPolicy`、`overflowPolicy`、`errorPlacementPolicy`、`loadingPlaceholderPolicy`、`conditionalLayoutBinding`、`actionBarAvoidance`、`responsivePolicy`、`focusRestorationPolicy` 和 `lifecycleDisposal`。

核心原则：视觉顺序、DOM 顺序、Tab 顺序和读屏顺序默认一致；字段组必须有语义；移动端不得保留需要横向滚动才能填写的多列表单。

## 验收边界

新增 Ruby 审计覆盖 owner、SKILL 路由、README、HANDOFF、相邻规范引用、GREEN 合同、负向变异和项目泄漏扫描。真实浏览器、键盘、读屏、触摸、虚拟键盘、缩放、低高度和移动端视口如未执行，必须明确标为未验证。

## 自检

- 无 TBD、TODO 或占位。
- 不涉及权限业务或权限矩阵。
- 不修改具体业务项目实现。
- 不因组件库 Form/Grid 默认行为降低规范。
