# Existing Standards Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Audit and minimally harden the existing Dialog, Drawer, Select / Combobox, and responsive interaction standards so their lifecycle, cross-form state, focus, animation, cleanup, and verification rules yield one unambiguous result.

**Architecture:** Use a source-backed audit ledger as the failure baseline, then repair rules at their single source of truth and replay seven end-to-end scenarios against the revised documents. Keep component-specific behavior in `references/*.md`, cross-viewport continuity in `references/responsive-adaptive.md`, global routing and red lines in `SKILL.md`, and user-facing summaries in `README.md`.

**Tech Stack:** Markdown, YAML, Git, `rg`, shell, Codex Skill `quick_validate.py`, Python with PyYAML.

## Global Constraints

- Only harden the four existing categories; do not add form, table, Toast, navigation, upload, or other new interaction categories.
- Describe observable product behavior and acceptance conditions without prescribing React, Vue, CSS frameworks, or component-library implementation details.
- Compatible rules all apply; shape-specific conflicts must be resolved by rendering phase and source of truth, not by a generic “stricter wins” rule.
- Keep full category rules only in the responsible `references/*.md`; `SKILL.md` contains routing, global principles, process, and red lines; `README.md` contains a user-facing summary.
- Every added or changed hard rule must have an executable acceptance check.
- Do not claim browser, screen-reader, touch-device, or real-viewport verification without a real component and test environment.
- Preserve unrelated user changes and keep each commit focused on one reviewable concern.

## File Responsibility Map

- `docs/audits/2026-07-25-existing-standards-hardening.md`: failure baseline, matrix findings, scenario replay, disposition, and verification boundary.
- `references/dialogs.md`: Dialog-specific modal lifecycle, scrolling, focus, animation, closing, and cleanup.
- `references/drawers.md`: Drawer-specific direction, modal lifecycle, scrolling, focus, animation, closing, and cleanup.
- `references/selects-comboboxes.md`: committed/draft selection state, placement, focus mapping, ARIA ownership, and Select-to-Drawer behavior.
- `references/responsive-adaptive.md`: single-instance cross-viewport transitions, phase ownership, state continuity, and cross-shape focus mapping.
- `SKILL.md`: routing and global enforcement only; modify only if the audit finds a routing or red-line gap.
- `README.md`: concise user-facing capability summary only; modify only when an externally visible guarantee changes.

---

### Task 1: Establish the failure baseline and audit ledger

**Files:**
- Create: `docs/audits/2026-07-25-existing-standards-hardening.md`
- Read: `references/dialogs.md`
- Read: `references/drawers.md`
- Read: `references/selects-comboboxes.md`
- Read: `references/responsive-adaptive.md`

**Interfaces:**
- Consumes: the approved design in `docs/superpowers/specs/2026-07-25-existing-standards-hardening-design.md`.
- Produces: finding IDs `F-01` through `F-07`, each with evidence, failure result, owning file, proposed disposition, and later verification status.

- [ ] **Step 1: Create the audit ledger with concrete baseline findings**

Create the document with these findings and quote only short identifying phrases plus rule numbers or section names:

| ID | Baseline failure | Owner |
| --- | --- | --- |
| F-01 | Dialog cleanup mentions scroll locking, but the normative modal-open rules do not explicitly require acquiring and retaining the page scroll lock. | `references/dialogs.md` |
| F-02 | Dialog cleanup says “关闭” rather than “关闭动画完成后”, which can be read as releasing modal protections before DOM removal. | `references/dialogs.md` |
| F-03 | Responsive rules define initial-open and live-conversion animation ownership but do not explicitly define which shape owns a later close animation. | `references/responsive-adaptive.md` |
| F-04 | Breakpoint changes that arrive after close has begun have no explicit disposition, allowing shape conversion, duplicate animation, or duplicate cleanup during closing. | `references/responsive-adaptive.md` |
| F-05 | Select preserves business state across placement conversion but does not define deterministic focus mapping between the outer trigger, inline main Combobox, panel search Combobox, and Drawer search Combobox. | `references/selects-comboboxes.md` |
| F-06 | Select states that placement conversion must not duplicate infrastructure, but it does not explicitly say that the same logical popup IDs and ARIA ownership must be valid immediately after focus mapping. | `references/selects-comboboxes.md` |
| F-07 | The completion checks do not replay closing-time conversion and focus mapping as named cross-document scenarios. | all four reference documents, with the cross-document check owned by the audit ledger |

