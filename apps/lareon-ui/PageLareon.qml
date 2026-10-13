import QtQuick
import QtQuick.Layouts
import Lareon

// Step 3: Lareon account (optional).
// The email is saved for the person's account; signing in finishes on
// lareon.org the first time the desktop opens (see setup-helper "apply").
Item {
    id: root
    property var setup
    property bool saved: setup.lareonEmail.trim() !== ""
    readonly property bool looksLikeEmail: /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.text.trim())

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        LIcon {
            Layout.alignment: Qt.AlignHCenter
            size: 72
            source: Theme.logo
        }
        Text {
            Layout.topMargin: 22
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Sign in with your Lareon account")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("One free account for all of Lareon. Optional: Lareon OS works fully without it.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 16.5
        }
        Row {
            Layout.topMargin: 18
            Layout.alignment: Qt.AlignHCenter
            spacing: 22
            Repeater {
                model: [["fledge", "Fledge"], ["aster", "Aster"], ["dusk", "Dusk"], ["ember", "Ember"]]
                Row {
                    spacing: 8
                    LIcon { size: 28; source: Theme.productLogo(modelData[0]) }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData[1]
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 13.5
                    }
                }
            }
        }

        ColumnLayout {
            Layout.topMargin: 30
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 440
            spacing: 14

            LField {
                id: email
                Layout.fillWidth: true
                label: qsTr("Email or username")
                text: root.setup.lareonEmail
                onEdited: root.saved = false
                onAccepted: save.clicked()
            }
            LButton {
                id: save
                Layout.fillWidth: true
                kind: "primary"
                size: 44
                text: root.saved ? "✓  " + qsTr("Saved") : qsTr("Continue")
                enabled: email.text.trim() !== ""
                onClicked: {
                    root.setup.lareonEmail = email.text.trim()
                    root.saved = true
                }
            }
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: root.saved
                      ? qsTr("You’ll finish signing in on lareon.org when your desktop opens.")
                      : qsTr("New to Lareon? You can create a free account at lareon.org.")
                color: Theme.faint
                font.family: Theme.font
                font.pixelSize: 13
            }
        }
        Item { Layout.fillHeight: true }
    }
}
