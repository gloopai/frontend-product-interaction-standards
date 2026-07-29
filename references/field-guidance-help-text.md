# 字段说明、帮助文本与占位提示交互规范

适用于字段 label、字段标题、必填、选填、条件必填、字段说明、帮助文本、辅助说明、hint、description、placeholder、占位提示、格式示例、单位、后缀、前缀、来源说明、空值说明、权限原因、只读原因、禁用原因、Tooltip 帮助、Popover 帮助、表单字段说明、筛选字段说明、设置项说明、详情字段说明、field label、field help、help text、field description、hint text、placeholder text、required indicator、optional indicator、field unit、format hint、empty value reason 和 disabled reason。

本文件是字段说明、帮助文本与占位提示 owner。它负责说明信息的身份、语义分层、可访问关联、移动端等价路径、权限安全、错误关系、语言/断点变化和生命周期清理。字段业务值、dirty、校验和提交读取 `references/forms.md`；只读字段和值展示读取 `references/information-display.md`；Tooltip、Popover、Action Sheet 和 Drawer 的触发/定位/关闭读取 `references/overlays-menus-tooltips.md`；权限和无泄露读取 `references/permissions-tenancy-visibility.md`；响应式和输入方式读取 `references/responsive-adaptive.md`。

长 label、长帮助、长 placeholder、长错误、长权限原因、截断、省略号、查看全文和 hover-only 全文说明必须同时执行 `references/text-overflow-truncation.md`；本文件继续负责说明语义和可访问关联，`text-overflow-truncation.md` 负责截断策略、全文恢复、移动端替代、复制全文和旧全文引用清理。

## 范围与边界

字段说明不是 Tooltip，也不是 placeholder。字段说明是帮助用户理解字段身份、输入要求、格式、单位、默认来源、权限原因、空值原因、风险和下一步的产品信息。

本 owner 不覆盖字段控件内部交互、值提交、异步校验、后端权限模型、浮层碰撞定位、视觉 token、品牌文案风格或具体业务字段字典。它只定义说明信息必须如何被声明、关联、降级、保留和验证。

## `fieldGuidanceState`

每个表单字段、筛选字段、设置项、详情只读字段或权限敏感字段说明必须声明 `fieldGuidanceState`，至少包含：

| 字段 | 语义 |
| --- | --- |
| `guidanceOwnerId` | 当前字段说明 owner 的稳定身份。 |
| `guidanceSurface` | `form-field`、`filter-field`、`settings-field`、`readonly-field`、`wizard-field`、`table-filter` 或产品声明的说明场景。 |
| `fieldIdentity` | 字段 ID、可见 label、字段组、业务含义、值类型、权限版本和语言版本。 |
| `labelPolicy` | label 来源、可访问名称、是否允许视觉隐藏、是否可换行、长文本和国际化策略。 |
| `requirementPolicy` | 必填、选填、条件必填、系统自动生成、继承默认、只读、禁用和不可编辑语义。 |
| `descriptionPolicy` | 帮助文本、说明、格式提示、示例、来源说明、风险说明和下一步动作。 |
| `placeholderPolicy` | placeholder 文案、清空后状态、是否只是输入示例、是否可被辅助技术忽略的降级策略。 |
| `helpDisclosurePolicy` | 内联说明、Tooltip、Popover、Disclosure、Drawer 或帮助链接的承载与等价路径。 |
| `unitAndFormatPolicy` | 单位、前缀、后缀、格式、范围、精度、时区、币种和示例的绑定。 |
| `emptyValuePolicy` | 空值、未配置、未知、无权限、加载失败、不适用、继承默认和系统生成的区分。 |
| `permissionReasonPolicy` | 隐藏、禁用、只读、未启用和无权限说明的安全文案与恢复路径。 |
| `errorRelationship` | 帮助、单位、错误、警告和成功提示之间的 owner、顺序、ARIA 描述和去重关系。 |
| `responsivePolicy` | 窄屏、触摸、虚拟键盘、低高度、200% 缩放和长文案下的保留策略。 |
| `lifecycleDisposal` | 字段隐藏、权限变化、语言切换、断点转换、校验变化和 owner 卸载后的旧引用清理。 |
| `runtimeVerification` | 真实浏览器、键盘、读屏、触摸、移动端、权限变化和语言切换验证状态；未执行必须标为未验证。 |

不得只用 `label`、`placeholder`、`required`、`disabled`、`help`、`tooltip`、`aria-label`、组件库 `Form.Item` 配置或后端字段 schema 替代 `fieldGuidanceState`。

## Label、placeholder 和必填语义

placeholder 不能替代 label、默认值、帮助说明、错误说明或空值状态。placeholder 只适合短示例、输入格式暗示或未输入时的轻量提示；输入后消失的信息不得是完成任务所必需的唯一信息。

