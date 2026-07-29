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

STATE_FIELDS = %w[
  attachmentSubmissionOwnerId contentDraftBinding inputSourcePolicy
  localAttachmentDrafts uploadBinding submitSnapshot sendPolicy
  postSubmitState revisionPolicy permissionBoundary feedbackBinding
  responsivePolicy
].freeze

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

RELATIONSHIP_TERMS = [
  "references/user-attachment-submission.md",
  "user-attachment-submission.md"
].freeze

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

def read(path)
  abort("missing file: #{path}") unless File.file?(path)

  File.read(path, encoding: "UTF-8")
end

def require_terms(text, terms, label)
  terms.reject { |term| text.include?(term) }.map { |term| "#{label}: missing #{term}" }
end

def owner_failures(owner)
  failures = []
  STATE_FIELDS.each do |field|
    failures << "owner: attachmentSubmissionState missing #{field}" unless owner.include?(field)
  end
  failures.concat(require_terms(owner, OWNER_TERMS, "owner"))
  failures
end

def integration_failures(uploads:, assets:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(require_terms(uploads, RELATIONSHIP_TERMS, "uploads relationship"))
  failures.concat(require_terms(assets, RELATIONSHIP_TERMS, "assets relationship"))
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

def audit(owner:, uploads:, assets:, skill:, readme:, handoff:, green:, red:)
  failures = []
  failures.concat(owner_failures(owner))
  failures.concat(integration_failures(uploads: uploads, assets: assets, skill: skill, readme: readme,
                                       handoff: handoff, green: green, red: red))
  failures.concat(project_leak_failures("owner" => owner, "green" => green, "red" => red))
  failures
end

def expect_failure(name)
  failures = yield
  abort("mutation did not fail: #{name}") if failures.empty?

  puts "EXPECTED_FAIL: #{name}"
end

owner = read(OWNER)
uploads = read(UPLOADS)
assets = read(ASSETS)
skill = read(SKILL)
readme = read(README)
handoff = read(HANDOFF)
green = read(GREEN)
red = read(RED)

failures = audit(owner: owner, uploads: uploads, assets: assets, skill: skill, readme: readme,
                 handoff: handoff, green: green, red: red)
unless failures.empty?
  warn failures.join("\n")
  exit 1
end

if ARGV.include?("--mutations")
  expect_failure("missing-owner-state") do
    audit(owner: owner.gsub("attachmentSubmissionState", "attachment-submission-state"), uploads: uploads,
          assets: assets, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("upload-success-as-content-success") do
    audit(owner: owner.gsub("上传成功只能说明文件引用可用于当前提交候选", "")
                      .gsub("不能自动说明消息已发送、评论已发布、头像已生效、内容已审核通过或资产已入库", ""),
          uploads: uploads, assets: assets, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("avatar-crop-as-effective") do
    audit(owner: owner.gsub("裁剪成功不等于头像已生效", ""), uploads: uploads, assets: assets,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("send-button-reads-local-name") do
    audit(owner: owner.gsub("发送按钮不得只读取“是否有本地文件名”", ""), uploads: uploads, assets: assets,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-send-freeze") do
    audit(owner: owner.gsub("发送时冻结附件项身份和上传引用候选", ""), uploads: uploads, assets: assets,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("duplicate-message-allowed") do
    audit(owner: owner.gsub("不能生成重复消息、重复评论、重复工单、重复头像更新或重复投稿", ""),
          uploads: uploads, assets: assets, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("late-result-writes-new-draft") do
    audit(owner: owner.gsub("本地文件 A 被替换为文件 B 后，A 的裁剪、压缩、上传或扫描迟到结果不得写入 B", ""),
          uploads: uploads, assets: assets, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("pre-send-delete-deletes-sent") do
    audit(owner: owner.gsub("发送前删除附件只删除当前草稿的附件项和上传候选", ""), uploads: uploads,
          assets: assets, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("post-send-delete-boundary-missing") do
    audit(owner: owner.gsub("发送后删除附件、撤回附件或编辑附件必须声明影响内容版本、附件可见性、审计、接收方已读状态、通知状态和恢复边界", ""),
          uploads: uploads, assets: assets, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("message-attachment-state-merged") do
    audit(owner: owner.gsub("文本发送成功但附件失败、附件上传成功但文本发送失败、部分附件失败、内容进入审核、服务端未知结果、离线队列等待发送和接收方无权查看附件都必须是可区分状态", ""),
          uploads: uploads, assets: assets, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("permission-zero-entry-missing") do
    audit(owner: owner.gsub("无权或未启用时，附件选择、相机/相册、录音录像、粘贴、拖拽、预览、上传、发送、重试、删除、撤回、下载和查看原图的 DOM、state、handler、request 和快捷键入口为 0", ""),
          uploads: uploads, assets: assets, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("attachment-privacy-leakage") do
    audit(owner: owner.gsub("附件预览、文件名、缩略图、EXIF、语音时长、视频时长、地理位置、内部 ID、下载链接、错误明细和旧缓存都不得在无权限、被删除、已撤回、被审核拦截或会话失效状态下泄露", ""),
          uploads: uploads, assets: assets, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("mobile-core-attachment-actions-removed") do
    audit(owner: owner.gsub("移动端不得删除相机、相册、文件选择、录音录像、附件预览、文件级错误、上传进度、删除/替换、重试、发送状态、离开保护、权限原因、失败恢复和已发送附件状态", ""),
          uploads: uploads, assets: assets, skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("toast-only-attachment-error") do
    audit(owner: owner.gsub("附件错误不能只挂在缩略图红框或 Toast", ""), uploads: uploads, assets: assets,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("duplicate-announcement-owner") do
    audit(owner: owner.gsub("同一完整错误消息只能由一个 primary owner 播报", ""), uploads: uploads, assets: assets,
          skill: skill, readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("runtime-boundary-marked-verified") do
    audit(owner: owner.gsub("未验证", "已验证"), uploads: uploads, assets: assets, skill: skill,
          readme: readme, handoff: handoff.gsub("未验证", "已验证"),
          green: green.gsub("未验证", "已验证"), red: red.gsub("未验证", "已验证"))
  end

  expect_failure("missing-route") do
    audit(owner: owner, uploads: uploads, assets: assets, skill: skill.gsub("references/user-attachment-submission.md", ""),
          readme: readme, handoff: handoff, green: green, red: red)
  end

  expect_failure("missing-adjacent-owner-link") do
    audit(owner: owner, uploads: uploads.gsub("user-attachment-submission.md", ""),
          assets: assets.gsub("user-attachment-submission.md", ""), skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end

  expect_failure("project-specific-leakage") do
    audit(owner: "#{owner}\nfex-admin", uploads: uploads, assets: assets, skill: skill, readme: readme,
          handoff: handoff, green: green, red: red)
  end
end

puts "PASS: 用户侧附件与内容提交上传规范符合结构化审计契约。"
