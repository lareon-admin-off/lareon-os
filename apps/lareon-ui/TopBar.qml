import QtQuick
import Lareon

// Top bar: Lareon mark + title, step indicator in the middle, clock on the right.
Item {
    id: root
    property string title: ""
    property var steps: []
    property int current: 0
    height: 72

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 36
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14
        LIcon { size: 34; source: Theme.logo }
        Text {
            text: root.title
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }
    }

    StepBar {
        anchors.centerIn: parent
        steps: root.steps
        current: root.current
        visible: root.steps.length > 0
    }

    Text {
        id: clock
        anchors.right: parent.right
        anchors.rightMargin: 36
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 13
        text: Qt.formatTime(new Date(), Qt.locale().timeFormat(Locale.ShortFormat))
        Timer {
            interval: 15000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatTime(new Date(), Qt.locale().timeFormat(Locale.ShortFormat))
        }
    }
}
