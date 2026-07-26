# 数据表格交互规范实施计划

> **面向执行代理：** 必须使用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 逐任务执行本计划。步骤使用复选框（`- [ ]`）跟踪。

**目标：** 新增一套与框架无关的数据表格交互规范，完整覆盖表格、分页、筛选、排序、选择和批量操作，并通过 RED/GREEN 新鲜代理场景验证规则能够消除关键决策分歧。

**架构：** 使用 `references/data-tables.md` 作为本类别完整规则的唯一 owner。`SKILL.md` 只增加中英文触发路由，`README.md` 和 `HANDOFF.md` 只保留摘要与链接。设计、计划和测试证据允许进入 Git，但临时 SDD 工作区仍由 `.superpowers/` 忽略。

**技术栈：** Markdown、YAML、Git、`rg`、Ruby 相对链接检查、Codex Skill `quick_validate.py`、新鲜 Codex 子代理。

## 全局约束

- 第一版同时覆盖数据表格、分页、筛选、排序、选择和批量操作。
- 支持 `display`、`row-action`、`bulk-action` 三种显式能力档位；选择能力不能成为所有表格的默认能力。
- 默认选择范围仅为当前页；“全部筛选结果”只能显式启用，并持续展示范围、数量和排除项。
- 支持页码分页与上一页/下一页游标分页；不包含加载更多和无限滚动。
- 第一版不包含行内编辑、树形表格、拖拽行排序、透视表、用户拖拽列排序和个人布局持久化。
- 使用与框架无关、用户可观察的产品语言。
- `references/data-tables.md` 是完整表格规则的唯一来源。
- `SKILL.md` 只包含路由；`README.md` 和 `HANDOFF.md` 只包含摘要与链接。
- 每条硬规则必须有可执行的验收检查。
- 既有 Dialog、Drawer、Select / Combobox、表单和响应式 owner 规则继续适用。
- 未在真实环境执行时，不得声称浏览器、屏幕阅读器、触摸设备或真实组件运行时验证通过。
- `docs/` 从本阶段起允许纳入 Git；不得把 `.superpowers/` 临时工作区加入 Git。

## 文件职责

- `.gitignore`：不再忽略 `docs/`，继续忽略 `.superpowers/` 和 `.worktrees/`。
- `docs/superpowers/specs/2026-07-26-data-table-interaction-standards-design.md`：本阶段已确认的中文设计。
- `docs/superpowers/plans/2026-07-26-data-table-interaction-standards.md`：本实施计划。
- `docs/superpowers/specs/2026-07-26-form-interaction-standards-design.md`、`docs/superpowers/plans/2026-07-26-form-interaction-standards.md`、`docs/superpowers/specs/2026-07-26-handoff-refresh-design.md`、`docs/superpowers/plans/2026-07-26-handoff-refresh.md`：此前阶段保留在本地的历史设计与计划；先独立审查，再用单独提交纳入 Git。
- `references/data-tables.md`：完整状态、查询、列、分页、选择、操作、错误、响应式、无障碍和验收规则。
- `SKILL.md`：表格相关中英文触发路由。
- `README.md`：面向使用者的简短能力摘要和链接。
- `HANDOFF.md`：已完成类别、仓库结构、下一优先级和验证边界。
- `agents/openai.yaml`：只检查；仅在现有定位不再覆盖表格任务时修改。
- `docs/testing/data-tables/`：可提交的 RED/GREEN 场景、prompt、输出摘要和验证结论。
- `.superpowers/sdd/2026-07-26-data-table-interaction-standards/`：被忽略的任务 brief、报告、review package 和临时证据。

---

### Task 1：发布中文设计、计划与 RED 基线

**文件：**

- 修改：`.gitignore`
- 创建：`docs/superpowers/specs/2026-07-26-data-table-interaction-standards-design.md`
- 创建：`docs/superpowers/plans/2026-07-26-data-table-interaction-standards.md`
- 创建：`docs/testing/data-tables/red-display-report.md`
- 创建：`docs/testing/data-tables/red-row-action-list.md`
- 创建：`docs/testing/data-tables/red-bulk-action-table.md`
- 创建：`docs/testing/data-tables/red-summary.md`
- 创建（纳入 Git）：此前阶段四份本地历史设计与计划

**接口：**

- 输入：已确认的中文设计，以及当前没有 `data-tables.md` 的 Skill。
- 输出：可追踪的设计/计划、三个无表格 owner 的新鲜代理输出，以及 Tasks 2–3 必须解决的真实分歧。

- [ ] **Step 1：确认 docs 跟踪边界**

运行：

```bash
git diff -- .gitignore
git status --short
```

