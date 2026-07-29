# Entity Resource Pickers Interaction Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Chinese interaction-standard owner for entity/resource/member pickers and make it auditable.

**Architecture:** Create one focused reference file as the source of truth, wire it into routing and adjacent owners, then add a Ruby audit that guards required terms, references, negative mutations, and project leakage.

**Tech Stack:** Markdown documentation and Ruby audit scripts.

## Global Constraints

- 文档必须使用中文。
- 不处理任何具体业务项目实现。
- 不因其他项目现状降低本 Skill 的规范强度。
- 真实浏览器、键盘、读屏、触摸、权限切换和移动端视口未执行时必须标为未验证。

---

### Task 1: Owner reference

**Files:**
- Create: `references/entity-resource-pickers.md`

**Interfaces:**
- Produces: `entityResourcePickerState`
- Consumes: `references/selects-comboboxes.md`, `references/multi-select-tag-inputs.md`, `references/forms.md`, `references/permissions-tenancy-visibility.md`, `references/members-invitations-access.md`, `references/approval-workflows.md`, `references/tree-hierarchy.md`

- [x] **Step 1: Write the owner with scope, state fields, rules, flow, mobile behavior and audit checklist.**
- [x] **Step 2: Include hard prohibitions for label-as-identity, stale search/recent/recommended results, permission leakage, Toast-only failures and unverified runtime.**
- [x] **Step 3: Ensure the owner does not mention project-specific implementation names.**

### Task 2: Routing and adjacent owners

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Modify: adjacent reference files that invoke object/resource/member picker behavior

**Interfaces:**
- Consumes: `entityResourcePickerState`
- Produces: route keywords and cross-owner boundaries

- [x] **Step 1: Add SKILL route keywords for Chinese and English picker scenarios.**
- [x] **Step 2: Add README summary and link.**
- [x] **Step 3: Add HANDOFF summary section.**
- [x] **Step 4: Add adjacent references requiring `references/entity-resource-pickers.md` and `entityResourcePickerState`.**

### Task 3: Audit

**Files:**
- Create: `docs/testing/entity-resource-pickers/entity-resource-pickers-audit.rb`
- Create: `docs/testing/entity-resource-pickers/red-summary.md`
- Create: `docs/testing/entity-resource-pickers/green-summary.md`

**Interfaces:**
- Consumes: owner, routing, README, HANDOFF, adjacent references
- Produces: executable audit

- [x] **Step 1: Write audit checks for required owner terms, route terms, README/HANDOFF terms and adjacent links.**
- [x] **Step 2: Write mutation controls for missing state, collapsed identity, stale caches, missing permission proof, Toast-only failures and false runtime verification.**
- [x] **Step 3: Write green and red summaries with the audit contract.**
- [x] **Step 4: Run mutation audit and normal audit.**

### Task 4: Verification and commit

**Files:**
- Verify all changed files

**Interfaces:**
- Consumes: all docs and audits
- Produces: committed and pushed main branch

- [ ] **Step 1: Run all existing audit scripts.**
- [ ] **Step 2: Run Markdown link validation.**
- [ ] **Step 3: Run `git diff --check`.**
- [ ] **Step 4: Run project-leak scan.**
- [ ] **Step 5: Stage, commit and push to `main`.**
