# 项目接入强制执行计划

## 目标

在通用规范 Skill 仓库内补齐“项目接入强制门禁”材料，让业务项目能通过最小 `AGENTS.md` 片段强制加载本 Skill，同时保证业务项目只作为消费者，不反向影响通用 owner。

## 范围

本轮只修改 `frontend-product-interaction-standards` 仓库：

- 新增通用项目接入片段。
- 新增项目接入检查清单。
- 新增接入文档静态审计。
- 在 README 和 HANDOFF 中补充接入入口。

本轮不修改任何业务项目，也不调整现有 Dialog、Drawer、Select、Forms、Data Tables、Record Editing Surfaces、Buttons、Responsive 或 Admin Console 规范语义。

## 执行步骤

1. 创建 `docs/adoption/project-agents-snippet.md`，提供可复制到业务项目 `AGENTS.md` 的最小强制片段。
2. 创建 `docs/adoption/checklist.md`，定义项目是否完成接入的通过与失败判定。
3. 创建 `docs/testing/adoption/adoption-audit.rb`，检查接入文档是否包含 Skill 路径、路由读取、不可读停止、冲突裁决、最终回复披露和项目例外隔离。
4. 补充 README 与 HANDOFF 的接入入口，避免重复完整规范。
5. 运行接入审计、Markdown 相对链接检查、未完成标记扫描和 `git diff --check`。

## 验收标准

- 接入片段明确要求前端交互任务开始前读取 `~/.codex/skills/frontend-product-interaction-standards/SKILL.md`。
- 接入片段明确要求按 Skill 路由读取适用的 `references/*.md`。
- Skill 或必需参考文件不可读时，必须停止受影响实现，不允许凭记忆继续。
- 项目本地规则与 Skill 同时适用；更严格且兼容者优先；冲突时停止并请用户裁决。
- 最终回复必须列出已读取规范、实际验证和未验证运行时检查。
- 项目例外只能留在业务项目，不能复制回通用 Skill。
- 通用接入文档保持项目无关，不包含业务项目专属名称、页面或模块。

## 风险与边界

- `allow_implicit_invocation: true` 只能提升自动触发概率，不能替代项目 `AGENTS.md` 的强制要求。
- 不在业务项目内复制完整通用规范，避免多份事实来源漂移。
- 后续接入具体项目时应单独提交，审查时区分“通用模板”与“业务项目消费”。
