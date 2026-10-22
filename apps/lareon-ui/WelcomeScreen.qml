import QtQuick
import QtQuick.Layouts
import Lareon

// First thing on the install disc: install Lareon OS, or just try it.
// Exits with code 10 for "install"; any other exit means "try".
Item {
    id: root
    focus: true
    Keys.onReturnPressed: Sys.quit(10)
    Keys.onEnterPressed: Sys.quit(10)

    Scene { anchors.fill: parent }

    TopBar {
        id: top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        title: qsTr("Lareon OS")
    }

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -10
        spacing: 0
        opacity: 0
        Component.onCompleted: rise.start()
        NumberAnimation on opacity { id: rise; running: false; to: 1; duration: 700; easing.type: Easing.OutCubic }

        LIcon {
            Layout.alignment: Qt.AlignHCenter
            size: 72
            source: Theme.logo
        }
        GradientText {
            Layout.topMargin: 16
            Layout.alignment: Qt.AlignHCenter
            text: "Lareon OS"
            pixelSize: 76
        }
        Text {
            Layout.topMargin: 6
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("What would you like to do?")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 20
        }

        RowLayout {
            Layout.topMargin: 44
            Layout.alignment: Qt.AlignHCenter
            spacing: 22

            Repeater {
                model: [
                    { key: "install", icon: "welcome-install", title: qsTr("Install Lareon OS"), text: qsTr("Put Lareon OS on this computer. It takes about ten minutes."), primary: true },
                    { key: "try", icon: "welcome-try", title: qsTr("Try Lareon OS"), text: qsTr("Look around first. Nothing on this computer is changed."), primary: false }
                ]
                delegate: LCard {
                    id: card
                    required property var modelData
                    Layout.preferredWidth: 330
                    Layout.preferredHeight: 250
                    selected: modelData.primary || hov.hovered
                    scale: hov.hovered ? 1.02 : 1
                    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                    HoverHandler { id: hov; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: Sys.quit(card.modelData.primary ? 10 : 0) }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 26
                        spacing: 0
                        Rectangle {
                            Layout.preferredWidth: 64
                            Layout.preferredHeight: 64
                            radius: 32
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: card.modelData.primary ? "#ff7c1f" : "#a35cf5" }
                                GradientStop { position: 1.0; color: card.modelData.primary ? "#d94fc4" : "#d94fc4" }
                            }
                            LIcon { anchors.centerIn: parent; size: 32; source: "file:///usr/share/lareon/ui/" + card.modelData.icon + ".svg" }
                        }
                        Text {
                            Layout.topMargin: 22
                            text: card.modelData.title
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 23
                            font.weight: Font.DemiBold
                        }
                        Text {
                            Layout.topMargin: 8
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            text: card.modelData.text
                            color: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 15
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        text: qsTr("Trouble with the screen? Restart and hold Esc at start-up for more options.")
        color: Theme.faint
        font.family: Theme.font
        font.pixelSize: 13
    }
}
