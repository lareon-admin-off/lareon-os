import QtQuick
import QtQuick.Layouts
import Lareon

// Step 4: installing. One big bar; the step name and the percentage.
Item {
    id: root
    property var install

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -40
        width: parent.width
        spacing: 0

        LIcon {
            Layout.alignment: Qt.AlignHCenter
            size: 96
            source: Theme.logo
        }
        Text {
            Layout.topMargin: 26
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Installing Lareon OS")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 38
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignHCenter
            text: root.install.stepText
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }

        Rectangle {
            Layout.topMargin: 34
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 560
            Layout.preferredHeight: 10
            radius: 5
            color: Theme.panel2
            clip: true
            Rectangle {
                height: parent.height
                radius: 5
                width: Math.max(10, parent.width * root.install.percent)
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Theme.accent }
                    GradientStop { position: 1.0; color: Theme.magenta }
                }
                Behavior on width { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
            }
        }
        Text {
            Layout.topMargin: 14
            Layout.alignment: Qt.AlignHCenter
            text: Math.round(root.install.percent * 100) + "%"
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 15
            font.weight: Font.Medium
        }
        Text {
            Layout.topMargin: 26
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("This takes a few minutes. Keep your computer plugged in.")
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 14
        }
    }
}
