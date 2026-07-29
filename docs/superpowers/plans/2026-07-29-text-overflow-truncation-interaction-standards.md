# 文本溢出与截断交互规范实施计划

## 计划

1. 复核信息展示、字段说明、响应式、浮层、表格、卡片、按钮和反馈规范里的长文本职责边界。
2. 新增 `references/text-overflow-truncation.md`，定义 `textOverflowState`、禁止项、内容类型、全文恢复、复制、移动端、权限和生命周期规则。
3. 补充 `SKILL.md` 自动触发路由。
4. 补充 `README.md` 与 `HANDOFF.md` 摘要。
5. 在相邻 owner 中加入到 `references/text-overflow-truncation.md` 的互操作引用。
6. 新增 RED/GREEN 证据和 `docs/testing/text-overflow-truncation/text-overflow-truncation-audit.rb`。
7. 运行专项 mutation 审计、全量审计、Markdown 链接检查、`git diff --check` 和项目泄露扫描。

## 通过标准

- 所有新增文档为中文。
- 规范不包含具体项目、技术栈或组件库绑定。
- 审计脚本可证明关键语义缺失会失败。
- 全量既有审计继续通过。
