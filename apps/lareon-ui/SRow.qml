import QtQuick
import QtQuick.Layouts
import Lareon

// One setting: a label (and a short hint) on the left, its control on the right.
RowLayout {
    id: root
    property string label: ""
    property string hint: ""
    default property alias control: slot.data

    Layout.fillWidth: true
    spacing: 16

    ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        spacing: 2
        Text {
            Layout.fillWidth: true
            text: root.label
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 15
            elide: Text.ElideRight
        }
        Text {
            visible: root.hint !== ""
            Layout.fillWidth: true
            text: root.hint
            wrapMode: Text.Wrap
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 13
        }
    }
    RowLayout {
        id: slot
        Layout.alignment: Qt.AlignVCenter
        spacing: 10
    }
}
