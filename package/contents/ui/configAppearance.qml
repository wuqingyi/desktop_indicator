import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property int cfg_iconSize
    property int cfg_tileHeight
    property int cfg_tileMinWidth
    property int cfg_tileRadius
    property int cfg_tileSpacing
    property int cfg_iconSpacing
    property int cfg_maxIcons
    property bool cfg_showNumbers
    property bool cfg_highlightCurrent
    property int cfg_inactiveOpacity
    property bool cfg_wheelSwitch

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: iconSizeSpin
            Kirigami.FormData.label: i18n("Icon size:")
            from: 12; to: 48; stepSize: 1
            value: page.cfg_iconSize
            onValueModified: page.cfg_iconSize = value
        }
        QQC2.SpinBox {
            id: tileHeightSpin
            Kirigami.FormData.label: i18n("Tile height:")
            from: 24; to: 64; stepSize: 1
            value: page.cfg_tileHeight
            onValueModified: page.cfg_tileHeight = value
        }
        QQC2.SpinBox {
            id: tileMinWidthSpin
            Kirigami.FormData.label: i18n("Minimum tile width:")
            from: 20; to: 96; stepSize: 1
            value: page.cfg_tileMinWidth
            onValueModified: page.cfg_tileMinWidth = value
        }
        QQC2.SpinBox {
            id: radiusSpin
            Kirigami.FormData.label: i18n("Corner radius:")
            from: 0; to: 24; stepSize: 1
            value: page.cfg_tileRadius
            onValueModified: page.cfg_tileRadius = value
        }
        QQC2.SpinBox {
            id: tileSpacingSpin
            Kirigami.FormData.label: i18n("Tile spacing:")
            from: 0; to: 24; stepSize: 1
            value: page.cfg_tileSpacing
            onValueModified: page.cfg_tileSpacing = value
        }
        QQC2.SpinBox {
            id: iconSpacingSpin
            Kirigami.FormData.label: i18n("Icon spacing:")
            from: 0; to: 16; stepSize: 1
            value: page.cfg_iconSpacing
            onValueModified: page.cfg_iconSpacing = value
        }
        QQC2.SpinBox {
            id: maxIconsSpin
            Kirigami.FormData.label: i18n("Icons per tile:")
            from: 1; to: 16; stepSize: 1
            value: page.cfg_maxIcons
            onValueModified: page.cfg_maxIcons = value
        }
        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Desktop number:")
            text: i18n("Show number in the corner")
            checked: page.cfg_showNumbers
            onToggled: page.cfg_showNumbers = checked
        }
        QQC2.CheckBox {
            text: i18n("Highlight the current desktop")
            checked: page.cfg_highlightCurrent
            onToggled: page.cfg_highlightCurrent = checked
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Inactive opacity:")
            from: 20; to: 100; stepSize: 1
            suffix: "%"
            value: page.cfg_inactiveOpacity
            onValueModified: page.cfg_inactiveOpacity = value
        }
        QQC2.CheckBox {
            text: i18n("Switch desktops with the mouse wheel")
            checked: page.cfg_wheelSwitch
            onToggled: page.cfg_wheelSwitch = checked
        }
    }
}
