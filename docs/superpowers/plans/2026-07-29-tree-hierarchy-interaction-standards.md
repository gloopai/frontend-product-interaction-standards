# 树形结构与级联交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增树形结构与级联 owner，覆盖 Tree、Tree Select、Cascader、Tree View、Tree Grid、组织树、权限树、菜单树、分类树和级联选择的身份、展开、选择、级联、半选、懒加载、权限安全、可访问性和移动端承载。

**Architecture:** 新建 `references/tree-hierarchy.md` 作为唯一事实来源，并在 `SKILL.md`、`README.md`、`HANDOFF.md` 中建立路由和摘要。新增 `docs/testing/tree-hierarchy/` 下的 GREEN/RED 摘要与 Ruby 静态审计器，沿用现有 owner 的术语覆盖 + mutation 模式。

**Tech Stack:** Markdown 文档；Ruby 标准库静态审计；Git 提交；不引入依赖。

## Global Constraints

- 普通 Checkbox/Radio/Switch/Segmented 继续由 `selection-controls.md` 负责；存在层级、父子级联、半选来源或懒加载时归本 owner。
- 数据表格树表的列、分页、排序、行选择和批量操作继续由 `data-tables.md` 负责。
- 展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 不得伪装成已提交选择。
- 半选只表达派生状态，不是业务提交值。
- 懒加载未完成、过滤后仅展示部分节点、权限未知或存在 disabled 后代时，不能把“全选当前可见”伪装成“全选全部后代”。
- 无权限节点不得泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存。
- 移动端不得删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限切换、懒加载、虚拟化、远程搜索和移动端视口验证在本轮文档工作中必须标为未验证。

---

## File Structure

- Create `references/tree-hierarchy.md`: 树形结构与级联 owner 正文、硬规则和完成前检查。
- Modify `SKILL.md`: 增加 tree/cascader/tree select/组织树/权限树等路由。
- Modify `README.md`: 在当前规范摘要和完整规则链接中加入新 owner。
- Modify `HANDOFF.md`: 在已完成规范与目录树中加入新 owner 摘要。
- Create `docs/testing/tree-hierarchy/green-summary.md`: 正向证据摘要。
- Create `docs/testing/tree-hierarchy/red-summary.md`: 负向失败摘要。
- Create `docs/testing/tree-hierarchy/tree-hierarchy-audit.rb`: 静态审计和 mutation checks。

---

### Task 1: 新增 owner 正文

**Files:**
- Create: `references/tree-hierarchy.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-tree-hierarchy-interaction-standards-design.md`
- Produces: `treeHierarchyState` 状态模型、完成前检查和可被审计器匹配的稳定术语。

- [ ] **Step 1: 创建 owner 文档**

写入 `references/tree-hierarchy.md`，必须包含以下开头：

```markdown
# 树形结构与级联交互规范

适用于 Tree、Tree View、Tree Select、Tree Grid、Cascader、级联选择、树形选择、组织树、部门树、权限树、菜单树、分类树、资源目录树和地区级联。本文件是层级数据展示、展开、选择、级联、半选、过滤、懒加载、权限安全、可访问性和验收的唯一事实来源。
```

- [ ] **Step 2: 写入 `treeHierarchyState`**

状态模型必须逐项包含：

```markdown
`treeOwnerId`、`nodeIdentity`、`treeDataSnapshot`、`expandedNodeIds`、`activeNodeId`、`selectedNodeIds`、`checkedNodeState`、`cascadePolicy`、`filterState`、`loadState`、`permissionBoundary`、`commitMode`、`feedbackState`、`a11yPolicy`、`responsivePolicy`
```

- [ ] **Step 3: 写入硬规则**

必须逐字保留以下核心规则，供审计器匹配：

```markdown
展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 不得伪装成已提交选择。
节点必须有稳定业务 ID、节点类型、父子关系、路径版本和权限版本。
半选只表达派生状态，不是业务提交值。
`indeterminate` / half-checked / partial selected 不能提交给后端。
懒加载未完成、过滤后仅展示部分节点、权限未知或存在 disabled 后代时，不能把“全选当前可见”伪装成“全选全部后代”。
无权限节点不得泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存。
移动端不得删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径。
```

