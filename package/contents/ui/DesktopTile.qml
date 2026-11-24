import QtQuick
import org.kde.kirigami as Kirigami

/* One virtual desktop, drawn as a rounded rectangle containing app icons. */
Rectangle {
    id: tile

    property var desktopId: 0
    property int desktopIndex: 0
    property var apps: []
    property int totalCount: 0
    property bool current: false

    property int tileHeight: 36
    property int minWidth: 34
    property int iconSize: 22
    property int iconSpacing: 2
    property int cornerRadius: 8
    property int maxIcons: 6
    property bool showNumber: true
    property bool highlightCurrent: true
    property int inactiveOpacity: 72

    signal clicked()

    readonly property int horizontalPadding: 7
    readonly property bool overflow: totalCount > maxIcons
    width: Math.max(minWidth,
                    horizontalPadding * 2
                    + apps.length * iconSize
                    + Math.max(0, apps.length - 1) * iconSpacing
                    + (overflow ? 20 : 0))
    height: tileHeight
    radius: cornerRadius

    color: {
        const c = (current && highlightCurrent) ? Kirigami.Theme.highlightColor
                                                : Kirigami.Theme.backgroundColor;
        return Qt.rgba(c.r, c.g, c.b, (current && highlightCurrent) ? 0.32 : 0.62);
    }
    border.width: (current && highlightCurrent) ? 2 : 1
    border.color: (current && highlightCurrent) ? Kirigami.Theme.highlightColor
                                               : Qt.rgba(Kirigami.Theme.textColor.r,
                                                         Kirigami.Theme.textColor.g,
                                                         Kirigami.Theme.textColor.b, 0.35)
    opacity: (!highlightCurrent || current) ? 1 : inactiveOpacity / 100

    Behavior on opacity {
        NumberAnimation { duration: Kirigami.Units.shortDuration }
    }

    // Desktop number, kept subtle so the icons stay dominant.
    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 3
        anchors.topMargin: 1
        visible: tile.showNumber
        text: String(tile.desktopIndex + 1)
        color: Kirigami.Theme.textColor
        opacity: 0.55
        font.pixelSize: Math.max(8, Math.min(11, tile.tileHeight / 3.6))
    }

    Row {
        anchors.centerIn: parent
        spacing: tile.iconSpacing

        Repeater {
            model: tile.apps
            delegate: Kirigami.Icon {
                readonly property var app: modelData
                width: tile.iconSize
                height: tile.iconSize
                // QIcon from the window is most accurate; fall back to the app id.
                source: app.icon !== undefined && app.icon !== null ? app.icon : app.iconName
                opacity: app.minimized ? 0.55 : 1
            }
        }

        Text {
            visible: tile.overflow
            anchors.verticalCenter: parent.verticalCenter
            text: "+" + (tile.totalCount - tile.maxIcons)
            color: Kirigami.Theme.textColor
            font.pixelSize: Math.max(9, tile.iconSize * 0.55)
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.clicked()
    }
}
