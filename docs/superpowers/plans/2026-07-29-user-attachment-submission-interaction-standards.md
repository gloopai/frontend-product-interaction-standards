# 用户侧附件与内容提交上传交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增用户侧附件与内容提交上传 owner，约束头像、评论/聊天/工单/反馈附件、内容投稿配图、移动端相机/相册/录音录像、发送前草稿、发送后附件引用和失败恢复。

**Architecture:** 采用现有规范仓库模式：先写 Ruby 静态审计并确认 RED，再新增 `references/user-attachment-submission.md` 作为唯一 owner，最后补齐 `SKILL.md` 路由、README/HANDOFF 摘要、相邻 owner 关系和 RED/GREEN 证据。审计使用 exact-term contract 与 mutation cases，保证新增规范不会被宽松文案绕过。

**Tech Stack:** Markdown 规范文档、Ruby 静态审计脚本、Git。

## Global Constraints

- 全部新增和复核文档使用中文。
- 不引入具体业务项目、客户名、业务仓库路径、前端框架、组件库、对象存储、消息服务或实现技术例外。
- `uploads-imports.md` 继续负责底层文件选择、上传队列、进度、取消、重试、文件项身份和迟到上传结果。
- `files-media-assets.md` 继续负责附件成为资产后的预览、版本、分享、发布、删除恢复和使用关系。
- 本 owner 只负责附件如何参与一次用户内容提交：草稿、上传引用、提交快照、发送结果、失败恢复、权限收敛和移动端输入边界。
- 真实浏览器、真实移动端设备、相机/相册/录音权限、真实上传、真实弱网/离线、真实后台切换、键盘、触摸和读屏检查未执行时，必须标为“未验证”。
- 提交前必须运行专项 mutation 审计、相邻 owner 审计、全量 owner 审计、Markdown 链接检查和 `git diff --check`。

---

## File Structure

- Create: `references/user-attachment-submission.md`  
  用户侧附件与内容提交上传的唯一 owner。负责 `attachmentSubmissionState`、草稿/上传/提交分层、发送按钮、迟到结果、头像/封面、消息/评论/工单/反馈附件、权限隐私、移动端弱网、反馈和完成前检查。
- Create: `docs/testing/user-attachment-submission/user-attachment-submission-audit.rb`  
  静态审计 owner、路由、相邻关系、README/HANDOFF、RED/GREEN 证据和 mutation。
- Create: `docs/testing/user-attachment-submission/red-summary.md`  
  记录应被审计识别为失败的负向场景。
- Create: `docs/testing/user-attachment-submission/green-summary.md`  
  记录当前规范已经证明的结构性行为。
- Modify: `SKILL.md`  
  增加用户附件、评论附件、聊天附件、头像上传、发送图片、相机/相册、附件草稿等触发词到 `references/user-attachment-submission.md`。
- Modify: `README.md`  
  增加面向使用者的简短摘要和 references 目录项。
- Modify: `HANDOFF.md`  
  增加结构树、已完成规范摘要，并移除“超出管理台范围的上传能力”待办。
- Modify: `references/uploads-imports.md`  
  在 owner 关系处说明用户侧附件提交还必须执行 `references/user-attachment-submission.md`。
- Modify: `references/files-media-assets.md`  
  在 owner 关系处说明用户侧发送前草稿和内容附件绑定还必须执行 `references/user-attachment-submission.md`。

---

### Task 1: Write the failing user attachment submission audit

**Files:**
- Create: `docs/testing/user-attachment-submission/user-attachment-submission-audit.rb`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-user-attachment-submission-interaction-standards-design.md`
- Produces: command `ruby docs/testing/user-attachment-submission/user-attachment-submission-audit.rb`

- [ ] **Step 1: Add the audit skeleton**

Create the Ruby audit with these paths:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/user-attachment-submission.md")
UPLOADS = File.join(ROOT, "references/uploads-imports.md")
ASSETS = File.join(ROOT, "references/files-media-assets.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/user-attachment-submission/green-summary.md")
RED = File.join(ROOT, "docs/testing/user-attachment-submission/red-summary.md")
```

- [ ] **Step 2: Define required state fields**

The audit must require these `attachmentSubmissionState` fields:

```ruby
STATE_FIELDS = %w[
  attachmentSubmissionOwnerId contentDraftBinding inputSourcePolicy
  localAttachmentDrafts uploadBinding submitSnapshot sendPolicy
  postSubmitState revisionPolicy permissionBoundary feedbackBinding
  responsivePolicy
].freeze
```

