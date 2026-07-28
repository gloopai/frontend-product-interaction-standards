# Risk Actions Recovery Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class dangerous action, confirmation, undo, cancel, unknown-result, and audit-receipt interaction owner to the frontend product interaction standards Skill.

**Architecture:** Create one focused reference file for risk action lifecycle behavior. Route it from `SKILL.md`, summarize it from README/HANDOFF, and add a Ruby audit plus RED/GREEN evidence.

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- The new owner must be project-agnostic and must not include business-project-specific pages, modules, routes, frameworks, or component libraries.
- Detailed rules live only in `references/risk-actions.md`; `SKILL.md`, README, and HANDOFF only route or summarize.
- Risk action rules are hard acceptance criteria when their route triggers.
- Runtime browser, screen reader, touch-device, and real-component checks must be marked unverified unless actually executed.
- Do not modify business repositories in this plan.

---

### Task 1: Add Risk Actions owner

**Files:**
- Create: `references/risk-actions.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-risk-actions-recovery-interaction-standards-design.md`
- Produces: rule families `RA-SCOPE-*`, `RA-STATE-*`, `RA-LEVEL-*`, `RA-CONFIRM-*`, `RA-UNDO-*`, `RA-CANCEL-*`, `RA-BULK-*`, `RA-PERM-*`, `RA-AUDIT-*`, `RA-A11Y-*`, `RA-RSP-*`

- [ ] **Step 1: Write the owner file**

Create `references/risk-actions.md` with the sections from the design: scope, owner relations, `riskActionState`, risk levels, confirmation strategies, undo, cancel, unknown results, batch snapshots, permission convergence, audit, focus/a11y/responsive, and executable acceptance.

- [ ] **Step 2: Include required state contract**

Ensure `riskActionState` contains `riskActionId`, `riskLevel`, `actionObject`, `impactScope`, `confirmationPolicy`, `confirmationEvidence`, `requestIdentity`, `executionPhase`, `undoPolicy`, `cancelPolicy`, `resultReceipt`, `auditBinding`, and `recoveryActions`.

- [ ] **Step 3: Include hard prohibitions**

Owner must prohibit color-only risk communication, naked confirm labels, requests before confirmation, client close as server cancel, Toast-only undo, missing batch snapshots, stale permission targets, unknown results as success/failure, and mobile removal of dangerous confirmation or recovery.

- [ ] **Step 4: Commit task output**

Commit message:

```bash
git add references/risk-actions.md
git commit -m "docs: 新增危险操作与恢复交互规范"
```

### Task 2: Route and summarize the new owner

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: `references/risk-actions.md`
- Produces: automatic routing from dangerous action, confirmation, undo, cancel, delete, disable, reset, bulk delete, permission change, sensitive export, unknown result, partial success, and audit receipt keywords to the owner

- [ ] **Step 1: Update `SKILL.md` routing**

Add a route requiring complete reading of `references/risk-actions.md` for Chinese and English risk-action keywords from the design.

- [ ] **Step 2: Update README summary**

Add one bullet to “当前规范” and include `危险操作与恢复交互规范` pointing to `references/risk-actions.md` in the complete-rules sentence.

- [ ] **Step 3: Update HANDOFF summary**

Add a short “危险操作与恢复” subsection under “已完成规范” and add `references/risk-actions.md` to the current structure.

### Task 3: Add audit and evidence

**Files:**
- Create: `docs/testing/risk-actions/risk-actions-audit.rb`
- Create: `docs/testing/risk-actions/red-summary.md`
- Create: `docs/testing/risk-actions/green-summary.md`

**Interfaces:**
- Consumes: `references/risk-actions.md`, `SKILL.md`, `README.md`, `HANDOFF.md`
- Produces: command `ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations`

- [ ] **Step 1: Write the Ruby audit**

The audit must verify required state fields, route terms, summary links, risk levels, confirmation policies, undo semantics, cancel semantics, unknown result boundaries, batch snapshots, permission convergence, audit receipts, mobile protection, and unverified runtime disclosure.

- [ ] **Step 2: Add mutation checks**

The `--mutations` mode must fail when removing the typed-confirm boundary, naked-label prohibition, request-before-confirmation prohibition, Toast-only undo prohibition, client-close-as-cancel boundary, unknown result boundary, batch snapshot requirement, permission revalidation, mobile protection, and runtime unverified disclosure.

- [ ] **Step 3: Add RED/GREEN summaries**

`red-summary.md` lists the negative cases. `green-summary.md` lists the behaviors proved by the current owner and audit.

### Task 4: Verify final integration

**Files:**
- Inspect all modified files.

**Interfaces:**
- Consumes: all outputs from Tasks 1-3
- Produces: final local verification evidence

- [ ] **Step 1: Run risk-actions audit**

Run:

```bash
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
```

Expected: all mutation checks print expected failures and final pass.

- [ ] **Step 2: Run existing high-overlap audits**

Run:

```bash
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/admin-console/admin-console-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
ruby docs/testing/navigation-routing/navigation-routing-audit.rb --mutations
ruby docs/testing/record-editing-surfaces/record-editing-surfaces-audit.rb --mutations
```

Expected: each audit passes with its expected mutation output.

- [ ] **Step 3: Run Markdown link and whitespace checks**

Run repository Markdown relative-link check and:

```bash
git diff --check
```

Expected: both pass.
