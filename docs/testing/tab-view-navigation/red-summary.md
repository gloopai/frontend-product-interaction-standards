# Tab 视图导航规范 RED 复核

## 结论

RED 通过：新增审计在 owner 文件缺失时失败，证明当前仓库还没有独立的 Tab 视图导航 owner。

## 执行命令

`ruby docs/testing/tab-view-navigation/tab-view-navigation-audit.rb`

## 期望失败

`missing file: .../references/tab-view-navigation.md`

## 覆盖点

- tabViewState
- tabOwnerId、surfaceKind、tabRegistry、activeTabId、pendingTabIntent、panelState
- requestBinding、urlHistoryBinding、permissionBoundary、dirtyBoundary、focusAnnouncementPolicy、responsivePolicy
- activeTabId、pendingTabIntent、panelState、requestBinding、dirtyBoundary、permissionBoundary、responsivePolicy
- URL、懒加载、未保存保护、移动端
- 未验证

## 未验证

真实浏览器、键盘、屏幕阅读器、移动端、权限切换、网络迟到和未保存确认尚未执行；这些必须在业务项目接入时继续标为未验证。
