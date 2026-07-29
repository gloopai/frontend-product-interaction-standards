# 文件与媒体资产管理交互规范 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增文件库、附件管理、媒体资产、素材库、在线预览、缩略图、图片裁剪、音视频转码、替换版本、发布/下架、分享链接、删除恢复和资产使用关系的独立交互 owner，并用静态审计防止上传完成即资产可用、缩略图当权限证明、旧 URL 泄漏、裁剪/转码/发布意图混用、删除无恢复边界和移动端能力删减。

**Architecture:** 以 `references/files-media-assets.md` 作为唯一 owner，`SKILL.md` 负责触发路由，`README.md` 与 `HANDOFF.md` 只保留中文摘要和 owner 链接。`docs/testing/files-media-assets/files-media-assets-audit.rb` 检查 owner、路由、摘要、RED/GREEN 证据和 mutation；它不替代 Uploads、Exports、Complex Editors、Information Display、Buttons、Risk、Permissions、Async Jobs、Feedback 或 Responsive，而是定义上传完成后的资产身份、版本、预览、分享、发布、删除和恢复生命周期。

**Tech Stack:** Markdown reference documentation, Ruby static audit, Git.

## Global Constraints

- 每个文件或媒体资产场景必须声明 `assetState`，并包含 `assetOwnerId`、`assetIdentity`、`assetLifecycle`、`variantState`、`previewPolicy`、`downloadPolicy`、`sharePolicy`、`editPolicy`、`publishPolicy`、`usageBinding`、`permissionBoundary`、`retentionPolicy`、`feedbackBinding` 和 `responsivePolicy`。
- 上传完成、资产入库、扫描完成、转码完成、缩略图生成完成、预览可用、下载可用、发布可用、CDN 生效和分享链接可用必须是不同状态。
- 上传成功只能说明文件内容或引用进入系统；不能自动写成资产已可预览、已发布、已分享、已扫描安全、已转码完成或已被下游使用。
- 缩略图、预览图、播放器 poster、PDF 首页图、波形图和已缓存媒体片段不能作为权限证明。
- 无权限状态不得泄露文件名、缩略图、预览内容、尺寸、时长、页数、波形、字幕、EXIF、内部 ID、路径、引用关系、分享范围、下载 URL、CDN URL、错误明细、旧缓存或旧可访问名称。
- 资产必须区分资产版本、文件版本、预览版本、缩略图版本、裁剪版本、转码版本、发布版本、CDN 版本和分享链接版本。
- 替换文件、重新裁剪、重新转码、重新生成缩略图、权限变化、租户/工作区切换、发布/下架、删除/恢复、分享撤销或资产被归档后，旧预览 URL、旧下载 URL、旧分享链接、旧 CDN 地址、旧缩略图、旧播放器状态、旧复制内容、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全。
- 替换文件、重命名、改描述、改分类、裁剪图片、旋转图片、重新转码、重新生成缩略图、发布、下架、撤销发布、删除、恢复和永久删除必须是不同意图。
- 裁剪成功不等于保存成功；保存裁剪不等于发布成功；转码任务创建不等于转码完成；发布请求发送不等于 CDN 生效；删除请求发送不等于文件已不可恢复。
- 无法完整证明引用关系时，不能把“未发现引用”写成“没有引用”。
- 分享链接、公开链接、嵌入链接和外部访问必须声明访问范围、有效期、密码或访问条件、是否允许下载、是否允许预览、是否记录审计、是否可撤销和撤销后旧链接失效策略。
- 删除、归档、移入回收站、恢复、永久删除和法务保留必须分开表达。
- 移动端不得删除预览、下载、替换、删除/恢复、转码状态、权限原因、分享管理、使用关系、版本说明、错误恢复和审计入口。
- 真实浏览器预览、真实下载、真实播放器、真实裁剪、真实转码任务、真实权限切换、真实链接过期、真实 CDN 失效和真实移动端视口未执行时，必须标为“未验证”。

---

## File Structure

- Create: `references/files-media-assets.md`  
  独立 owner，定义适用范围、`assetState`、上传后资产状态分层、预览权限边界、版本与旧 URL 失效、裁剪/转码/发布意图、使用关系、分享链接、删除恢复、移动端承载和完成前检查。
- Modify: `SKILL.md`  
  增加文件管理、文件库、附件管理、媒体资产、素材库、在线预览、图片裁剪、视频转码、分享链接、删除恢复等中英文路由。
