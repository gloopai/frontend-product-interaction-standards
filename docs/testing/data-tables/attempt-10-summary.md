# Attempt 10 结构化选择代次契约总结

## 状态

`GREEN_STATIC_WITH_RUNTIME_UNVERIFIED`

三轮复核证明自由文本正则无法可靠裁决“谁在何时递增 selectionGeneration”。Attempt 10 将权威验收入口改为唯一九列结构化事件表；自由文本不再作为通过基础。

## RED

新增审计后、修改 owner 和证据前：

```text
ERROR OWNER selection generation event table count=0, expected=1
ERROR EVIDENCE selection generation event table count=0, expected=1
```

## GREEN

- 默认 GREEN 命令：`ruby docs/testing/data-tables/attempt-10-selection-event-audit.rb`，默认读取 Attempt 10 证据并返回 exit 0。
- owner 与 Attempt 10 证据均具有唯一九列表和四个 `actorPath/event` 唯一事件。
- 选择意图和资格变化均为 `generationWrite=+1`、整数 `sequence < asyncStartSequence`、`before-async-start`。
- 异步选择协调回调与操作结果均为 `generationWrite=0`，各自门禁和失配零写入可解析。
- 十五个 mutation 覆盖回调/意图写入、顺序、缺行、重复行、额外行、四类快照效果、record-only/垃圾字段门禁和两类矛盾 mismatch，均产生独立预期错误。
- 合法自由文本“回调比较意图接受时已经递增的代次”不改变结构化裁决并通过 control。

Attempt 8 RAW 与历史审计器未修改；Attempt 9 保留为自由文本审计架构的失败诊断，其旧 owner 断言会因 `DT-REPORT-05.d` 已切换为九列结构化契约而返回两个预期错误，不再作为当前 GREEN 门禁。浏览器、辅助技术、真实组件运行时和真实竞态仍未验证。官方 `quick_validate.py` 所用系统 Python 仍缺少 PyYAML，本阶段不安装依赖。
