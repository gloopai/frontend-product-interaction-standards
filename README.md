# 前端产品交互规范

为前端设计、开发、评审与测试提供可执行的统一产品交互标准。

## 当前规范

本 Skill 当前包含以下 Dialog、四向抽屉、可搜索单选 Select 与跨端适配核心要求：

- PC、平板和移动端保持核心能力一致；低频能力可以折叠或收纳，但不能删除，且必须保持可发现、可访问。

- 遮罩点击不会关闭 Dialog；外框保持非滚动、仅内容区域滚动，且遮罩以正确层级覆盖整个视口。
- 打开和关闭动画防止重复操作并遵循 reduced-motion 偏好；焦点进入合理元素、在当前 Dialog 内循环，并在关闭后恢复。
- Dialog 具有可访问的角色、名称和可见操作；普通 Dialog 必须保留右上角关闭按钮，只有业务明确禁止退出时才可隐藏或禁用；背景隔离且多层 Dialog 仅允许最上层交互。
- 异步提交防止重复操作并可访问地传达 loading 与错误；关闭、路由变化和再次打开会清理相关状态。
- 在移动端、缩放、低高度与虚拟键盘场景中，内容和操作保持可访问。
- 上、下、左、右抽屉按来源边缘进入与退出；遮罩点击、拖拽和滑动均不会关闭抽屉，外框保持非滚动且仅内容区域滚动。
- 普通可退出抽屉在固定标题区右上角保留关闭按钮，并遵循全视口遮罩、焦点管理、背景隔离、安全区域、多层叠加、异步错误与状态清理规则。
- 自绘可搜索单选 Select 的值只能来自已有选项，支持完整键盘和 ARIA；PC 使用非模态浮层，移动端在需要时转换为移动端 Drawer。

完整规则、验收标准与完成前检查见 [Dialog 交互规范](references/dialogs.md)、[Drawer 交互规范](references/drawers.md)、[可搜索单选 Select / Combobox 交互规范](references/selects-comboboxes.md) 和 [响应式与自适应交互规范](references/responsive-adaptive.md)。

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
└── references/
    ├── dialogs.md
    ├── drawers.md
    ├── selects-comboboxes.md
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