- [ ] **Step 3: Define required owner terms**

The audit must fail unless the owner includes all of these exact terms:

```ruby
OWNER_TERMS = [
  "attachmentSubmissionState",
  "选择文件、生成本地预览、完成裁剪/压缩、上传成功、发送成功、内容发布成功、头像生效和资产入库必须是不同状态",
  "上传成功只能说明文件引用可用于当前提交候选",
  "不能自动说明消息已发送、评论已发布、头像已生效、内容已审核通过或资产已入库",
  "发送按钮不得只读取“是否有本地文件名”",
  "发送时冻结附件项身份和上传引用候选",
  "不能生成重复消息、重复评论、重复工单、重复头像更新或重复投稿",
  "本地文件 A 被替换为文件 B 后，A 的裁剪、压缩、上传或扫描迟到结果不得写入 B",
  "发送前删除附件只删除当前草稿的附件项和上传候选",
  "发送后删除附件、撤回附件或编辑附件必须声明影响内容版本、附件可见性、审计、接收方已读状态、通知状态和恢复边界",
  "头像上传、封面上传和内容配图必须区分选择、裁剪、预览、上传、保存、生效、审核、缓存刷新和旧图片失效",
  "裁剪成功不等于头像已生效",
  "消息、评论、工单和反馈附件必须绑定到对应内容草稿和发送请求",
  "文本发送成功但附件失败、附件上传成功但文本发送失败、部分附件失败、内容进入审核、服务端未知结果、离线队列等待发送和接收方无权查看附件都必须是可区分状态",
  "无权或未启用时，附件选择、相机/相册、录音录像、粘贴、拖拽、预览、上传、发送、重试、删除、撤回、下载和查看原图的 DOM、state、handler、request 和快捷键入口为 0",
  "附件预览、文件名、缩略图、EXIF、语音时长、视频时长、地理位置、内部 ID、下载链接、错误明细和旧缓存都不得在无权限、被删除、已撤回、被审核拦截或会话失效状态下泄露",
  "移动端不得删除相机、相册、文件选择、录音录像、附件预览、文件级错误、上传进度、删除/替换、重试、发送状态、离开保护、权限原因、失败恢复和已发送附件状态",
  "附件错误不能只挂在缩略图红框或 Toast",
  "同一完整错误消息只能由一个 primary owner 播报",
  "未验证"
].freeze
```

- [ ] **Step 4: Define route, relationship and summary terms**

The audit must require `SKILL.md` to route at least these terms:

```ruby
ROUTE_TERMS = [
  "用户附件", "附件提交", "内容附件", "评论附件", "聊天附件", "消息附件",
  "工单附件", "反馈附件", "客服附件", "头像上传", "资料图片", "封面上传",
  "配图上传", "帖子图片", "文章图片", "内容投稿", "发送图片", "发送文件",
  "发送语音", "发送视频", "拍照上传", "相册选择", "录音上传", "录像上传",
  "粘贴图片", "拖拽附件", "附件草稿", "发送前预览", "附件重试",
  "删除附件", "撤回附件", "替换附件", "user attachment",
  "attachment submission", "content attachment", "comment attachment",
  "chat attachment", "message attachment", "ticket attachment",
  "support attachment", "feedback attachment", "avatar upload",
  "profile photo", "cover upload", "image attachment", "post image",
  "article image", "content submission", "send image", "send file",
  "send voice", "send video", "camera upload", "photo library",
  "audio upload", "video upload", "paste image", "drag attachment",
  "attachment draft", "pre-send preview", "retry attachment",
  "delete attachment", "revoke attachment", "replace attachment",
  "references/user-attachment-submission.md"
].freeze
```

The audit must require adjacent owner relationship text:

```ruby
RELATIONSHIP_TERMS = [
  "references/user-attachment-submission.md",
  "user-attachment-submission.md"
].freeze
```

The audit must require README and HANDOFF to include:

```ruby
README_TERMS = [
  "用户侧附件与内容提交上传规范",
  "references/user-attachment-submission.md"
].freeze

HANDOFF_TERMS = [
  "### 用户侧附件与内容提交上传",
  "attachmentSubmissionState",
  "上传成功只能说明文件引用可用于当前提交候选",
  "发送按钮不得只读取“是否有本地文件名”",
  "移动端不得删除相机、相册、文件选择、录音录像、附件预览、文件级错误、上传进度、删除/替换、重试、发送状态、离开保护、权限原因、失败恢复和已发送附件状态",
  "references/user-attachment-submission.md"
].freeze
```

