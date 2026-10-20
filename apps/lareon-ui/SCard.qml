import QtQuick
import QtQuick.Layouts
import Lareon

// A settings card: optional title and note, then whatever you put inside.
Rectangle {
    id: root
    property string title: ""
    property string note: ""
    default property alias content: body.data

    Layout.fillWidth: true
    implicitHeight: col.implicitHeight + 36
    radius: 16
    color: Qt.rgba(0.129, 0.118, 0.176, 0.85)
    border.width: 1
    border.color: Theme.lines

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 18
        spacing: 12

        Text {
            visible: root.title !== ""
            Layout.fillWidth: true
            text: root.title
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 15
            font.weight: Font.Medium
        }
        Text {
            visible: root.note !== ""
            Layout.fillWidth: true
            text: root.note
            wrapMode: Text.Wrap
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 13
        }
        ColumnLayout {
            id: body
            Layout.fillWidth: true
            spacing: 14
        }
    }
}
