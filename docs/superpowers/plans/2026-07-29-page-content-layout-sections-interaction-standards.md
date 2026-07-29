# 页面内容区与 Section 布局交互规范实施计划

## 计划

1. 复核 Page Header、Toolbar、Responsive、Feedback、Admin、Information Display、Forms 和 Data Tables 的边界，确认新 owner 只负责页面正文布局与 Section/Card 编排。
2. 新增设计文档、RED 证据和 owner 规范文档。
3. 新增结构化审计脚本，并补 GREEN 证据。
4. 更新 `SKILL.md` 路由、`README.md` 摘要与目录、`HANDOFF.md` 交接说明，以及相邻 owner 的引用关系。
5. 运行 mutation、全量审计、Markdown 链接、diff check 和项目泄漏扫描后提交并推送。

## 交付边界

- 本次只处理通用 Skill 仓库，不处理任何业务项目接入。
- 文档、证据和审计均使用中文。
- 真实浏览器、键盘、读屏、触摸和视口检查未在本仓库执行时，必须保留“未验证”边界。