- [ ] **Step 5: Define evidence and leakage terms**

The audit must require both evidence files to contain:

```ruby
EVIDENCE_TERMS = [
  "attachmentSubmissionState", "attachmentSubmissionOwnerId",
  "contentDraftBinding", "inputSourcePolicy", "localAttachmentDrafts",
  "uploadBinding", "submitSnapshot", "sendPolicy", "postSubmitState",
  "revisionPolicy", "permissionBoundary", "feedbackBinding",
  "responsivePolicy", "上传成功", "消息已发送", "评论已发布",
  "头像已生效", "资产已入库", "本地文件名", "发送时冻结",
  "重复消息", "迟到结果", "发送前删除附件", "发送后删除附件",
  "撤回附件", "裁剪成功", "文本发送成功但附件失败",
  "附件上传成功但文本发送失败", "DOM、state、handler、request 和快捷键入口为 0",
  "缩略图红框或 Toast", "primary owner", "移动端", "未验证"
].freeze

PROJECT_BANNED_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/",
  "src/pages",
  "Ant Design",
  "ant-design",
  "shadcn",
  "Next.js",
  "Vite",
  "React",
  "Vue",
  "S3",
  "OSS",
  "Supabase",
  "Firebase"
].freeze
```

- [ ] **Step 6: Implement audit helpers and mutations**

Use this helper shape:

```ruby
def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  failures = []
  STATE_FIELDS.each { |field| failures << "owner: attachmentSubmissionState missing #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end
```

Add `integration_failures`, `project_leak_failures`, `audit` and `expect_failure` helpers matching existing audits, then add `--mutations` cases named exactly:

```ruby
missing-owner-state
upload-success-as-content-success
avatar-crop-as-effective
send-button-reads-local-name
missing-send-freeze
duplicate-message-allowed
late-result-writes-new-draft
pre-send-delete-deletes-sent
post-send-delete-boundary-missing
message-attachment-state-merged
permission-zero-entry-missing
attachment-privacy-leakage
mobile-core-attachment-actions-removed
toast-only-attachment-error
duplicate-announcement-owner
runtime-boundary-marked-verified
missing-route
missing-adjacent-owner-link
project-specific-leakage
```

- [ ] **Step 7: Run audit to verify RED**

Run:

```bash
ruby docs/testing/user-attachment-submission/user-attachment-submission-audit.rb
```

Expected: FAIL with missing `references/user-attachment-submission.md`. This is the RED proof that the new audit detects the absent owner.

- [ ] **Step 8: Commit the RED audit only if splitting commits**

If using multiple implementation commits, commit only the audit file:

```bash
git add docs/testing/user-attachment-submission/user-attachment-submission-audit.rb
git commit -m "test: 添加用户侧附件提交规范审计"
```

If using a single implementation commit, leave the audit uncommitted until Task 4.

---

### Task 2: Implement the owner and adjacent owner relationships

**Files:**
- Create: `references/user-attachment-submission.md`
- Modify: `references/uploads-imports.md`
- Modify: `references/files-media-assets.md`

**Interfaces:**
- Consumes: Task 1 audit constants and the design spec.
- Produces: owner terms required by `OWNER_TERMS` and adjacent relationship terms required by `RELATIONSHIP_TERMS`.

- [ ] **Step 1: Create the owner document**

Create `references/user-attachment-submission.md` with these sections, in this order:

```markdown
# 用户侧附件与内容提交上传交互规范

适用于用户附件、附件提交、内容附件、评论附件、聊天附件、消息附件、工单附件、反馈附件、客服附件、头像上传、资料图片、封面上传、配图上传、帖子图片、文章图片、内容投稿、发送图片、发送文件、发送语音、发送视频、拍照上传、相册选择、录音上传、录像上传、粘贴图片、拖拽附件、附件草稿、发送前预览、附件重试、删除附件、撤回附件和替换附件。

本文件是附件作为一次用户内容提交的一部分时的唯一 owner。底层文件选择、上传队列、上传进度、取消、重试和迟到上传结果继续执行 `uploads-imports.md`；附件成为文件或媒体资产后的预览、版本、分享、发布、删除恢复和使用关系继续执行 `files-media-assets.md`。

## 范围与非目标

## `attachmentSubmissionState`

## 附件草稿、上传引用和内容提交分层

## 发送按钮和附件队列的关系

## 迟到结果、替换和删除

## 头像、封面和内容配图

## 消息、评论、工单和反馈附件

## 权限、会话和隐私

## 移动端和弱网承载

## 反馈、可访问性和恢复

## 与其他 owner 的关系

## 完成前检查

## 参考资料
```

