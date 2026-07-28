# 项目接入强制执行设计

## 背景

当前 `frontend-product-interaction-standards` Skill 已经包含 Dialog、Drawer、Select、表单、数据表格、记录编辑承载面、按钮、响应式和管理台治理等 owner，并且 Skill 自身声明 `allow_implicit_invocation: true`。但“允许隐式触发”不等于“业务项目强制执行”：当其他项目的 `AGENTS.md` 没有要求读取本 Skill 时，Agent 仍可能只按项目本地旧规则、记忆或组件库默认行为实现。

`fex-admin` 暴露了这个问题：它的项目规则包含部分旧兜底规范，但没有强制读取本 Skill，也没有覆盖后续新增的表单、表格、管理台、记录编辑承载面和按钮 owner。这个项目只能作为接入问题的证据，不能反向影响通用规范内容。

## 核心原则

通用规范与业务项目必须隔离：

- `frontend-product-interaction-standards` 只提供通用 Skill、接入模板、检查清单和可审计门禁。
- 业务项目只消费这些模板；业务项目的页面、模块、组件库和历史实现不能反向改变通用 owner。
- 若业务项目需要例外，只能在业务项目自己的 `AGENTS.md` 或项目文档中声明明确范围；不得把项目例外写入通用 Skill。
- 通用 Skill 的 owner 继续保持框架无关、项目无关、产品交互导向。

## 目标

- 在规范仓库新增项目接入模板，让任何业务项目都能通过最小 `AGENTS.md` 片段强制加载本 Skill。
- 明确“未加载规范不得继续实现”的阻塞规则，防止 Agent 在业务项目中绕过 Skill。
- 提供项目接入检查清单，方便逐个仓库验证是否强制接入。
- 先把 `fex-admin` 作为消费方接入示例处理，但不把 `fex-admin` 专属规则写入通用规范。

## 非目标

- 不修改现有 Dialog、Drawer、Select、Forms、Data Tables、Record Editing Surfaces、Buttons、Responsive 或 Admin Console owner 的行为。
- 不把 `fex-admin` 的业务页面、模块、组件、路由或设计偏好写入通用 Skill。
- 不复制完整规范到每个业务项目，避免多份规则长期漂移。
- 不通过 lint 或 CI 自动阻断实现；首版只提供 Agent 指令级强制门禁和文档审计。

## 推荐方案

采用“通用接入包 + 项目最小强制片段 + 可审计清单”。

### 方案对比

| 方案 | 优点 | 缺点 | 结论 |
| --- | --- | --- | --- |
| 通用接入包 + 项目最小强制片段 | 不污染通用 owner；每个业务项目只复制很短的门禁；后续规范更新自动通过 Skill 路由生效。 | 需要逐个项目更新 `AGENTS.md`。 | 推荐。 |
| 把完整规范复制进业务项目 | 项目离线时也能看到完整规则。 | 极易漂移；每次通用规范更新都要同步多份长文档。 | 不采用。 |
| 依赖 Skill 的隐式触发 | 不用改业务项目。 | 无法保证 Agent 一定加载；已经证明会漏。 | 不采用。 |
| 直接按 `fex-admin` 定制通用规范 | 短期贴合当前项目。 | 破坏通用性，后续其他项目会被 fex-admin 牵着走。 | 明确禁止。 |

## 通用接入包结构

计划在规范仓库新增：

```text
docs/adoption/
├── project-agents-snippet.md
└── checklist.md
```

### `project-agents-snippet.md`

提供可复制到任意业务项目 `AGENTS.md` 的标准片段。片段必须包含：

- 前端交互任务开始前读取本地 Skill：`~/.codex/skills/frontend-product-interaction-standards/SKILL.md`。
- 根据 Skill 路由读取对应 `references/*.md`。
- 若本地 Skill 缺失或不可读，停止受影响的前端交互实现，说明阻塞，不凭记忆继续。
- 本项目本地规则与 Skill 同时适用；更严格者优先；冲突时停止并请用户裁决。
- 最终回复列出读取的规范文件、实际验证、未验证项。
- 禁止把业务项目例外同步回通用 Skill。

### `checklist.md`

提供项目接入检查清单：

- 项目根目录是否存在 `AGENTS.md`。
- 是否包含强制读取 Skill 的本地路径。
- 是否包含 “Skill 不可读则停止”。
- 是否包含 “按路由读取 references”。
- 是否包含 “项目例外不得反向污染通用 Skill”。
- 是否包含 “最终回复列明规范与验证状态”。
- 是否保留项目自身必要上下文，而不是复制完整通用规范。

## 业务项目接入策略

业务项目只需要一段最小强制门禁，而不是完整规范副本。建议结构：

```markdown
## Frontend interaction standards

For any frontend page, component, form, list, table, dialog, drawer, button, admin-console, responsive, or interaction change:

1. Read `~/.codex/skills/frontend-product-interaction-standards/SKILL.md` before implementation or review.
2. Follow that Skill's routing and read every applicable `references/*.md`.
3. Treat those rules as hard acceptance criteria.
4. If the Skill or required reference file is unavailable, stop the affected work and report the blocker.
5. Apply project-local rules together with the Skill; follow the stricter compatible rule, and stop on conflicts.
6. Final responses must list loaded standard files and mark unverified runtime checks.
7. Do not copy project-specific exceptions back into the shared Skill.
```

中文项目可使用同义中文片段，但应保持相同语义。

## `fex-admin` 处理边界

`fex-admin` 的处理只作为消费方接入：

- 可以更新 `/Users/evanqi/code/fex-admin/AGENTS.md`，加入强制读取 Skill 的标准片段。
- 可以保留 `fex-admin` 自己的技术栈、运行命令、模块说明和项目上下文。
- 应减少或替换复制在项目内的大段旧通用规范，避免它和 Skill 新版本冲突。
- 不得把 `fex-admin` 的模块、页面、现有实现妥协或专属偏好写入 `frontend-product-interaction-standards` 的 owner。
- `fex-admin` 的提交和规范仓库的提交应分开，避免审查时混淆通用模板与业务项目接入。

## 验证策略

规范仓库验证：

- Markdown 相对链接检查。
- 未完成标记扫描。
- `git diff --check`。
- 新增 adoption 文档关键词检查：`project-agents-snippet.md` 必须包含 Skill 路径、停止规则、路由读取、冲突裁决和禁止项目污染通用 Skill。

业务项目验证：

- 检查项目 `AGENTS.md` 是否包含标准片段的核心语义。
- 检查项目 `AGENTS.md` 不再把过期的完整通用规范作为唯一事实来源。
- 若保留本地兜底规则，必须标记为“Skill 不可用时的最小红线”，不能覆盖完整 Skill。

## 验收标准

- 通用规范仓库新增可复用接入文档，而不是 fex-admin 专属规则。
- 接入模板明确强制读取 Skill，且 Skill 不可读时停止受影响实现。
- 接入模板明确项目例外不得反向污染通用 Skill。
- `fex-admin` 后续接入只消费模板，不改变通用 owner。
- README/HANDOFF 可只补充 adoption 摘要，不复制接入片段全文。
