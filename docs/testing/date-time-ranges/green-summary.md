# 日期时间与时区规范 GREEN 摘要

当前 GREEN 状态要求：

- `references/date-time-ranges.md` 已定义 `dateTimeState`，并覆盖 `dateTimeOwnerId`、`valueKind`、`inputMode`、`displayTimezone`、`storageTimezone`、`rangeBoundary`、`granularity`、`presetPolicy`、`relativeAnchor`、`validationState`、`urlSerialization`、`requestBinding` 和 `localePolicy`。
- owner 明确要求日期时间值声明展示时区、存储/请求时区、边界语义和粒度，并禁止不得使用含糊本地字符串。
- 范围推荐使用 `[start, end)`；`end < start`、部分范围、格式错误、DST、权限范围和不可选日期均进入可见错误。
- 快捷范围必须冻结应用时的 `relativeAnchor`；今天、昨天、本周、本月、近 7 天和近 30 天不得在同一已应用查询中随时间漂移。
- URL 只允许明确 `urlSafe` 的日期时间值，并要求格式版本、时区恢复和失效恢复路径。
- 报表、导出和审计必须携带范围快照、时区、数据延迟和刷新时间；英文路由包含 `data latency`。
- 移动端不得删除清空、重置、快捷范围、错误说明或时区说明；复杂控件可转换为 Bottom Drawer、Bottom Sheet 或独立页。
- `SKILL.md`、`README.md` 和 `HANDOFF.md` 均已接入 `references/date-time-ranges.md`。
- 本次是文档和静态审计更新，真实 UI 点击、键盘、滚动、视口、时区、DST 和请求绑定仍标为未验证。

审计命令：

```bash
ruby docs/testing/date-time-ranges/date-time-ranges-audit.rb --mutations
```