- Modify: `README.md`  
  增加中文摘要与 `references/files-media-assets.md` 链接，目录结构中列出新 owner。
- Modify: `HANDOFF.md`  
  增加中文交接摘要，说明 owner 边界、状态字段、状态分层、权限清理、分享/删除/恢复、移动端和未验证边界，并调整后续建议。
- Create: `docs/testing/files-media-assets/files-media-assets-audit.rb`  
  静态审计 owner、路由、摘要、RED/GREEN 证据和 mutation。
- Create: `docs/testing/files-media-assets/red-summary.md`  
  记录应被审计识别为失败的负向场景。
- Create: `docs/testing/files-media-assets/green-summary.md`  
  记录当前规范已经证明的结构性行为。

---

### Task 1: Write the failing files/media assets audit

**Files:**
- Create: `docs/testing/files-media-assets/files-media-assets-audit.rb`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-29-files-media-assets-interaction-standards-design.md`
- Produces: command `ruby docs/testing/files-media-assets/files-media-assets-audit.rb`

- [ ] **Step 1: Add the audit skeleton**

Create the Ruby audit with these paths:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/files-media-assets.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/files-media-assets/green-summary.md")
RED = File.join(ROOT, "docs/testing/files-media-assets/red-summary.md")
```

- [ ] **Step 2: Define required state fields**

The audit must require these `assetState` fields:

```ruby
STATE_FIELDS = %w[
  assetOwnerId assetIdentity assetLifecycle variantState previewPolicy
  downloadPolicy sharePolicy editPolicy publishPolicy usageBinding
  permissionBoundary retentionPolicy feedbackBinding responsivePolicy
].freeze
```

- [ ] **Step 3: Define required owner terms**

The audit must fail unless the owner includes all of these terms:

```ruby
OWNER_TERMS = [
  "assetState",
  "上传完成、资产入库、扫描完成、转码完成、缩略图生成完成、预览可用、下载可用、发布可用、CDN 生效和分享链接可用必须是不同状态",
  "上传成功只能说明文件内容或引用进入系统",
  "缩略图、预览图、播放器 poster、PDF 首页图、波形图和已缓存媒体片段不能作为权限证明",
  "无权限状态不得泄露文件名、缩略图、预览内容、尺寸、时长、页数、波形、字幕、EXIF、内部 ID、路径、引用关系、分享范围、下载 URL、CDN URL、错误明细、旧缓存或旧可访问名称",
  "资产必须区分资产版本、文件版本、预览版本、缩略图版本、裁剪版本、转码版本、发布版本、CDN 版本和分享链接版本",
  "旧预览 URL、旧下载 URL、旧分享链接、旧 CDN 地址、旧缩略图、旧播放器状态、旧复制内容、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全",
  "替换文件、重命名、改描述、改分类、裁剪图片、旋转图片、重新转码、重新生成缩略图、发布、下架、撤销发布、删除、恢复和永久删除必须是不同意图",
  "裁剪成功不等于保存成功",
  "转码任务创建不等于转码完成",
  "发布请求发送不等于 CDN 生效",
  "删除请求发送不等于文件已不可恢复",
  "无法完整证明引用关系时，不能把“未发现引用”写成“没有引用”",
  "分享链接、公开链接、嵌入链接和外部访问必须声明访问范围、有效期、密码或访问条件、是否允许下载、是否允许预览、是否记录审计、是否可撤销和撤销后旧链接失效策略",
  "复制分享链接不能只 Toast",
  "删除、归档、移入回收站、恢复、永久删除和法务保留必须分开表达",
  "移动端不得删除预览、下载、替换、删除/恢复、转码状态、权限原因、分享管理、使用关系、版本说明、错误恢复和审计入口",
  "虚拟键盘、横竖屏、低高度视口、播放器控制条、图片缩放、裁剪手柄、底部操作、安全区域和系统字体放大后",
  "未验证"
].freeze
```

- [ ] **Step 4: Define route and summary terms**

The audit must require `SKILL.md` to route at least these terms:

