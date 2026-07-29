# 表单状态、校验与错误交互规范

适用于含一个或多个可编辑字段、客户端/服务端校验与提交操作的表单。本文件是表单 owner 的状态、校验时机、错误归属和可访问错误反馈的唯一事实来源；视觉样式、字段控件内部草稿和弹层呈现不属于本文件。

表单放在 [Dialog](dialogs.md) 或 [Drawer](drawers.md) 中时，容器的打开、关闭、焦点陷阱、退出动画与 disposal 仍由对应 owner 负责；表单仅提供 `dirty`、`submitting`、错误摘要和可聚焦目标。Select / Combobox 的 `query`、`activeOption` 与 popup 会话仍由 [Select / Combobox](selects-comboboxes.md) owner 负责，只有已提交的 `selectedValue` 才是表单字段值。断点切换、跨端呈现和 route/unmount disposal 同时遵循 [响应式与自适应交互规范](responsive-adaptive.md)，不得重置同一表单会话。

关键词搜索输入作为表单字段时必须执行 `references/keyword-search-inputs.md`；表单只接收已提交的 `committedKeyword`，不得把 `inputDraft`、`normalizedDraft` 或 `compositionState` 当作字段业务值、dirty 或 submit payload。

字段 label、字段标题、必填/选填、条件必填、placeholder、字段说明、帮助文本、单位、格式示例、来源说明、权限原因、只读原因和禁用原因必须同时执行 `references/field-guidance-help-text.md`；本文件继续负责字段值、dirty、校验、错误 owner 和提交生命周期，`field-guidance-help-text.md` 负责说明信息、可访问描述、移动端等价路径和旧说明引用清理。

数字输入、金额输入、百分比、比例、费率、数量、排序序号、权重、阈值、配额、额度、余额、预算、时长、容量和单价必须同时执行 `references/numeric-amount-inputs.md`；Forms owner 只接收数字 owner 提交的 `committedValue`，数字 owner 负责 `numericInputState`、draftText、parsedValue、unitBinding、precisionPolicy、rangePolicy、submitSnapshotPolicy 和输入法/粘贴/移动端键盘边界。

条件字段、依赖字段、字段联动、条件显示/隐藏、条件必填、上游字段、下游字段、隐藏字段清理、自动填充和派生值必须同时执行 `references/conditional-fields-dependent-inputs.md`。Forms owner 继续负责字段值、dirty、校验、错误摘要和提交生命周期；条件字段 owner 负责 `fieldDependencyState`、dependencyGraph、upstreamSnapshot、downstreamPolicy、valueRetentionPolicy、candidatePolicy 和 submitSnapshotPolicy。

TabPanel 内表单的 dirty、提交、错误摘要和字段焦点仍归本文件；页面内 Tabs 执行 `references/tab-view-navigation.md`，tab owner 只能读取 `dirtyBoundary`，不得把激活 tab 当作提交表单、保存视图或清空表单草稿。

表单分组、可折叠字段区、隐藏高级设置和错误详情折叠必须同时执行 `references/disclosure-accordions.md`；折叠 owner 负责外显收起内容中的字段错误、必填缺失和恢复入口，Forms owner 继续负责 dirty、submit、字段错误和错误摘要。

页面正文中的表单 Section、字段分组卡片、主滚动、Sticky/fixed 保存区避让、移动端单列和内容密度必须同时执行 `references/page-content-layout-sections.md`；Forms owner 继续负责字段值、dirty、校验、错误和提交生命周期，`page-content-layout-sections.md` 负责表单所在 Section 的注册、布局、滚动和遮挡边界。

表单提交、字段保存、自动保存、开关保存或设置保存如果使用乐观更新、先改界面、撤销、失败回滚、离线队列、自动重试或迟到响应协调，必须同时执行 `references/optimistic-update-undo.md`；Forms owner 继续负责字段值、dirty、校验和提交生命周期，`optimistic-update-undo.md` 负责 pending 投影、撤销窗口、回滚依据、幂等、权威结果合并和旧投影清理。

## 范围与首版排除项

本规范覆盖单一编辑会话中的字段值、校验、提交、错误与焦点。首版不定义详细上传、富文本、日期、树/级联、多步骤向导、业务特定复合字段、跨页草稿持久化、离线队列/自动重试、协同编辑合并或产品特有的离开确认文案；这些控件只保留向表单提交**已提交业务值**的一般值提交边界，内部草稿、呈现与专属交互由各自 owner 定义。它们接入时仍不得绕过本文件的值版本、错误归属和 live-session 判断。

