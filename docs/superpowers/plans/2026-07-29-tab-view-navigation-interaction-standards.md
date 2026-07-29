# Tab 视图导航交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增 Tab 视图导航 owner，约束页面内 Tabs、TabList、TabPanel、active tab、URL/历史恢复、懒加载、权限隐藏、未保存保护和移动端形态转换。

**Architecture:** 采用现有规范仓库模式：先写 Ruby 静态审计并确认 RED，再新增 `references/tab-view-navigation.md` 作为页面内 tab view primary owner，最后补齐 `SKILL.md` 路由、README/HANDOFF 摘要、相邻 owner 关系和 RED/GREEN 证据。审计使用 exact-term contract 与 mutation cases，确保 Tabs 不被误当成全局路由、字段选择或保存视图。

**Tech Stack:** Markdown 规范文档、Ruby 静态审计脚本、Git。

## Global Constraints

- 只处理本 skill 仓库内的交互规范，不修改任何业务项目代码。
- 不得引用或依赖 `fex-admin`、`/Users/evanqi/code/`、`src/pages`、`Ant Design`、`ant-design`、`shadcn`、`Next.js`、`Vite`、`React`、`Vue`。
- 新 owner 必须保持框架无关、组件库无关、项目无关。
- 规范、复核文档和证据文档必须使用中文。
- 新 owner 只负责页面内 tab view；全局导航、路由离开和浏览器 Back/Forward 仍由 `references/navigation-routing.md` 负责，字段选择仍由 `references/selection-controls.md` 负责，TabPanel 内内容仍由对应专项 owner 负责。
- 真实浏览器、键盘、屏幕阅读器、移动端、权限切换、网络迟到和未保存确认未执行时，必须标为 `未验证`。
- 实施必须先 RED、后 GREEN；不能把未执行的验证写成已经通过。

---

## File Structure

- Create: `references/tab-view-navigation.md`
  - Tab 视图导航 primary owner，覆盖页面内 Tabs、标签页、TabList、TabPanel、active tab、URL/历史恢复、懒加载、权限、未保存保护和移动端承载。
- Create: `docs/testing/tab-view-navigation/tab-view-navigation-audit.rb`
  - 新 owner 的 exact-term contract、路由检查、相邻 owner 检查、证据检查、项目泄漏检查和 mutation suite。
- Create: `docs/testing/tab-view-navigation/red-summary.md`
  - 记录新增 owner 前的 RED 结果。
- Create: `docs/testing/tab-view-navigation/green-summary.md`
  - 记录新增 owner 后的 GREEN 结果。
- Modify: `SKILL.md`
  - 新增 Tab 视图导航路由。
- Modify: `README.md`
  - 新增规范总览摘要和 owner 引用。
- Modify: `HANDOFF.md`
  - 新增中文阶段性交接摘要。
- Modify: `references/navigation-routing.md`
  - 明确页面内 Tabs 执行 `references/tab-view-navigation.md`，并接入同一离开保护管线。
- Modify: `references/selection-controls.md`
  - 明确 Segmented Control 作为移动端 Tab 承载时不提交字段值。
- Modify: `references/forms.md`
  - 明确 TabPanel dirty、提交和错误归 Forms；tab owner 只读 dirtyBoundary。
- Modify: `references/permissions-tenancy-visibility.md`
  - 明确 tab 可见/禁用/隐藏/无权限和旧 panel 清理执行权限边界。
- Modify: `references/responsive-adaptive.md`
  - 明确移动端 Tabs 转 Select/Drawer/Action Sheet 时保持 tab view 语义。
- Modify: `references/feedback-states.md`
  - 明确 TabPanel loading/error/stale/empty 的反馈承载关系。
- Modify: `references/page-toolbars-actions.md`
  - 明确 tab 上方或 tab 内工具栏只读取当前 active tab 和已提交 panel 状态。
- Modify: `references/saved-views-layout-presets.md`
  - 明确保存视图可保存安全 active tab，但不得保存草稿、旧权限或无权限 tab。

---

### Task 1: 写失败审计并记录 RED

**Files:**
- Create: `docs/testing/tab-view-navigation/tab-view-navigation-audit.rb`
- Create: `docs/testing/tab-view-navigation/red-summary.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-tab-view-navigation-interaction-standards-design.md`
- Produces: command `ruby docs/testing/tab-view-navigation/tab-view-navigation-audit.rb`

- [ ] **Step 1: 创建审计脚本目录**

Run:

```sh
mkdir -p docs/testing/tab-view-navigation
```

- [ ] **Step 2: 创建审计脚本**

Create `docs/testing/tab-view-navigation/tab-view-navigation-audit.rb` with:

