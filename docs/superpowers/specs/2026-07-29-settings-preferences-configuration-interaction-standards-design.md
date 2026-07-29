# 设置、偏好与配置页交互规范设计

## 背景

管理台的设置页、偏好页和配置页出现频率很高：通知、成员权限、集成开关、配额、默认值、审批策略、外部系统连接和租户级配置都属于这一类。现有规范已经覆盖表单、开关、按钮、危险操作、权限和导航离开保护，但缺少一个组合 owner 来约束“配置项如何生效、作用于谁、如何保存/取消/重置、权限变化后如何收敛”。

本设计新增 `settings-preferences-configuration` owner，作为设置、偏好、配置项、策略项和管理台配置页的唯一事实来源。

## 目标

- 区分 `draftSettings`、`savedSettings`、`effectiveSettings` 和 `defaultSettings`，避免 hover、toggle 视觉态或未保存草稿伪装成已生效配置。
- 要求每个配置项声明作用域：用户、租户、工作区、项目、环境、角色、对象或集成。
- 明确即时生效、显式保存和高风险确认三类提交模式，禁止同页混用而无说明。
- 规范保存、取消、恢复、重置默认、继承默认、局部重置和离开保护。
- 约束危险设置、权限降级、外部集成、异步保存、部分成功和未知结果。
- 保证移动端不删除保存/取消、脏状态、作用域说明、默认值说明、危险确认和恢复路径。

## 非目标

- 不重新定义字段校验、错误摘要和表单提交细节；继续执行 `forms.md`。
- 不重新定义 Switch、Radio、Checkbox 等控件语义；继续执行 `selection-controls.md`。
- 不重新定义按钮文案、loading 和防重复；继续执行 `buttons.md`。
- 不重新定义危险操作强确认；继续执行 `risk-actions.md`。
- 不规定具体设置项、业务默认值、后端接口或存储模型。

## 方案

新增 `references/settings-preferences-configuration.md`，并在 `SKILL.md` 增加 settings、preferences、configuration、config page、setting page、preference page、feature setting、notification setting、integration setting、default setting、save settings、reset defaults、inherit defaults、设置、偏好、配置页、设置页、偏好页、配置项、策略配置、通知设置、集成设置、默认设置、保存设置、重置默认、继承默认等路由关键词。

owner 定义 `settingsState`：

- `settingsOwnerId`：当前设置页面、设置组或配置项 owner。
- `settingsScope`：配置作用域，含用户、租户、工作区、项目、环境、角色、对象、集成。
- `draftSettings`：用户当前编辑但未保存的草稿。
- `savedSettings`：服务端确认保存的值。
- `effectiveSettings`：当前实际生效的值，可能来自保存值、默认值、继承值或权限派生值。
- `defaultSettings`：产品默认、组织默认、上级继承默认或权限派生默认。
- `applyMode`：`immediate`、`explicit-save`、`confirm-required`。
- `dirtyState`：脏字段、脏分组、保存能力、取消能力和离开保护。
- `resetPolicy`：恢复保存值、重置默认、继承默认和清空自定义的差异。
- `permissionBoundary`：谁可读、可改、可恢复、可查看默认、可查看审计。
- `resultReceipt`：保存成功、部分成功、失败、冲突、未知、审计回执。

## 核心规则

1. 设置项必须声明作用域和生效模式。用户偏好、租户配置、项目配置、环境配置和外部集成配置不得混用同一含糊状态。
2. `draftSettings` 不得伪装成 `effectiveSettings`。显式保存模式下，切换开关或编辑字段只改变草稿；即时生效模式必须在控件旁说明“更改会立即生效”并处理失败恢复。
3. 保存、取消、恢复保存值、重置默认、继承默认和清空自定义是不同意图，不得都写成“重置”。
4. 高风险设置必须进入 `risk-actions.md`，保存前请求数为 0；关闭确认或离开页面不得伪装成服务端已取消。
5. 权限、租户/工作区、角色、对象状态或配置版本变化后，旧草稿、旧默认值、旧禁用原因、旧保存按钮和旧集成状态必须原子收敛。
6. 异步保存必须绑定不可变配置快照、作用域、权限版本和幂等键。部分成功、失败、冲突和未知结果不得伪装成成功。
7. 移动端不得删除保存/取消、脏状态、作用域说明、默认值说明、继承说明、危险确认、错误摘要、审计回执或恢复路径。

## 文档影响

- 新增 `references/settings-preferences-configuration.md`。
- 更新 `SKILL.md` 路由。
- 更新 `README.md` 当前规范、摘要、链接和目录树。
- 更新 `HANDOFF.md` 交接摘要。
- 新增 `docs/testing/settings-preferences-configuration/` 红绿证据和 Ruby 突变审计。

## 验证策略

- RED：先写审计脚本并要求 owner、路由、README、HANDOFF 和证据术语，确认缺少 owner 时失败。
- GREEN：补 owner 和摘要后，审计通过并输出突变失败。
- 突变覆盖缺少 settingsState、缺少作用域、草稿伪装生效、重置语义合并、危险设置绕过 risk owner、权限收敛缺失、异步结果状态合并、移动端核心能力删除、运行时边界伪装已验证、项目泄漏。
- 全量执行现有 owner 审计、Markdown 链接检查和 `git diff --check`。

## 自检

- 文档内容完整。
- 范围聚焦设置/偏好/配置页组合 owner，不抢表单、选择控件、按钮或危险操作 owner。
- 可以单次实施：一个 reference、三个摘要/路由文件、一个测试目录。