审批意见、审批备注、审批附件说明、驳回原因、转交理由、加签说明、委托说明和批量审批意见必须同时执行 `references/approval-workflows.md`；本文件继续负责字段值、校验、dirty、提交和错误 owner，`approval-workflows.md` 负责审批节点、意见可见范围、附件证据、决策快照和审计用途。

## 表单与字段 owner 状态

表单 owner 维护以下正交状态，不能用一个笼统的 `loading` 或 `invalid` 代替：

- `pristine`：所有字段相对各自显式 `initialValue` 都不 dirty；`dirty`：至少一个字段 dirty。它们是聚合派生值，不是可被直接置位的历史标志。
- `submitPhase`：当前提交意图的阶段，只能是 `idle`、`awaiting-validation`、`validation-aborted`、`request-in-flight`、`request-succeeded` 或 `request-failed`。`validation-aborted` 是尚未发送请求的意图终态，不得伪装成请求失败；新一次显式提交使用新的 `submitId`。
- `validating`：存在当前适用的同步或异步校验；`submitting` 仅在 `submitPhase: request-in-flight` 时为 true，不能把等待校验也表示成请求在途。
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
| `validationGeneration` | 值发生语义变化时递增；显式会话或校验 epoch 失效（reset、重建会话、接受 server-refill）也递增，即使值未变。focus/blur 不递增。异步结果必须带同一代次和值才能写回。 |

`user-input` 改变值并递增校验代次；`focus` 本身不改值或 touched；`blur` 把字段设为 `touched` 并触发该字段校验，二者都不递增代次。`prefill` 仅在会话建立前设定 `initialValue` 与 `value`，结果为 pristine、untouched。`programmatic-assignment` 必须声明它是替换当前值还是重建会话；前者照常重新计算 dirty 并在值语义变化时递增代次，后者同时替换 `initialValue`、清除会话状态并开始新 epoch。`reset` 把值还原为显式 initial 值、清除 touched 和本会话错误/异步工作，并开始新 epoch，因此即使值本来相同也递增代次。`server-refill` 在字段不 dirty 时原子更新 `value` 与 `initialValue`、保持 pristine、保留 touched 历史、取消旧异步工作并开始新的服务端校验 epoch；字段 dirty 时记录被拒绝的 refill 事件但不得覆盖草稿、初始值或来源。只有被实际接受的 refill 才将 `source` 设为 `server-refill`。

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
6. 提交先冻结 `submitSnapshot` 与 `submitId` 并进入 `awaiting-validation`，等待该候选快照的当前适用校验完成；绝不发送已知 invalid 的快照。校验确认候选仍适用且有效后才进入 `request-in-flight`；若校验产生错误、不可用、可恢复检查失败、超时或候选失配，本次意图进入 `validation-aborted` 并按第 3 条处理，提交端点仍是最终服务端权威。

取消只节省资源，不能作为正确性条件：迟到的结果、重试、防抖回调、提交结果和排队焦点任务都必须先验证 live session、当前路由/owner 与相应 generation、`submitId` 或快照。route/unmount disposal 时取消或失效它们，并不得向已移除字段恢复焦点。

产品必须记录 `awaiting-validation` 阶段的编辑策略。默认且推荐允许编辑，但任何会改变候选字段、generation 或版本令牌的材料性 user input、programmatic assignment、accepted server refill 或 reset，都必须立即把该 `submitId` 一次性终结为 `validation-aborted`；新草稿照常校验，旧候选的结果不能自动提交旧值或新值，用户必须对当前草稿再次显式提交。若产品选择在等待期锁定编辑，控件必须以可访问方式说明原因并提供适用的显式取消路径，取消同样进入 `validation-aborted`。两种策略都必须为校验失败、检查不可用、超时与取消定义有限终止路径，不能让提交意图永久停在 `awaiting-validation`；route/unmount 则直接服从 disposal，不在已失效 owner 中公告提交结果。

## 提交、响应与恢复生命周期

