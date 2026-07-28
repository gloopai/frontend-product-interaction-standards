# 按钮规范 GREEN 总结

GREEN 输出证明业务按钮被建模为独立 Button owner，而不是散落在 Form、Dialog、Table 或 Admin 文本中。审计命令：

```bash
ruby docs/testing/buttons/buttons-audit.rb --mutations
```

审计覆盖真实按钮语义、图标按钮名称、loading 名称、主按钮唯一、禁用原因、危险确认与回执、批量按钮快照、任务取消边界和移动端核心按钮可达性。

浏览器、屏幕阅读器、触摸设备和真实组件运行时未执行，保持未验证。