```ruby
STATE_FIELDS = %w[
  tabOwnerId surfaceKind tabRegistry activeTabId pendingTabIntent panelState
  requestBinding urlHistoryBinding permissionBoundary dirtyBoundary
  focusAnnouncementPolicy responsivePolicy
].freeze

OWNER_TERMS = [
  "tabViewState",
  "Tabs 只能用于同一资源或同一任务上下文",
  "激活 tab 不等于提交表单、不等于保存视图、不等于切换租户/工作区",
  "disabled tab、hidden tab、permission-denied tab 和 not-enabled tab 不是同一状态",
  "旧 tab 请求不得写回新 active tab 或无权限 panel",
  "Tab 切换必须经过同一未保存保护管线",
  "移动端改变承载形态不得改变 `activeTabId`、URL、权限和 dirty 语义",
  "Tab 切换先创建 `pendingTabIntent`",
  "写 URL 的 tab 必须只写稳定 `tabId`",
  "浏览器 Back/Forward、URL 恢复、保存视图恢复和默认 tab 恢复必须先校验 tabRegistry 版本、权限、租户/工作区、对象状态和 tab 是否仍启用",
  "懒加载请求必须绑定 `tabOwnerId`、`activeTabId`、目标 `tabId`、对象 ID、权限版本、租户/工作区、route 和请求代次",
  "用户确认放弃前不得卸载 panel、发起新 tab 请求或改变 URL",
  "未启用表示 DOM、state、handler、request 和 URL 入口均为 0",
  "无权限不得泄露 tab 标题、数量、对象名、错误明细、旧内容或内部 ID",
  "移动端不得删除当前 tab、可用 tab、禁用原因、权限原因、错误状态、未保存保护、返回路径和恢复入口",
  "转换为 Select 或 Drawer 时仍是页面内 tab view，不得变成字段选择",
  "未验证"
].freeze
```

Add `ROUTE_TERMS` from the design doc plus `references/tab-view-navigation.md`.

Add relationship terms requiring `references/tab-view-navigation.md` or `tab-view-navigation.md` in `navigation-routing.md`、`selection-controls.md`、`forms.md`、`permissions-tenancy-visibility.md`、`responsive-adaptive.md`、`feedback-states.md`、`page-toolbars-actions.md`、`saved-views-layout-presets.md`.

Add mutation cases:

- `missing-owner-state`
- `tabs-cross-resource`
- `active-tab-submits-form`
- `tab-states-merged`
- `late-request-writes-active`
- `dirty-guard-removed`
- `mobile-conversion-changes-active`
- `pending-intent-missing`
- `url-writes-title`
- `url-restore-without-validation`
- `lazy-request-weak-binding`
- `unmount-before-discard-confirm`
- `not-enabled-still-has-entry`
- `permission-leakage`
- `mobile-tab-capability-removed`
- `select-conversion-as-field`
- `runtime-boundary-marked-verified`
- `missing-route`
- `missing-adjacent-owner-link`
- `project-specific-leakage`

- [ ] **Step 3: 运行 RED**

Run:

```sh
ruby docs/testing/tab-view-navigation/tab-view-navigation-audit.rb
```

Expected: FAIL with `missing file: .../references/tab-view-navigation.md`.

- [ ] **Step 4: 创建 RED 证据文档**

Create `docs/testing/tab-view-navigation/red-summary.md` with Chinese coverage for `tabViewState`、all state fields、activeTabId、pendingTabIntent、panelState、requestBinding、dirtyBoundary、permissionBoundary、responsivePolicy、URL、懒加载、未保存保护、移动端、未验证.

- [ ] **Step 5: 提交 RED**

Run:

```sh
git add docs/testing/tab-view-navigation/tab-view-navigation-audit.rb docs/testing/tab-view-navigation/red-summary.md
git commit -m "test: 增加标签页视图规范审计"
```

---

### Task 2: 新增 owner 文档并补相邻边界

**Files:**
- Create: `references/tab-view-navigation.md`
- Modify: `references/navigation-routing.md`
- Modify: `references/selection-controls.md`
- Modify: `references/forms.md`
- Modify: `references/permissions-tenancy-visibility.md`
- Modify: `references/responsive-adaptive.md`
- Modify: `references/feedback-states.md`
- Modify: `references/page-toolbars-actions.md`
- Modify: `references/saved-views-layout-presets.md`

**Interfaces:**
- Consumes: Task 1 audit script
- Produces: owner terms and relationship terms that satisfy the audit except route/README/HANDOFF/GREEN

- [ ] **Step 1: 新增 `references/tab-view-navigation.md`**

The file must include `tabViewState` table with all `STATE_FIELDS`, then exact rule sections for:

- scope and owner boundary
- activation and pendingTabIntent
- URL/history restore
- lazy loading and late response
- dirtyBoundary and unsaved guard
- permission states
- focus and ARIA
- responsive conversion
- completion checks with `未验证`

The owner text must include every `OWNER_TERMS` exact string.

- [ ] **Step 2: 补相邻 owner 边界**

Add one sentence containing `references/tab-view-navigation.md` to each target:

