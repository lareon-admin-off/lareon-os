import QtQuick
import QtQuick.Layouts
import Lareon

// Last step: everything is ready; the button opens the desktop for the first time.
Item {
    id: root
    property var setup

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -60
        spacing: 0

        LIcon {
            Layout.alignment: Qt.AlignHCenter
            size: 120
            source: Theme.logo
        }
        Text {
            Layout.topMargin: 28
            Layout.alignment: Qt.AlignHCenter
            text: root.setup.firstName() !== ""
                  ? qsTr("You’re all set, %1").arg(root.setup.firstName())
                  : qsTr("You’re all set")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 42
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 12
            Layout.alignment: Qt.AlignHCenter
            text: {
                const bits = []
                if (root.setup.lareonEmail !== "") bits.push(qsTr("Lareon account saved"))
                bits.push(root.setup.theme === "light" ? qsTr("Lareon Light") : qsTr("Lareon Dark"))
                if (root.setup.connectedTo !== "") bits.push(qsTr("Connected to %1").arg(root.setup.connectedTo))
                return bits.join("  ·  ")
            }
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }
        LButton {
            Layout.topMargin: 38
            Layout.alignment: Qt.AlignHCenter
            kind: "primary"
            size: 48
            text: qsTr("Start using Lareon OS") + "  ›"
            onClicked: root.setup.finish()
        }
    }

    // a little celebration, once
    Item {
        id: confetti
        anchors.fill: parent
        visible: root.visible
        clip: true
        z: 5
        Repeater {
            model: 44
            delegate: Rectangle {
                id: piece
                required property int index
                readonly property real startX: Math.random() * confetti.width
                readonly property real drift: (Math.random() - 0.5) * 160
                width: 6 + Math.random() * 6
                height: width * 1.6
                radius: 2
                x: startX
                y: -30
                opacity: 0
                color: index % 4 === 0 ? "#ff7c1f" : (index % 4 === 1 ? "#d94fc4" : (index % 4 === 2 ? "#a35cf5" : "#ece9f5"))
                SequentialAnimation {
                    running: confetti.visible && root.StackLayout.isCurrentItem
                    PauseAnimation { duration: Math.random() * 900 }
                    ParallelAnimation {
                        NumberAnimation { target: piece; property: "y"; from: -30; to: confetti.height + 30; duration: 2600 + Math.random() * 1800; easing.type: Easing.InQuad }
                        NumberAnimation { target: piece; property: "x"; from: piece.startX; to: piece.startX + piece.drift; duration: 3600; easing.type: Easing.InOutSine }
                        NumberAnimation { target: piece; property: "rotation"; from: 0; to: 360 * (index % 2 === 0 ? 2 : -2); duration: 3600 }
                        SequentialAnimation {
                            NumberAnimation { target: piece; property: "opacity"; to: 1; duration: 200 }
                            PauseAnimation { duration: 2600 }
                            NumberAnimation { target: piece; property: "opacity"; to: 0; duration: 800 }
                        }
                    }
                }
            }
        }
    }
}
