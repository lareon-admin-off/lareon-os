import QtQuick
import QtQuick.Layouts
import Lareon

// The first thing you see: "Hello" in many languages, over a pulsing Lareon mark.
Item {
    id: root
    property string lead: qsTr("Let’s get your computer ready.")
    property string buttonText: qsTr("Get started")
    property string hint: ""
    signal go()

    readonly property var words: [
        { t: "Hello", c: "#ff7c1f" }, { t: "مرحبا", c: "#d94fc4" }, { t: "Bonjour", c: "#a35cf5" },
        { t: "Hola", c: "#ff7c1f" }, { t: "你好", c: "#d94fc4" }, { t: "Merhaba", c: "#a35cf5" },
        { t: "سلام", c: "#ff7c1f" }, { t: "こんにちは", c: "#d94fc4" }, { t: "Hallo", c: "#a35cf5" },
        { t: "Ciao", c: "#ff7c1f" }, { t: "Привет", c: "#d94fc4" }, { t: "नमस्ते", c: "#a35cf5" },
        { t: "안녕하세요", c: "#ff7c1f" }, { t: "Olá", c: "#d94fc4" }, { t: "Salam", c: "#a35cf5" }
    ]
    property int idx: 0

    Timer {
        interval: 2300
        running: root.visible
        repeat: true
        onTriggered: {
            root.idx = (root.idx + 1) % root.words.length
            swap.restart()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -30
        spacing: 0

        // the mark, with slow rings
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 240
            Layout.preferredHeight: 240
            Repeater {
                model: 3
                delegate: Rectangle {
                    id: ring
                    required property int index
                    anchors.centerIn: parent
                    width: 130
                    height: 130
                    radius: 65
                    color: "transparent"
                    border.width: 2
                    border.color: Theme.accent
                    opacity: 0
                    SequentialAnimation {
                        running: root.visible
                        loops: Animation.Infinite
                        PauseAnimation { duration: index * 1100 }
                        ParallelAnimation {
                            NumberAnimation { target: ring; property: "scale"; from: 1; to: 1.9; duration: 3300; easing.type: Easing.OutCubic }
                            NumberAnimation { target: ring; property: "opacity"; from: 0.5; to: 0; duration: 3300; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }
            LIcon {
                id: mark
                anchors.centerIn: parent
                size: 120
                source: Theme.logo
                SequentialAnimation on scale {
                    running: root.visible
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.05; duration: 1800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 1800; easing.type: Easing.InOutSine }
                }
            }
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 760
            Layout.preferredHeight: 120
            Text {
                id: word
                anchors.centerIn: parent
                text: root.words[0].t
                color: root.words[0].c
                font.family: Theme.font
                font.pixelSize: 92
                font.weight: Font.DemiBold
            }
            SequentialAnimation {
                id: swap
                NumberAnimation { target: word; property: "opacity"; to: 0; duration: 260 }
                ScriptAction {
                    script: {
                        word.text = root.words[root.idx].t
                        word.color = root.words[root.idx].c
                        word.anchors.verticalCenterOffset = 14
                    }
                }
                ParallelAnimation {
                    NumberAnimation { target: word; property: "opacity"; to: 1; duration: 420; easing.type: Easing.OutCubic }
                    NumberAnimation { target: word; property: "anchors.verticalCenterOffset"; to: 0; duration: 420; easing.type: Easing.OutCubic }
                }
            }
        }

        Text {
            Layout.topMargin: 6
            Layout.alignment: Qt.AlignHCenter
            text: root.lead
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 20
        }
        LButton {
            Layout.topMargin: 40
            Layout.alignment: Qt.AlignHCenter
            kind: "primary"
            size: 52
            text: root.buttonText + "  ›"
            onClicked: root.go()
        }
        Text {
            visible: root.hint !== ""
            Layout.topMargin: 16
            Layout.alignment: Qt.AlignHCenter
            text: root.hint
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 14
        }
    }
}
