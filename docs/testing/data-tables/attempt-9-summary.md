# Attempt 9 选择代次时序修复审计

## 结论

新批准的独立修复阶段只收紧 `selectionGeneration` 时序。Attempt 8 RAW 与历史审计器未修改；其 report-contract 仍稳定为 `135 records / 1 error`，A40 仍为 `144 records / 0 errors`。

## RED / GREEN

- RED：`ruby docs/testing/data-tables/attempt-9-selection-timing-audit.rb` 返回 exit 1，只报告 owner 报告契约缺少“意图接受先 +1 再启动异步”与“回调代次写入 0”。
- GREEN：最小修改 `DT-SEL-06`、`DT-REPORT-05.d`、对应 clause 与 A39 mutation 后，同一命令返回 `PASS selection timing owner contract`。
- fresh pressure：`fork_turns=none` 的独立 bulk 场景输出保存于 [attempt-9-bulk-action-table.md](attempt-9-bulk-action-table.md)。RAW payload 为 32031 字节，SHA-256 `d44a2aadfaca3000d8c54f74ff75b6bda7f1bc2892c407f0524e44da5d293094`；证据包装后的文件 SHA-256 为 `3176d88802de048b1cf30773b0355b45cd2a1e357cb79feb2704c4c7366a206d`。
- 应用审计：`ruby docs/testing/data-tables/attempt-9-selection-timing-audit.rb docs/testing/data-tables/attempt-9-bulk-action-table.md --mutations` 返回 exit 0；fresh 输出通过。晚递增 mutation 产生 4 个预期错误；固定行追加反义句和正文回调递增两个独立 mutation 各产生 1 个预期错误。
- A25 运行时契约：事件序列、预期状态和事件日志分别固定意图接受写入完成序号早于异步启动，以及每个协调回调 generation 写入为 0；owner contract 审计通过。
- 误报控制：两个合法 fixture 分别覆盖“回调只比较先前已递增代次”和“回调提交前只校验先前已递增代次”，均通过；检测只在回调作为递增施事或递增发生于回调返回/结束/提交时点时失败。

## 验证边界

相对链接、占位词检查和 `git diff --check` 通过。skill `quick_validate.py` 的系统 Python 缺少 `yaml`，因此该命令未能启动；这是验证环境依赖问题，不计作规范通过。浏览器、辅助技术、组件运行时和真实竞态仍未验证。
