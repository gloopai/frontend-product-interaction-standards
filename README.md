# 前端产品交互规范

为前端设计、开发、评审与测试提供可执行的统一产品交互标准。

## 当前规范

本 Skill 当前包含以下 Dialog、四向抽屉、可搜索单选 Select、表单、数据表格、查询条件与筛选、记录新增/编辑承载面、按钮、上传与导入、反馈状态、全局反馈、跨端适配和管理台治理核心要求：

- PC、平板和移动端保持核心能力一致；低频能力可以折叠或收纳，但不能删除，且必须保持可发现、可访问。

- 遮罩点击不会关闭 Dialog；外框保持非滚动、仅内容区域滚动，且遮罩以正确层级覆盖整个视口。
- 打开和关闭动画防止重复操作并遵循 reduced-motion 偏好；焦点进入合理元素、在当前 Dialog 内循环，并在关闭后恢复。
- Dialog 具有可访问的角色、名称和可见操作；普通 Dialog 必须保留右上角关闭按钮，只有业务明确禁止退出时才可隐藏或禁用；背景隔离且多层 Dialog 仅允许最上层交互。
- 异步提交防止重复操作并可访问地传达 loading 与错误；关闭、路由变化和再次打开会清理相关状态。
- 在移动端、缩放、低高度与虚拟键盘场景中，内容和操作保持可访问。
- 上、下、左、右抽屉按来源边缘进入与退出；遮罩点击、拖拽和滑动均不会关闭抽屉，外框保持非滚动且仅内容区域滚动。
- 普通可退出抽屉在固定标题区右上角保留关闭按钮，并遵循全视口遮罩、焦点管理、背景隔离、安全区域、多层叠加、异步错误与状态清理规则。
- 自绘可搜索单选 Select 的值只能来自已有选项，支持完整键盘和 ARIA；`auto` 按稳定声明条件确定性解析为 `inline`、`panel`、`drawer` 或 Select-only `none`，PC 使用非模态浮层，移动端在需要时转换为移动端 Drawer。
- 表单以明确的字段状态、校验与提交生命周期管理错误、恢复、未保存更改和可访问错误反馈。
- 数据表格以显式能力档位覆盖展示、单行与批量场景，并约束筛选、排序、页码/游标分页、列与固定列、选择、批量操作和部分成功的交互。
- 查询条件与筛选规范约束草稿/已应用分离、应用模式、默认值、重置/清空、已应用摘要、URL 安全同步、权限收敛和移动端筛选可达性。
- 记录新增/编辑承载面禁止列表内嵌表单、常驻可编辑列表、单元格编辑、行内保存按钮和 spreadsheet-like 编辑矩阵；新增、编辑、复制创建和批量配置必须按场景进入 Dialog、Drawer 或独立页。
- 按钮规范首版聚焦管理台和业务操作按钮，约束按钮语义、文案、主次层级、禁用、loading、防重复、危险操作、图标按钮、按钮组和响应式可达性。
- 上传与导入规范覆盖文件选择、拖拽、本地校验、上传队列、进度、取消、重试、表单内文件字段、导入预检、字段映射、部分成功、错误明细和下载权限复核。
- 反馈状态与状态承载规范区分 loading、skeleton、empty、zero-results、error、refresh-error、stale、permission、partial 和 recovery，约束旧内容保留、Toast 边界、敏感信息和恢复入口。
- 全局反馈与通知规范约束 Toast、Alert、Banner、Notification 和 Inline Feedback 的通道选择、结果绑定、自动关闭、去重堆叠、恢复入口、移动端遮挡和敏感信息边界。
- 管理台完整治理覆盖导航、权限/租户、危险操作、审计、导入导出、异步任务、报表口径和全局反馈，并规定报表默认只读、能力显式声明、Toast 不得作为唯一回执。

完整规则、验收标准与完成前检查见 [Dialog 交互规范](references/dialogs.md)、[Drawer 交互规范](references/drawers.md)、[可搜索单选 Select / Combobox 交互规范](references/selects-comboboxes.md)、[表单状态、校验与错误交互规范](references/forms.md)、[数据表格交互规范](references/data-tables.md)、[查询条件与筛选交互规范](references/query-filters.md)、[记录新增/编辑承载面交互规范](references/record-editing-surfaces.md)、[按钮交互规范](references/buttons.md)、[上传与导入交互规范](references/uploads-imports.md)、[反馈状态与状态承载规范](references/feedback-states.md)、[全局反馈与通知交互规范](references/global-feedback.md)、[响应式与自适应交互规范](references/responsive-adaptive.md) 和 [管理台完整治理交互规范](references/admin-console.md)。

## 系统要求

需要已安装 Git、可使用 Codex，并且 `~/.codex/skills/` 目录具有写入权限。

## 安装

先确认目标目录不存在，再通过 HTTPS 克隆：

```sh
test ! -e ~/.codex/skills/frontend-product-interaction-standards
git clone https://github.com/gloopai/frontend-product-interaction-standards.git ~/.codex/skills/frontend-product-interaction-standards
```

## 使用

`SKILL.md` 的描述将此 Skill 定义为前端产品交互任务的适用规范，而 `agents/openai.yaml` 中的 `allow_implicit_invocation: true` 允许 Codex 在匹配的前端页面、组件、布局、Dialog、表单和交互任务中自动加载它。

也可以显式提出：`使用 $frontend-product-interaction-standards 检查这个 Dialog`。

## 项目接入

仅依赖隐式触发不足以保证业务项目强制执行本 Skill。需要在业务项目的 `AGENTS.md` 中加入最小接入片段，见 [项目 AGENTS.md 接入片段](docs/adoption/project-agents-snippet.md)；接入完成后可用 [项目接入检查清单](docs/adoption/checklist.md) 复核。

业务项目不要复制完整 `references/*.md` 作为长期事实来源；应强制读取本 Skill，并把项目例外留在业务项目内。

## 更新

```sh
git -C ~/.codex/skills/frontend-product-interaction-standards pull --ff-only
```

## 卸载

先确认目标目录存在：

```sh
test -d ~/.codex/skills/frontend-product-interaction-standards
```

删除该目录不可恢复。确认不再需要后，请由你自行删除 `~/.codex/skills/frontend-product-interaction-standards`；本文不提供删除命令。

## 目录结构

```text
frontend-product-interaction-standards/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── SKILL.md
├── agents/
│   └── openai.yaml
├── docs/
│   └── adoption/
│       ├── checklist.md
│       └── project-agents-snippet.md
└── references/
    ├── admin-console.md
    ├── buttons.md
    ├── data-tables.md
    ├── dialogs.md
    ├── drawers.md
    ├── feedback-states.md
    ├── forms.md
    ├── global-feedback.md
    ├── query-filters.md
    ├── record-editing-surfaces.md
    ├── selects-comboboxes.md
    ├── uploads-imports.md
    └── responsive-adaptive.md
```

## 扩展规范

新增或调整规范时，请遵循 [贡献指南](CONTRIBUTING.md) 中的分类、路由与验证要求。

## 适用范围

已在 Codex 中验证安装和使用流程。其他 Agent Skills 工具尚未验证，使用前请自行确认其兼容性。

## 贡献

贡献流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 行为准则

社区参与规范见 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。

## 安全

安全问题的私密报告方式见 [SECURITY.md](SECURITY.md)。

## 许可证

本项目采用 [MIT License](LICENSE)。