For each finding include: evidence location, why two reasonable implementations could diverge, owner, smallest intended correction, and status `baseline-failing`.

- [ ] **Step 2: Record the seven scenario baselines**

Add scenarios `S-01` through `S-07` matching the approved design. For each, record the five assertions: business state, one active instance/infrastructure set, close boundary, focus/background continuity, and exactly-once animation/unmount/cleanup. Mark the assertion `underdetermined` only when it maps to F-01 through F-07; otherwise mark it `already-determined` and cite the rule.

- [ ] **Step 3: Verify the baseline is evidence-backed**

Run:

```bash
rg -n "滚动锁定|关闭动画|形态|焦点|resolvedPlacement|aria-controls|完成前检查|验收" references/*.md
```

Expected: every finding has at least one matching source location, and no finding relies only on preference or implementation style.

- [ ] **Step 4: Check the ledger formatting**

Run:

```bash
git diff --check -- docs/audits/2026-07-25-existing-standards-hardening.md
rg -n '\b(T[B]D|T[O]DO|F[I]XME|X[X]X)\b' docs/audits/2026-07-25-existing-standards-hardening.md
```

Expected: `git diff --check` exits 0; the placeholder scan prints no matches.

- [ ] **Step 5: Commit the baseline**

```bash
git add docs/audits/2026-07-25-existing-standards-hardening.md
git commit -m "docs: 建立现有规范加固基线"
```

### Task 2: Close Dialog and cross-shape lifecycle gaps

**Files:**
- Modify: `references/dialogs.md`
- Modify: `references/responsive-adaptive.md`
- Modify: `docs/audits/2026-07-25-existing-standards-hardening.md`

**Interfaces:**
- Consumes: findings F-01 through F-04 and scenarios S-01, S-03, S-04, and S-07.
- Produces: an explicit modal-protection lifetime and a deterministic animation owner for initial open, live conversion, and close.

- [ ] **Step 1: Add failing textual assertions to the ledger**

Under F-01 through F-04, add the exact acceptance phrases that must become discoverable:

- Dialog acquires page scroll lock when modal activity begins.
- Modal protections remain until close animation completion and DOM removal.
- Closing uses the currently rendered shape’s exit animation.
- Once closing begins, the rendered shape is frozen and later breakpoint changes cannot start conversion.

Run:

```bash
rg -n "当前渲染形态.*关闭|关闭开始后.*形态|关闭动画完成后.*滚动锁定" references/dialogs.md references/responsive-adaptive.md
```

Expected: at least one required assertion is absent, demonstrating the baseline gap.

- [ ] **Step 2: Repair Dialog modal protection lifetime**

In `references/dialogs.md`:

- Add page scroll locking to the modal-open background isolation rule.
- State that backdrop, focus constraint, background isolation, and page scroll lock remain active until the close animation completes and the DOM is removed.
- Change cleanup timing so normal close cleanup occurs after close animation completion; route change and component unmount may perform immediate teardown because the owning instance is being destroyed.
- Keep reopen cleanup scoped to stale prior-instance state and never clear protections belonging to the active instance.

- [ ] **Step 3: Define cross-shape close ownership**

In `references/responsive-adaptive.md`, extend the shape transition rules:

- Initial open uses the final rendered shape’s entrance animation.
- Live open-state conversion uses a single instance and no entrance/exit animation.
- A later close uses the shape rendered when closing begins.
- After closing begins, freeze shape selection until unmount; ignore breakpoint-driven shape conversion for that closing instance.
- Preserve backdrop, background isolation, scroll lock, focus constraints, async state, and exactly-once cleanup throughout.

- [ ] **Step 4: Add acceptance checks**

Update the relevant completion/acceptance sections to require:

