# Dialog Select Responsive Popup Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Strengthen Dialog, Select/Combobox, and responsive standards so Dialog-contained popups are not clipped and mobile complex Dialog/Select flows can convert to bottom Drawer without losing state.

**Architecture:** Update the existing `dialogs.md`, `selects-comboboxes.md`, and `responsive-adaptive.md` owners rather than adding a new owner. Add a focused audit under `docs/testing/dialog-select-responsive-popup/` and run overlapping existing audits.

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- Do not relax existing Dialog outer-frame non-scroll rules.
- Do not relax existing Drawer modal, focus, backdrop, scroll, close, animation, or disposal rules.
- Do not alter Select submission semantics: non-submit close and shape conversion must not change `selectedValue`.
- Runtime browser, screen reader, touch-device, and real-component checks must be marked unverified unless actually executed.
- Do not modify business repositories in this plan.

---

### Task 1: Strengthen owner documents

**Files:**
- Modify: `references/dialogs.md`
- Modify: `references/selects-comboboxes.md`
- Modify: `references/responsive-adaptive.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-dialog-select-responsive-popup-standards-design.md`
- Produces: explicit rules for Dialog-contained popup clipping, PC portal/flip/max-height, mobile Bottom Drawer shape, and Select Drawer conversion continuity

- [ ] **Step 1: Update Dialog owner**

Add a section stating Dialog-contained popup surfaces must not be clipped by the Dialog content scroll area, frame, fixed footer, local container, `overflow`, or `transform`; Dialog outer frame must not be made scrollable to solve popup clipping.

- [ ] **Step 2: Update Select owner**

Add explicit PC popup requirements: portal to application root or modal popup root, anchor to trigger, keep below higher modal layers, flip when space is insufficient, max-height with options-only scroll, and convert to Drawer on mobile when popup would be clipped or virtual keyboard affects layout.

- [ ] **Step 3: Update Responsive owner**

Clarify that mobile complex Dialog may convert to bottom Drawer / Bottom Sheet with side margins and rounded corners, while still executing Drawer modal semantics and preserving single-instance state.

### Task 2: Add audit and evidence

**Files:**
- Create: `docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb`
- Create: `docs/testing/dialog-select-responsive-popup/red-summary.md`
- Create: `docs/testing/dialog-select-responsive-popup/green-summary.md`

**Interfaces:**
- Consumes: `references/dialogs.md`, `references/selects-comboboxes.md`, `references/responsive-adaptive.md`
- Produces: command `ruby docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb --mutations`

- [ ] **Step 1: Write Ruby audit**

Audit required terms in the three owners and RED/GREEN evidence: no clipping, no Dialog outer-frame scroll workaround, portal/modal popup root, flip/max-height/options-only scroll, visible-rectangle proof for screenshot-shaped footer conflicts, mobile bottom Drawer / Bottom Sheet, side margins/rounded corners, Drawer semantics, no shared scroll container between Select Drawer and outer Bottom Sheet body, selectedValue/query/activeOption continuity, no duplicate overlay/focus trap/scroll lock/requests/animations, and unverified runtime disclosure.

- [ ] **Step 2: Add mutation checks**

The `--mutations` mode must fail when removing the no-clipping rule, no-outer-scroll workaround rule, portal root rule, flip/max-height rule, footer visible-rectangle proof rule, selected-option/action non-intersection rule, mobile Bottom Drawer rule, Drawer semantics despite margins/corners rule, Select Drawer independent scroll boundary rule, Select state continuity rule, duplicate overlay/focus trap/scroll lock/request/animation rule, and runtime unverified disclosure.

- [ ] **Step 3: Add RED/GREEN summaries**

`red-summary.md` lists the screenshot-shaped negative cases. `green-summary.md` lists the behaviors proved by the current owner changes and audit.

### Task 3: Verify final integration

**Files:**
- Inspect all modified files.

**Interfaces:**
- Consumes: all outputs from Tasks 1-2
- Produces: final local verification evidence

- [ ] **Step 1: Run new audit**

Run:

```bash
ruby docs/testing/dialog-select-responsive-popup/dialog-select-responsive-popup-audit.rb --mutations
```

Expected: all mutation checks print expected failures and final pass.

- [ ] **Step 2: Run existing overlapping audits**

Run:

```bash
ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
```

Expected: each audit passes with its expected mutation output.

- [ ] **Step 3: Run Markdown link and whitespace checks**

Run repository Markdown relative-link check and:

```bash
git diff --check
```

Expected: both pass.
