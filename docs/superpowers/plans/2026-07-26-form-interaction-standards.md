# Form Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a framework-independent form interaction standard covering field state, validation timing, errors, submission, recovery, unsaved changes, accessibility, and integration with existing component standards.

**Architecture:** Keep all complete form rules in one owner file, `references/forms.md`. Route matching tasks through `SKILL.md`; keep `README.md` and `HANDOFF.md` concise; validate the revised Skill with fresh-agent RED/GREEN application scenarios and repository checks.

**Tech Stack:** Markdown, YAML, Git, `rg`, Ruby relative-link checking, Codex Skill `quick_validate.py`, fresh Codex subagents.

## Global Constraints

- First version covers general fields, validation, errors, submission, recovery, unsaved changes, and cross-component behavior.
- Do not add detailed upload, rich-text, date, tree/cascade, multi-step wizard, or business-specific compound-field rules.
- Use framework-independent, user-observable product language.
- `references/forms.md` is the only source of complete form rules.
- `SKILL.md` contains routing; `README.md` and `HANDOFF.md` contain summaries and links only.
- Every hard rule must have an executable acceptance check.
- Existing Dialog, Drawer, Select / Combobox, and responsive owner rules continue to apply.
- Do not claim browser, screen-reader, touch-device, or real-component runtime validation without a real implementation environment.
- `docs/` remains ignored and must not be force-added.

## File Responsibility Map

- `references/forms.md`: complete state, validation, error, submission, recovery, accessibility, cross-component, and acceptance rules.
- `SKILL.md`: Chinese and English form-task trigger routing to `references/forms.md`.
- `README.md`: concise user-facing form capability summary and link.
- `HANDOFF.md`: completed-category summary, updated priority list, repository structure, and validation boundary.
- `agents/openai.yaml`: inspect only; change only if it no longer matches the Skill positioning.
- `.superpowers/sdd/2026-07-26-form-interaction-standards/`: ignored RED/GREEN prompts, outputs, briefs, reports, and review packages.

---

### Task 1: Establish fresh-agent RED baselines

**Files:**
- Create ignored artifacts: `.superpowers/sdd/2026-07-26-form-interaction-standards/baseline-*.md`
- Read: current `SKILL.md` and existing `references/*.md`

**Interfaces:**
- Consumes: the approved local design at `docs/superpowers/specs/2026-07-26-form-interaction-standards-design.md`.
- Produces: raw no-form-Skill outputs and a concise baseline report identifying divergent decisions that Tasks 2 and 3 must resolve.

- [ ] **Step 1: Run three fresh agents without the form standard**

Dispatch independent agents with no intended answer or diagnosis. Use these scenarios:

1. A profile form with pristine/dirty/touched fields, prefilling, reverting to initial values, first submit, field blur, and a server field error followed by editing.
2. A registration form with debounced async username validation, rapid value changes, first submit during validation, editing while submit is in flight, and an old response arriving late.
3. A dirty form inside a desktop Dialog that becomes a mobile Drawer, fails submission, then receives route navigation while an async callback and focus task are pending.

Require each agent to specify state transitions, validation timing, error ownership, focus, request/result applicability, close/navigation behavior, and decisions that cannot be uniquely derived.

- [ ] **Step 2: Record baseline divergence**

Create an ignored baseline report summarizing exact disagreements, including at minimum:

- whether reverting to the initial value clears dirty;
- whether untouched fields show errors before first submit;
- what happens when submit starts during async validation;
- whether editing during submit is allowed and how old responses apply;
- when server field errors become stale;
- whether route/unmount restores focus to an old field;
- whether responsive Dialog/Drawer conversion resets form state.

- [ ] **Step 3: Verify RED evidence is task-local**

Run:

```bash
git check-ignore -v .superpowers/sdd/2026-07-26-form-interaction-standards/baseline-report.md
git status --short
```

Expected: baseline artifacts are ignored; tracked working tree remains unchanged.

### Task 2: Add field state, validation, and error semantics

**Files:**
- Create: `references/forms.md`

**Interfaces:**
- Consumes: baseline disagreements about pristine/dirty/touched, validation timing, server errors, and focus.
- Produces: the owner state model and default “提交前温和、提交后及时” validation contract used by Task 3.

- [ ] **Step 1: Write failing textual assertions**

Before creating the owner file, run:

```bash
test -f references/forms.md
rg -n "pristine|dirty|touched|校验代次|错误摘要|aria-invalid" references/forms.md
```

Expected: the file test or search fails because no form owner exists.

- [ ] **Step 2: Create the owner and scope sections**

Create `references/forms.md` with:

- purpose and explicit first-version exclusions;
- cross-links to Dialog, Drawer, Select / Combobox, and responsive owners;
- form-level states `pristine`, `dirty`, `validating`, `submitting`, `submitError`, `submitSucceeded`;
- field-level current value, initial value, source, `touched`, `dirty`, sync/async/server errors, visibility, and validation generation.

