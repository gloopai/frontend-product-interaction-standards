# 空态、无结果与首次使用引导规范 GREEN 复核

## 目标

证明新增 owner、路由和相邻规范转接完整可用。

## 通过条件

- `references/empty-first-run-zero-results.md` 声明 `emptyStateDecision`。
- owner 覆盖 firstRunEmpty、trueEmpty、zeroResults、permissionEmpty、errorEmpty、loadingEmpty、archivedEmpty、notConfiguredEmpty 和 readOnlyEmpty。
- zeroResults、首次使用、只读报表、权限空态和错误空态有不同 CTA 与恢复路径。
- 权限空态不泄露对象名称、数量、字段、筛选值、归档数量、文件名、金额、内部 ID 或旧可访问名称。
- SKILL、README、HANDOFF 和相邻 owner 均指向 `references/empty-first-run-zero-results.md`。
- 运行时验证未执行的项目保持“未验证”。

## 命令

```bash
ruby docs/testing/empty-first-run-zero-results/empty-first-run-zero-results-audit.rb
```

## 结果

审计通过，新增规范未包含项目专属泄露词。

