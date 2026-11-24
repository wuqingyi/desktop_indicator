# Virtual Desktop Indicator（KDE Plasma 6）

一个 Plasma 面板小部件：每个虚拟桌面显示为一个圆角矩形，矩形内显示该桌面上所有已打开程序的图标；当前桌面高亮，点击矩形即可切换。

## 特性

- 每个虚拟桌面一个圆角矩形，内含该桌面的应用图标（同一应用多个窗口去重）
- 当前桌面用主题强调色高亮，其他桌面半透明
- 点击切换桌面，鼠标滚轮也可以切换
- 悬停不弹出任何提示框
- 桌面数为 0 图标时仍保留最小宽度，方便定位
- 原生支持 Wayland（基于 `TaskManager`，不依赖 `wmctrl`/`xdotool`）
- 可配置：图标大小、矩形高度/圆角/间距、每桌面图标上限、编号显示、透明度

## 安装

```bash
chmod +x install.sh
./install.sh
```

脚本会把插件安装到 `~/.local/share/plasma/plasmoids/org.workbuddy.vdeskicons`，并自动加入第一个面板。
如果 Plasma 未运行，登录后从面板右键 → 添加小部件 → 搜索“Virtual Desktop Indicator”手动添加。
若通过脚本热添加后面板没有立即重排（新部件宽度为 0），重启 plasmashell 或重新登录即可正常显示。

## 卸载

```bash
kpackagetool6 --type=Plasma/Applet --remove org.workbuddy.vdeskicons
```

## 实现说明

- `TaskManager.VirtualDesktopInfo` 提供桌面 ID、名称和当前桌面
- `TaskManager.TasksModel`（关闭 `filterByVirtualDesktop`）枚举全部窗口，通过 `VirtualDesktops` 角色映射窗口到桌面
- 桌面切换调用 KWin D-Bus：`org.kde.KWin /KWin setCurrentDesktop <序号>`
- 目录结构符合 KPackage 的 `Plasma/Applet` 规范，可直接用 `kpackagetool6` 管理
