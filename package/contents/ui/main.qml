import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager
import org.kde.plasma.workspace.dbus as DBus

PlasmoidItem {
    id: root

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    readonly property int iconSize: Math.max(1, Plasmoid.configuration.iconSize ?? 22)
    readonly property int tileHeight: Math.max(1, Plasmoid.configuration.tileHeight ?? 36)
    readonly property int tileMinWidth: Math.max(1, Plasmoid.configuration.tileMinWidth ?? 34)
    readonly property int tileRadius: Math.max(0, Plasmoid.configuration.tileRadius ?? 8)
    readonly property int tileSpacing: Math.max(0, Plasmoid.configuration.tileSpacing ?? 4)
    readonly property int iconSpacing: Math.max(0, Plasmoid.configuration.iconSpacing ?? 2)
    readonly property int maxIcons: Math.max(1, Plasmoid.configuration.maxIcons ?? 6)
    readonly property bool showNumbers: Plasmoid.configuration.showNumbers ?? true
    readonly property bool highlightCurrent: Plasmoid.configuration.highlightCurrent ?? true
    readonly property int inactiveOpacity: Plasmoid.configuration.inactiveOpacity ?? 72
    readonly property bool wheelSwitch: Plasmoid.configuration.wheelSwitch ?? true

    Plasmoid.icon: "virtual-desktops"

    TaskManager.VirtualDesktopInfo {
        id: vdi
        onCurrentDesktopChanged: root.refreshCurrent()
        onCurrentDesktopForScreenChanged: root.refreshCurrent()
        onDesktopIdsChanged: root.refreshCurrent()
    }

    WindowCollector {
        id: collector
    }

    readonly property bool screenAware: typeof vdi.currentDesktopByScreenGeometry === "function"
    property var activeDesktop: vdi.currentDesktop
    readonly property int currentIndex: vdi.desktopIds.indexOf(activeDesktop)
    readonly property int desktopCount: Math.max(1, vdi.desktopIds.length)

    Component.onCompleted: root.refreshCurrent()

    function refreshCurrent() {
        let desktop = vdi.currentDesktop;
        if (screenAware && Plasmoid.containment && Plasmoid.containment.screenGeometry) {
            const perScreen = vdi.currentDesktopByScreenGeometry(Plasmoid.containment.screenGeometry);
            if (perScreen !== undefined && perScreen !== null) desktop = perScreen;
        }
        activeDesktop = desktop;
    }

    function appsFor(desktopId) {
        return (collector.appsByDesktop[desktopId] || []).slice(0, root.maxIcons);
    }

    function tileWidthFor(index) {
        const all = collector.appsByDesktop[vdi.desktopIds[index]] || [];
        const shown = Math.min(all.length, root.maxIcons);
        const overflow = all.length > root.maxIcons ? 20 : 0;
        return Math.max(root.tileMinWidth,
                        14 + shown * root.iconSize
                        + Math.max(0, shown - 1) * root.iconSpacing + overflow);
    }

    function tilesWidth() {
        let width = 0;
        for (let i = 0; i < root.desktopCount; ++i) {
            width += root.tileWidthFor(i) + (i > 0 ? root.tileSpacing : 0);
        }
        return width;
    }

    function tilesHeight() {
        return root.desktopCount * root.tileHeight
               + Math.max(0, root.desktopCount - 1) * root.tileSpacing;
    }

    function switchTo(index) {
        if (index < 0 || index >= vdi.numberOfDesktops) return;
        DBus.SessionBus.asyncCall({
            service: "org.kde.KWin",
            path: "/KWin",
            iface: "org.kde.KWin",
            member: "setCurrentDesktop",
            arguments: [new DBus.int32(index + 1)]
        });
    }

    function step(delta) {
        const n = vdi.numberOfDesktops;
        if (n < 1) return;
        switchTo(((currentIndex + delta) % n + n) % n);
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Configure Virtual Desktops…")
            icon.name: "virtual-desktops"
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]

    preferredRepresentation: fullRepresentation

    fullRepresentation: MouseArea {
        id: view
        acceptedButtons: Qt.NoButton

        property int wheelDelta: 0
        onWheel: wheel => {
            if (!root.wheelSwitch) { wheel.accepted = false; return; }
            const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x;
            if (delta * wheelDelta < 0) wheelDelta = 0;
            wheelDelta += delta;
            while (wheelDelta >= 120) { wheelDelta -= 120; root.step(-1); }
            while (wheelDelta <= -120) { wheelDelta += 120; root.step(1); }
        }

        implicitWidth: root.vertical ? root.tileHeight : Math.max(root.tileHeight, root.tilesWidth())
        implicitHeight: root.vertical ? Math.max(root.tileHeight, root.tilesHeight()) : root.tileHeight
        Layout.minimumWidth: root.vertical ? 0 : implicitWidth
        Layout.minimumHeight: root.vertical ? implicitHeight : 0
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight

        Grid {
            id: grid
            anchors.centerIn: parent
            rows: root.vertical ? root.desktopCount : 1
            columns: root.vertical ? 1 : root.desktopCount
            spacing: root.tileSpacing

            Repeater {
                model: root.desktopCount
                delegate: DesktopTile {
                    readonly property var desktopId: vdi.desktopIds[index]
                    desktopIndex: index
                    apps: root.appsFor(desktopId)
                    totalCount: (collector.appsByDesktop[desktopId] || []).length
                    current: index === root.currentIndex

                    tileHeight: root.tileHeight
                    minWidth: root.tileMinWidth
                    iconSize: root.iconSize
                    iconSpacing: root.iconSpacing
                    cornerRadius: root.tileRadius
                    maxIcons: root.maxIcons
                    showNumber: root.showNumbers
                    highlightCurrent: root.highlightCurrent
                    inactiveOpacity: root.inactiveOpacity

                    onClicked: root.switchTo(index)
                }
            }
        }
    }
}
