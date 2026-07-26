# 表单状态、校验与错误交互规范

适用于含一个或多个可编辑字段、客户端/服务端校验与提交操作的表单。本文件是表单 owner 的状态、校验时机、错误归属和可访问错误反馈的唯一事实来源；视觉样式、字段控件内部草稿和弹层呈现不属于本文件。

表单放在 [Dialog](dialogs.md) 或 [Drawer](drawers.md) 中时，容器的打开、关闭、焦点陷阱、退出动画与 disposal 仍由对应 owner 负责；表单仅提供 `dirty`、`submitting`、错误摘要和可聚焦目标。Select / Combobox 的 `query`、`activeOption` 与 popup 会话仍由 [Select / Combobox](selects-comboboxes.md) owner 负责，只有已提交的 `selectedValue` 才是表单字段值。断点切换、跨端呈现和 route/unmount disposal 同时遵循 [响应式与自适应交互规范](responsive-adaptive.md)，不得重置同一表单会话。

## 范围与首版排除项

本规范覆盖单一编辑会话中的字段值、校验、提交、错误与焦点。首版不定义多步骤向导的跨页草稿持久化、离线队列/自动重试、协同编辑合并、文件上传进度或产品特有的离开确认文案；这些能力接入时仍不得绕过本文件的值版本、错误归属和 live-session 判断。

## 表单与字段 owner 状态

表单 owner 维护以下正交状态，不能用一个笼统的 `loading` 或 `invalid` 代替：

- `pristine`：所有字段相对各自显式 `initialValue` 都不 dirty；`dirty`：至少一个字段 dirty。它们是聚合派生值，不是可被直接置位的历史标志。
- `validating`：存在当前适用的同步后续异步校验；`submitting`：当前 `submitId` 的提交请求在途。
- `submitError`：当前提交的表单级失败仍适用；`submitSucceeded`：当前提交成功且结果仍对应此会话。新的编辑、reset 或新提交会按产品流程撤销成功态，不能把旧成功态覆盖新草稿。
- `hasSubmitted`（首次提交尝试）记录验证可见性门槛；它不是 `dirty`、`touched` 或提交成功的同义词。

每个字段 owner 至少维护：

| 状态 | 语义 |
| --- | --- |
| `value` / `initialValue` | 当前业务值及明确设定的初始值；比较使用该字段已声明的语义相等规则，而非把对象引用或显示文本当作值。 |
| `source` | 最近一次值/交互来源：`user-input`、`focus`、`blur`、`prefill`、`programmatic-assignment`、`reset` 或 `server-refill`。来源必须随状态转换记录，不能把程序写值伪装成用户输入。 |
| `touched` / `dirty` | `touched` 表示用户曾实际离开过该字段的编辑焦点；`dirty` 是 `value` 与 `initialValue` 的派生比较。两者独立。 |
| `syncErrors` / `asyncErrors` / `serverErrors` | 已知错误的来源集合及其适用键；错误存在不等于当前应显示。 |
| `errorVisible` | 根据可见性门槛计算的展示状态；不得从错误是否存在反推。 |
| `validationGeneration` | 每次会改变校验意义的值变化递增的代次；异步结果必须带同一代次和值才能写回。 |

`user-input` 改变值并递增校验代次；`focus` 本身不改值或 touched；`blur` 把字段设为 `touched` 并触发该字段校验。`prefill` 仅在会话建立前设定 `initialValue` 与 `value`，结果为 pristine、untouched。`programmatic-assignment` 必须声明它是替换当前值还是重建会话；前者照常重新计算 dirty 和校验代次，后者同时明确替换 `initialValue`。`reset` 把值还原为显式 initial 值、清除 touched 和本会话错误/异步工作，并建立新的校验代次。`server-refill` 必须显式选择：只刷新初始快照（无未保存编辑时）或作为程序赋值；它不得静默吞掉用户 dirty 草稿。

## 值、dirty 与复合控件

`dirty` 始终由 `value` 与显式 `initialValue` 比较得出；用户把值改回初始语义值时立即恢复 pristine，即使 `touched` 仍为 true。空值、`0`、`false`、日期、结构化值和 Select option 均必须有产品定义的语义比较，不能用真值判断。

复合控件写入表单的只能是已提交业务值。例如 Select / Combobox 只将 `selectedValue` 作为字段 `value`；搜索 `query`、`activeOption`、展示标签与未提交 popup 草稿绝不是表单值，也不得触发 dirty、字段校验或提交。控件 owner 仍负责其内部请求和 ARIA，会在提交值改变时通知表单 owner。

## 校验时机、可见性与竞态

默认契约是“**提交前温和、提交后及时**”：

