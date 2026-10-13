import QtQuick
import QtQuick.Layouts
import Lareon

// Step 5: the only choices that involve sharing anything.
Item {
    id: root
    property var setup

    component Row2: Item {
        id: r
        property string title
        property string detail
        property bool first: false
        default property alias control: slot.data
        Layout.fillWidth: true
        Layout.preferredHeight: 86
        Rectangle { visible: !r.first; width: parent.width; height: 1; color: Theme.lines }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 18
            Column {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    text: r.title
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 15.5
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    text: r.detail
                    wrapMode: Text.Wrap
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 13.8
                }
            }
            Item {
                id: slot
                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Your privacy")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            Layout.maximumWidth: 700
            wrapMode: Text.Wrap
            text: qsTr("Lareon OS doesn’t send anything about you. No ads, no tracking, no telemetry. These are the only choices that involve your data:")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 16.5
            lineHeight: 1.2
        }

        LCard {
            Layout.topMargin: 34
            Layout.fillWidth: true
            Layout.preferredHeight: 86 * 3
            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Row2 {
                    first: true
                    title: qsTr("Crash reports")
                    detail: qsTr("When an app closes unexpectedly. Reports stay on this computer and never include your files.")
                    Row {
                        spacing: 2
                        Repeater {
                            model: [["ask", qsTr("Ask each time")], ["never", qsTr("Never")]]
                            Rectangle {
                                width: label.implicitWidth + 24
                                height: 32
                                radius: 6
                                color: root.setup.crashReports === modelData[0] ? Theme.panel2 : Theme.bg
                                border.width: 1
                                border.color: root.setup.crashReports === modelData[0] ? Theme.lines : Theme.bg
                                Text {
                                    id: label
                                    anchors.centerIn: parent
                                    text: modelData[1]
                                    color: root.setup.crashReports === modelData[0] ? Theme.text : Theme.muted
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.setup.crashReports = modelData[0]
                                }
                            }
                        }
                    }
                }
                Row2 {
                    title: qsTr("Match dawn and dusk to real sunrise")
                    detail: qsTr("Uses your time zone only. Your location is never looked up.")
                    LToggle { checked: root.setup.followSun; onToggled: (on) => root.setup.followSun = on }
                }
                Row2 {
                    title: qsTr("Check for updates automatically")
                    detail: qsTr("Asks the Debian and Lareon update servers what’s new. Nothing about you is sent.")
                    LToggle { checked: root.setup.autoUpdates; onToggled: (on) => root.setup.autoUpdates = on }
                }
            }
        }
        Item { Layout.fillHeight: true }
    }
}
