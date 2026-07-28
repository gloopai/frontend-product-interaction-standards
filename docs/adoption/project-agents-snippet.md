# 项目 AGENTS.md 接入片段

这份文档提供可复制到任意业务项目 `AGENTS.md` 的最小强制片段。它的目标是让项目在处理前端产品交互任务时强制读取本地 `frontend-product-interaction-standards` Skill，而不是把完整规范复制进业务仓库。

业务项目可以保留自己的技术栈、运行命令、目录说明和项目例外；但项目例外只能留在业务项目内，不得复制回通用 Skill。

## 推荐片段

将下面片段放入项目根目录或对应前端子目录的 `AGENTS.md`：

```markdown
## Frontend interaction standards

These instructions apply to every frontend page, component, form, list, table, dialog, drawer, button, admin-console, responsive, or interaction change in this repository.

Before implementation or review:

1. Read `~/.codex/skills/frontend-product-interaction-standards/SKILL.md`.
2. Follow that Skill's routing and read every applicable `references/*.md`.
3. Treat the loaded rules as hard acceptance criteria.
4. If the Skill or any required reference file is unavailable, stop the affected work and report the blocker. Do not continue from memory, copied legacy rules, or component-library defaults.
5. Apply project-local rules together with the Skill; follow the stricter compatible rule, and stop on conflicts.
6. Final responses must list loaded standard files, checks actually run, and unverified runtime checks.
7. Project-specific exceptions stay in this repository only and must not be copied back into the shared Skill.
```

## 中文片段

中文项目也可以使用下面同义片段：

```markdown
## 前端交互规范

本规则适用于本仓库内所有前端页面、组件、表单、列表、表格、Dialog、Drawer、按钮、管理台、响应式和交互行为的创建、修改、重构、评审或测试。

开始实现或评审前：

1. 先读取 `~/.codex/skills/frontend-product-interaction-standards/SKILL.md`。
2. 按该 Skill 的路由读取所有适用的 `references/*.md`。
3. 将已加载规范视为硬性验收标准。
4. 如果 Skill 或任何必需参考文件不可读，停止受影响的前端交互工作并说明阻塞原因；不得凭记忆、旧复制规则或组件库默认行为继续。
5. 项目本地规则与 Skill 同时适用；更严格且兼容者优先；出现冲突时停止并请用户裁决。
6. 最终回复必须列出已读取的规范文件、实际运行的检查，以及未验证的运行时检查。
7. 项目专属例外只允许留在本仓库，不得复制回共享 Skill。
```

## 使用要求

- 不要把 `references/*.md` 的完整内容复制进业务项目；业务项目只需要保留上面的强制加载片段。
- 如果项目已有旧版复制规则，应将其替换为此最小片段，或明确降级为“Skill 不可用时的最小红线”，不得作为唯一事实来源。
- 如果业务项目需要例外，必须写清适用范围、原因和审批边界；例外不能改写通用 Skill 的 owner。
- 如果任务不涉及前端产品交互，可以不加载本 Skill；一旦涉及列表、表格、表单、按钮、Dialog、Drawer、管理台或响应式行为，就必须加载。