```ruby
ROUTE_TERMS = [
  "文件管理", "文件库", "文件详情", "附件管理", "附件列表",
  "媒体资产", "素材库", "资产库", "图片管理", "视频管理",
  "音频管理", "文档预览", "在线预览", "文件预览", "图片预览",
  "视频预览", "音频预览", "缩略图", "图片裁剪", "图片编辑",
  "视频转码", "音频转码", "重新转码", "替换文件", "文件版本",
  "资产版本", "发布资产", "下架资产", "删除文件", "恢复文件",
  "永久删除", "分享链接", "公开链接", "下载权限", "文件引用", "使用关系",
  "file management", "file library", "file detail", "attachment management",
  "attachment list", "media asset", "media assets", "asset library",
  "image management", "video management", "audio management",
  "document preview", "online preview", "file preview", "image preview",
  "video preview", "audio preview", "thumbnail", "image crop",
  "image editing", "video transcode", "audio transcode", "retranscode",
  "replace file", "file version", "asset version", "publish asset",
  "unpublish asset", "delete file", "restore file", "permanent delete",
  "share link", "public link", "download permission", "file reference",
  "asset usage", "references/files-media-assets.md"
].freeze
```

The audit must require README and HANDOFF to include:

```ruby
README_TERMS = [
  "文件与媒体资产管理规范",
  "references/files-media-assets.md"
].freeze

HANDOFF_TERMS = [
  "### 文件与媒体资产管理",
  "assetState",
  "上传完成、资产入库、扫描完成、转码完成、缩略图生成完成、预览可用、下载可用、发布可用、CDN 生效和分享链接可用必须是不同状态",
  "缩略图、预览图、播放器 poster、PDF 首页图、波形图和已缓存媒体片段不能作为权限证明",
  "移动端不得删除预览、下载、替换、删除/恢复、转码状态、权限原因、分享管理、使用关系、版本说明、错误恢复和审计入口",
  "references/files-media-assets.md"
].freeze
```

- [ ] **Step 5: Define evidence and leakage terms**

The audit must require both evidence files to contain:

```ruby
EVIDENCE_TERMS = [
  "assetState", "assetOwnerId", "assetIdentity", "assetLifecycle",
  "variantState", "previewPolicy", "downloadPolicy", "sharePolicy",
  "editPolicy", "publishPolicy", "usageBinding", "permissionBoundary",
  "retentionPolicy", "feedbackBinding", "responsivePolicy",
  "上传完成", "扫描完成", "转码完成", "预览可用", "CDN 生效",
  "分享链接", "缩略图", "权限证明", "旧预览 URL", "旧下载 URL",
  "旧分享链接", "旧 CDN 地址", "裁剪", "转码", "发布",
  "删除", "恢复", "永久删除", "使用关系", "不能只 Toast",
  "移动端", "虚拟键盘", "裁剪手柄", "未验证"
].freeze

PROJECT_BANNED_TERMS = [
  "fex-admin",
  "/Users/evanqi/code/",
  "src/pages",
  "Ant Design",
  "ant-design",
  "shadcn",
  "Next.js",
  "Vite"
].freeze
```

- [ ] **Step 6: Implement audit helpers and mutations**

Use the same helper shape as existing audits:

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
  STATE_FIELDS.each { |field| failures << "owner: assetState missing #{field}" unless owner.include?(field) }
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end
```

Add `integration_failures`, `project_leak_failures`, `audit` and `expect_failure` helpers matching other audits, then add `--mutations` cases named exactly:

```ruby
missing-owner-state
upload-complete-as-ready
thumbnail-as-permission-proof
permission-leakage-preview
asset-version-missing
old-url-survives
merged-asset-intents
crop-as-publish
transcode-job-as-complete
delete-as-purged
unknown-usage-as-empty
toast-only-share-link
retention-boundary-missing
mobile-core-asset-actions-removed
runtime-boundary-marked-verified
project-specific-leakage
```

- [ ] **Step 7: Run audit to verify RED**

Run:

```bash
ruby docs/testing/files-media-assets/files-media-assets-audit.rb
```

Expected: FAIL because `references/files-media-assets.md`, RED/GREEN evidence, route, README, and HANDOFF integration do not yet satisfy the new contract.

### Task 2: Implement the owner and integration

**Files:**
- Create: `references/files-media-assets.md`
- Modify: `SKILL.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`
- Create: `docs/testing/files-media-assets/red-summary.md`
- Create: `docs/testing/files-media-assets/green-summary.md`

**Interfaces:**
- Consumes: failing audit from Task 1
- Produces: passing owner, route, README/HANDOFF summaries, and evidence files

- [ ] **Step 1: Add `references/files-media-assets.md`**

The owner must include these sections:

```markdown
# 文件与媒体资产管理交互规范