每次提交意图先创建不可变的 `submitSnapshot`（完整业务字段值、会话 epoch 与必要的版本/并发令牌）和唯一 `submitId`；之后的编辑、prefill 或程序写值均不得改变该 payload。同一意图处于 `awaiting-validation` 时，重复点击、键盘重复触发或重放事件只能复用该 `submitId`，不得新增校验或候选。完整字段及跨字段校验对该快照完成并确认适用前，不得发送请求；已知 invalid 快照的请求数必须为 0。只有进入 `request-in-flight` 的 `submitId` 才适用请求 exactly-once：请求发送与开始公告各恰好一次；收到适用终态后，终态回调与终态公告各恰好一次，且成功/失败分支互斥，成功时成功动作恰好一次、失败处理/归档为 0，失败时失败处理/归档恰好一次、成功动作为 0。重复事件、重试投递或迟到回调均不得增加这些计数。

仍处于 live session、但未进入请求阶段的 `validation-aborted` 不是请求终态：该 `submitId` 的请求发送、请求终态回调、成功动作与失败处理/归档计数都必须为 0；`validation-aborted` 终态事件、候选意图清理与由唯一状态 owner 发出的简短结果公告各为 1。清理必须一次取消/失效仅归该候选的校验工作与等待句柄，清除活动候选引用并令 `submitting: false`，但 `validating` 仍按新草稿的当前适用校验重算；只读终态日志保留 `submitId`/快照哈希，供迟到回调拒绝写回。invalid 时完整错误仍只由字段、字段组或表单 primary owner 呈现，摘要只公告汇总/导航；因编辑取消时只说明旧提交已取消并要求重新提交当前内容，不得同时播报请求失败。route/unmount disposal 的清理与静默失效按 owner 资源验收计数，不产生 `validation-aborted` 的 UI 公告。

进入 `request-in-flight` 后，产品必须明确选择提交中的编辑策略：禁止编辑时，受影响控件以可访问的禁用/只读状态表达原因，仍保留可读值和必要的恢复信息；允许编辑时，形成下一份草稿并按通常规则递增 generation。允许编辑并不使旧响应适用于新草稿：响应只有 live session、`submitId`、不可变快照及适用的版本/并发令牌均匹配时才可处理该次终态；它不得覆盖较新的值、字段错误、表单错误、dirty/touched 或成功状态。该次成功可将其快照更新为新的 initial baseline，但若当前值已是较新的 `S′`，必须保留 `S′`、以成功快照 `S` 重算 dirty，并继续把离开会话视为未保存变更。新提交取代旧提交时，旧 `submitId` 立即失去写回资格。

失败必须保留用户值、`dirty`、`touched`、可见错误及任务上下文，不得以 reset、关闭容器或路由跳转作为默认恢复。恢复路径必须与失败类别相符：网络失败提供保留草稿的重试/稍后处理；认证失败引导重新认证后安全重试；权限失败说明不可执行的原因并保留可读上下文；冲突失败说明版本冲突并提供重新加载、比较或明确的解决路径；服务端校验失败按其适用 owner 呈现且允许修复后重新提交。所有路径都不得把失败伪装为成功或静默丢弃草稿。

成功必须有可感知的结果反馈（可见状态及适用的状态公告），并由产品明确本次成功后的 `reset`、留在当前表单、关闭容器或导航路径；不得由 `loading` 结束隐式决定。对成功快照 `S`，成功结果成为新的 `initialValue`/会话基线：当前值仍为 `S` 时可恢复 pristine；当前值已为 `S′` 时必须保留 `S′`、相对 `S` 重算 dirty，且不得无条件撤销未保存提示。成功前的草稿、旧成功回调或旧响应不得回写。离开当前会话时，任何 dirty 导航、浏览器返回、路由切换或容器关闭都必须确认；只有成功后相对最新 initial baseline 已 pristine、用户明确 discard，或值回到该 baseline 时才撤销该提示。

路由变化或表单 owner 卸载立即使旧会话的校验、提交、错误写回、动画、重试/防抖和排队焦点回调失效，并仅释放该 form owner 持有的资源。资源释放按实例隔离且每项恰好一次：旧表单 A 不得释放存活表单 B 或容器持有的资源，A 的迟到回调也不得改变 B。此路径不恢复焦点到已移除字段；新路由在提交后独自拥有后续焦点。放在 Dialog/Drawer 中的表单仍遵循各容器的关闭、确认与 disposal 规则：`submitting`/loading 本身不得新增、移除或改写任何关闭路径，只有已声明的不可中断或未保存策略才能限制退出。

