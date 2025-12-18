# 命运大转盘 (Destiny Wheel)

基于 OpenHarmony 5.0 (API 12) 开发的极简决策转盘应用，适配进迭时空 K1 RISC-V 开发板。

## ✨ 特性
- **极简 UI**: 纯 Canvas 绘制，无图片资源依赖。
- **实心转盘**: 支持动态添加选项，自动计算扇形角度。
- **物理动画**: 使用 `FastOutSlowIn` 曲线模拟真实转盘阻尼感。
- **防误触**: 必须添加选项后才能开始转动。

## 🛠️ 开发环境
- **IDE**: DevEco Studio 5.0.5.310 
- **SDK**: OpenHarmony API 12 (Full SDK) 
- **Hardware**: SpacemiT K1 (RISC-V Architecture) 

## 🚀 快速开始
1. 克隆仓库: `git clone https://github.com/您的用户名/仓库名.git`
2. 使用 DevEco Studio 打开项目。
3.确保 `build-profile.json5` 中 `runtimeOS` 设置为 `OpenHarmony` 。
4. 连接 K1 设备或使用模拟器运行。
