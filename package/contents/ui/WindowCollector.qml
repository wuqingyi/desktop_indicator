import QtQuick
import org.kde.taskmanager as TaskManager

/*
 * Collects, for every virtual desktop, the list of applications that have a
 * window there. Uses the TaskManager model, which works on both X11 and
 * Wayland (no wmctrl/xdotool needed).
 *
 * Result shape: { <desktopId>: [ {key, appId, title, icon, iconName, active, minimized, count}, ... ] }
 */
Item {
    id: collector
    visible: false

    property var appsByDesktop: ({})

    TaskManager.TasksModel {
        id: tasks
        filterByVirtualDesktop: false
        filterByScreen: false
        filterByActivity: false
        filterMinimized: false
        groupMode: TaskManager.TasksModel.GroupDisabled

        onRowsInserted: refresh.restart()
        onRowsRemoved: refresh.restart()
        onModelReset: refresh.restart()
        onDataChanged: refresh.restart()
    }

    // Debounce: a single window change can emit several model signals.
    Timer {
        id: refresh
        interval: 120
        running: true
        onTriggered: collector.rebuild()
    }

    function rebuild() {
        const map = {};
        const R = TaskManager.AbstractTasksModel;

        for (let row = 0; row < tasks.count; ++row) {
            const idx = tasks.index(row, 0);
            if (!tasks.data(idx, R.IsWindow)) continue;
            // Windows pinned to all desktops would otherwise appear everywhere.
            if (tasks.data(idx, R.IsOnAllVirtualDesktops)) continue;

            const appId = tasks.data(idx, R.AppId) || "";
            const title = tasks.data(idx, Qt.DisplayRole) || appId || "?";
            const icon = tasks.data(idx, Qt.DecorationRole);
            const active = !!tasks.data(idx, R.IsActive);
            const minimized = !!tasks.data(idx, R.IsMinimized);
            const desktops = tasks.data(idx, R.VirtualDesktops) || [];
            const key = appId || title;

            for (const desktopId of desktops) {
                if (!map[desktopId]) map[desktopId] = [];
                const list = map[desktopId];
                const existing = list.find(app => app.key === key);
                if (existing) {
                    if (active) existing.active = true;
                    existing.count += 1;
                    continue;
                }
                list.push({
                    key: key,
                    appId: appId,
                    title: title,
                    icon: icon,
                    iconName: appId || title,
                    active: active,
                    minimized: minimized,
                    count: 1
                });
            }
        }
        appsByDesktop = map;
    }

    function appsFor(desktopId) {
        return appsByDesktop[desktopId] || [];
    }
}
