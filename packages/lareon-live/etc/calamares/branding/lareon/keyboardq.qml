/* Lareon installer, step 2: Keyboard.
   Uses Calamares' keyboard models (config.keyboardLayoutsModel and
   config.keyboardVariantsModel); setting their currentIndex applies the layout
   straight away, so the test field and the drive password use it. */
import io.calamares.core 1.0
import io.calamares.ui 1.0

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: page

    component Choice: ListView {
        id: list
        clip: true
        currentIndex: model.currentIndex
        Component.onCompleted: positionViewAtIndex(model.currentIndex, ListView.Center)
        delegate: Rectangle {
            width: list.width
            height: 44
            color: index === list.model.currentIndex ? Qt.rgba(1, 0.486, 0.122, 0.10) : "transparent"
            Rectangle { visible: index === list.model.currentIndex; width: 3; height: parent.height; color: "#ff7c1f" }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.right: parent.right
                anchors.rightMargin: 12
                text: model.label
                elide: Text.ElideRight
                color: "#ece9f5"
                font.family: "Geist"
                font.pixelSize: 14.5
                font.weight: index === list.model.currentIndex ? Font.DemiBold : Font.Normal
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    list.model.currentIndex = index
                    list.positionViewAtIndex(index, ListView.Contain)
                }
            }
        }
    }

    Rectangle { anchors.fill: parent; color: "#13111b" }

    ColumnLayout {
        anchors.top: parent.top
        anchors.topMargin: 78
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 72, 820)
        spacing: 0

        Text {
            text: qsTr("Choose your keyboard")
            color: "#ece9f5"
            font.family: "Geist"
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr("Pick the layout printed on your keys. If you encrypt the drive, its password is typed with this layout every time the computer starts.")
            color: "#a7a4ba"
            font.family: "Geist"
            font.pixelSize: 16.5
        }

        RowLayout {
            Layout.topMargin: 30
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 3
                radius: 12
                color: Qt.rgba(0.102, 0.094, 0.141, 0.92)
                border.color: "#2b2838"
                clip: true
                Choice { anchors.fill: parent; anchors.margins: 1; model: config.keyboardLayoutsModel }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 2
                radius: 12
                color: Qt.rgba(0.102, 0.094, 0.141, 0.92)
                border.color: "#2b2838"
                clip: true
                Choice { anchors.fill: parent; anchors.margins: 1; model: config.keyboardVariantsModel }
            }
        }

        Text {
            Layout.topMargin: 18
            text: qsTr("Try it")
            color: "#a7a4ba"
            font.family: "Geist"
            font.pixelSize: 13
            font.weight: Font.Medium
        }
        TextField {
            Layout.topMargin: 7
            Layout.fillWidth: true
            implicitHeight: 44
            leftPadding: 14
            placeholderText: qsTr("Type here to check the layout")
            placeholderTextColor: "#74718a"
            color: "#ece9f5"
            font.family: "Geist"
            font.pixelSize: 15
            background: Rectangle {
                radius: 9
                color: "#13111b"
                border.color: parent.activeFocus ? "#ff7c1f" : "#2b2838"
            }
        }
    }

    function onActivate() {}
    function onLeave() {}
}
