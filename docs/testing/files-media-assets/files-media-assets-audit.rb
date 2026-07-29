#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../../..", __dir__)
OWNER = File.join(ROOT, "references/files-media-assets.md")
SKILL = File.join(ROOT, "SKILL.md")
README = File.join(ROOT, "README.md")
HANDOFF = File.join(ROOT, "HANDOFF.md")
GREEN = File.join(ROOT, "docs/testing/files-media-assets/green-summary.md")
RED = File.join(ROOT, "docs/testing/files-media-assets/red-summary.md")

STATE_FIELDS = %w[
  assetOwnerId assetIdentity assetLifecycle variantState previewPolicy
  downloadPolicy sharePolicy editPolicy publishPolicy usageBinding
  permissionBoundary retentionPolicy feedbackBinding responsivePolicy
].freeze

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

def integration_failures(skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(skill, ROUTE_TERMS, "SKILL route"))
  failures.concat(require_terms(readme, README_TERMS, "README"))
  failures.concat(require_terms(handoff, HANDOFF_TERMS, "HANDOFF"))
  failures.concat(require_terms(green, EVIDENCE_TERMS, "GREEN evidence"))
  failures.concat(require_terms(red, EVIDENCE_TERMS, "RED evidence"))
  failures
end

def project_leak_failures(texts)
  PROJECT_BANNED_TERMS.flat_map do |term|
    texts.select { |label, text| text.include?(term) }.map { |label, _text| "#{label}: forbidden project-specific term #{term}" }
  end
end

def audit(owner:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(owner_failures(owner))
  failures.concat(integration_failures(skill: skill, readme: readme, handoff: handoff, green: green, red: red))
  failures.concat(project_leak_failures("owner" => owner, "green" => green, "red" => red))
  failures
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

owner = read(OWNER)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  expect_failure("missing-owner-state") do
    audit(owner: owner.gsub("assetState", "asset-state"),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("upload-complete-as-ready") do
    audit(owner: owner.gsub("上传成功只能说明文件内容或引用进入系统", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("thumbnail-as-permission-proof") do
    audit(owner: owner.gsub("缩略图、预览图、播放器 poster、PDF 首页图、波形图和已缓存媒体片段不能作为权限证明", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-leakage-preview") do
    audit(owner: owner.gsub("无权限状态不得泄露文件名、缩略图、预览内容、尺寸、时长、页数、波形、字幕、EXIF、内部 ID、路径、引用关系、分享范围、下载 URL、CDN URL、错误明细、旧缓存或旧可访问名称", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("asset-version-missing") do
    audit(owner: owner.gsub("资产必须区分资产版本、文件版本、预览版本、缩略图版本、裁剪版本、转码版本、发布版本、CDN 版本和分享链接版本", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("old-url-survives") do
    audit(owner: owner.gsub("旧预览 URL、旧下载 URL、旧分享链接、旧 CDN 地址、旧缩略图、旧播放器状态、旧复制内容、旧焦点目标和旧 ARIA 引用必须失效或重新证明安全", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("merged-asset-intents") do
    audit(owner: owner.gsub("替换文件、重命名、改描述、改分类、裁剪图片、旋转图片、重新转码、重新生成缩略图、发布、下架、撤销发布、删除、恢复和永久删除必须是不同意图", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("crop-as-publish") do
    audit(owner: owner.gsub("裁剪成功不等于保存成功", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("transcode-job-as-complete") do
    audit(owner: owner.gsub("转码任务创建不等于转码完成", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("delete-as-purged") do
    audit(owner: owner.gsub("删除请求发送不等于文件已不可恢复", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("unknown-usage-as-empty") do
    audit(owner: owner.gsub("无法完整证明引用关系时，不能把“未发现引用”写成“没有引用”", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-only-share-link") do
    audit(owner: owner.gsub("复制分享链接不能只 Toast", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("retention-boundary-missing") do
    audit(owner: owner.gsub("删除、归档、移入回收站、恢复、永久删除和法务保留必须分开表达", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-core-asset-actions-removed") do
    audit(owner: owner.gsub("移动端不得删除预览、下载、替换、删除/恢复、转码状态、权限原因、分享管理、使用关系、版本说明、错误恢复和审计入口", ""),
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), skill: skill, readme: readme,
          handoff: handoff.gsub("未验证", "已验证"), green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin", skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 文件与媒体资产管理规范符合结构化审计契约。"
