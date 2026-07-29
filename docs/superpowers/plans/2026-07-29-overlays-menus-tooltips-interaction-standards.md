# Overlays Menus Tooltips Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class non-modal overlay, menu, popover, tooltip, context menu, action sheet, and mobile drawer interaction owner to the frontend product interaction standards Skill.

**Architecture:** Create one focused reference file for non-modal overlays and menus. Route it from `SKILL.md`, summarize it from README/HANDOFF, and add a Ruby audit plus RED/GREEN evidence.

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- The new owner must be project-agnostic and must not include business-project-specific pages, modules, routes, frameworks, or component libraries.
- Detailed rules live only in `references/overlays-menus-tooltips.md`; `SKILL.md`, README, and HANDOFF only route or summarize.
- Overlay/menu/tooltip rules are hard acceptance criteria when their route triggers.
- Runtime browser, screen reader, touch-device, and real-component checks must be marked unverified unless actually executed.
- Do not modify business repositories in this plan.

---

### Task 1: Add Overlays Menus Tooltips owner

**Files:**
- Create: `references/overlays-menus-tooltips.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-overlays-menus-tooltips-interaction-standards-design.md`
- Produces: rule families `OMT-SCOPE-*`, `OMT-STATE-*`, `OMT-CHOICE-*`, `OMT-TRIGGER-*`, `OMT-CONTENT-*`, `OMT-MENU-*`, `OMT-LAYOUT-*`, `OMT-PERM-*`, `OMT-A11Y-*`, `OMT-RSP-*`, `OMT-LIFE-*`

- [ ] **Step 1: Write the owner file**

Create `references/overlays-menus-tooltips.md` with scope, owner relations, `overlayState`, carrier selection, trigger/dismiss/focus, content boundaries, menu actions, layout/portal/collision handling, permission/security, accessibility, responsive conversion, lifecycle/disposal, and executable acceptance.

- [ ] **Step 2: Include required state contract**

Ensure `overlayState` contains `overlayId`, `overlayKind`, `triggerOwner`, `contentOwner`, `openState`, `placementPolicy`, `interactionMode`, `dismissPolicy`, `focusPolicy`, `itemStates`, `responsivePolicy`, and `disposalLog`.

- [ ] **Step 3: Include hard prohibitions**

Owner must prohibit hover-only critical information, tooltip-only required information, popover-only errors/confirmations/results/recovery, context-menu-only actions, menu-hidden permission/error/recovery, naked menu item labels, tooltip-only disabled reasons, dangerous menu actions without risk owner, clipping by overflow/transform, stale floating overlays after route/unmount, and mobile deletion of menu or explanation paths.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add references/overlays-menus-tooltips.md
git commit -m "docs: 新增浮层菜单与提示交互规范"
```

### Task 2: Route and summarize the new owner

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/overlays-menus-tooltips.md`
- Produces: automatic routing from tooltip, popover, menu, dropdown menu, context menu, more actions, hover help, action sheet, floating layer, and overlay keywords to the owner

- [ ] **Step 1: Update `SKILL.md` routing**

Add a route requiring complete reading of `references/overlays-menus-tooltips.md` for Chinese and English overlay/menu/tooltip keywords from the design.

- [ ] **Step 2: Update README summary**

Add one bullet to “当前规范” and include `浮层菜单与提示交互规范` pointing to `references/overlays-menus-tooltips.md` in the complete-rules sentence.

- [ ] **Step 3: Update HANDOFF summary**

Add a short “浮层菜单与提示” subsection under “已完成规范” and add `references/overlays-menus-tooltips.md` to the current structure.

### Task 3: Add audit and evidence

**Files:**
- Create: `docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb`
- Create: `docs/testing/overlays-menus-tooltips/red-summary.md`
- Create: `docs/testing/overlays-menus-tooltips/green-summary.md`

**Interfaces:**
- Consumes: `references/overlays-menus-tooltips.md`, `SKILL.md`, `README.md`, `HANDOFF.md`
- Produces: command `ruby docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb --mutations`

- [ ] **Step 1: Write the Ruby audit**

The audit must verify required state fields, route terms, summary links, overlay kinds, trigger/dismiss/focus policy, content boundaries, menu action requirements, portal/collision rules, permission and risk integration, responsive conversion, lifecycle/disposal, and unverified runtime disclosure.

- [ ] **Step 2: Add mutation checks**

The `--mutations` mode must fail when removing the hover-only prohibition, tooltip-only required information prohibition, popover-only critical content prohibition, context-menu-only prohibition, menu-hidden critical content prohibition, naked menu labels prohibition, tooltip-only disabled reason prohibition, dangerous menu risk integration, clipping prohibition, stale overlay disposal rule, mobile equivalent path rule, and runtime unverified disclosure.

- [ ] **Step 3: Add RED/GREEN summaries**

`red-summary.md` lists the negative cases. `green-summary.md` lists the behaviors proved by the current owner and audit.

### Task 4: Verify final integration

**Files:**
- Inspect all modified files.

**Interfaces:**
- Consumes: all outputs from Tasks 1-3
- Produces: final local verification evidence

- [ ] **Step 1: Run overlays audit**

Run:

```bash
ruby docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb --mutations
```

Expected: all mutation checks print expected failures and final pass.

- [ ] **Step 2: Run existing high-overlap audits**

Run:

```bash
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/admin-console/admin-console-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations
ruby docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb --mutations
```

Expected: each audit passes with its expected mutation output.

- [ ] **Step 3: Run Markdown link and whitespace checks**

Run repository Markdown relative-link check and:

```bash
git diff --check
```

Expected: both pass.
