# Tab 视图导航规范 GREEN 复核

## 结论

GREEN 通过：已新增 `references/tab-view-navigation.md`，并补齐路由、README、HANDOFF、相邻 owner 边界和 mutation 审计。

## 执行命令

`ruby docs/testing/tab-view-navigation/tab-view-navigation-audit.rb --mutations`

## 覆盖点

- tabViewState
- tabOwnerId、surfaceKind、tabRegistry、activeTabId、pendingTabIntent、panelState
- requestBinding、urlHistoryBinding、permissionBoundary、dirtyBoundary、focusAnnouncementPolicy、responsivePolicy
- activeTabId、pendingTabIntent、panelState、requestBinding、dirtyBoundary、permissionBoundary、responsivePolicy
- URL、懒加载、未保存保护、移动端
- 未验证

## 未验证

真实浏览器、键盘、屏幕阅读器、移动端、权限切换、网络迟到和未保存确认尚未执行；这些必须在业务项目接入时继续标为未验证。