- Observe page scrolling while Dialog is open and during its close animation.
- Change the breakpoint before close and after close begins; verify one exit animation, one unmount, and one cleanup sequence.
- Verify route/unmount teardown does not leave inert state or scroll lock behind.

- [ ] **Step 5: Replay affected scenarios and update the ledger**

For S-01, S-03, S-04, and S-07, cite the revised rules and mark F-01 through F-04 `repaired-static`. Record that runtime behavior remains unverified without a concrete component.

- [ ] **Step 6: Run focused checks**

```bash
rg -n "滚动锁定|关闭动画完成后|当前.*形态|关闭开始后|断点" references/dialogs.md references/responsive-adaptive.md
git diff --check -- references/dialogs.md references/responsive-adaptive.md docs/audits/2026-07-25-existing-standards-hardening.md
```

Expected: each new lifecycle assertion appears in its owning file; `git diff --check` exits 0.

- [ ] **Step 7: Commit the lifecycle repair**

```bash
git add references/dialogs.md references/responsive-adaptive.md docs/audits/2026-07-25-existing-standards-hardening.md
git commit -m "docs: 明确跨形态关闭生命周期"
```

### Task 3: Make Select placement conversion focus and ARIA deterministic

**Files:**
- Modify: `references/selects-comboboxes.md`
- Modify: `references/responsive-adaptive.md`
- Modify: `docs/audits/2026-07-25-existing-standards-hardening.md`

**Interfaces:**
- Consumes: findings F-05 through F-07 and scenarios S-02, S-05, and S-06.
- Produces: a focus mapping keyed by `resolvedPlacement`, with stable logical ownership and no value submission during conversion.

- [ ] **Step 1: Demonstrate the missing focus map**

Run:

```bash
rg -n "inline.*焦点|panel.*焦点|drawer.*焦点|none.*焦点|等价.*焦点" references/selects-comboboxes.md references/responsive-adaptive.md
```

Expected: rules exist for opening each placement, but there is no complete conversion map covering all source and destination placements.

- [ ] **Step 2: Add the deterministic conversion focus map**

In `references/selects-comboboxes.md`, add one placement-conversion subsection with these rules:

- Conversion never commits `query` or `activeOption`, never changes `selectedValue`, and never fires a value-change callback.
- Destination `inline`: focus the main editable Combobox and expose the preserved draft query according to the existing inline draft-editing contract.
- Destination `panel`: if the composite remains open, focus its inner search Combobox; if conversion also closes by an independently defined external action, return focus after close animation to the outer disclosure trigger.
- Destination `drawer`: focus its inner search Combobox inside the active focus trap; the outer trigger remains the eventual close-return target.
- Destination `none`: focus the Select-only Combobox, preserve the session query without applying it, reconcile active against the full unfiltered option set, and expose only a rendered active option through `aria-activedescendant`.
- If the exact focused node survives Portal/layout movement, retain focus without a blur/refocus cycle; otherwise move focus once to the destination-equivalent node.

- [ ] **Step 3: Tighten logical identity and ARIA ownership**

In the same subsection state:

- Preserve the session’s logical popup, Listbox, and option IDs whenever the corresponding logical nodes continue across conversion.
- Update `aria-controls`, `aria-expanded`, `aria-haspopup`, and `aria-activedescendant` synchronously with the destination DOM before or in the same committed render that moves focus.
- Never leave a focused controller pointing to a removed Listbox or option.
- When the destination has a different controller role, remove source-only ARIA attributes rather than carrying them across.

- [ ] **Step 4: Align the responsive source of truth**

In `references/responsive-adaptive.md`, keep only the cross-category invariant: retain the exact focused node when it survives; otherwise move focus once to the destination’s equivalent controller defined by the Select standard. Do not duplicate the placement-by-placement map.

- [ ] **Step 5: Add acceptance checks and replay scenarios**

Extend Select acceptance text to cover conversion among `inline`, `panel`, `drawer`, and `none` while query, active, loading, error, orphaned invalid value, and remote requests exist. Require checks for one focus movement, current `aria-controls`, rendered `aria-activedescendant`, no value callback, no duplicate request, and preserved close-return target.

