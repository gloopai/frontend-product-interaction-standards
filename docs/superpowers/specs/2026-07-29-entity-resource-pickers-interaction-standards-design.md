# 对象、资源与成员选择器交互规范设计

## 目标

新增一个高频管理台 owner，专门约束对象、资源、成员、负责人、审批人、账号、项目、工作区和关联记录选择器，避免这类控件被误当成普通 Select，从而出现身份混淆、旧缓存提交、权限泄露、跨范围绑定和移动端能力缺失。

## 推荐方案

采用独立 `references/entity-resource-pickers.md` owner，并在 Select、多选、表单、权限、成员、审批、记录编辑和树形结构等相邻规范中建立交叉引用。这个方案比继续加厚 Select 更清晰：Select 负责输入和弹层机制，新 owner 负责业务实体身份、可绑定性、权限与 scope。

## 状态模型

新增 `entityResourcePickerState`，强制分离 `committedSelection`、`draftSelection`、`queryState`、`candidateResults`、`recentAndSuggested`、`identityResolution`、`availabilityMap`、`permissionBoundary`、`scopeBinding`、`bindingPolicy`、`requestIdentity`、`feedbackBinding`、`responsivePolicy`、`focusAnnouncementPolicy` 和 `lifecycleDisposal`。

核心原则是：display label 不是对象身份；最近项、推荐项、搜索结果和已选实体必须分层；跨租户/工作区/账号/项目边界必须先证明可见且可绑定。

## 验收边界

审计脚本需要覆盖 owner、SKILL 路由、README、HANDOFF、相邻规范引用、负向变异和项目泄漏扫描。运行时真实浏览器、键盘、读屏、触摸、权限切换和移动端视口如未执行，必须明确标为未验证。

## 自检

- 无 TBD、TODO 或占位描述。
- 范围聚焦选择器 owner，不修改业务项目实现。
- 与现有 Select、多选、权限、成员和审批 owner 的职责边界不冲突。
