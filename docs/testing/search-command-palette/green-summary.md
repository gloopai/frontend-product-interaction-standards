# 搜索与命令面板 GREEN 证据摘要

当前规范和审计证明以下结构已经就位：

- `searchCommandState` 固定包含 owner、草稿、已提交查询、结果快照、分组、active、命令绑定、权限、历史、快捷键、反馈、响应式和可访问性。
- 搜索草稿、active result、hover suggestion 和最近搜索高亮不得触发导航、命令执行或请求副作用。
- 只有明确提交搜索或激活结果后，才能改变导航、执行命令或写入已提交查询。
- 结果分组必须声明来源、对象类型、排序依据、权限边界和可执行动作。
- 风险命令必须进入 `risk-actions.md`。
- 无权限结果不得泄露对象名称、数量、字段、摘要片段、文件名、内部 ID 或旧缓存。
- 搜索结果必须区分 loading、empty、zero-results、partial、stale、error 和 permission-denied。
- 搜索历史、最近搜索和保存搜索必须声明存储范围、清除路径、权限复核和敏感查询策略。
- 移动端不得删除查询输入、提交、清空、结果分组、错误/权限说明、最近/保存搜索入口或恢复路径。
- AI search 不得把建议答案、候选结果、可执行命令和已执行结果混为一谈。
- 真实浏览器、触摸、快捷键、搜索服务、AI 服务、权限切换和移动端视口仍是未验证。

对应静态审计入口：`ruby docs/testing/search-command-palette/search-command-palette-audit.rb --mutations`。
