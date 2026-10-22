import QtQuick
import QtQuick.Layouts
import Lareon

// Before anything else: what Lareon OS will never do.
Item {
    id: root
    property var install
    property real shown: 0

    onVisibleChanged: if (visible) { shown = 0; reveal.restart() }
    NumberAnimation { id: reveal; target: root; property: "shown"; from: 0; to: 3.4; duration: 1700; easing.type: Easing.Linear }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Our promise to you")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            text: qsTr("Lareon OS is built to stay out of your way, and out of your business.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }

        RowLayout {
            Layout.topMargin: 36
            Layout.fillWidth: true
            spacing: 16
            Repeater {
                model: [
                    { icon: "promise-telemetry", title: qsTr("No telemetry"), text: qsTr("Lareon OS never sends usage data, crash reports or a device ID anywhere.") },
                    { icon: "promise-shield", title: qsTr("No ads, no tracking"), text: qsTr("Nothing in the system watches what you do or tries to sell you something.") },
                    { icon: "promise-lock", title: qsTr("Yours to keep"), text: qsTr("Your files stay on this computer. Nothing leaves unless you send it.") }
                ]
                delegate: LCard {
                    required property int index
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 270
                    opacity: Math.max(0, Math.min(1, root.shown - index * 0.8))
                    transform: Translate { y: (1 - Math.max(0, Math.min(1, root.shown - index * 0.8))) * 24 }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 0
                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 60
                            radius: 30
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: index === 0 ? "#ff7c1f" : (index === 1 ? "#d94fc4" : "#a35cf5") }
                                GradientStop { position: 1.0; color: index === 0 ? "#d94fc4" : (index === 1 ? "#a35cf5" : "#ff7c1f") }
                            }
                            LIcon { anchors.centerIn: parent; size: 30; source: "file:///usr/share/lareon/ui/" + modelData.icon + ".svg" }
                        }
                        Text {
                            Layout.topMargin: 22
                            text: modelData.title
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                        }
                        Text {
                            Layout.topMargin: 10
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            text: modelData.text
                            color: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 15
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
        Item { Layout.fillHeight: true }
    }
}