预期：`.gitignore` 只删除 `docs` 忽略项；现有本地历史设计/计划单独列出。

- [ ] **Step 2：独立审查并提交历史设计与计划**

逐份检查四个历史文件没有占位符、内部矛盾、错误路径或与已提交实现明显不一致的状态描述。只修正文档本身，不改既有规范。运行：

```bash
if rg -n "\b(T[B]D|T[O]DO|F[I]XME|X[X]X)\b|待[定]|稍后[补]充" docs/superpowers/specs/2026-07-26-form-interaction-standards-design.md docs/superpowers/plans/2026-07-26-form-interaction-standards.md docs/superpowers/specs/2026-07-26-handoff-refresh-design.md docs/superpowers/plans/2026-07-26-handoff-refresh.md; then exit 20; else test $? -eq 1; fi
git diff --check -- docs/superpowers/specs/2026-07-26-form-interaction-standards-design.md docs/superpowers/plans/2026-07-26-form-interaction-standards.md docs/superpowers/specs/2026-07-26-handoff-refresh-design.md docs/superpowers/plans/2026-07-26-handoff-refresh.md
git add docs/superpowers/specs/2026-07-26-form-interaction-standards-design.md docs/superpowers/plans/2026-07-26-form-interaction-standards.md docs/superpowers/specs/2026-07-26-handoff-refresh-design.md docs/superpowers/plans/2026-07-26-handoff-refresh.md
git commit -m "docs: 纳入历史设计与实施计划"
```

预期：该提交只包含四份历史文档，不包含本阶段文件或 `.gitignore`。

- [ ] **Step 3：验证表格 owner 尚不存在**

运行：

```bash
test ! -f references/data-tables.md
rg -n "data-tables\.md|数据表格交互规范" SKILL.md README.md HANDOFF.md
```

预期：文件不存在；路由扫描没有完整 owner 命中。

- [ ] **Step 4：运行展示型报表 RED**

向无表格 owner 的新鲜代理提供用户式任务：设计一个只读报表，包含筛选、稳定排序、页码分页、长内容、200% 缩放和移动端查看。要求说明能力边界、状态转换、加载/错误/空状态、键盘、焦点、ARIA、跨端行为和未验证边界。保存完整 prompt、派发参数、输出和 receipt。

- [ ] **Step 5：运行单行操作列表 RED**

向另一名新鲜代理提供用户式任务：设计一个 `row-action` 管理列表，包含游标分页、刷新失败、行菜单、焦点恢复、权限变化和路由卸载。要求同样的状态、错误、焦点、ARIA、响应适配和 disposal 说明。

- [ ] **Step 6：运行批量操作表格 RED**

向第三名新鲜代理提供用户式任务：设计一个 `bulk-action` 表格，包含当前页选择、可选的全部筛选结果、排除项、筛选变化、部分成功、重试和路由卸载。

- [ ] **Step 7：记录基线分歧**

`red-summary.md` 至少逐项记录：

- 只读报表是否错误出现选择列；
- 筛选草稿与已应用条件是否分离；
- 排序是否包含稳定次序键；
- 翻页、筛选和排序是否改变选择；
- “当前页全选”是否被误解为全数据集全选；
- 跨页选择是否绑定查询快照和排除项；
- 刷新失败是否保留旧数据；
- 部分成功是否保留失败项及重试；
- 原生 Table 与 ARIA Grid 的选择依据；
- 移动端是否静默删除列或操作；
- route/unmount 后旧响应和焦点是否仍生效。

- [ ] **Step 8：验证并提交**

运行：

```bash
git check-ignore -v .superpowers/
git check-ignore -q docs/superpowers/specs/2026-07-26-data-table-interaction-standards-design.md && exit 1 || true
if rg -n "\b(T[B]D|T[O]DO|F[I]XME|X[X]X)\b|待[定]|稍后[补]充" docs/superpowers/specs/2026-07-26-data-table-interaction-standards-design.md docs/superpowers/plans/2026-07-26-data-table-interaction-standards.md docs/testing/data-tables; then exit 20; else test $? -eq 1; fi
git diff --check -- .gitignore docs
git add .gitignore docs/superpowers/specs/2026-07-26-data-table-interaction-standards-design.md docs/superpowers/plans/2026-07-26-data-table-interaction-standards.md docs/testing/data-tables
git commit -m "docs: 添加数据表格规范设计与 RED 基线"
```

预期：占位符扫描无匹配；提交只包含本阶段设计、计划、RED 证据和 `.gitignore`；历史文档已在独立提交中处理。

### Task 2：建立查询、展示与导航规则

**文件：**

- 创建：`references/data-tables.md`