- `navigation-routing.md`: page tabs execute tab owner and share leave guard.
- `selection-controls.md`: segmented mobile tab carrier keeps tab semantics, not field value.
- `forms.md`: tab owner reads dirtyBoundary; form dirty remains Forms owner.
- `permissions-tenancy-visibility.md`: tab visibility/old panel cleanup follows permission boundary.
- `responsive-adaptive.md`: mobile tab conversion preserves activeTabId/URL/dirty.
- `feedback-states.md`: TabPanel feedback is carried by feedback owner.
- `page-toolbars-actions.md`: toolbar reads active tab and committed panel state.
- `saved-views-layout-presets.md`: saved views may persist safe active tab only.

- [ ] **Step 3: 阶段验证并提交**

Run:

```sh
ruby docs/testing/tab-view-navigation/tab-view-navigation-audit.rb
git diff --check
git add references/tab-view-navigation.md references/navigation-routing.md references/selection-controls.md references/forms.md references/permissions-tenancy-visibility.md references/responsive-adaptive.md references/feedback-states.md references/page-toolbars-actions.md references/saved-views-layout-presets.md
git commit -m "docs: 新增标签页视图规范"
```

Expected audit failure at this stage should be limited to route/README/HANDOFF/GREEN gaps.

---

### Task 3: 补路由、README、HANDOFF 和 GREEN 证据

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/tab-view-navigation/green-summary.md`

**Interfaces:**
- Consumes: Task 2 owner and audit script
- Produces: complete GREEN audit

- [ ] **Step 1: 补 `SKILL.md` 路由**

Add route for Chinese/English trigger terms listed in the design doc, pointing to `references/tab-view-navigation.md`.

- [ ] **Step 2: 补 `README.md`**

Add summary:

```md
- Tab 视图导航规范：见 `references/tab-view-navigation.md`。约束 tabViewState、TabList/TabPanel、activeTabId、URL/历史恢复、懒加载、权限隐藏、未保存保护、焦点公告和移动端形态转换。
```

- [ ] **Step 3: 补 `HANDOFF.md`**

Add Chinese section:

```md
### Tab 视图导航

- 已定义 Tabs、标签页、页签、TabList、TabPanel、当前标签、默认标签、禁用标签、隐藏标签、权限标签、页面内视图切换和移动端标签承载的首版 owner。
- `tabViewState` 必须声明 `tabOwnerId`、`surfaceKind`、`tabRegistry`、`activeTabId`、`pendingTabIntent`、`panelState`、`requestBinding`、`urlHistoryBinding`、`permissionBoundary`、`dirtyBoundary`、`focusAnnouncementPolicy` 和 `responsivePolicy`。
- Tabs 只能用于同一资源或同一任务上下文；激活 tab 不等于提交表单、不等于保存视图、不等于切换租户/工作区。
- 旧 tab 请求不得写回新 active tab 或无权限 panel；Tab 切换必须经过同一未保存保护管线。
- 移动端改变承载形态不得改变 `activeTabId`、URL、权限和 dirty 语义。
- 详细规则和可执行验收仅维护在 [Tab 视图导航交互规范](references/tab-view-navigation.md)，本交接不重复其状态模型或检查项。
```

- [ ] **Step 4: 创建 GREEN 证据**

Create `docs/testing/tab-view-navigation/green-summary.md` with Chinese coverage for `tabViewState`、all fields、activeTabId、pendingTabIntent、panelState、requestBinding、dirtyBoundary、permissionBoundary、responsivePolicy、URL、懒加载、未保存保护、移动端、未验证.

- [ ] **Step 5: GREEN 验证并提交**

Run:

```sh
ruby docs/testing/tab-view-navigation/tab-view-navigation-audit.rb --mutations
git diff --check
git add SKILL.md README.md HANDOFF.md docs/testing/tab-view-navigation/green-summary.md
git commit -m "docs: 补齐标签页视图规范路由"
```

---

### Task 4: 全量验证并推送

**Files:**
- No new files unless verification exposes a defect.

**Interfaces:**
- Consumes: Tasks 1-3 commits
- Produces: pushed `main`

- [ ] **Step 1: 运行专项审计**

Run:

```sh
ruby docs/testing/tab-view-navigation/tab-view-navigation-audit.rb --mutations
```

- [ ] **Step 2: 运行相邻 owner 审计**

Run:

```sh
ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations
ruby docs/testing/selection-controls/selection-controls-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
ruby docs/testing/page-toolbars-actions/page-toolbars-actions-audit.rb --mutations
ruby docs/testing/saved-views-layout-presets/saved-views-layout-presets-audit.rb --mutations
```

- [ ] **Step 3: 运行全量审计、链接和泄漏检查**

Run:

```sh
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
git diff --check
rg -n "fex-admin|/Users/evanqi/code/|src/pages|Ant Design|ant-design|shadcn|Next.js|Vite|React|Vue" references/tab-view-navigation.md docs/testing/tab-view-navigation/red-summary.md docs/testing/tab-view-navigation/green-summary.md README.md || true
```

- [ ] **Step 4: 推送 main**

Run:

```sh
git status --short --branch
git push origin main
git status --short --branch
git log --oneline -8
```
