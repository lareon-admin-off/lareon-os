/* Lareon installer: the bar along the bottom (Calamares "navigation: qml,bottom").
   Cancel and Back on the left, Continue / Install on the right. */
import io.calamares.ui 1.0
import io.calamares.core 1.0

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: nav
    color: "#13111b"
    implicitHeight: 96
    height: 96

    // "&Next" -> "Next" (Calamares' labels carry keyboard-shortcut marks)
    function plain(label) { return label.replace(/&/g, "") }

    component LareonButton: Button {
        id: b
        property bool primary: false
        property bool ghost: false
        implicitHeight: 42
        leftPadding: 22
        rightPadding: 22
        hoverEnabled: true
        contentItem: Text {
            text: b.text
            color: !b.enabled ? "#74718a" : (b.primary ? "#13111b" : (b.ghost ? "#a7a4ba" : "#ece9f5"))
            font.family: "Geist"
            font.pixelSize: 15
            font.weight: b.primary ? Font.DemiBold : Font.Medium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 9
            color: b.ghost ? (b.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
                 : b.primary ? (!b.enabled ? "#2b2838" : (b.hovered ? "#ff8f3d" : "#ff7c1f"))
                 : (b.hovered ? "#2b2838" : "#211e2d")
            border.width: b.ghost || b.primary ? 0 : 1
            border.color: "#2b2838"
        }
    }

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -8
        width: Math.min(parent.width - 72, 1000)
        spacing: 10

        LareonButton {
            ghost: true
            text: nav.plain(ViewManager.quitLabel)
            visible: ViewManager.quitVisible && ViewManager.backAndNextVisible
            enabled: ViewManager.quitEnabled
            onClicked: ViewManager.quit()
        }
        LareonButton {
            ghost: true
            text: "‹  " + nav.plain(ViewManager.backLabel)
            visible: ViewManager.backAndNextVisible && ViewManager.backEnabled
            onClicked: ViewManager.back()
        }
        Item { Layout.fillWidth: true }
        LareonButton {
            primary: true
            text: nav.plain(ViewManager.nextLabel) + "  ›"
            visible: ViewManager.backAndNextVisible
            enabled: ViewManager.nextEnabled
            onClicked: ViewManager.next()
        }
    }
}
