import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// A drop-down list. options: [{ label: "...", value: ... }]
Item {
    id: root
    property var options: []
    property var current
    property string placeholder: qsTr("Choose…")
    property int popupHeight: 280
    signal picked(var value)

    implicitWidth: 240
    implicitHeight: 38
    Layout.preferredWidth: 240
    Layout.preferredHeight: 38

    readonly property string shown: {
        for (let i = 0; i < options.length; i++) {
            if (options[i].value === current) return options[i].label
        }
        return placeholder
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: hov.hovered || pop.opened ? Theme.lines : Theme.panel2
        border.width: 1
        border.color: pop.opened ? Theme.accent : Theme.lines
        Behavior on color { ColorAnimation { duration: 120 } }
        HoverHandler { id: hov; cursorShape: Qt.PointingHandCursor }
        Text {
            anchors.left: parent.left
            anchors.right: chevron.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 14
            anchors.rightMargin: 8
            text: root.shown
            elide: Text.ElideRight
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 14
        }
        Text {
            id: chevron
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: "⌄"
            color: Theme.muted
            font.pixelSize: 16
        }
        TapHandler { onTapped: pop.opened ? pop.close() : pop.open() }
    }

    Popup {
        id: pop
        y: root.height + 6
        x: root.width - width
        width: Math.max(root.width, 260)
        height: Math.min(root.popupHeight, list.contentHeight + 12)
        padding: 6
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 140 }
                NumberAnimation { property: "scale"; from: 0.96; to: 1; duration: 160; easing.type: Easing.OutCubic }
            }
        }
        background: Rectangle {
            radius: 14
            color: Theme.panel
            border.width: 1
            border.color: Theme.lines
        }
        contentItem: ListView {
            id: list
            clip: true
            model: root.options
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { }
            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: 36
                radius: 10
                color: ih.hovered ? Qt.rgba(1, 1, 1, 0.07) : (root.current === modelData.value ? Qt.rgba(1, 0.486, 0.122, 0.14) : "transparent")
                HoverHandler { id: ih; cursorShape: Qt.PointingHandCursor }
                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    text: modelData.label
                    elide: Text.ElideRight
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 14
                }
                TapHandler {
                    onTapped: {
                        root.picked(modelData.value)
                        pop.close()
                    }
                }
            }
        }
    }
}
