import QtQuick
import QtQuick.Layouts
import Lareon

// After the account is made: three quick pictures of what Lareon OS is like.
Item {
    id: root
    property var setup
    property int slide: 0
    readonly property var slides: [
        { title: qsTr("Everything in one place"), text: qsTr("Lareon Home puts your apps, search and settings one click away. Press the Meta key any time.") },
        { title: qsTr("Settings that do the job"), text: qsTr("Wi-Fi, sound, display, power, keyboard and more, in one calm window. No hunting through menus.") },
        { title: qsTr("Private by default"), text: qsTr("No telemetry, no ads, no tracking. Lareon OS only talks to the internet when you ask it to.") }
    ]

    Timer {
        interval: 6000
        running: root.visible && root.StackLayout.isCurrentItem
        repeat: true
        onTriggered: root.slide = (root.slide + 1) % root.slides.length
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("A quick look around")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }

        Item {
            Layout.topMargin: 28
            Layout.fillWidth: true
            Layout.preferredHeight: 270

            // slide 0: Lareon Home
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 520
                height: 260
                radius: 16
                color: Theme.panel
                border.width: 1
                border.color: Theme.lines
                opacity: root.slide === 0 ? 1 : 0
                scale: root.slide === 0 ? 1 : 0.96
                visible: opacity > 0.01
                Behavior on opacity { NumberAnimation { duration: 350 } }
                Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
                Rectangle { x: 20; y: 18; width: parent.width - 40; height: 34; radius: 17; color: Theme.panel2; border.width: 1; border.color: Theme.lines
                    Text { x: 16; anchors.verticalCenter: parent.verticalCenter; text: qsTr("Search apps and files"); color: Theme.faint; font.family: Theme.font; font.pixelSize: 13 } }
                Grid {
                    x: 20
                    y: 70
                    columns: 5
                    spacing: 18
                    Repeater {
                        model: [qsTr("Files"), qsTr("Ember"), qsTr("Mail"), qsTr("Notes"), qsTr("Music"), qsTr("Photos"), qsTr("Terminal"), qsTr("Settings"), qsTr("Software"), qsTr("Lareon")]
                        delegate: Column {
                            required property int index
                            required property string modelData
                            spacing: 6
                            Rectangle {
                                width: 52
                                height: 52
                                radius: 15
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: index % 3 === 0 ? "#ff7c1f" : (index % 3 === 1 ? "#d94fc4" : "#a35cf5") }
                                    GradientStop { position: 1.0; color: index % 3 === 0 ? "#d94fc4" : (index % 3 === 1 ? "#a35cf5" : "#ff7c1f") }
                                }
                                opacity: 0.9
                            }
                            Text { width: 52; horizontalAlignment: Text.AlignHCenter; text: modelData; color: Theme.muted; font.family: Theme.font; font.pixelSize: 11; elide: Text.ElideRight }
                        }
                    }
                }
            }

            // slide 1: Settings
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 520
                height: 260
                radius: 16
                color: Theme.panel
                border.width: 1
                border.color: Theme.lines
                clip: true
                opacity: root.slide === 1 ? 1 : 0
                scale: root.slide === 1 ? 1 : 0.96
                visible: opacity > 0.01
                Behavior on opacity { NumberAnimation { duration: 350 } }
                Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
                Rectangle { width: parent.width; height: 3; gradient: Gradient { orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Theme.accent } GradientStop { position: 0.6; color: Theme.magenta } GradientStop { position: 1.0; color: Theme.violet } } }
                Column {
                    x: 12
                    y: 16
                    spacing: 5
                    Repeater {
                        model: [qsTr("Appearance"), qsTr("Display"), qsTr("Sound"), qsTr("Network"), qsTr("Power")]
                        delegate: Rectangle {
                            required property int index
                            required property string modelData
                            width: 130
                            height: 34
                            radius: 11
                            color: index === 0 ? Qt.rgba(1, 0.486, 0.122, 0.18) : "transparent"
                            Text { x: 12; anchors.verticalCenter: parent.verticalCenter; text: modelData; color: index === 0 ? "white" : Theme.muted; font.family: Theme.font; font.pixelSize: 13 }
                        }
                    }
                }
                Column {
                    x: 160
                    y: 20
                    spacing: 12
                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            required property int index
                            width: 340
                            height: 64
                            radius: 12
                            color: Theme.panel2
                            border.width: 1
                            border.color: Theme.lines
                            Rectangle { x: 16; y: 16; width: 120 + index * 30; height: 8; radius: 4; color: Theme.lines }
                            Rectangle { x: 16; y: 34; width: 80; height: 6; radius: 3; color: Theme.lines; opacity: 0.6 }
                            Rectangle { x: parent.width - 58; y: 20; width: 40; height: 22; radius: 11; color: index === 1 ? Theme.lines : Theme.accent
                                Rectangle { x: index === 1 ? 2 : 20; y: 2; width: 18; height: 18; radius: 9; color: "white" } }
                        }
                    }
                }
            }

            // slide 2: privacy
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 520
                height: 260
                radius: 16
                color: Theme.panel
                border.width: 1
                border.color: Theme.lines
                opacity: root.slide === 2 ? 1 : 0
                scale: root.slide === 2 ? 1 : 0.96
                visible: opacity > 0.01
                Behavior on opacity { NumberAnimation { duration: 350 } }
                Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
                Column {
                    anchors.centerIn: parent
                    spacing: 14
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 64
                        height: 64
                        radius: 32
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Theme.accent }
                            GradientStop { position: 1.0; color: Theme.violet }
                        }
                        Text { anchors.centerIn: parent; text: "✓"; color: "white"; font.pixelSize: 32; font.weight: Font.Bold }
                    }
                    Repeater {
                        model: [qsTr("No telemetry"), qsTr("No ads"), qsTr("No tracking")]
                        delegate: Text {
                            required property string modelData
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 18
                        }
                    }
                }
            }
        }

        Text {
            Layout.topMargin: 22
            Layout.alignment: Qt.AlignHCenter
            text: root.slides[root.slide].title
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 24
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 8
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 560
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: root.slides[root.slide].text
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 16
        }
        Row {
            Layout.topMargin: 18
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            Repeater {
                model: root.slides.length
                delegate: Rectangle {
                    required property int index
                    width: root.slide === index ? 26 : 8
                    height: 8
                    radius: 4
                    color: root.slide === index ? Theme.accent : Theme.lines
                    Behavior on width { NumberAnimation { duration: 200 } }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: root.slide = index }
                }
            }
        }
        Item { Layout.fillHeight: true }
    }
}