## 范围与非目标
## `assetState`
## 上传后资产状态分层
## 预览、缩略图与权限边界
## 版本、变体和旧 URL 失效
## 编辑、裁剪、转码和发布意图
## 使用关系和影响范围
## 分享链接和公开访问
## 删除、恢复和保留
## 移动端、播放器和裁剪器承载
## 与其他 owner 的关系
## 完成前检查
## 参考资料
```

The file must include the exact state field names and exact owner sentences from Task 1.

- [ ] **Step 2: Add route in `SKILL.md`**

Insert a routing bullet near Uploads / Exports / Complex Editors routes:

```markdown
- 涉及文件管理、文件库、文件详情、附件管理、附件列表、媒体资产、素材库、资产库、图片管理、视频管理、音频管理、文档预览、在线预览、文件预览、图片预览、视频预览、音频预览、缩略图、图片裁剪、图片编辑、视频转码、音频转码、重新转码、替换文件、文件版本、资产版本、发布资产、下架资产、删除文件、恢复文件、永久删除、分享链接、公开链接、下载权限、文件引用、使用关系，或 file management、file library、file detail、attachment management、attachment list、media asset、media assets、asset library、image management、video management、audio management、document preview、online preview、file preview、image preview、video preview、audio preview、thumbnail、image crop、image editing、video transcode、audio transcode、retranscode、replace file、file version、asset version、publish asset、unpublish asset、delete file、restore file、permanent delete、share link、public link、download permission、file reference、asset usage 时，必须完整读取 `references/files-media-assets.md`。
```

- [ ] **Step 3: Update README summary and owner link**

Add one summary bullet:

```markdown
- 文件与媒体资产管理规范约束 assetState、上传后状态分层、预览/缩略图权限边界、资产版本、变体、旧 URL 失效、裁剪/转码/发布意图区分、分享链接、删除恢复、使用关系和移动端播放器/裁剪器承载，避免上传成功即资产可用、缩略图当权限证明、Toast-only 分享和旧 CDN/下载链接泄漏。
```

Add the full rules link:

```markdown
文件与媒体资产管理交互规范：`references/files-media-assets.md`
```

Add `files-media-assets.md` to the `references/` tree.

- [ ] **Step 4: Update HANDOFF summary**

Add a section:

```markdown
### 文件与媒体资产管理

- 已定义文件管理、文件库、附件管理、媒体资产、素材库、在线预览、缩略图、图片裁剪、音视频转码、替换文件、资产版本、发布/下架、分享链接、删除恢复和使用关系的首版 owner。
- `assetState` 必须声明 `assetOwnerId`、`assetIdentity`、`assetLifecycle`、`variantState`、`previewPolicy`、`downloadPolicy`、`sharePolicy`、`editPolicy`、`publishPolicy`、`usageBinding`、`permissionBoundary`、`retentionPolicy`、`feedbackBinding` 和 `responsivePolicy`。
- 上传完成、资产入库、扫描完成、转码完成、缩略图生成完成、预览可用、下载可用、发布可用、CDN 生效和分享链接可用必须是不同状态。
- 缩略图、预览图、播放器 poster、PDF 首页图、波形图和已缓存媒体片段不能作为权限证明；旧预览 URL、旧下载 URL、旧分享链接、旧 CDN 地址、旧缩略图、旧播放器状态、旧复制内容、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全。
- 移动端不得删除预览、下载、替换、删除/恢复、转码状态、权限原因、分享管理、使用关系、版本说明、错误恢复和审计入口。
- 详细规则和可执行验收仅维护在 `references/files-media-assets.md`，本交接不重复其状态模型或检查项。
```

Add `files-media-assets.md` to the top structure tree and remove or adjust “超出管理台范围的上传能力 / 文件与媒体管理” from future recommendations once the owner is implemented.

- [ ] **Step 5: Add RED evidence**

Create `docs/testing/files-media-assets/red-summary.md` with these negative cases:

```markdown
# 文件与媒体资产管理 RED 证据摘要