同一 live form session 在 Dialog 与 Drawer 间转换时保持单一实例，不得重建表单、重复校验或重复提交；必须原样延续 `initialValue`、当前值、dirty、touched、可见错误、validation generations、`submitSnapshot`、`submitId` 与在途请求。焦点节点仍存活时保持原焦点；否则由新容器按其 owner 规则仅一次移至等价字段或错误摘要。Select / Combobox 仅在其 owner 明确提交 `selectedValue` 时贡献字段值与该字段适用的有效性；`query`、active option、popup 草稿和搜索回调绝不进入表单 payload、dirty、校验或提交生命周期。

## 响应式与可访问性

每个字段的可见 label 必须用原生 `<label>`（显式或隐式）或 `aria-labelledby` 提供可访问名称；帮助、单位与错误文本才以稳定的 `aria-describedby`/等价描述关联对应同一输入，且每个引用的 ID 都指向当前存活节点。错误显示时 `aria-invalid` 与描述关联同步更新，修复或失效时移除过时关联。键盘顺序必须与视觉和任务顺序一致：错误摘要、字段、重试、提交及明确的放弃/恢复动作均可达，且焦点不会跳过错误或被旧回调夺走。状态变化（开始提交、失败、成功及必要的恢复状态）应由其唯一 owner 以非重复的可感知状态公告表达。

在 200% 缩放、系统字体放大、长标签/帮助/错误文本、低高度视口、动态 viewport、虚拟键盘和四向安全区域下，字段、关联文本、错误摘要、提交与所有恢复/放弃动作必须保持可达且可见。表单可从多列重排为单列或随容器改变形态，但不得删除字段、错误、摘要、恢复路径或离开确认；固定标题、页脚或键盘不得完全遮挡当前焦点、错误或主操作。具体容器几何、滚动、safe area 与焦点陷阱仍由响应式和 Dialog/Drawer owner 定义。

## 错误归属、关联与修复

每条错误只指定一个 primary owner，并可在错误摘要中以导航链接引用，不能在多个 live region 或字段重复播报完整消息：

- 单字段同步、异步和服务端错误归该字段；可见错误紧邻字段，字段以 `aria-describedby`（或等价描述关联）引用错误文本，不得把错误文本用作字段可访问名称。字段有可见错误时设 `aria-invalid="true"`，修复后移除该状态与过时关联。
- 错误摘要是可聚焦的表单级导航（例如 `tabindex="-1"`），列出“请修复以下 N 项”及每项的字段链接；链接把焦点移动到字段，不重复以 live region 朗读字段的完整错误。字段文本是字段错误的唯一完整公告；摘要本身只公告汇总或其 own 的表单级错误。
- 网络、认证、权限和 optimistic-lock 错误默认归当前提交/表单，保留在 `submitError`，不得假装成任一字段格式错误。若权限只限制一个明确字段，才由该字段作为 primary owner。
- 跨字段规则归明确的字段组或表单；只有一个 primary owner。摘要可以导航到该组的第一个可修复字段，但不得把同一完整冲突信息复制给每个参与字段。

服务端字段错误必须绑定 `{sessionId, submitId, fieldId, submittedValue, validationGeneration}`。它只在该字段仍对应被提交值且请求仍为当前时可见；该字段任何材料性值变化都会使该错误 stale 并撤销其显示资格，即使之后又改回相同字面值也不自动复活，需重新校验或重新提交。修复一个字段只清理该字段适用的错误，不能清除未改字段的服务端错误、表单网络错误或其他跨字段错误，也不得把焦点强制从用户正在修复的字段移开。

提交失败后的错误摘要必须保持在当前表单容器中；Dialog/Drawer 负责保持容器打开并按其规范处理焦点与关闭。若错误目标在响应式切换后仍存活，保持焦点；否则仅一次移动到等价字段或摘要，不能由旧会话延迟抢焦点。

## 可执行验收检查

下列检查以可观察状态、DOM 属性和事件日志断言；未实际执行时必须报告为**未验证**及所需环境。