**接口：**

- 输入：Task 1 的 RED 分歧。
- 输出：能力档位、状态模型、筛选、排序、分页、加载、列、语义和焦点的 owner 基础，供 Task 3 扩展。

- [ ] **Step 1：写入会失败的文本断言**

运行：

```bash
test -f references/data-tables.md
rg -n "display|row-action|bulk-action|查询快照|筛选草稿|稳定次序键|游标分页|刷新失败|ARIA Grid" references/data-tables.md
```

预期：因 owner 文件不存在而失败。

- [ ] **Step 2：建立范围与能力档位**

创建 `references/data-tables.md`，明确第一版范围、排除项、三个能力档位和权限降级规则；禁止展示型报表出现选择列或空批量工具栏。

- [ ] **Step 3：建立状态与请求代次**

定义查询、展示、交互和操作四组状态；每次查询冻结不可变快照并递增请求代次；只有代次、快照和 live owner 同时匹配的响应才能更新结果。

- [ ] **Step 4：定义筛选与排序**

定义筛选草稿、已应用条件、即时应用与显式应用、默认重置、URL 敏感值边界、稳定排序和单列/多列模式。

- [ ] **Step 5：定义分页与数据状态**

定义页码和游标分页、页大小变化、删除后的无效页恢复、首次加载、刷新、过期数据、初次失败、刷新失败、筛选零结果和空数据集。

- [ ] **Step 6：定义列、Table/Grid 和焦点**

定义列显示/隐藏、固定、受限宽度、键盘调整、依赖迁移；原生 Table 与 ARIA Grid 的选择条件和各自键盘模型；稳定记录/列标识的焦点恢复。

- [ ] **Step 7：添加可执行验收**

使用初始状态、事件序列、预期状态、DOM/ARIA 断言和事件日志，为本任务每条硬规则建立验收。至少覆盖能力档位、快速请求竞态、稳定排序、分页边界、加载/错误/空状态、列行为、Table/Grid 键盘和焦点目标消失。

- [ ] **Step 8：验证并提交**

运行：

```bash
rg -n "display|row-action|bulk-action|查询快照|请求代次|筛选草稿|稳定次序键|页码分页|游标分页|刷新失败|固定列|ARIA Grid|验收" references/data-tables.md
git diff --check -- references/data-tables.md
git add references/data-tables.md
git commit -m "docs: 添加数据表格查询与展示规范"
```

预期：所有基础概念和验收可检索；提交只包含 `references/data-tables.md`。

### Task 3：完成选择、批量操作、响应式与生命周期规则

**文件：**

- 修改：`references/data-tables.md`

**接口：**

- 输入：Task 2 的查询快照、状态和分页模型。
- 输出：完整的数据表格生命周期和所有剩余验收。

- [ ] **Step 1：证明生命周期规则尚不完整**

运行逐项断言；任一缺失都必须令命令失败：

```bash
rg -n "全部筛选结果" references/data-tables.md
rg -n "排除项" references/data-tables.md
rg -n "部分成功" references/data-tables.md
rg -n "操作快照" references/data-tables.md
rg -n "表格.*卡片" references/data-tables.md
rg -n "200%|虚拟键盘|安全区域" references/data-tables.md
rg -n "路由.*卸载|owner.*卸载" references/data-tables.md
```

预期：修订前至少一个断言失败，并记录准确 exit code。

- [ ] **Step 2：定义当前页和跨页选择**

默认只选择当前页可选记录；表头复选框只表达当前页三态。全部筛选结果模式必须二次显式选择，绑定查询快照、筛选范围、排除项和数量。

- [ ] **Step 3：定义选择失效与批量快照**

明确筛选、排序、权限和数据集变化何时清除选择、何时要求重新确认；批量操作冻结选择快照，不能由迟到结果覆盖新选择。

- [ ] **Step 4：定义批量终态和错误恢复**

分别定义全部成功、部分成功、全部失败、权限变化和数据版本冲突；阻止重复提交，保留失败项、错误 owner、重试入口和结果对应的焦点目标。

- [ ] **Step 5：定义响应式等价**

核心能力跨端一致；次要列进入可访问行详情或列控制；横向滚动只发生在表格容器；卡片模式必须显式且语义等价，并保留查询、分页、选择、展开、焦点意图和操作快照。

- [ ] **Step 6：定义无障碍与生命周期**

覆盖可访问名称、状态、简洁单次公告、200% 缩放、长文本、低高度、触摸、动态视口、虚拟键盘、安全区域；route/unmount 使查询、菜单、焦点、操作和公告回调失效，并隔离两个表格实例。

- [ ] **Step 7：补全可执行验收**