- [ ] **Step 2: Fill `attachmentSubmissionState`**

Add the state table with these exact fields and meanings:

```markdown
每个用户侧附件提交场景必须声明 `attachmentSubmissionState`，并包含 `attachmentSubmissionOwnerId`、`contentDraftBinding`、`inputSourcePolicy`、`localAttachmentDrafts`、`uploadBinding`、`submitSnapshot`、`sendPolicy`、`postSubmitState`、`revisionPolicy`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。

- `attachmentSubmissionOwnerId`：当前附件提交实例身份，绑定内容草稿、消息/评论/工单/头像对象、会话、租户/工作区、权限版本和承载面。
- `contentDraftBinding`：文本、富文本、表单字段、评论、消息、工单、头像、投稿或反馈草稿身份，以及附件与草稿的绑定关系。
- `inputSourcePolicy`：允许的输入来源，包括文件选择、相机、相册、录音、录像、粘贴、拖拽、系统分享、重新选择和平台限制。
- `localAttachmentDrafts`：本地文件、临时预览、裁剪/压缩/转码草稿、顺序、描述、替代文本、删除标记和本地错误。
- `uploadBinding`：对应 Upload owner 的 `uploadSessionState`、文件项身份、上传凭证、上传引用、进度、失败、取消和迟到结果策略。
- `submitSnapshot`：用户点击发送、提交、保存、发布或更新头像时冻结的文本、附件引用、权限版本、内容版本、幂等键和来源意图。
- `sendPolicy`：发送/提交/保存/发布/更新头像的防重复、loading、未知结果、失败恢复、重试范围和回执 owner。
- `postSubmitState`：发送后内容、评论、消息、工单、头像或投稿的可见状态、附件可见性、审核/扫描/转码状态和失败回滚。
- `revisionPolicy`：发送前删除/替换/重排附件、发送后编辑、撤回、删除附件、重新上传、重新发送和版本冲突策略。
- `permissionBoundary`：上传、预览、发送、查看、下载、编辑、撤回、删除和重试时的权限、会话、租户/工作区和旧状态收敛。
- `feedbackBinding`：Inline、字段错误、附件项错误、发送结果、弱网状态、Toast、Alert、Notification 和恢复入口的 owner。
- `responsivePolicy`：移动端相机/相册、触摸排序、虚拟键盘、输入栏、底部操作、安全区域、后台切换和离线恢复策略。
```

- [ ] **Step 3: Fill core rules with exact audit terms**

Ensure the owner includes every `OWNER_TERMS` exact string from Task 1. Keep the wording aligned with the design spec:

- 草稿、上传引用和内容提交分层。
- 发送按钮不能读本地文件名。
- 发送时冻结附件项身份和上传引用候选。
- 重复触发不得生成重复消息/评论/工单/头像更新/投稿。
- A 文件迟到结果不能写入 B。
- 发送前删除与发送后删除/撤回/编辑分离。
- 头像/封面状态分层。
- 消息/评论/工单/反馈附件结果分层。
- 无权入口为 0。
- 移动端核心能力不可删除。
- 附件错误不能 Toast-only 或缩略图-only。

- [ ] **Step 4: Add adjacent owner links in uploads**

In `references/uploads-imports.md`, in “与组件 owner 的关系”, add this sentence:

```markdown
用户侧附件、头像上传、评论/聊天/工单/反馈附件、内容投稿配图、发送前草稿和发送后附件引用还必须执行 `references/user-attachment-submission.md`；本文件继续负责底层上传会话、文件项身份、队列、进度、取消、重试和迟到上传结果。
```

- [ ] **Step 5: Add adjacent owner links in files/media assets**

In `references/files-media-assets.md`, after the paragraph that links `uploads-imports.md`, add this sentence:

```markdown
用户侧附件、头像上传、评论/聊天/工单/反馈附件、内容投稿配图、发送前草稿和发送后附件引用还必须执行 `references/user-attachment-submission.md`；本文件继续负责附件成为资产后的预览、版本、分享、发布、删除恢复和使用关系。
```

