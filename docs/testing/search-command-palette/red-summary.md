# 搜索与命令面板 RED 证据摘要

这些负向场景必须被规范和审计识别为失败：

- 输入搜索草稿、hover suggestion、active result 或最近搜索高亮时直接导航或执行命令。
- `searchCommandState` 缺少 owner、草稿、已提交查询、结果快照、分组、active、命令绑定、权限、历史、快捷键、反馈、响应式或可访问性。
- 搜索草稿、active result、hover suggestion 和最近搜索高亮产生请求副作用，或者在没有明确提交搜索时改变导航、命令执行或已提交查询。
- 查询草稿、建议请求、结果请求、URL、标题、历史和来源上下文混用，导致未提交查询被当成已提交结果。
- 结果分组没有来源、对象类型、排序依据、权限边界或可执行动作。
- 会修改数据、权限、导出、任务、密钥或外部系统的命令绕过 `risk-actions.md`。
- 无权限结果显示对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存。
- loading、empty、zero-results、partial、stale、error 和 permission-denied 被合并成一个模糊状态。
- 搜索历史、最近搜索和保存搜索没有存储范围、清除路径、权限复核或敏感查询策略。
- 移动端不得删除查询输入这条规则被破坏，导致移动端删除提交、清空、结果分组、错误/权限说明、最近/保存搜索入口或恢复路径。
- AI search 把建议答案、候选结果、可执行命令和已执行结果混为一谈。
- 真实浏览器、触摸、快捷键、搜索服务、AI 服务、权限切换和移动端视口没有执行时，不能写成已验证，必须标为未验证。

对应静态审计入口：`ruby docs/testing/search-command-palette/search-command-palette-audit.rb --mutations`。
