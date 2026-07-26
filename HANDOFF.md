# 前端产品交互规范 Skill 交接说明

## 项目定位

这是一个面向 Codex Agent 的中文前端产品交互规范 Skill。它应在创建、修改、重构、评审或测试前端页面、组件和交互行为时自动触发，并将相关规范作为硬性验收条件。

## 项目位置

- Codex 本地 Skill：`/Users/evanqi/.codex/skills/frontend-product-interaction-standards`
- GitHub 仓库：`https://github.com/gloopai/frontend-product-interaction-standards`
- 默认分支：`main`
- 当前交接版本：`e8cd5451fc3cc7d6c528c99773708a27192f63fb`

新建 Codex Project 时，请直接选择本地 Skill 目录，不要选择原业务项目 `/Users/evanqi/code/fex-admin`。

## 当前结构

```text
frontend-product-interaction-standards/
├── SKILL.md
├── README.md
├── agents/openai.yaml
├── docs/
│   └── audits/
│       └── 2026-07-25-existing-standards-hardening.md
└── references/
    ├── dialogs.md
    ├── drawers.md
    ├── forms.md
    ├── responsive-adaptive.md
    └── selects-comboboxes.md
```

仓库同时包含 `LICENSE`、`CONTRIBUTING.md`、`CODE_OF_CONDUCT.md` 和 `SECURITY.md` 等开源项目文件。

## 已完成规范

### Dialog

- 点击遮罩不得关闭 Dialog。
- 遮罩必须覆盖完整视口。
- 外框不得滚动，仅内容区域滚动；标题、关闭按钮和操作区保持可见。
- 普通可退出 Dialog 必须保留右上角关闭按钮。
- 已定义打开/关闭动画、焦点管理、Escape、焦点陷阱、多层弹窗、异步状态、错误反馈、清理和 reduced motion。
- 普通关闭固定遵循“退出完成 → DOM 移除 → 本实例保护释放 → 恰好一次焦点恢复”；路由变化或卸载走立即 disposal。

### Drawer

- 支持上、下、左、右四个方向。
- 已定义遮罩、关闭路径、滚动区域、焦点、层级、动画、异步状态和响应式规则。
- PC 与移动端核心能力保持一致；低频能力可以折叠，但不能彻底删除。
- 从 Drawer 转为非模态形态时，Drawer 专属模态基础设施必须释放；进入 Drawer 时必须由其取得，并且每项只处理一次。
- 普通关闭固定遵循“退出完成 → DOM 移除 → 本实例保护释放 → 恰好一次焦点恢复”；路由变化或 owner 卸载立即执行幂等 disposal。

### PC 与移动端兼容

- 以核心任务和能力一致为原则，不要求像素级一致。
- 对触控、键盘、低高度视口、动态视口、软键盘、安全区域、缩放和布局迁移均有约束。

### 可搜索单选 Select

- 只支持单选，提交值必须来自当前合法选项。
- 使用自绘 Combobox/Listbox 交互，支持键盘和无障碍语义。
- 搜索位置支持 `auto`、`inline`、`panel`、`drawer`、`none`。
- `auto` 必须按照稳定条件确定性解析，不能由 Agent 临时猜测，也不能因过滤结果数量在打开期间跳变。
- PC 可以使用行内输入或非模态面板；受限空间和移动端场景可以使用 Drawer。
- `none` 仅使用 Select-only Combobox，不再允许 button + Listbox 的替代模型。
- 已定义草稿查询与已提交值、失效值、异步搜索、状态播报、焦点、Tab、Space/Enter、Home/End 和 ARIA 所有权。
- `resolvedPlacement` 转换保留逻辑 ID；目标焦点和 ARIA 必须在焦点移动前或同一 committed render 更新，来源专属属性随之移除，且转换不提交值或草稿。

### 表单

- 已定义字段与表单的状态、校验时机、提交快照、错误归属、失败恢复、未保存更改确认及可访问错误反馈。
- 详细规则和可执行验收仅维护在 [表单状态、校验与错误交互规范](references/forms.md)，本交接不重复其状态模型或检查项。

### 响应式 closing

- 进入 closing 后冻结当前渲染形态，忽略后续断点转换；只能执行一次专项退出动画、卸载和清理，并持续保持保护直到该流程完成。

详细的 F-01 至 F-07 加固账本、交叉矩阵、静态场景重放和验证边界见 [现有规范加固最终审计账本](docs/audits/2026-07-25-existing-standards-hardening.md)。本交接仅摘要已完成保证，不复制该账本。

## 已确认的设计原则

1. 核心能力跨端一致，低频能力可以折叠但不能删除。
2. 搜索位置按场景灵活处理，但必须通过明确配置或确定性 `auto` 规则得出。
3. 选择必须显式提交；关闭、取消或模式切换不得静默改变已提交值。
4. 组件库默认行为与规范冲突时，应配置、封装或替换组件，而不是降低规范。
5. 实现完成后必须逐项验证相关交互、键盘、无障碍和视口；未实际验证的项目必须明确报告。

## 与原业务项目的关系

原业务项目位于 `/Users/evanqi/code/fex-admin`。该项目的 `AGENTS.md` 已保留 Dialog 和可搜索单选 Select 的关键兜底约束，供未成功加载 Skill 的 Agent 使用。

规范仓库和业务仓库应独立维护：

- 通用规则修改在 Skill 仓库完成并发布。
- 业务实现修改在具体业务仓库完成。
- 只有确实需要离线兜底的关键约束才同步到业务项目的 `AGENTS.md`，避免两份完整规范长期漂移。

## 后续建议

建议按优先级继续增加：

1. 表格、分页、筛选、排序和批量操作。
2. Toast、Alert、Notification、Popover 与 Tooltip。
3. 导航、面包屑、Tabs 和页面离开确认。
4. 上传、下载、进度与失败重试。
5. 空状态、加载骨架、权限不足和数据异常。

每次新增规范时，应同步检查：

- `SKILL.md` 是否有准确的自动触发关键词和参考文件路由。
- 详细规则是否只保存在对应 `references/*.md`，避免与 README 重复。
- `README.md` 是否只保留面向使用者的摘要、安装和贡献说明。
- `agents/openai.yaml` 是否仍与 Skill 定位一致。
- 新规则是否有明确的状态模型、键盘交互、ARIA、跨端行为和验收清单。
- 修改是否已提交并推送到公开仓库，Codex 本地 Skill 是否与 `origin/main` 一致。

## 新 Project 的建议开场指令

切换后可以直接发送：

> 请先阅读 `HANDOFF.md`、`SKILL.md`、`README.md` 和现有 `references/`，确认仓库状态与远端 `main` 一致。之后继续维护“前端产品交互规范” Skill；新增规范时保持中文、自动触发、跨端核心能力一致，并在提交前完成独立评审和验证。

## 当前验证状态

- 已通过官方 Skill 验证、Markdown 相对链接检查、占位符扫描和 `git diff --check` 等文档静态检查。
- 已完成 Base→Head 完整差异审查、独立 RED/GREEN 应用检查及最终复审；静态修订、账本和证据边界见上述审计链接。
- 本次交接更新已核对本地 `HEAD` 与 GitHub `main` 的版本一致性，并且只更新 `HANDOFF.md`。
- 本轮属于规范文档工作；浏览器、屏幕阅读器、触控设备和真实业务组件测试均未执行，需在具体组件实现时完成。