- [ ] **Step 6: Run owner audit**

Run:

```bash
ruby docs/testing/user-attachment-submission/user-attachment-submission-audit.rb
```

Expected: still FAIL because SKILL/README/HANDOFF/evidence files are not yet complete, but owner-specific missing term failures should be gone.

---

### Task 3: Add route, summaries and evidence

**Files:**
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/user-attachment-submission/red-summary.md`
- Create: `docs/testing/user-attachment-submission/green-summary.md`

**Interfaces:**
- Consumes: Task 1 route and evidence constants.
- Produces: route, summary and evidence terms required by audit.

- [ ] **Step 1: Add SKILL route**

In `SKILL.md`, insert a route near the existing upload/file routes:

```markdown
- 涉及用户附件、附件提交、内容附件、评论附件、聊天附件、消息附件、工单附件、反馈附件、客服附件、头像上传、资料图片、封面上传、配图上传、帖子图片、文章图片、内容投稿、发送图片、发送文件、发送语音、发送视频、拍照上传、相册选择、录音上传、录像上传、粘贴图片、拖拽附件、附件草稿、发送前预览、附件重试、删除附件、撤回附件、替换附件，或 user attachment、attachment submission、content attachment、comment attachment、chat attachment、message attachment、ticket attachment、support attachment、feedback attachment、avatar upload、profile photo、cover upload、image attachment、post image、article image、content submission、send image、send file、send voice、send video、camera upload、photo library、audio upload、video upload、paste image、drag attachment、attachment draft、pre-send preview、retry attachment、delete attachment、revoke attachment、replace attachment 时，必须完整读取 `references/user-attachment-submission.md`。
```

- [ ] **Step 2: Add README summary and tree entry**

In `README.md`, add a summary bullet near upload/file media:

```markdown
- 用户侧附件与内容提交上传规范约束 attachmentSubmissionState、内容草稿绑定、相机/相册/粘贴/拖拽来源、附件草稿、上传引用、提交快照、发送结果、撤回/删除、权限隐私、弱网恢复和移动端输入承载，避免文件已选即发送、上传成功即内容成功、头像裁剪即生效、迟到结果写入新草稿和 Toast-only 附件错误。
```

Also add `references/user-attachment-submission.md` to the complete rules sentence and `user-attachment-submission.md` to the references tree.

- [ ] **Step 3: Add HANDOFF summary**

In `HANDOFF.md`, add the references tree entry and this section near “上传与导入” / “文件与媒体资产管理”:

```markdown
### 用户侧附件与内容提交上传