1. **状态来源转换**：记录 `{source, value, initialValue, touched, dirty, syncErrors, asyncErrors, serverErrors, validating, validationGeneration}` 的事件日志。prefill `X` 后断言 `{source: prefill, value: X, initialValue: X, touched: false, dirty: false}`、三类 errors 为空、无异步请求且为新会话 epoch；focus 后仅 `source` 变为 `focus`，其余状态、errors、异步状态和 generation 均不变；blur 后 `source: blur`、`touched: true`，值/dirty/generation 不变，且只记录本字段校验启动。user-input `Y` 后断言 `source: user-input`、`value: Y`、dirty 按比较重算、旧 async 失效且 generation 加一。
2. **程序写值、reset 与 server-refill**：programmatic replace 从 `X` 写 `Y` 时断言 `source: programmatic-assignment`、`initialValue: X`、`value: Y`、`touched` 不被伪造、dirty 重算、旧 errors/async 对新值不适用且 generation 因语义变化加一；programmatic rebuild 会把 `value` 和 `initialValue` 都设为 `Y`、清空 touched/errors/async、令 dirty 为 false，并开始新 epoch。reset（即使已是 `X`）断言 `{source: reset, value: X, initialValue: X, touched: false, dirty: false}`、三类 errors 清空、异步取消、generation 加一。无 dirty 的 server-refill `Z` 断言原子得到 `{source: server-refill, value: Z, initialValue: Z, dirty: false}`、touched 保持、旧 errors/async 失效且开始新 epoch；dirty 时断言事件为 `server-refill-rejected`，`value`、`initialValue`、`source`、errors、async 和 generation 均未被 refill 覆盖。
3. **改回初始值与未提交复合草稿**：prefill 后编辑字段、blur、再改回 `initialValue`；断言字段和聚合表单为 `pristine`，且 `touched` 仍为 true。对 Select / Combobox 只改变 `query` 和 `activeOption`，断言表单 `value`、dirty、generation、字段校验和提交 payload 均不变；明确提交 `selectedValue` 后才断言这些表单状态按该值变化。
4. **默认时机**：首次提交前只输入不 blur 无可见错误；blur 后仅该 touched 字段显示错误；首次提交后所有 invalid 字段进入摘要；再编辑已暴露 invalid 字段时同步错误立即更新且异步校验按防抖开始。
5. **异步顺序与 preflight 终止**：对同一字段先发 generation N、再改值发 N+1，并让 N 最后返回；断言只有 N+1 的同值结果可改变 `asyncErrors`、`validating` 或可见错误。以点击创建 `{submitId, submitSnapshot, submitPhase: awaiting-validation}`，再用 Enter 和重放事件触发同一意图；断言仍只有一个候选和一组适用校验。按默认允许编辑策略材料性修改候选字段，断言状态恰好一次变为 `validation-aborted`，该 `submitId` 的请求、请求终态回调、成功动作与失败处理计数均为 0，候选清理为 1、取消结果公告为 1，`submitting: false` 且 `validating` 按新草稿重算；随后交付旧校验成功结果，断言它既不提交旧值也不自动提交新值，只有再次显式提交才创建新 `submitId`。另以 invalid、unavailable、check-failed、超时及锁定策略的显式取消逐项重复，断言均在有限终止路径进入 `validation-aborted`，不会悬挂在 `awaiting-validation`。
6. **请求阶段 exactly-once、快照与重复提交**：让匹配校验成功的候选进入 `request-in-flight`，记录不可变 `{submitId, submitSnapshot}`；对同一 `submitId` 断言请求发送与开始公告各为 1。构造成功和失败两次独立请求尝试：成功分支断言请求终态回调、成功动作与终态公告各为 1、失败处理/归档为 0；失败分支断言请求终态回调、失败处理/归档与终态公告各为 1、成功动作为 0。重复点击、Enter、重放与重复响应不得增加计数。随后允许的下一草稿或程序赋值不得改变 payload；迟到结果只有在同一 live session、`submitId` 与快照及版本令牌匹配时才可写回，绝不覆盖新草稿、errors 或状态。成功后断言 `submitSucceeded: true`；任何新编辑、reset 或新提交都必须撤销它，旧成功结果不得重新置回 true。
7. **关联、摘要导航与错误 owner**：制造字段错误，断言可见 label 以原生 label 或 `aria-labelledby` 给出正确 accessible name，help/unit/error 仅通过 `aria-describedby`/等价描述关联，且所有描述 ID 均指向存活节点；字段具有 `aria-invalid="true"` 及有效错误文本关联。聚焦错误摘要并激活字段链接，断言焦点仅移动到目标字段。分别注入网络、认证、权限和 optimistic-lock 错误：断言它们的 primary owner 为 `submitError`，唯明确单字段权限限制归该字段；摘要/字段/live region 事件日志中同一完整消息只能出现一次。再制造一个同时涉及字段 A/B 的跨字段冲突，记录 `{errorId, groupOwnerId, announcementOwnerId, summaryTargetId, fieldMessageIds}`：断言 `groupOwnerId` 只有一个且指向明确字段组或 form owner，`announcementOwnerId` 与其一致并只完整公告一次，摘要对该错误只有一个 `summaryTargetId` 且指向第一个可修复字段，A/B 的 `fieldMessageIds` 均不复制完整冲突文本。
8. **无重复公告与服务端错误 stale**：记录辅助技术公告通道；一个字段错误产生一次完整字段消息，错误摘要只产生汇总/导航文本，网络或冲突错误只在其 primary owner 公告，不能同时在字段与摘要重复完整文本。以提交快照返回字段错误，断言它绑定 submitted value；编辑该字段后断言该错误立即不再显示且不会在改回旧值时复活。与此同时断言其他字段错误和表单级 `submitError` 仍保留，焦点仍留在正在修复的字段。
9. **请求中编辑、失败恢复与成功基线**：分别执行产品已声明的 `request-in-flight` 中禁止编辑和允许编辑策略；禁止时断言控件原因可感知且值/恢复路径仍可读，允许时编辑形成新草稿并使旧响应失去覆盖资格。对网络、认证、权限、冲突和服务端校验失败逐项断言值、dirty、touched、可见错误和上下文保留，且只呈现匹配的重试、认证、权限说明、冲突解决或字段修复路径；不得关闭或 reset。成功时断言可见/可访问反馈及成功动作各一次，且产品定义的 reset、stay、close 或 navigate 行为被明确执行；若提交快照为 `S` 而当前值已为 `S′`，断言 baseline 更新为 `S`、当前值仍为 `S′`、dirty 重算为 true，且导航仍确认。
10. **未保存导航、处置与容器转换**：dirty 时分别触发路由导航、浏览器返回、Dialog/Drawer 关闭，断言先确认；只有成功后相对最新 baseline 已 pristine、明确 discard 或改回该 baseline 后断言不再提示。然后让表单 A 与存活表单 B（或 B 所在容器）各自持有可区分的资源；在 A 的防抖、异步校验、提交/错误/动画回调和排队焦点任务待处理时触发 route/unmount，记录 disposal、取消/失效、每项 owned-resource release 与焦点事件。断言 A 的每项资源恰好释放一次，B/容器资源与状态不变；随后交付 A 的全部迟到回调，断言它们不改 A 的已处置状态、DOM 或焦点，也不影响 B，新路由仅按自己的策略聚焦一次。保持同一表单会话切换 Dialog/Drawer 或断点形态：精确焦点节点仍存活时断言零次 `blur`/重新 focus；节点不存活时仅一次 focus 到等价字段或错误摘要；`initialValue`、当前值、dirty、touched、可见 errors、generation、快照、`submitId` 与请求均保持，且无重复校验或提交。仅 loading 时断言关闭路径不变。
11. **复合字段边界、关联和状态公告**：只改变 Select / Combobox 的 `query`、active option 或未提交 popup 草稿，断言字段值、validity、dirty、generation、payload、请求与提交计数均不变；明确提交 `selectedValue` 后才断言该字段的值和适用 validity 更新。检查可见 label 产生的 accessible name、help/unit/error 的描述关联及全部引用 ID 的存活性、`aria-invalid`、键盘顺序和错误摘要导航；对每次进入请求的提交分别断言开始公告一次，互斥成功或失败终态公告一次，完整错误或状态消息只由一个 owner 播报，焦点不会被迟到回调抢走。
12. **缩放、移动与运行时报告**：在 200% 缩放、字体放大、长文本、低高度、动态 viewport、虚拟键盘、四向 safe area 与移动单列重排中，断言字段、关联文本、错误、摘要、提交及所有恢复/放弃动作仍可达，当前焦点、错误与主操作不被固定区域或键盘完全遮挡，且没有字段或恢复动作因重排而删除。上述运行时、辅助技术和真实视口检查未实际执行时，报告必须逐项标为**未验证**，并写明所需浏览器、设备/viewport、输入方式及辅助技术环境；不得将静态文档检查写成运行时通过。

## 参考资料

- [WCAG 2.2: Error Identification](https://www.w3.org/WAI/WCAG22/Understanding/error-identification.html)
- [WCAG 2.2: Error Suggestion](https://www.w3.org/WAI/WCAG22/Understanding/error-suggestion.html)
- [WAI Forms Tutorial: Validating Input](https://www.w3.org/WAI/tutorials/forms/validation/)