Update S-02, S-05, and S-06 in the ledger; mark F-05 through F-07 `repaired-static` and runtime behavior unverified.

- [ ] **Step 6: Run focused checks**

```bash
rg -n "转换.*焦点|aria-controls|aria-activedescendant|selectedValue|回调|逻辑.*ID" references/selects-comboboxes.md references/responsive-adaptive.md
git diff --check -- references/selects-comboboxes.md references/responsive-adaptive.md docs/audits/2026-07-25-existing-standards-hardening.md
```

Expected: the full placement map exists only in the Select standard, the responsive file links to that source of truth, and `git diff --check` exits 0.

- [ ] **Step 7: Commit the Select conversion repair**

```bash
git add references/selects-comboboxes.md references/responsive-adaptive.md docs/audits/2026-07-25-existing-standards-hardening.md
git commit -m "docs: 明确选择器跨形态焦点语义"
```

### Task 4: Reconcile routing, summaries, and complete verification

**Files:**
- Modify if needed: `SKILL.md`
- Modify if needed: `README.md`
- Modify: `docs/audits/2026-07-25-existing-standards-hardening.md`

**Interfaces:**
- Consumes: all repaired findings and replayed scenarios from Tasks 1 through 3.
- Produces: a complete audit conclusion and a repository whose structure, links, placeholders, wording, and Git diff all validate.

- [ ] **Step 1: Check whether routing or user summary changes are required**

Run:

```bash
rg -n "Dialog|Drawer|Select|Combobox|响应式|移动端|视口" SKILL.md README.md
```

Decision rule:

- Leave `SKILL.md` unchanged if all four categories still route to their owning files and no new global red line was introduced.
- Leave `README.md` unchanged if the repairs only disambiguate lifecycle and conversion behavior already summarized.
- If either file changes, add only a link or one concise externally visible guarantee; do not copy the repaired full rules.

- [ ] **Step 2: Complete the audit disposition**

In the audit ledger:

- Mark every finding either `repaired-static` with exact file/section evidence or `no-change` with a reason tied to an existing rule.
- Mark all seven scenarios `determined-static` only when all five assertions have citations.
- Add a verification table distinguishing official Skill validation, link checking, placeholder scanning, diff checking, static scenario replay, and unperformed runtime/device testing.
- State explicitly that browser, screen-reader, touch-device, and real-viewport behavior remains unverified.

- [ ] **Step 3: Validate relative Markdown links**

Run this repository-local Ruby check:

```bash
ruby -e 'Dir.glob("**/*.md").each { |f| File.read(f).scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |u| next if u =~ /\A(?:https?:|mailto:|#)/; p = File.expand_path(u.split("#", 2).first, File.dirname(f)); abort("broken link: #{f} -> #{u}") unless File.exist?(p) } }'
```

Expected: exit 0 with no output.

- [ ] **Step 4: Run the official Skill validator**

Use an existing Python environment with PyYAML, or create an isolated temporary environment as described in `CONTRIBUTING.md`, then run:

```bash
python /Users/evanqi/.codex/skills/.system/skill-creator/scripts/quick_validate.py .
```

Expected: `Skill is valid!`

- [ ] **Step 5: Run repository-wide static checks**

```bash
rg -n '\b(T[B]D|T[O]DO|F[I]XME|X[X]X)\b' SKILL.md README.md references docs/audits
git diff --check
git status --short
```

Expected: placeholder scan prints no matches; `git diff --check` exits 0; status lists only intended audit or documentation changes not already committed.

- [ ] **Step 6: Review the final diff against the design**

Run:

```bash
git diff HEAD~3 -- SKILL.md README.md references docs/audits
```

Expected: every normative change maps to F-01 through F-07, every repaired rule has an acceptance check, no new component category appears, and runtime testing is not reported as completed.

- [ ] **Step 7: Commit final reconciliation if it produced changes**

If Task 4 changed tracked files:

```bash
git add SKILL.md README.md docs/audits/2026-07-25-existing-standards-hardening.md
git commit -m "docs: 完成现有规范加固验证"
```

If only the audit ledger changed, stage and commit only that file with the same message. If no file changed, do not create an empty commit.
