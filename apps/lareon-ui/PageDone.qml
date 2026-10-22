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

}