- [ ] **Step 3: Define field semantics**

Require:

- dirty is derived from current versus explicit initial value and clears when reverted;
- touched and dirty remain independent;
- user input, focus/blur, prefill, programmatic assignment, reset, and server refill have explicit sources;
- error existence and error visibility remain separate;
- committed values of compound controls are form values; Select `query` and `activeOption` are not.

- [ ] **Step 4: Define validation timing and races**

Specify the default sequence:

- no untouched-field errors before first submit;
- touched fields validate on blur;
- first submit runs complete field and form validation;
- after first submit, exposed invalid fields revalidate while editing;
- async validation uses debounce plus cancellation or generation matching;
- submit waits for current applicable validation and never sends known-invalid values.

- [ ] **Step 5: Define error ownership and focus**

Specify:

- field errors adjacent to fields with native/ARIA association;
- focusable error summary with field navigation;
- network, permission, authentication, optimistic-lock, and cross-field conflicts retain correct ownership;
- one primary ownership and no duplicate full-message announcement;
- server field errors bind to submitted values and become stale when those values change;
- field repair does not clear unrelated errors or force focus away.

- [ ] **Step 6: Add focused acceptance checks**

Add executable checks for state-source transitions, revert-to-pristine, default timing before/after first submit, async result ordering, error association, summary navigation, duplicate announcement prevention, and server-error staleness.

- [ ] **Step 7: Run focused GREEN and commit**

```bash
rg -n "pristine|dirty|touched|提交前温和|校验代次|错误摘要|aria-invalid|服务端字段错误|验收" references/forms.md
git diff --check -- references/forms.md
git add references/forms.md
git commit -m "docs: 添加表单状态与校验规范"
```

Expected: all owner concepts and acceptance sections are discoverable; diff check passes; commit contains only `references/forms.md`.

### Task 3: Complete submission, recovery, cross-component, and accessibility rules

**Files:**
- Modify: `references/forms.md`

**Interfaces:**
- Consumes: the Task 2 state and validation model.
- Produces: a complete form lifecycle contract and acceptance list ready for routing.

- [ ] **Step 1: Demonstrate missing lifecycle assertions**

Run:

```bash
rg -n "提交快照|重复提交|未保存|路由.*卸载|Dialog.*Drawer|200%|虚拟键盘" references/forms.md
```

Expected: one or more lifecycle areas are absent before this task.

- [ ] **Step 2: Define submission and response applicability**

Require an immutable submission snapshot, exactly-once submission callbacks and success actions, complete validation before request, and an explicit product decision for editing during submit. If editing is allowed, results apply only to matching snapshot values and cannot overwrite newer values or errors.

- [ ] **Step 3: Define failure, success, and unsaved changes**

Require:

- failures preserve values, dirty/touched state, and context;
- recovery paths match network, authentication, permission, conflict, or validation failure;
- success feedback is perceivable and reset/stay/close/navigate is explicit;
- continued editing after success uses the successful result as a new initial baseline;
- dirty navigation confirms; success, explicit discard, or return to baseline removes the prompt.

- [ ] **Step 4: Define disposal and cross-owner behavior**

Require:

- route/owner unmount invalidates old validation, submit, error, animation, and focus callbacks and releases only owned resources;
- no focus restoration to removed fields; new route owns subsequent focus;
- Dialog/Drawer forms follow modal close rules, and loading alone never changes close paths;
- Dialog↔Drawer conversion preserves initial/current values, dirty/touched, visible errors, validation generations, snapshots, and requests without duplicate validation or submission;
- Select/Combobox contributes only committed value and applicable field validity.

- [ ] **Step 5: Define responsive and accessibility rules**

Cover label/help/unit/error relationships, keyboard order, 200% zoom, font enlargement, long text, low height, dynamic viewport, virtual keyboard, safe areas, error visibility, status announcements, and mobile reflow without deleting fields or recovery actions.

- [ ] **Step 6: Complete lifecycle acceptance checks**

Add observable tests for duplicate submit, submit-during-validation, editing during submit, stale responses, failure recovery, success baseline, dirty navigation, route disposal, modal conversion, compound-field draft boundaries, focus/status announcements, zoom/mobile/virtual-keyboard/safe-area behavior, and explicit runtime-unverified reporting.

- [ ] **Step 7: Run focused checks and commit**

```bash
rg -n "提交快照|重复提交|未保存|路由.*卸载|Dialog.*Drawer|Select.*query|200%|虚拟键盘|未验证" references/forms.md
git diff --check -- references/forms.md
git add references/forms.md
git commit -m "docs: 完善表单提交与错误恢复"
```