- 已定义头像上传、评论附件、聊天附件、消息附件、工单附件、反馈附件、内容投稿附件、移动端拍照/录音/录像、发送前预览、发送后附件引用和附件草稿恢复的首版 owner。
- `attachmentSubmissionState` 必须声明 `attachmentSubmissionOwnerId`、`contentDraftBinding`、`inputSourcePolicy`、`localAttachmentDrafts`、`uploadBinding`、`submitSnapshot`、`sendPolicy`、`postSubmitState`、`revisionPolicy`、`permissionBoundary`、`feedbackBinding` 和 `responsivePolicy`。
- 上传成功只能说明文件引用可用于当前提交候选；不能自动说明消息已发送、评论已发布、头像已生效、内容已审核通过或资产已入库。
- 发送按钮不得只读取“是否有本地文件名”；必须绑定文本草稿、附件草稿、上传状态、必填规则、权限、会话、内容版本和提交策略。
- 移动端不得删除相机、相册、文件选择、录音录像、附件预览、文件级错误、上传进度、删除/替换、重试、发送状态、离开保护、权限原因、失败恢复和已发送附件状态。
- 详细规则和可执行验收仅维护在 `references/user-attachment-submission.md`，本交接不重复其状态模型或检查项。
```

Remove `1. 超出管理台范围的上传能力。` from “后续建议” because this plan implements that remaining recommendation.

- [ ] **Step 4: Add RED evidence**

Create `docs/testing/user-attachment-submission/red-summary.md` with bullets covering:

- Missing `attachmentSubmissionState` fields.
- 文件已选即发送。
- 上传成功即消息/评论/头像/资产成功。
- 发送按钮读取本地文件名。
- 未冻结发送快照。
- 重复消息/评论/工单/头像更新/投稿。
- 迟到结果写入新草稿。
- 发送前删除误删已发送附件。
- 发送后删除/撤回/编辑无边界。
- 消息/评论/工单/反馈附件状态混合。
- 无权入口未做到 DOM/state/handler/request/shortcut 为 0。
- 附件隐私泄露。
- 移动端删除相机、相册、重试、离开保护和已发送附件状态。
- 缩略图红框或 Toast 作为唯一错误。
- 重复公告 owner。
- 未执行真实运行时验证却写成已验证。

The file must contain every `EVIDENCE_TERMS` exact string from Task 1.

- [ ] **Step 5: Add GREEN evidence**

Create `docs/testing/user-attachment-submission/green-summary.md` with positive bullets proving:

- Full `attachmentSubmissionState`.
- Clear state separation between upload success, message sent, comment published, avatar effective and asset stored.
- `submitSnapshot` boundary.
- send freeze and duplicate prevention.
- late result rejection.
- pre-send vs post-send deletion boundaries.
- avatar/cover crop vs effective state boundary.
- message/comment/ticket/feedback attachment partial and unknown states.
- permission zero-entry rule with exact phrase `DOM、state、handler、request 和快捷键入口为 0`.
- mobile capability preservation.
- accessible error and single `primary owner`.
- runtime checks marked `未验证`.

End with:

```markdown
对应静态审计入口：`ruby docs/testing/user-attachment-submission/user-attachment-submission-audit.rb --mutations`。
```

- [ ] **Step 6: Run focused mutation audit**

Run:

```bash
ruby docs/testing/user-attachment-submission/user-attachment-submission-audit.rb --mutations
```

Expected: all mutation names print `EXPECTED_FAIL`, followed by a PASS line.

---

### Task 4: Run full verification and commit

**Files:**
- All files from Tasks 1-3.

**Interfaces:**
- Consumes: completed owner, route, adjacent owner relationships, evidence and summaries.
- Produces: verified commit on `main`.

- [ ] **Step 1: Run adjacent owner audits**

Run:

```bash
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
ruby docs/testing/files-media-assets/files-media-assets-audit.rb --mutations
ruby docs/testing/forms/forms-audit.rb --mutations
ruby docs/testing/complex-editors-builders/complex-editors-builders-audit.rb --mutations
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/overlays-menus-tooltips/overlays-menus-tooltips-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
```

Expected: every command exits 0 and mutation runs print their expected failure labels.

- [ ] **Step 2: Run full owner audit suite**

Run:

```bash
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
```

Expected: every audit exits 0.

- [ ] **Step 3: Run Markdown link check**

Run:

```bash
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
```

Expected: `PASS: markdown links resolve`.

- [ ] **Step 4: Run diff and project-leak checks**

Run:

```bash
git diff --check
rg -n "fex-admin|/Users/evanqi/code/|src/pages|Ant Design|ant-design|shadcn|Next.js|Vite|React|Vue|S3|OSS|Supabase|Firebase" references/user-attachment-submission.md docs/testing/user-attachment-submission/red-summary.md docs/testing/user-attachment-submission/green-summary.md README.md HANDOFF.md || true
git status --short --branch
```

Expected: `git diff --check` exits 0. The `rg` command prints no project-specific hits outside audit constants. `git status` shows only intended files modified or added.

- [ ] **Step 5: Commit and push**

Run:

```bash
git add SKILL.md README.md HANDOFF.md references/user-attachment-submission.md references/uploads-imports.md references/files-media-assets.md docs/testing/user-attachment-submission
git commit -m "docs: 新增用户侧附件提交规范"
git push origin main
git status --short --branch
git log --oneline -1
```

Expected: commit succeeds, push updates `main`, final status is clean and aligned with `origin/main`.

---

## Self-Review

- Spec coverage: covered target owner file, route, README/HANDOFF, adjacent owner links, RED/GREEN evidence, focused audit, adjacent audits, full audit, links, diff check, project-specific leakage scan and git delivery.
- Placeholder scan: no unresolved placeholder or vague implementation instruction is present.
- Type consistency: `attachmentSubmissionState` and its fields are identical across plan tasks; audit constants, owner field list, evidence terms and HANDOFF summary use the same names.
- Scope check: this is one owner, not multiple subsystems. Upload queue and asset library behavior remain in their existing owners; this plan only implements the user-side attachment submission layer.

Plan complete and saved to `docs/superpowers/plans/2026-07-29-user-attachment-submission-interaction-standards.md`.