- [ ] **Step 4: 写入完成前检查**

检查项必须覆盖：节点身份、路径、数据快照、展开/active/选择分离、级联策略、半选、全选范围、过滤、懒加载、权限降级、键盘、ARIA、移动端、异步回调/disposal 和未验证声明。

- [ ] **Step 5: 本地检查**

Run:

```bash
rg -n "treeHierarchyState|nodeIdentity|cascadePolicy|半选只表达派生状态|全选当前可见|无权限节点|移动端不得删除|未验证" references/tree-hierarchy.md
git diff --check
```

Expected: `rg` 找到对应术语；`git diff --check` 无输出且 exit 0。

---

### Task 2: 接入路由与摘要

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: Task 1 的 `references/tree-hierarchy.md`
- Produces: 用户任务能够路由到新 owner；README/HANDOFF 能让维护者发现新规范。

- [ ] **Step 1: 更新 `SKILL.md` 路由**

在 selection controls 路由之后或 data tables 路由之前加入：

```markdown
- 涉及 Tree、Tree View、Tree Select、Tree Grid、Cascader、树形结构、树形选择、级联选择、层级选择、组织树、部门树、权限树、菜单树、分类树、资源目录树、地区级联、父子级联、半选、懒加载节点、树节点搜索，或 tree、tree view、tree select、tree grid、cascader、hierarchy、hierarchical select、cascade select、organization tree、permission tree、menu tree、category tree、lazy tree、half checked 时，必须完整读取 `references/tree-hierarchy.md`。
```

- [ ] **Step 2: 更新 `README.md` 当前规范摘要**

在当前规范列表加入一句：

```markdown
- 树形结构与级联规范约束 Tree、Tree Select、Cascader、组织树、权限树、菜单树、分类树的节点身份、展开、选择、级联、半选、过滤、懒加载、权限无泄露和移动端承载。
```

并在完整规则链接列表中加入：

```markdown
树形结构与级联交互规范：`references/tree-hierarchy.md`
```

- [ ] **Step 3: 更新 `HANDOFF.md`**

在目录树加入：

```markdown
├── tree-hierarchy.md
```

在已完成规范中加入：

```markdown
### 树形结构与级联

- 已定义 Tree、Tree Select、Cascader、组织树、权限树、菜单树、分类树和级联选择的首版 owner。
- 展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 不得伪装成已提交选择。
- 半选只表达派生状态，不是业务提交值；懒加载未完成、过滤后仅展示部分节点、权限未知或存在 disabled 后代时，不能把“全选当前可见”伪装成“全选全部后代”。
- 无权限节点不得泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存。
- 移动端不得删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径。
```

- [ ] **Step 4: 本地检查**

Run:

```bash
rg -n "tree-hierarchy.md|Tree Select|Cascader|权限树|菜单树|half checked" SKILL.md README.md HANDOFF.md
git diff --check
```

Expected: 三个文档都命中新 owner；`git diff --check` 通过。

---

### Task 3: 新增审计证据和静态审计器

**Files:**
- Create: `docs/testing/tree-hierarchy/green-summary.md`
- Create: `docs/testing/tree-hierarchy/red-summary.md`
- Create: `docs/testing/tree-hierarchy/tree-hierarchy-audit.rb`

**Interfaces:**
- Consumes: Task 1 owner 和 Task 2 路由摘要
- Produces: `ruby docs/testing/tree-hierarchy/tree-hierarchy-audit.rb --mutations`

- [ ] **Step 1: 写 GREEN 摘要**

`green-summary.md` 必须覆盖：

```markdown
- `treeHierarchyState` 固定包含 owner、节点身份、树数据快照、展开、active、选择、勾选、级联、过滤、加载、权限、提交、反馈、可访问性和响应式策略。
- 展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 和 optimistic preview 不得伪装成已提交选择。
- 节点必须有稳定业务 ID、节点类型、父子关系、路径版本和权限版本。
- 半选只表达派生状态，不是业务提交值。
- `indeterminate` / half-checked / partial selected 不能提交给后端。
- 懒加载未完成、过滤后仅展示部分节点、权限未知或存在 disabled 后代时，不能把“全选当前可见”伪装成“全选全部后代”。
- 无权限节点不得泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存。
- 移动端不得删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径。
- 真实浏览器、触摸、键盘、屏幕阅读器、权限切换、懒加载、虚拟化、远程搜索和移动端视口仍是未验证。
```