| 规则 ID | 规则 |
| --- | --- |
| `FGH-LABEL-01` | 每个可编辑字段、只读字段和筛选字段必须有稳定 label 或等价可访问名称；图标、颜色、位置和 placeholder 不能作为唯一名称。 |
| `FGH-LABEL-02` | label、单位、帮助、错误和权限说明必须能关联到同一 `fieldIdentity`，不得因 DOM 重排或响应式布局把值排到错误 label 下。 |
| `FGH-REQ-01` | 必填、选填、条件必填、系统自动生成、继承默认和不可编辑必须可区分，不得只用星号、灰色、空 placeholder 或隐藏输入表达。 |
| `FGH-REQ-02` | 条件必填必须说明触发条件、当前是否满足、如何修复和提交前校验 owner；不得只在提交失败后才暴露规则。 |
| `FGH-PLACE-01` | placeholder 文案不得包含唯一格式、唯一示例、唯一单位、唯一默认值、唯一权限原因或唯一风险说明。 |

## 帮助说明、单位和格式

帮助说明、单位、格式、示例、来源说明、权限原因和空值原因必须有稳定 owner。说明可以内联、折叠、点击打开或进入帮助链接，但不能只存在于 hover-only Tooltip。

| 规则 ID | 规则 |
| --- | --- |
| `FGH-HELP-01` | 用户完成字段所必需的说明必须默认可见，或通过可见且可访问的“帮助/说明/查看规则”入口发现。 |
| `FGH-HELP-02` | Hover-only 帮助在移动端、触摸、键盘和读屏下必须有等价路径。 |
| `FGH-HELP-03` | 单位、精度、币种、时区、范围、大小写、自然排序、日期边界和格式示例必须和字段值绑定；不得只写在页面顶部泛化说明里。 |
| `FGH-HELP-04` | 来源说明必须区分用户输入、系统生成、继承默认、服务端回填、权限隐藏和数据尚未产生。 |
| `FGH-HELP-05` | 外链帮助不得成为唯一说明；离线、权限不足或新窗口失败时仍需有当前页面可理解的最小说明。 |

## 错误、权限和空值关系

错误文本不得覆盖帮助文本的唯一含义。错误出现时，字段原有帮助、单位、格式、权限说明和恢复路径仍需可达；错误修复或失效后，过时错误描述不得继续被读屏引用。

| 规则 ID | 规则 |
| --- | --- |
| `FGH-ERR-01` | 字段错误、警告、帮助和单位都必须有明确顺序和 ARIA 描述关系；同一完整消息不得被多个 owner 重复公告。 |
| `FGH-ERR-02` | 错误出现时可以提高错误优先级，但不得删除唯一帮助、唯一单位、唯一格式示例或唯一权限原因。 |
| `FGH-ERR-03` | 错误修复、权限变化、字段隐藏、字段重建或语言切换后，旧 `aria-describedby`、旧 tooltip、旧 help DOM 和旧错误引用必须失效或重算。 |
| `FGH-PERM-01` | 权限不足、只读、禁用、未启用和隐藏必须用安全说明区分；不得通过 placeholder、tooltip、ARIA label、空值文案或旧 DOM 泄露无权字段名、对象名、数量或内部原因。 |
| `FGH-EMPTY-01` | 空值、未配置、未知、无权限、加载失败、不适用、继承默认和系统生成必须可区分，不能统一显示为空字符串、`-`、`N/A` 或灰色 placeholder。 |

## 响应式、国际化和生命周期

长 label、长帮助、翻译文本扩展、200% 缩放、系统字体放大、低高度、虚拟键盘、动态 viewport 和 safe area 下，字段说明、错误、单位、权限原因、主要操作和恢复路径必须保持可达。

| 规则 ID | 规则 |
| --- | --- |
| `FGH-RSP-01` | 移动端不得删除 label、必填/选填、帮助说明、单位、错误、权限原因、空值原因、取消/返回和恢复路径。 |
| `FGH-RSP-02` | 字段说明可从内联转为 Disclosure、Popover、Action Sheet、Drawer 或帮助页，但必须保留同一 `fieldIdentity` 和焦点返回。 |
| `FGH-I18N-01` | 语言切换、文案远程加载和字段字典更新必须重算 label、帮助、placeholder、单位、错误描述和 ARIA 引用；旧语言引用不得残留。 |
| `FGH-LIFE-01` | 权限降级、字段隐藏、字段重排、断点转换、语言切换、校验变化或 owner 卸载后，旧 label、旧 help、旧 placeholder、旧 aria-describedby 和旧 tooltip 引用必须失效或重算。 |

## 完成前检查

1. 是否声明 `fieldGuidanceState` 及全部字段。
2. placeholder 是否没有替代 label、默认值、帮助说明、错误说明或空值状态。
3. 必填、选填、条件必填、系统自动生成、继承默认和不可编辑是否可区分。
4. 帮助说明、单位、格式、示例、来源说明、权限原因和空值原因是否有稳定 owner。
5. Hover-only 帮助是否在移动端、触摸、键盘和读屏下有等价路径。
6. 错误出现时，唯一帮助、单位、格式示例和权限原因是否仍可达。
7. 权限降级、字段隐藏、字段重排、断点转换、语言切换、校验变化或 owner 卸载后，旧 label、旧 help、旧 placeholder、旧 `aria-describedby` 和旧 tooltip 引用是否失效或重算。
8. 空值、未配置、未知、无权限、加载失败、不适用、继承默认和系统生成是否可区分。
9. 真实浏览器、键盘、读屏、触摸、移动端、语言切换、权限降级和断点切换未实际执行时，是否明确标为未验证并列出所需验证。
