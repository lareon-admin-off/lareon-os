import QtQuick
import QtQuick.Layouts
import Lareon

// The first thing you see: a big gradient "Hello" that changes language.
Item {
    id: root
    property string lead: qsTr("Let’s get your computer ready.")
    property string buttonText: qsTr("Get started")
    property string hint: ""
    signal go()

    readonly property var words: ["Hello", "مرحبا", "Bonjour", "Hola", "你好", "Merhaba", "سلام", "こんにちは", "Hallo", "Ciao", "Привет", "नमस्ते", "안녕하세요", "Olá", "Salam"]
    property int idx: 0

    Timer {
        interval: 2400
        running: root.visible
        repeat: true
        onTriggered: swap.restart()
    }
    SequentialAnimation {
        id: swap
        NumberAnimation { target: wordBox; property: "opacity"; to: 0; duration: 300; easing.type: Easing.InQuad }
        ScriptAction { script: { root.idx = (root.idx + 1) % root.words.length; wordBox.anchors.verticalCenterOffset = 16 } }
        ParallelAnimation {
            NumberAnimation { target: wordBox; property: "opacity"; to: 1; duration: 480; easing.type: Easing.OutCubic }
            NumberAnimation { target: wordBox; property: "anchors.verticalCenterOffset"; to: 0; duration: 480; easing.type: Easing.OutCubic }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -20
        spacing: 0

        LIcon {
            Layout.alignment: Qt.AlignHCenter
            size: 72
            source: Theme.logo
        }

        Item {
            Layout.topMargin: 18
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 800
            Layout.preferredHeight: 150
            Item {
                id: wordBox
                anchors.centerIn: parent
                width: word.width
                height: word.height
                GradientText {
                    id: word
                    text: root.words[root.idx]
                    pixelSize: 118
                }
            }
        }

        // where we are in the list of languages
        Row {
            Layout.topMargin: 4
            Layout.alignment: Qt.AlignHCenter
            spacing: 8
            Repeater {
                model: root.words.length
                delegate: Rectangle {
                    required property int index
                    width: root.idx === index ? 22 : 6
                    height: 6
                    radius: 3
                    color: root.idx === index ? Theme.accent : Theme.lines
                    Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                }
            }
        }

        Text {
            Layout.topMargin: 30
            Layout.alignment: Qt.AlignHCenter
            text: root.lead
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 22
        }
        LButton {
            Layout.topMargin: 36
            Layout.alignment: Qt.AlignHCenter
            kind: "primary"
            size: 54
            text: root.buttonText + "  ›"
            onClicked: root.go()
        }
        Text {
            visible: root.hint !== ""
            Layout.topMargin: 18
            Layout.alignment: Qt.AlignHCenter
            text: root.hint
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 14
        }
    }
}
