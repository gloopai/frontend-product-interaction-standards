# 折叠面板与 Disclosure 规范 RED 复核

## 结论

RED 通过：新增审计在 owner 文件缺失时失败，证明当前仓库还没有独立的折叠面板与 Disclosure owner。

## 执行命令

`ruby docs/testing/disclosure-accordions/disclosure-accordions-audit.rb`

## 期望失败

`missing file: .../references/disclosure-accordions.md`

## 覆盖点

- disclosureAccordionState
- disclosureOwnerId、surfaceKind、itemRegistry、expandedItemIds、expansionPolicy
- contentState、requestBinding、errorVisibilityBinding、permissionBoundary、persistenceBinding、focusAnnouncementPolicy、responsivePolicy
- expandedItemIds、expansionPolicy、contentState、requestBinding、errorVisibilityBinding、permissionBoundary、persistenceBinding、responsivePolicy
- 未验证

## 未验证

真实浏览器、键盘、屏幕阅读器、移动端、权限切换、懒加载迟到和表单提交尚未执行；这些必须在业务项目接入时继续标为未验证。