添加当前页三态、全部筛选结果、排除项、范围重确认、重复提交、四类终态、过期快照、响应式转换、横向滚动、缩放/触摸/虚拟键盘/安全区域、disposal 和实例隔离的事件日志及 DOM/ARIA 断言。

- [ ] **Step 8：验证并提交**

运行：

```bash
rg -n "当前页|全部筛选结果|排除项|操作快照|部分成功|全部失败|权限|数据版本|表格.*卡片|200%|虚拟键盘|安全区域|未验证|验收" references/data-tables.md
git diff --check -- references/data-tables.md
git add references/data-tables.md
git commit -m "docs: 完善数据表格选择与批量操作规范"
```

预期：完整生命周期及对应验收可检索；提交只包含 owner 文件。

### Task 4：路由并发布表格规范

**文件：**

- 修改：`SKILL.md`
- 修改：`README.md`
- 修改：`HANDOFF.md`
- 只检查：`agents/openai.yaml`

**接口：**

- 输入：完整的 `references/data-tables.md`。
- 输出：准确触发、简洁摘要、当前交接状态和更新后的下一优先级。

- [ ] **Step 1：增加中英文路由**

在 `SKILL.md` 增加要求完整读取 `references/data-tables.md` 的路由，覆盖：表格、数据表格、报表、列、固定列、筛选、排序、分页、游标分页、行选择、全选、批量操作、部分成功，以及 table、data table、report、column、pinned column、filter、sort、pagination、cursor pagination、row selection、select all、bulk action、partial success。

- [ ] **Step 2：更新 README 摘要**

增加一条数据表格能力摘要和 owner 链接，不复制状态模型和验收列表；更新目录结构。

- [ ] **Step 3：更新 HANDOFF**

增加 `data-tables.md` 结构和“数据表格”完成摘要；把 Toast、Alert、Notification、Popover、Tooltip 调整为下一优先级第一位；删除“表单分支仍在本地且未推送”的过期描述，并说明 `docs/` 已允许纳入 Git。

- [ ] **Step 4：核对 agent 元数据**

比较 `agents/openai.yaml` 与更新后的 Skill 定位。若“前端设计、开发、评审与测试中的统一产品交互标准”仍覆盖表格任务，保持不变并在报告中记录。

- [ ] **Step 5：验证并提交**

运行：

```bash
rg -n "表格|报表|筛选|排序|分页|批量|table|report|filter|sort|pagination|bulk" SKILL.md README.md HANDOFF.md
git diff --check -- SKILL.md README.md HANDOFF.md
git diff --name-only
git add SKILL.md README.md HANDOFF.md
git commit -m "docs: 路由并发布数据表格交互规范"
```

预期：中英文触发完整，摘要链接 owner，`agents/openai.yaml` 除非存在具体定位缺口否则不变。

### Task 5：GREEN 前向测试与仓库级验证

**文件：**

- 修改（仅发现真实规范缺口时）：`references/data-tables.md`、`SKILL.md`、`README.md`、`HANDOFF.md`
- 创建：`docs/testing/data-tables/green-display-report.md`
- 创建：`docs/testing/data-tables/green-row-action-list.md`
- 创建：`docs/testing/data-tables/green-bulk-action-table.md`
- 创建：`docs/testing/data-tables/green-summary.md`
- 创建：`docs/testing/data-tables/dispatch-receipts.md`

**接口：**

- 输入：Tasks 1–4、RED 证据和完整 owner。
- 输出：可提交的 GREEN 收敛证据、仓库验证结果，以及由真实应用失败驱动的最小修复。

- [ ] **Step 1：用新版 Skill 重跑三个场景**

分别派发三名 `fork_turns=none` 的新鲜代理，使用用户式 prompt：`Use $frontend-product-interaction-standards at <worktree-path> to define/review this data-table interaction.` 不提供期望答案或 RED 诊断。保存 canonical agent identity、模型参数、完整 prompt、输出、completion receipt 和 prompt/output SHA-256。

- [ ] **Step 2：逐项比较 RED 与 GREEN**

确认三个输出严格收敛于：

- 能力档位与选择能力显式启用；
- 查询快照、代次和迟到响应；
- 筛选草稿、已应用条件和默认重置；
- 稳定排序与分页重置；
- 页码/游标边界、首次失败、刷新失败、过期数据和零结果；
- 当前页三态与全部筛选结果范围；
- 操作快照、重复提交、部分成功和恢复；
- 原生 Table/Grid 选择与键盘；
- 列隐藏/固定/宽度、响应式等价和横向滚动；
- disposal、实例隔离、焦点、ARIA、公告和运行时未验证边界。

