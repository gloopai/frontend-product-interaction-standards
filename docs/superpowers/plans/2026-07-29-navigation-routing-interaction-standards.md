# Navigation Routing Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class navigation, return, breadcrumb, tabs, and route-leave interaction owner to the frontend product interaction standards Skill.

**Architecture:** Create one focused reference file for navigation and routing behavior. Route it from `SKILL.md`, summarize it from README/HANDOFF, and add a Ruby audit plus RED/GREEN evidence.

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- The new owner must be project-agnostic and must not include business-project-specific pages, modules, routes, frameworks, or component libraries.
- Detailed rules live only in `references/navigation-routing.md`; `SKILL.md`, README, and HANDOFF only route or summarize.
- Navigation-routing rules are hard acceptance criteria when their route triggers.
- Runtime browser, screen reader, touch-device, and real-component checks must be marked unverified unless actually executed.
- Do not modify business repositories in this plan.

---

### Task 1: Add Navigation Routing owner

**Files:**
- Create: `references/navigation-routing.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-navigation-routing-interaction-standards-design.md`
- Produces: rule families `NAV-SCOPE-*`, `NAV-STATE-*`, `NAV-RETURN-*`, `NAV-BLOCK-*`, `NAV-STRUCT-*`, `NAV-HISTORY-*`, `NAV-PERM-*`, `NAV-A11Y-*`, `NAV-RSP-*`

- [ ] **Step 1: Write the owner file**

Create `references/navigation-routing.md` with the sections from the design: scope, owner relations, `navigationState`, return/source restore, route blockers, breadcrumb/Tabs, browser history, permissions, focus/a11y/responsive, and executable acceptance.

- [ ] **Step 2: Include required state contract**

Ensure `navigationState` contains `routeOwnerId`, `currentLocation`, `sourceContext`, `returnPolicy`, `historyIntent`, `permissionVersion`, `dirtyBlockers`, `focusRestoreTarget`, and `disposalLog`.

- [ ] **Step 3: Include hard prohibitions**

Owner must prohibit direct `history.back()` as the return model, missing sourceContext, missing returnPolicy, Back bypassing dirty blockers, breadcrumb as recent-history return, Tabs for unrelated pages, stale permission context leakage, late route callbacks writing back, and mobile removal of back/leave protection.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add references/navigation-routing.md
git commit -m "docs: 新增导航与路由交互规范"
```

### Task 2: Route and summarize the new owner

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/navigation-routing.md`
- Produces: automatic routing from navigation/back/breadcrumb/tabs/routing keywords to the owner

- [ ] **Step 1: Update `SKILL.md` routing**

Add a route requiring complete reading of `references/navigation-routing.md` for Chinese and English navigation/routing keywords from the design.

- [ ] **Step 2: Update README summary**

Add one bullet to “当前规范” and include `导航与路由交互规范` pointing to `references/navigation-routing.md` in the complete-rules sentence.

- [ ] **Step 3: Update HANDOFF summary**

Add a short “导航与路由” subsection under “已完成规范” and add `references/navigation-routing.md` to the current structure.

### Task 3: Add audit and evidence

**Files:**
- Create: `docs/testing/navigation-routing/navigation-routing-audit.rb`
- Create: `docs/testing/navigation-routing/red-summary.md`
- Create: `docs/testing/navigation-routing/green-summary.md`

**Interfaces:**
- Consumes: `references/navigation-routing.md`, `SKILL.md`, `README.md`, `HANDOFF.md`
- Produces: command `ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations`

- [ ] **Step 1: Write the Ruby audit**

The audit must verify required state fields, route terms, summary links, return/source restoration, blocker enforcement, breadcrumb/Tabs boundaries, permission revalidation, late callback rejection, mobile back protection, and unverified runtime disclosure.

- [ ] **Step 2: Add mutation checks**

The `--mutations` mode must fail when removing the state model, sourceContext, returnPolicy, history.back boundary, dirty blockers, breadcrumb boundary, Tabs boundary, permission revalidation, late callback disposal, mobile protection, and runtime unverified disclosure.

- [ ] **Step 3: Add RED/GREEN summaries**

`red-summary.md` lists the negative cases. `green-summary.md` lists the behaviors proved by the current owner and audit.

### Task 4: Verify final integration

**Files:**
- Inspect all modified files.

**Interfaces:**
- Consumes: all outputs from Tasks 1-3
- Produces: final local verification evidence

- [ ] **Step 1: Run navigation-routing audit**

Run:

```bash
ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations
```

Expected: all mutation checks print expected failures and final pass.

- [ ] **Step 2: Run existing high-overlap audits**

Run:

```bash
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
ruby docs/testing/query-filters/query-filters-audit.rb --mutations
ruby docs/testing/admin-console/admin-console-audit.rb --mutations
```

Expected: each audit passes with its expected mutation output.

- [ ] **Step 3: Run Markdown link and whitespace checks**

Run repository Markdown relative-link check and:

```bash
git diff --check
```

Expected: both pass.
