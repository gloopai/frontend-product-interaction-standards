---
name: frontend-product-interaction-standards
description: 用于创建、修改、重构、评审或测试前端页面、组件、布局、弹窗、表单及交互行为时；凡是前端产品交互任务都应自动加载。
---

# 前端产品交互规范

## 核心原则

把本 Skill 中与任务相关的规则视为硬性验收条件。框架限制、组件库默认行为、现有代码和交付压力都不能降低标准。只有用户针对明确范围作出的直接授权才构成例外。

## 执行流程

1. 判断任务涉及哪些交互类别。
2. 修改或评审前读取对应参考文件。
3. 实现前检查方案，实现后检查代码并验证相关交互和视口。
4. 第三方组件冲突时，优先配置、封装或替换。
5. 最终回复列明已验证的相关规则；无法验证时明确说明。

## 规范路由

- 涉及 Dialog、Modal、弹窗或对话框时，必须完整读取 `references/dialogs.md`。
- 涉及 Drawer、Sheet、抽屉、侧滑面板或上下滑出面板时，必须完整读取 `references/drawers.md`。
- 涉及 Select、Combobox、下拉选择、可搜索选择器、Autocomplete、Dropdown Select、Searchable Select、单选选择器，或 select、combobox、dropdown、autocomplete、searchable select、single-select 时，必须完整读取 `references/selects-comboboxes.md`。
- 涉及表单、字段、校验、必填/选填、错误摘要、提交、脏状态/已修改状态、已触碰状态、dirty/touched、未保存更改或错误恢复，或 form、field、validation、required/optional、error summary、submit、dirty/touched、unsaved changes、error recovery 时，必须完整读取 `references/forms.md`。
- 涉及表格、数据表格、报表、列、固定列、筛选、排序、分页、游标分页、行选择、全选、批量操作或部分成功，或 table、data table、report、column、pinned column、filter、sort、pagination、cursor pagination、row selection、select all、bulk action、partial success 时，必须完整读取 `references/data-tables.md`。
- 涉及新增记录、编辑记录、新建记录、复制创建、列表内编辑、表格内编辑、行内编辑、内嵌表单、常驻可编辑列表、单元格编辑、行内保存、记录配置、批量配置编辑、记录编辑承载面、编辑承载面，或 create record、edit record、record editor、inline edit、inline create、inline form、row edit、cell edit、embedded form、editing surface、row save、editable grid 时，必须完整读取 `references/record-editing-surfaces.md`。
- 涉及按钮、主按钮、次按钮、图标按钮、保存按钮、提交按钮、取消按钮、确认按钮、删除按钮、导出按钮、批量按钮、行操作按钮、危险按钮、禁用按钮、loading 按钮、按钮组、工具栏按钮，或 button、primary button、secondary button、icon button、submit button、save button、cancel button、confirm button、delete button、export button、bulk action button、row action button、danger button、disabled button、loading button、button group、toolbar action 时，必须完整读取 `references/buttons.md`。
- 涉及上传、文件上传、附件、拖拽上传、导入、批量导入、模板下载、导入预检、字段映射、错误明细、上传进度、取消上传、重试上传，或 upload、file upload、attachment、drag upload、dropzone、import、bulk import、template download、preflight import、field mapping、error report、upload progress、cancel upload、retry upload 时，必须完整读取 `references/uploads-imports.md`。
- 涉及响应式、移动端、手机、PC、桌面端、平板、断点、视口、横竖屏、窄屏、触摸、虚拟键盘、安全区域、缩放或跨端适配，或涉及 responsive、adaptive、desktop、mobile、tablet、breakpoint、viewport、orientation、portrait、landscape、touch、virtual keyboard、safe area、zoom 时，必须完整读取 `references/responsive-adaptive.md`。
- 涉及后台、管理台、控制台、运营后台、内部工具、SaaS console、RBAC、权限降级、租户/工作区切换、危险操作、审计日志、导入、导出、异步任务、任务中心、报表仪表盘或全局反馈，或 admin、console、dashboard、RBAC、tenant、workspace、audit log、import、export、async job、job center 时，必须完整读取 `references/admin-console.md`。`notification`、`toast`、`alert`、`popover`、`tooltip` 等反馈词只有与上述管理台上下文同时出现时才触发本 owner；单独出现时不触发。
- 用户增加新类别规范时，创建职责单一的 `references/<category>.md`，并在此增加路由。

## 与项目规则的关系

- 兼容规则全部执行。
- 一方更严格且不冲突时，执行更严格的规则。
- 规则冲突时停止受影响的实现并请用户裁决，不能自行采用宽松版本。

## 红线

- 不得因为“组件默认如此”而保留违规行为。
- 不得因为“只要求检查其他内容”而忽略当前改动涉及的交互违规。
- 不得把未执行的验证写成已经通过。
- 不得在给出实现建议、评审结论或受限环境反馈时省略验证状态；未实际执行点击、滚动或视口检查的，必须明确标为未验证并列出所需验证。
- 不得将“今天必须交付”“最小可交付”或“少依赖”当成允许遮罩点击关闭或整个 Dialog 滚动的理由。
- 不得以仅内容区域滚动会导致固定标题或底部在小屏溢出为由让 Dialog 外框滚动；应调整内容布局和高度限制。