若输出发明 owner 未定义的状态或遗漏硬规则，先记录失败。只有确认 owner 存在真实缺口时才做最小 tracked 修复并增加对应验收。

- [ ] **Step 3：验证相对链接**

运行：

```bash
ruby -e 'Dir.glob("**/*.md").each { |f| File.read(f).scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |u| next if u =~ /\A(?:https?:|mailto:|#)/; p = File.expand_path(u.split("#", 2).first, File.dirname(f)); abort("broken link: #{f} -> #{u}") unless File.exist?(p) } }'
```

预期：exit 0，无输出。

- [ ] **Step 4：运行官方和静态验证**

运行：

```bash
/tmp/frontend-standards-validation-venv/bin/python /Users/evanqi/.codex/skills/.system/skill-creator/scripts/quick_validate.py .
if rg -n '\b(T[B]D|T[O]DO|F[I]XME|X[X]X)\b|待[定]|稍后[补]充' SKILL.md README.md HANDOFF.md references docs/testing/data-tables; then exit 20; else test $? -eq 1; fi
git diff --check
git status --short --branch
```

预期：输出 `Skill is valid!`；占位符扫描无匹配；diff 检查通过；只存在本任务预期的未提交文件。

- [ ] **Step 5：检查完整分支范围**

运行：

```bash
branch_base=$(git merge-base main HEAD)
git diff --stat "$branch_base"..HEAD
git diff --name-only "$branch_base"..HEAD
git diff "$branch_base"..HEAD -- .gitignore SKILL.md README.md HANDOFF.md references docs agents/openai.yaml
```

预期：只包含 `.gitignore`、独立审查后的历史设计/计划、本阶段设计/计划/测试证据、表格 owner、路由和摘要；`.superpowers/` 不在提交范围。

- [ ] **Step 6：按需提交最小修复与 GREEN 证据**

若存在 tracked 规范修复：

```bash
git add references/data-tables.md SKILL.md README.md HANDOFF.md docs/testing/data-tables
git commit -m "docs: 完成数据表格规范应用验证"
```

若不存在规范修复，也必须提交 GREEN 证据：

```bash
git add docs/testing/data-tables
git commit -m "test: 添加数据表格规范 GREEN 证据"
```

预期：不创建空提交；所有可追踪测试证据进入 Git。

### Task 6：最终独立审查与交付验证

**文件：**

- 修改（仅最终审查发现真实缺口时）：本计划已列出的 tracked 文件。

**接口：**

- 输入：完整分支差异、Task 1–5 报告和所有 RED/GREEN 证据。
- 输出：无 Critical/Important 的最终审查结论和可集成分支。

- [ ] **Step 1：生成完整评审包**

从 `main` merge-base 到当前 HEAD 生成 commit、stat 和完整 diff package，不能使用 `HEAD~1` 代替分支 base。

- [ ] **Step 2：派发最高能力最终审查**

审查完整设计和计划覆盖、owner 唯一性、硬规则与验收映射、跨既有 owner 一致性、中英文路由、README/HANDOFF 摘要边界、RED/GREEN 证据真实性、docs 跟踪边界和运行时未验证声明。

- [ ] **Step 3：执行唯一最终修复波**

如有 Critical/Important，使用一名修复代理一次性处理完整 findings，运行覆盖修复的 RED/GREEN 和静态验证，并提交一个修复 commit；随后只做一次 scoped re-review。若仍有承重缺口，停止并报告用户。

- [ ] **Step 4：主控执行 fresh 最终验证**

运行：

```bash
ruby -e 'Dir.glob("**/*.md").each { |f| File.read(f).scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |u| next if u =~ /\A(?:https?:|mailto:|#)/; p = File.expand_path(u.split("#", 2).first, File.dirname(f)); abort("broken link: #{f} -> #{u}") unless File.exist?(p) } }'
/tmp/frontend-standards-validation-venv/bin/python /Users/evanqi/.codex/skills/.system/skill-creator/scripts/quick_validate.py .
if rg -n '\b(T[B]D|T[O]DO|F[I]XME|X[X]X)\b|待[定]|稍后[补]充' SKILL.md README.md HANDOFF.md references docs/testing/data-tables; then exit 20; else test $? -eq 1; fi
git diff --check
test -z "$(git status --porcelain)"
```

预期：相对链接通过；输出 `Skill is valid!`；占位符无匹配；diff 检查通过；工作树干净。

- [ ] **Step 5：进入分支集成选择**

使用 superpowers:finishing-a-development-branch，向用户提供本地合并、推送并创建 PR、保留分支三种选择。未经用户选择不自行集成。
