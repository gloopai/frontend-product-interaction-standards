# HANDOFF Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `HANDOFF.md` so it accurately records the current hardened standards, repository structure, validation evidence, and next priority.

**Architecture:** Keep `HANDOFF.md` as a concise handoff summary and link to the durable audit rather than copying its matrix. Modify no Skill routing, user documentation, agent metadata, or owner reference rules.

**Tech Stack:** Markdown, Git, `rg`, Ruby link check, Codex Skill `quick_validate.py`.

## Global Constraints

- Only `HANDOFF.md` may be committed for the implementation.
- `docs/` remains ignored; the local design and plan files are not force-added.
- Do not modify `SKILL.md`, `README.md`, `agents/openai.yaml`, or `references/*.md`.
- Keep forms as the next priority; add no form rules in this task.
- Do not claim browser, screen-reader, touch-device, or real-component runtime validation.

---

### Task 1: Refresh the handoff document

**Files:**
- Modify: `HANDOFF.md`
- Read: `docs/audits/2026-07-25-existing-standards-hardening.md`
- Verify unchanged: `SKILL.md`, `README.md`, `agents/openai.yaml`, `references/*.md`

**Interfaces:**
- Consumes: current `origin/main`, the durable hardening audit, and the approved local design.
- Produces: one committed `HANDOFF.md` whose version, structure, completed guarantees, validation boundary, and next priority are current.

- [ ] **Step 1: Capture the pre-edit failure baseline**

Run:

```bash
current_head=$(git rev-parse origin/main)
handoff_head=$(rg -o '[0-9a-f]{40}' HANDOFF.md | head -1)
test "$current_head" = "$handoff_head"
```

Expected: exit 1 because `HANDOFF.md` still records `e27e44db88b7d1708adec567ccf3662ed43d7b3c`.

- [ ] **Step 2: Update only the approved handoff sections**

Use `apply_patch` to:

- Replace the current handoff version with the current `origin/main` full SHA captured immediately before the edit.
- Extend the structure tree with `docs/audits/` and the durable hardening audit file; do not present ignored local design/plan files as committed repository structure.
- Add concise completed guarantees for Dialog/Drawer close ordering and disposal, cross-shape closing freeze, Select placement focus/ARIA, and Drawer-to-non-modal infrastructure acquire/release.
- Link to `docs/audits/2026-07-25-existing-standards-hardening.md` instead of copying its matrix.
- Update validation status with official Skill validation, relative-link and placeholder checks, Base-to-Head diff review, independent RED/GREEN application checks, and final reviews.
- Preserve runtime tests as explicitly unperformed.
- Keep “表单字段、校验、提交与错误恢复” as the first next recommendation.

- [ ] **Step 3: Verify version and scope**

Run:

```bash
current_head=$(git rev-parse origin/main)
handoff_head=$(rg -o '[0-9a-f]{40}' HANDOFF.md | head -1)
test "$current_head" = "$handoff_head"
git diff --name-only
```

Expected: version comparison exits 0; `git diff --name-only` prints only `HANDOFF.md` because `docs/` remains ignored.

- [ ] **Step 4: Run document and Skill validation**

Run:

```bash
ruby -e 'File.read("HANDOFF.md").scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |u| next if u =~ /\A(?:https?:|mailto:|#)/; p = File.expand_path(u.split("#", 2).first, File.dirname("HANDOFF.md")); abort("broken link: #{u}") unless File.exist?(p) }'
/tmp/frontend-standards-validation-venv/bin/python /Users/evanqi/.codex/skills/.system/skill-creator/scripts/quick_validate.py .
rg -n '\b(T[B]D|T[O]DO|F[I]XME|X[X]X)\b' HANDOFF.md
git diff --check
```

Expected: link check exits 0 with no output; validator prints `Skill is valid!`; placeholder scan prints no matches; `git diff --check` exits 0.

- [ ] **Step 5: Review and commit the focused diff**

Run:

```bash
git diff -- HANDOFF.md
git diff --quiet -- SKILL.md README.md agents/openai.yaml references
git add HANDOFF.md
git commit -m "docs: 更新规范交接状态"
```

Expected: the diff contains only approved handoff changes; owner files are unchanged; the commit succeeds with only `HANDOFF.md`.

- [ ] **Step 6: Push and confirm synchronization**

Run:

```bash
git push origin main
git status --short --branch
```

Expected: push updates `origin/main`; status reports `main...origin/main` with no ahead/behind count and no tracked changes.
