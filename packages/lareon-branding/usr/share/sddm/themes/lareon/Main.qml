import QtQuick 2.15

// The Lareon sign-in screen. Plain Qt Quick only, so it needs nothing beyond
// the greeter itself. Colours and shapes follow the Lareon app.
Rectangle {
    id: root
    color: "#13111b"

    readonly property real u: Math.max(0.6, Math.min(width / 1280, height / 800))
    property string selName: ""
    property string selReal: ""
    property bool failed: false
    property bool busy: false

    readonly property color panel: "#1a1824"
    readonly property color panel2: "#211e2d"
    readonly property color line: "#2b2838"
    readonly property color textColor: "#ece9f5"
    readonly property color muted: "#a7a4ba"
    readonly property color accent: "#ff7c1f"

    Image {
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    function tryLogin() {
        if (root.busy || root.selName === "")
            return
        root.failed = false
        root.busy = true
        sddm.login(root.selName, pw.text, sessionModel.lastIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false
            root.failed = true
            pw.text = ""
            pw.forceActiveFocus()
        }
        function onLoginSucceeded() {
            root.busy = false
        }
    }

    // time, top left
    Column {
        x: 40 * root.u
        y: 32 * root.u
        spacing: 2
        Text {
            id: clockText
            color: root.textColor
            font.pixelSize: 30 * root.u
            font.weight: Font.Medium
            font.family: "Geist"
            text: Qt.formatTime(new Date(), "h:mm")
        }
        Text {
            id: dateText
            color: root.muted
            font.pixelSize: 14 * root.u
            font.family: "Geist"
            text: Qt.formatDate(new Date(), "dddd d MMMM")
        }
    }
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            clockText.text = Qt.formatTime(new Date(), "h:mm")
            dateText.text = Qt.formatDate(new Date(), "dddd d MMMM")
        }
    }

    // the sign-in card
    Rectangle {
        id: card
        width: 400 * root.u
        height: cardColumn.height + 64 * root.u
        anchors.centerIn: parent
        radius: 22 * root.u
        color: Qt.rgba(0.102, 0.094, 0.141, 0.92)
        border.width: 1
        border.color: root.line

        Column {
            id: cardColumn
            width: parent.width - 64 * root.u
            anchors.horizontalCenter: parent.horizontalCenter
            y: 32 * root.u
            spacing: 18 * root.u

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 56 * root.u
                height: 56 * root.u
                source: "logo.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: root.textColor
                font.pixelSize: 24 * root.u
                font.weight: Font.Medium
                font.family: "Geist"
                elide: Text.ElideRight
                text: root.selReal !== "" ? root.selReal : root.selName
            }

            // more than one person on this computer: tap a name
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8 * root.u
                visible: userModel.count > 1
                Repeater {
                    model: userModel
                    delegate: Rectangle {
                        width: nameLabel.implicitWidth + 24 * root.u
                        height: 30 * root.u
                        radius: height / 2
                        color: root.selName === model.name ? root.panel2 : "transparent"
                        border.width: 1
                        border.color: root.selName === model.name ? root.accent : root.line
                        Text {
                            id: nameLabel
                            anchors.centerIn: parent
                            color: root.textColor
                            font.pixelSize: 13 * root.u
                            font.family: "Geist"
                            text: model.name
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.selName = model.name
                                root.selReal = model.realName
                                root.failed = false
                                pw.forceActiveFocus()
                            }
                        }
                        Component.onCompleted: {
                            if (index === userModel.lastIndex) {
                                root.selName = model.name
                                root.selReal = model.realName
                            }
                        }
                    }
                }
            }

            // the password box
            Rectangle {
                width: parent.width
                height: 48 * root.u
                radius: 12 * root.u
                color: root.panel2
                border.width: pw.activeFocus ? 2 : 1
                border.color: root.failed ? "#ff4f7a" : (pw.activeFocus ? root.accent : root.line)

                TextInput {
                    id: pw
                    anchors.fill: parent
                    anchors.leftMargin: 16 * root.u
                    anchors.rightMargin: 16 * root.u
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    color: root.textColor
                    selectionColor: root.accent
                    selectedTextColor: "#13111b"
                    font.pixelSize: 16 * root.u
                    font.family: "Geist"
                    focus: true
                    clip: true
                    Keys.onReturnPressed: root.tryLogin()
                    Keys.onEnterPressed: root.tryLogin()
                    onTextChanged: root.failed = false
                }
                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 16 * root.u
                    verticalAlignment: Text.AlignVCenter
                    visible: pw.text.length === 0
                    color: root.muted
                    font.pixelSize: 16 * root.u
                    font.family: "Geist"
                    text: "Password"
                }
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                visible: root.failed
                color: "#ff4f7a"
                font.pixelSize: 13 * root.u
                font.family: "Geist"
                text: "That password didn’t work. Try again."
            }

            // the sign-in button
            Rectangle {
                id: go
                width: parent.width
                height: 48 * root.u
                radius: 12 * root.u
                opacity: root.busy ? 0.6 : 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#ff7c1f" }
                    GradientStop { position: 1.0; color: "#d94fc4" }
                }
                Text {
                    anchors.centerIn: parent
                    color: "#13111b"
                    font.pixelSize: 16 * root.u
                    font.weight: Font.DemiBold
                    font.family: "Geist"
                    text: root.busy ? "Signing in…" : "Sign in"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.tryLogin()
                }
            }
        }
    }

    // restart and shut down, bottom right
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 40 * root.u
        anchors.bottomMargin: 32 * root.u
        spacing: 10 * root.u

        Rectangle {
            width: restartLabel.implicitWidth + 28 * root.u
            height: 36 * root.u
            radius: height / 2
            color: "transparent"
            border.width: 1
            border.color: root.line
            visible: sddm.canReboot
            Text {
                id: restartLabel
                anchors.centerIn: parent
                color: root.textColor
                font.pixelSize: 13 * root.u
                font.family: "Geist"
                text: "Restart"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: sddm.reboot()
            }
        }
        Rectangle {
            width: offLabel.implicitWidth + 28 * root.u
            height: 36 * root.u
            radius: height / 2
            color: "transparent"
            border.width: 1
            border.color: root.line
            visible: sddm.canPowerOff
            Text {
                id: offLabel
                anchors.centerIn: parent
                color: root.textColor
                font.pixelSize: 13 * root.u
                font.family: "Geist"
                text: "Shut down"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: sddm.powerOff()
            }
        }
    }

    Component.onCompleted: pw.forceActiveFocus()
}
