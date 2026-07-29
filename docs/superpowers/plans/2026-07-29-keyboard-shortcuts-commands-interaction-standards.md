# 快捷键与键盘命令交互规范实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增快捷键与键盘命令交互规范，统一管理快捷键作用域、冲突、输入保护、执行门禁、可发现性和移动端替代。

**Architecture:** 新增一个职责单一的 reference owner，并通过 `SKILL.md`、`README.md`、`HANDOFF.md` 和相邻 owner 建立路由。用 RED/GREEN 文档与 Ruby 审计脚本验证结构化规则和项目无关性。

**Tech Stack:** Markdown 规范文档、Ruby 静态审计、Git。

## Global Constraints

- 全部新增复核文档使用中文。
- 不引入具体项目名、目录、框架、组件库或技术栈绑定。
- 不把未执行的真实浏览器、平台、键盘布局、输入法、读屏、移动端硬件键盘、Dialog/菜单/表格冲突和浏览器快捷键验证写成已通过。

---

### Task 1: 新增 owner 与证据

**Files:**
- Create: `references/keyboard-shortcuts-commands.md`
- Create: `docs/superpowers/specs/2026-07-29-keyboard-shortcuts-commands-interaction-standards-design.md`
- Create: `docs/testing/keyboard-shortcuts-commands/red-summary.md`
- Create: `docs/testing/keyboard-shortcuts-commands/green-summary.md`

**Interfaces:**
- Produces: `keyboardShortcutState`、`scopeBinding`、`commandRegistry`、`keyBindingMap`、`inputProtectionPolicy`、`conflictPolicy`、`discoverabilityPolicy`、`executionPolicy`、`runtimeVerification`。

- [x] **Step 1: 写 RED 证据**

记录缺少独立快捷键 owner 时的失败：全局 keydown 穿透、输入框误触、系统快捷键冲突、无权限帮助泄露和移动端无替代。

- [x] **Step 2: 写 owner 正文**

定义状态模型、作用域、冲突、输入保护、执行门禁、可发现性、权限安全、移动端和完成前检查。

- [x] **Step 3: 写 GREEN 证据**

列明新增 owner、状态字段、硬禁止、相邻 owner 接入和未验证边界。

### Task 2: 接入路由和相邻 owner

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Modify: `references/buttons.md`
- Modify: `references/search-command-palette.md`
- Modify: `references/data-tables.md`
- Modify: `references/dialogs.md`
- Modify: `references/overlays-menus-tooltips.md`
- Modify: `references/navigation-routing.md`
- Modify: `references/responsive-adaptive.md`

**Interfaces:**
- Consumes: `references/keyboard-shortcuts-commands.md`
- Produces: 自动路由和相邻 owner 边界引用。

- [x] **Step 1: 补 SKILL 路由**

加入快捷键、热键、keybinding、shortcut help 等关键词。

- [x] **Step 2: 补 README/HANDOFF 摘要**

让使用者能从首页和交接文档找到 owner。

- [x] **Step 3: 补相邻 owner 引用**

在按钮、命令面板、表格、Dialog、菜单、导航和响应式规范中引用新 owner。

### Task 3: 新增审计并验证

**Files:**
- Create: `docs/testing/keyboard-shortcuts-commands/keyboard-shortcuts-commands-audit.rb`

**Interfaces:**
- Consumes: owner、路由、README、HANDOFF、相邻 owner 和 RED/GREEN 证据。
- Produces: `PASS: 快捷键与键盘命令 owner、路由和证据符合结构化审计契约。`

- [x] **Step 1: 写审计脚本**

审计状态字段、关键硬禁止、路由关键词、相邻引用、README/HANDOFF 摘要、证据字段和项目泄露。

- [x] **Step 2: 运行专项 mutation 审计**

Run: `ruby docs/testing/keyboard-shortcuts-commands/keyboard-shortcuts-commands-audit.rb --mutations`

- [x] **Step 3: 运行全量审计、链接检查和 diff 检查**

Run: 全量 `docs/testing/*/*-audit.rb`、Markdown 链接解析、`git diff --check` 和项目泄露扫描。