- [ ] **Step 2: 写 RED 摘要**

`red-summary.md` 必须覆盖：

```markdown
- 使用显示名称、数组 index、过滤位置、懒加载顺序或 DOM key 作为业务身份。
- 展开、active、hover、filter match、visible descendants、indeterminate、partial loaded 或 optimistic preview 被写成已提交选择。
- 半选或 `indeterminate` / half-checked / partial selected 被提交给后端。
- 过滤后只展示部分节点，却把“全选当前可见”当作“全选全部后代”。
- 懒加载失败被当作无子节点或完整 loaded。
- 无权限节点泄露节点名称、数量、路径、父子关系、图标、类型、内部 ID、排序位置、子节点是否存在或旧缓存。
- 移动端删除搜索、展开、返回上级、路径摘要、已选摘要、清空、应用、错误说明、权限说明或恢复路径。
```

- [ ] **Step 3: 写 Ruby 审计器**

审计器必须检查 owner、路由、README、HANDOFF、GREEN、RED 和项目泄露。Mutation checks 至少包含：

```ruby
"visual-state-not-committed"
"stable-node-identity"
"half-check-not-business-value"
"indeterminate-not-submitted"
"visible-all-not-descendants"
"permission-no-leakage"
"mobile-capability-preserved"
"runtime-boundary-marked-verified"
"missing-route"
"project-leak"
```

- [ ] **Step 4: 运行专项审计**

Run:

```bash
ruby docs/testing/tree-hierarchy/tree-hierarchy-audit.rb --mutations
```

Expected: baseline PASS；所有 mutation 输出 `EXPECTED_FAIL`。

---

### Task 4: 全量验证、提交和推送

**Files:**
- All files modified by Tasks 1-3

**Interfaces:**
- Consumes: 完整 owner、路由、摘要和审计器
- Produces: pushed commit on `main`

- [ ] **Step 1: 运行维护 owner 审计**

Run:

```bash
ruby docs/testing/admin-console/admin-console-audit.rb --mutations
ruby docs/testing/adoption/adoption-audit.rb --mutations
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/charts-visualization/charts-visualization-audit.rb --mutations
ruby docs/testing/date-time-ranges/date-time-ranges-audit.rb --mutations
ruby docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
ruby docs/testing/information-display/information-display-audit.rb --mutations
ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations
ruby docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb --mutations
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
ruby docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/search-command-palette/search-command-palette-audit.rb --mutations
ruby docs/testing/selection-controls/selection-controls-audit.rb --mutations
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
ruby docs/testing/wizards-steppers/wizards-steppers-audit.rb --mutations
ruby docs/testing/tree-hierarchy/tree-hierarchy-audit.rb --mutations
```

Expected: all commands exit 0. Do not use historical `docs/testing/data-tables/attempt-*` scripts as maintained owner gates.

- [ ] **Step 2: 运行 Markdown 链接检查**

Run:

```bash
ruby -e 'files = Dir["README.md", "HANDOFF.md", "SKILL.md", "references/*.md", "docs/**/*.md"]; missing = []; files.each do |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |href| next if href =~ /\Ahttps?:/; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target); end; end; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
```

Expected: `PASS: markdown links resolve`

- [ ] **Step 3: 运行 diff 检查**

Run:

```bash
git diff --check
git status --short --branch
```

Expected: diff check exit 0；只包含本计划相关修改。

- [ ] **Step 4: 提交实现**

Run:

```bash
git add SKILL.md README.md HANDOFF.md references/tree-hierarchy.md docs/testing/tree-hierarchy/green-summary.md docs/testing/tree-hierarchy/red-summary.md docs/testing/tree-hierarchy/tree-hierarchy-audit.rb
git commit -m "docs: 新增树形层级交互规范"
```

Expected: commit succeeds.

- [ ] **Step 5: 提交后复验并推送**

Run the maintained owner audit list again, then:

```bash
git push origin main
git status --short --branch
```

Expected: `main` pushed to origin and worktree clean.
