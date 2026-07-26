# Attempt 9 前置 RED：选择代次递增时序

## 单一假设

`DT-SEL-06.a` 已要求每个被接受的选择意图令 `selectionGeneration` 恰好加一，但 `DT-REPORT-05.d` 没有把“意图接受时先递增、再启动异步工作、回调自身不递增”固定到选择代次契约表。因此应用答复可以保留四项提交门禁和失配零写入，同时把递增推迟到结果返回后。

## RED 命令

```sh
ruby docs/testing/data-tables/attempt-9-selection-timing-audit.rb
```

修复前应稳定返回 exit 1，并只报告报告契约缺少上述两个时序约束。Attempt 8 RAW 不参与修改。

实际 RED：exit 1；错误为 `missing intent-accept +1 before async start` 与 `missing callback generationWrite=0`。修复后同一命令返回 `PASS selection timing owner contract`。

## 独立复核后的第二轮 RED

复核指出首版审计只看固定行且反义模式过窄。先加入两个互相独立的 mutation：在正确行后追加“但是回调随后递增 selectionGeneration”，以及在正文其他位置声明回调递增；两者在修复前均 `unexpectedly passed`。同时新增 A25 owner contract 断言，修复前准确报告缺少“代次写入严格先于异步启动”及“回调 generation 写入为 0”两项运行时断言。

审计随后按语义子句扫描固定行与全文：明确的“意图接受 +1 后启动异步”不计作回调递增，具有回调主语、`selectionGeneration` 和正向递增效果且没有零写入/禁止语义的子句计作矛盾。A25 最小补入事件顺序、预期状态和事件日志断言。

## Scoped rereview pass-control

复核继续指出“回调比较其捕获的、在选择意图接受时已经递增的 selectionGeneration”可能被粗粒度关键词扫描误报。先加入两个合法 fixture：回调只比较先前代次，以及回调提交前只校验先前代次；旧检测器均错误拒绝。修复后仅当回调是递增动作施事，或递增明确发生在回调返回、结束、提交时点时才拒绝；先前意图递增的定语/校验描述被识别为合法归因。两个 pass-control 均通过，M9/M10/M11 仍全部失败。