Expected: all lifecycle concepts and checks are present; diff check passes; commit contains only `references/forms.md`.

### Task 4: Route and summarize the new standard

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Inspect only: `agents/openai.yaml`

**Interfaces:**
- Consumes: complete `references/forms.md`.
- Produces: discoverable routing, concise user and handoff summaries, and an updated next-priority list.

- [ ] **Step 1: Add precise routing**

In `SKILL.md`, add a route requiring full `references/forms.md` reading for Chinese and English triggers covering form, field, validation, required/optional, error summary, submit, dirty/touched, unsaved changes, and error recovery. Keep existing component routes intact so multiple owner files can load together.

- [ ] **Step 2: Update the user summary**

In `README.md`, add a concise form capability bullet and link to `references/forms.md`. Do not copy the state model or acceptance list.

- [ ] **Step 3: Update handoff state**

In `HANDOFF.md`:

- add `references/forms.md` to the committed structure;
- add an “表单” completed-category summary;
- move tables to the first future priority and remove forms from the future list;
- update validation wording without claiming runtime tests.

- [ ] **Step 4: Confirm agent metadata remains accurate**

Compare `agents/openai.yaml` to updated Skill positioning. Leave it unchanged if “前端设计、开发、评审与测试中的统一产品交互标准” still covers forms; record the no-change decision in the task report.

- [ ] **Step 5: Validate routing and commit**

```bash
rg -n "表单|字段|校验|提交|dirty|touched|unsaved|validation|submit" SKILL.md README.md HANDOFF.md
git diff --check -- SKILL.md README.md HANDOFF.md
git add SKILL.md README.md HANDOFF.md
git commit -m "docs: 路由并发布表单交互规范"
```

Expected: forms are discoverable in Chinese and English; summaries link to the owner; `agents/openai.yaml` remains unchanged unless a concrete mismatch was found.

### Task 5: Forward-test and complete repository verification

**Files:**
- Modify if a real gap is found: `references/forms.md`, `SKILL.md`, `README.md`, `HANDOFF.md`
- Create ignored artifacts: `.superpowers/sdd/2026-07-26-form-interaction-standards/green-*.md`

**Interfaces:**
- Consumes: Tasks 1–4 and their commit history.
- Produces: fresh-agent GREEN evidence, repository validation, and any minimal repair required by actual application failures.

- [ ] **Step 1: Re-run the three baseline scenarios with the revised Skill**

Dispatch fresh agents with prompts phrased as user tasks: `Use $frontend-product-interaction-standards at <worktree-path> to define/review this form interaction.` Do not provide expected answers or baseline diagnoses.

- [ ] **Step 2: Compare RED and GREEN outputs**

Verify revised agents converge on:

- revert-to-pristine and touched/dirty independence;
- submit-before/after validation timing;
- async generation and submit-snapshot applicability;
- server error staleness;
- failure preservation and success baseline;
- dirty navigation;
- Dialog/Drawer state continuity and route disposal;
- focus, ARIA, status, responsive, and runtime-unverified boundaries.

If a real normative gap appears, first record the failing application, then add only the smallest owner rule and acceptance check required to close it.

- [ ] **Step 3: Validate all relative links**

```bash
ruby -e 'Dir.glob("**/*.md").each { |f| File.read(f).scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |u| next if u =~ /\A(?:https?:|mailto:|#)/; p = File.expand_path(u.split("#", 2).first, File.dirname(f)); abort("broken link: #{f} -> #{u}") unless File.exist?(p) } }'
```

Expected: exit 0 with no output.

- [ ] **Step 4: Run official and static validation**

```bash
/tmp/frontend-standards-validation-venv/bin/python /Users/evanqi/.codex/skills/.system/skill-creator/scripts/quick_validate.py .
rg -n '\b(T[B]D|T[O]DO|F[I]XME|X[X]X)\b' SKILL.md README.md HANDOFF.md references
git diff --check
git status --short --branch
```

Expected: validator prints `Skill is valid!`; placeholder scan prints no matches; diff check passes; only intended uncommitted changes appear.

- [ ] **Step 5: Review full implementation range**

Run from the branch base to current HEAD:

```bash
branch_base=$(git merge-base main HEAD)
git diff --stat "$branch_base"..HEAD
git diff "$branch_base"..HEAD -- SKILL.md README.md HANDOFF.md references agents/openai.yaml
```

Expected: only the form owner, routing, summaries, and any evidence-driven minimal repairs changed; no `docs/` files are committed.

- [ ] **Step 6: Commit final repair only if needed**

If Step 2 or final validation required tracked corrections:

```bash
git add references/forms.md SKILL.md README.md HANDOFF.md
git commit -m "docs: 完成表单规范应用验证"
```

If no tracked correction exists, do not create an empty commit.
