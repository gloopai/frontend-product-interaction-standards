# Attempt 1 文本 RED 与根因诊断

## 失败样本

三份 `fork_turns=none` 输出在没有 RED 诊断或期望答案提示的情况下，系统性遗漏 prompt 未逐字点名的 owner 规则。最直接的结构错误来自 bulk 输出：

```ts
selectionSnapshot?: {
  selectionSnapshotId: string;
  sourceQuerySnapshotId: string;
  rangeKey: string;
  appliedFilters: AppliedFilter[];
  permissionScope: PermissionScope;
  datasetVersion?: string;
  eligibleTotal: number;
};
excludedIds: Set<RecordId>;
```

`excludedIds` 是 `SelectionState` 的 sibling，而不是不可变 `selectionSnapshot` 的字段。原 summary 误判为“完整快照”，现已在 [Attempt 1 失败汇总](attempt-1-summary.md)纠正。

## owner 文本 RED

修复前运行：

```bash
rg -n '完成前.*(适用|规则)|规则族.*(适用|不适用)|应用检查清单|不得因.*提示.*省略|输出契约' references/data-tables.md
```

结果：exit 1、无输出。现有 owner 声明自己是硬规则全集，并用 `A22` 检查 owner 文本的 clause 覆盖；但它没有约束“使用本规范定义/评审一个具体表格”时的答复形状或完成前检查行为。

## 根因

1. `SKILL.md` 只要求读取对应 reference，`references/data-tables.md` 只列硬规则；没有结构槽要求应用者逐规则族判定适用性。
2. 三名代理按用户 prompt 的章节组织长答复并主动压缩；prompt 未点名的筛选、列、实例隔离规则因没有完成前 gate 而被跳过。
3. `A22` 只证明 owner 自己没有 clause 缺口，不证明一个消费 owner 的设计/评审答复覆盖了所有适用规则。
4. `DT-SEL-03` 的“冻结……和空排除项”语义意图正确，但没有直说 `excludedIds` 是 `selectionSnapshot` 的内部字段；失败输出把行为规则写对却把状态归属拆错。
5. 第一轮回执只保存人工整理后的参数与 completion 摘要，没有逐字保存 dispatcher 的实际 spawn arguments、工具返回对象和 completion envelope，也没有声明换行归一化协议。

## 单一修复假设

如果 owner 增加一个正向“应用检查清单/完成前输出契约”，要求先声明能力与分页、按规则族给出适用/不适用及依据、把适用硬规则写入状态/快照/转换/DOM/键盘/生命周期/验证边界，并把局部决策标明归属，那么新鲜代理会在不向 dispatch prompt 泄露矩阵的情况下自行补齐。与此同时把 `excludedIds` 明确写为 `selectionSnapshot` 内部字段，可消除 sibling state 的歧义。

Attempt 2 用相同三类用户式 prompt 检验这个假设；任一适用维度仍遗漏即继续判失败。