1. 首次提交前，未 touched 字段可以有内部校验结果，但不得显示字段错误或把焦点导向它们。
2. touched 字段在 `blur` 时运行本字段同步与适用异步校验，并在错误存在时显示；仅输入、尚未 blur 的字段不因内部 invalid 而阻塞式报错。
3. 首次提交将 `hasSubmitted` 设为 true，并运行完整字段校验与表单/跨字段校验；有错误时不发送请求，显示可导航错误摘要并聚焦摘要或第一个适用错误目标。
4. 首次提交后，已暴露且仍 invalid 的字段在编辑时立即重新校验（同步），并按字段策略启动异步校验；尚未暴露且未 touched 的字段仍按上述门槛处理。
5. 适用异步校验必须先防抖，再取消旧请求或将旧请求失效；每项结果携带 live form session、field id、`validationGeneration` 与被校验值。只有四者均匹配时才可更新 `asyncErrors` 或 `validating`。
6. 提交先冻结 `submitSnapshot` 与 `submitId`，等待当前适用校验完成；绝不发送已知 invalid 的快照。若校验产生错误，取消本次提交并按第 3 条处理；提交端点仍是最终服务端权威。

取消只节省资源，不能作为正确性条件：迟到的结果、重试、防抖回调、提交结果和排队焦点任务都必须先验证 live session、当前路由/owner 与相应 generation、`submitId` 或快照。route/unmount disposal 时取消或失效它们，并不得向已移除字段恢复焦点。

## 错误归属、关联与修复

每条错误只指定一个 primary owner，并可在错误摘要中以导航链接引用，不能在多个 live region 或字段重复播报完整消息：

- 单字段同步、异步和服务端错误归该字段；可见错误紧邻字段，字段以原生关联或 `aria-describedby` 关联错误文本。字段有可见错误时设 `aria-invalid="true"`，修复后移除该状态与过时关联。
- 错误摘要是可聚焦的表单级导航（例如 `tabindex="-1"`），列出“请修复以下 N 项”及每项的字段链接；链接把焦点移动到字段，不重复以 live region 朗读字段的完整错误。字段文本是字段错误的唯一完整公告；摘要本身只公告汇总或其 own 的表单级错误。
- 网络、认证、权限和 optimistic-lock 错误默认归当前提交/表单，保留在 `submitError`，不得假装成任一字段格式错误。若权限只限制一个明确字段，才由该字段作为 primary owner。
- 跨字段规则归明确的字段组或表单；只有一个 primary owner。摘要可以导航到该组的第一个可修复字段，但不得把同一完整冲突信息复制给每个参与字段。

服务端字段错误必须绑定 `{sessionId, submitId, fieldId, submittedValue, validationGeneration}`。它只在该字段仍对应被提交值且请求仍为当前时可见；该字段任何材料性值变化都会使该错误 stale 并撤销其显示资格，即使之后又改回相同字面值也不自动复活，需重新校验或重新提交。修复一个字段只清理该字段适用的错误，不能清除未改字段的服务端错误、表单网络错误或其他跨字段错误，也不得把焦点强制从用户正在修复的字段移开。

提交失败后的错误摘要必须保持在当前表单容器中；Dialog/Drawer 负责保持容器打开并按其规范处理焦点与关闭。若错误目标在响应式切换后仍存活，保持焦点；否则仅一次移动到等价字段或摘要，不能由旧会话延迟抢焦点。

## 可执行验收检查

下列检查以可观察状态、DOM 属性和事件日志断言；未实际执行时必须报告为**未验证**及所需环境。

1. **状态来源转换**：依次执行 prefill、focus、`user-input`、blur、`programmatic-assignment`、reset、server-refill；记录每次 `source`、`value`、`initialValue`、`touched`、`dirty` 与 `validationGeneration`，并断言只有值语义变化递增代次。
2. **改回初始值**：prefill 后编辑字段、blur、再改回 `initialValue`；断言字段和聚合表单为 `pristine`，且 `touched` 仍为 true。
3. **默认时机**：首次提交前只输入不 blur 无可见错误；blur 后仅该 touched 字段显示错误；首次提交后所有 invalid 字段进入摘要；再编辑已暴露 invalid 字段时同步错误立即更新且异步校验按防抖开始。
4. **异步顺序**：对同一字段先发 generation N、再改值发 N+1，并让 N 最后返回；断言只有 N+1 的同值结果可改变 `asyncErrors`、`validating` 或可见错误。提交在当前适用校验完成前不得发送，已知 invalid 时发送计数为 0。
5. **关联与摘要导航**：制造字段错误，断言可见错误相邻、字段具有 `aria-invalid="true"` 及有效错误文本关联；聚焦错误摘要并激活字段链接，断言焦点仅移动到目标字段。
6. **无重复公告**：记录辅助技术公告通道；一个字段错误产生一次完整字段消息，错误摘要只产生汇总/导航文本，网络或冲突错误只在其 primary owner 公告，不能同时在字段与摘要重复完整文本。
7. **服务端错误 stale**：以提交快照返回字段错误，断言它绑定 submitted value；编辑该字段后断言该错误立即不再显示且不会在改回旧值时复活。与此同时断言其他字段错误和表单级 `submitError` 仍保留，焦点仍留在正在修复的字段。

## 参考资料

- [WCAG 2.2: Error Identification](https://www.w3.org/WAI/WCAG22/Understanding/error-identification.html)
- [WCAG 2.2: Error Suggestion](https://www.w3.org/WAI/WCAG22/Understanding/error-suggestion.html)
- [WAI-ARIA APG: Form Validation](https://www.w3.org/WAI/ARIA/apg/practices/landmark-regions/)
