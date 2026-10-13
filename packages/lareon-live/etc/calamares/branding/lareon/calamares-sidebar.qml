/* Lareon installer: the bar across the top (Calamares "sidebar: qml,top").
   Lareon mark, "Install Lareon OS", and the steps: Language, Keyboard, Drive, Install. */
import io.calamares.ui 1.0
import io.calamares.core 1.0

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: bar
    color: "#13111b"
    implicitHeight: 72
    height: 72

    // Calamares' own step names, in order, are Welcome, Keyboard, Partitions,
    // Install, Finish. Lareon names them by what the person does.
    readonly property var names: [qsTr("Language"), qsTr("Keyboard"), qsTr("Drive"), qsTr("Install")]

    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 36
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14
        Image {
            source: "file:/" + Branding.imagePath(Branding.ProductLogo)
            sourceSize.width: 68
            sourceSize.height: 68
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            fillMode: Image.PreserveAspectFit
        }
        Text {
            text: qsTr("Install %1").arg(Branding.string(Branding.ProductName))
            color: "#ece9f5"
            font.family: "Geist"
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 6
        Repeater {
            model: ViewManager
            Row {
                spacing: 6
                visible: index < bar.names.length
                readonly property bool done: index < ViewManager.currentStepIndex
                readonly property bool current: index === ViewManager.currentStepIndex
                Rectangle {
                    visible: index > 0
                    width: 22
                    height: 1.5
                    color: "#2b2838"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 22
                    height: 22
                    radius: 11
                    anchors.verticalCenter: parent.verticalCenter
                    color: parent.done ? "#211e2d" : (parent.current ? "#ff7c1f" : "transparent")
                    border.width: parent.done || parent.current ? 0 : 1.5
                    border.color: "#2b2838"
                    Text {
                        anchors.centerIn: parent
                        text: parent.parent.done ? "✓" : (index + 1)
                        color: parent.parent.current ? "#13111b" : "#a7a4ba"
                        font.family: "Geist"
                        font.pixelSize: 11.5
                        font.weight: Font.DemiBold
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: index < bar.names.length ? bar.names[index] : display
                    color: parent.current ? "#ece9f5" : (parent.done ? "#a7a4ba" : "#74718a")
                    font.family: "Geist"
                    font.pixelSize: 13
                    font.weight: parent.current ? Font.Medium : Font.Normal
                }
            }
        }
    }
}