- 缺少 `assetState`，或者缺少 `assetOwnerId`、`assetIdentity`、`assetLifecycle`、`variantState`、`previewPolicy`、`downloadPolicy`、`sharePolicy`、`editPolicy`、`publishPolicy`、`usageBinding`、`permissionBoundary`、`retentionPolicy`、`feedbackBinding`、`responsivePolicy`。
- 上传完成、资产入库、扫描完成、转码完成、缩略图生成完成、预览可用、下载可用、发布可用、CDN 生效和分享链接可用混成同一状态。
- 上传成功被写成资产已可预览、已发布、已分享、已扫描安全、已转码完成或已被下游使用。
- 缩略图、预览图、播放器 poster、PDF 首页图、波形图或已缓存媒体片段被当成权限证明。
- 无权限状态泄露文件名、缩略图、预览内容、尺寸、时长、页数、波形、字幕、EXIF、内部 ID、路径、引用关系、分享范围、下载 URL、CDN URL、错误明细、旧缓存或旧可访问名称。
- 替换文件、重新裁剪、重新转码、重新生成缩略图、权限变化、租户/工作区切换、发布/下架、删除/恢复、分享撤销或资产被归档后，旧预览 URL、旧下载 URL、旧分享链接、旧 CDN 地址、旧缩略图、旧播放器状态、旧复制内容、旧焦点目标或旧 ARIA 引用继续生效。
- 替换文件、裁剪图片、重新转码、发布、下架、撤销发布、删除、恢复和永久删除混用同一个意图。
- 裁剪成功被当成保存成功，保存裁剪被当成发布成功，转码任务创建被当成转码完成，发布请求发送被当成 CDN 生效，删除请求发送被当成文件已不可恢复。
- 使用关系无法完整证明时，把“未发现引用”写成“没有引用”。
- 复制分享链接只显示 Toast，没有可见状态、有效期、访问范围和撤销入口。
- 删除、归档、移入回收站、恢复、永久删除和法务保留没有分开表达，或没有说明恢复窗口和不可恢复边界。
- 移动端删除预览、下载、替换、删除/恢复、转码状态、权限原因、分享管理、使用关系、版本说明、错误恢复或审计入口。
- 虚拟键盘、横竖屏、低高度视口、播放器控制条、图片缩放、裁剪手柄、底部操作、安全区域和系统字体放大后，预览内容、文件状态、错误说明、下载、替换、保存裁剪、发布、删除、恢复、撤销分享或返回路径不可见且不可滚动到达。
- 真实浏览器预览、真实下载、真实播放器、真实裁剪、真实转码任务、真实权限切换、真实链接过期、真实 CDN 失效和真实移动端视口未执行时，不能写成已验证，必须标为未验证。
```

- [ ] **Step 6: Add GREEN evidence**

Create `docs/testing/files-media-assets/green-summary.md` with the positive evidence corresponding to every RED case and this command line:

```markdown
对应静态审计入口：`ruby docs/testing/files-media-assets/files-media-assets-audit.rb --mutations`。
```

- [ ] **Step 7: Run focused audit to verify GREEN**

Run:

```bash
ruby docs/testing/files-media-assets/files-media-assets-audit.rb --mutations
```

Expected: every named mutation prints `EXPECTED_FAIL: <name>`, then the audit prints a PASS line for files/media assets.

### Task 3: Verify adjacent owner boundaries and repository health

**Files:**
- No new files.
- Read and verify: `references/uploads-imports.md`, `references/exports-downloads-artifacts.md`, `references/complex-editors-builders.md`, `references/information-display.md`, `references/buttons.md`, `references/risk-actions.md`, `references/permissions-tenancy-visibility.md`, `references/async-jobs-task-center.md`, `references/feedback-states.md`, `references/global-feedback.md`, `references/responsive-adaptive.md`

**Interfaces:**
- Consumes: implemented owner and audit from Task 2
- Produces: verified working tree ready to commit

- [ ] **Step 1: Run adjacent executable audits**

Run:

```bash
ruby docs/testing/uploads-imports/uploads-imports-audit.rb --mutations
ruby docs/testing/exports-downloads-artifacts/exports-downloads-artifacts-audit.rb --mutations
ruby docs/testing/complex-editors-builders/complex-editors-builders-audit.rb --mutations
ruby docs/testing/information-display/information-display-audit.rb --mutations
ruby docs/testing/buttons/buttons-audit.rb --mutations
ruby docs/testing/risk-actions/risk-actions-audit.rb --mutations
ruby docs/testing/permissions-tenancy-visibility/permissions-tenancy-visibility-audit.rb --mutations
ruby docs/testing/async-jobs-task-center/async-jobs-task-center-audit.rb --mutations
ruby docs/testing/feedback-states/feedback-states-audit.rb --mutations
ruby docs/testing/global-feedback/global-feedback-audit.rb --mutations
```

Expected: all listed audits exit 0. If a path does not exist, inspect `docs/testing` with `rg --files docs/testing | rg '<owner-name>'` and run the actual matching audit; record any owner without an executable audit as “无独立可执行审计”.

- [ ] **Step 2: Run full owner audit collection**

Run the known-good collection command that skips historical data-table attempts:

```bash
for audit in docs/testing/*/*-audit.rb; do
  case "$audit" in
    docs/testing/data-tables/attempt-*) continue ;;
  esac
  ruby "$audit" || exit 1
done
```

Expected: exit 0 and includes the new files/media assets audit PASS line.

- [ ] **Step 3: Verify Markdown links**

Run:

```bash
ruby -e 'files = Dir["**/*.md"].reject { |f| f.start_with?(".worktrees/") }; missing = []; files.each { |file| text = File.read(file, encoding: "UTF-8"); text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each { |href| next if href =~ /\A[a-z][a-z0-9+.-]*:/i; path = href.split("#", 2).first; next if path.empty?; target = File.expand_path(path, File.dirname(file)); missing << "#{file}: #{href}" unless File.exist?(target) } }; abort(missing.join("\n")) unless missing.empty?; puts "PASS: markdown links resolve"'
```

Expected: `PASS: markdown links resolve`.

- [ ] **Step 4: Verify formatting and project-agnostic boundaries**

Run:

```bash
git diff --check
rg -n "fex-admin|/Users/evanqi/code/|src/pages|Ant Design|ant-design|shadcn|Next.js|Vite" references/files-media-assets.md docs/testing/files-media-assets SKILL.md README.md HANDOFF.md || true
```

Expected: `git diff --check` exits 0. The project-specific scan must not find those terms in the new owner or evidence files. Existing `HANDOFF.md` historical relationship notes may still mention the original business project; do not copy those terms into the new owner.

- [ ] **Step 5: Inspect final diff**

Run:

```bash
git diff --stat
git diff -- references/files-media-assets.md docs/testing/files-media-assets SKILL.md README.md HANDOFF.md | sed -n '1,260p'
```

Expected: diff contains only this owner, routing, summaries, evidence and audit changes.

### Task 4: Commit and push implementation

**Files:**
- Stage: `SKILL.md`, `README.md`, `HANDOFF.md`, `references/files-media-assets.md`, `docs/testing/files-media-assets`

**Interfaces:**
- Consumes: verified green state from Task 3
- Produces: pushed `main` commit

- [ ] **Step 1: Read completion skills before claiming done**

Read and follow:

```bash
sed -n '1,220p' /Users/evanqi/.codex/plugins/cache/openai-curated-remote/superpowers/6.2.0/skills/verification-before-completion/SKILL.md
sed -n '1,260p' /Users/evanqi/.codex/plugins/cache/openai-curated-remote/superpowers/6.2.0/skills/finishing-a-development-branch/SKILL.md
```

- [ ] **Step 2: Stage files**

Run:

```bash
git add SKILL.md README.md HANDOFF.md references/files-media-assets.md docs/testing/files-media-assets
```

- [ ] **Step 3: Commit**

Run:

```bash
git commit -m "docs: 新增文件媒体资产管理规范"
```

- [ ] **Step 4: Push**

Run:

```bash
git push origin main
```

- [ ] **Step 5: Confirm final state**

Run:

```bash
git status --short --branch
git log --oneline -1
```

Expected: `main...origin/main` with no uncommitted files and the latest commit is `docs: 新增文件媒体资产管理规范`.

## Self-Review

- Spec coverage: Task 1 covers executable audit design; Task 2 covers owner, routing, README, HANDOFF and RED/GREEN evidence; Task 3 covers adjacent owner boundaries, full owner collection, Markdown links, formatting and project-agnostic constraints; Task 4 covers verified commit and push.
- Scope check: This plan implements one owner only: files/media assets. It does not implement runtime UI components, storage/CDN behavior, upload protocols, media processing algorithms or business-project adoption.
- Type/name consistency: The plan uses one owner file name `references/files-media-assets.md`, one audit directory `docs/testing/files-media-assets`, one state name `assetState`, and the same fourteen state fields in Global Constraints, Task 1 and Task 2.
