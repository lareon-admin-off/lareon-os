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
    property bool showPw: false
    property int sess: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool sessOpen: false
    property date now: new Date()

    readonly property color panel: "#1a1824"
    readonly property color panel2: "#211e2d"
    readonly property color line: "#2b2838"
    readonly property color textColor: "#ece9f5"
    readonly property color muted: "#a7a4ba"
    readonly property color faint: "#74718a"
    readonly property color accent: "#ff7c1f"

    readonly property string greeting: {
        const h = now.getHours()
        if (h < 5) return "Still up?"
        if (h < 12) return "Good morning"
        if (h < 18) return "Good afternoon"
        return "Good evening"
    }
    readonly property bool hasKeyboard: typeof keyboard !== "undefined" && keyboard !== null
    readonly property string layoutName: {
        if (!hasKeyboard) return ""
        try {
            const l = keyboard.layouts
            if (l && l.length > 1) return String(l[keyboard.currentLayout].shortName).toUpperCase()
        } catch (e) { }
        return ""
    }

    Image {
        id: bg
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    // slow drifting glows: the screen is never perfectly still
    Rectangle {
        id: glowA
        width: 640 * root.u
        height: width
        radius: width / 2
        x: root.width * 0.08
        y: root.height * 0.05
        opacity: 0.16
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ff7c1f" }
            GradientStop { position: 1.0; color: "#d94fc4" }
        }
        SequentialAnimation on x {
            loops: Animation.Infinite
            NumberAnimation { to: root.width * 0.16; duration: 14000; easing.type: Easing.InOutSine }
            NumberAnimation { to: root.width * 0.04; duration: 14000; easing.type: Easing.InOutSine }
        }
        SequentialAnimation on y {
            loops: Animation.Infinite
            NumberAnimation { to: root.height * 0.14; duration: 11000; easing.type: Easing.InOutSine }
            NumberAnimation { to: root.height * 0.0; duration: 11000; easing.type: Easing.InOutSine }
        }
    }
    Rectangle {
        id: glowB
        width: 560 * root.u
        height: width
        radius: width / 2
        x: root.width * 0.62
        y: root.height * 0.55
        opacity: 0.14
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#d94fc4" }
            GradientStop { position: 1.0; color: "#a35cf5" }
        }
        SequentialAnimation on x {
            loops: Animation.Infinite
            NumberAnimation { to: root.width * 0.54; duration: 16000; easing.type: Easing.InOutSine }
            NumberAnimation { to: root.width * 0.68; duration: 16000; easing.type: Easing.InOutSine }
        }
        SequentialAnimation on y {
            loops: Animation.Infinite
            NumberAnimation { to: root.height * 0.46; duration: 12000; easing.type: Easing.InOutSine }
            NumberAnimation { to: root.height * 0.62; duration: 12000; easing.type: Easing.InOutSine }
        }
    }
    // keeps the text readable over the glows
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.075, 0.067, 0.106, 0.35) }
            GradientStop { position: 1.0; color: Qt.rgba(0.075, 0.067, 0.106, 0.75) }
        }
    }

    function tryLogin() {
        if (root.busy || root.selName === "")
            return
        root.failed = false
        root.busy = true
        sddm.login(root.selName, pw.text, root.sess)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false
            root.failed = true
            pw.text = ""
            pw.forceActiveFocus()
            shake.restart()
        }
        function onLoginSucceeded() {
            root.busy = false
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    // clock and date, top centre
    Column {
        id: clockCol
        anchors.horizontalCenter: parent.horizontalCenter
        y: 56 * root.u
        spacing: 0
        opacity: 0
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.textColor
            font.pixelSize: 84 * root.u
            font.weight: Font.Light
            font.family: "Geist"
            text: Qt.formatTime(root.now, "h:mm")
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.muted
            font.pixelSize: 18 * root.u
            font.family: "Geist"
            text: Qt.formatDate(root.now, "dddd d MMMM")
        }
    }

    // the sign-in card
    Rectangle {
        id: card
        width: 400 * root.u
        height: cardColumn.height + 64 * root.u
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.5 - height * 0.42
        radius: 22 * root.u
        color: Qt.rgba(0.102, 0.094, 0.141, 0.9)
        border.width: 1
        border.color: root.line
        opacity: 0
        transform: Translate { id: cardShift; y: 18 * root.u; x: 0 }

        SequentialAnimation {
            id: shake
            NumberAnimation { target: cardShift; property: "x"; to: -12 * root.u; duration: 60 }
            NumberAnimation { target: cardShift; property: "x"; to: 12 * root.u; duration: 90 }
            NumberAnimation { target: cardShift; property: "x"; to: -8 * root.u; duration: 80 }
            NumberAnimation { target: cardShift; property: "x"; to: 0; duration: 80 }
        }

        Column {
            id: cardColumn
            width: parent.width - 64 * root.u
            anchors.horizontalCenter: parent.horizontalCenter
            y: 32 * root.u
            spacing: 16 * root.u

            // avatar: first letter on the Lareon gradient
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 76 * root.u
                height: width
                radius: width / 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#ff7c1f" }
                    GradientStop { position: 0.6; color: "#d94fc4" }
                    GradientStop { position: 1.0; color: "#a35cf5" }
                }
                Text {
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: 34 * root.u
                    font.weight: Font.DemiBold
                    font.family: "Geist"
                    text: (root.selReal !== "" ? root.selReal : root.selName).charAt(0).toUpperCase()
                }
            }

            Column {
                width: parent.width
                spacing: 2 * root.u
                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    color: root.muted
                    font.pixelSize: 13 * root.u
                    font.family: "Geist"
                    text: root.greeting
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
            }

            // more than one person on this computer: tap a name
            Flow {
                width: parent.width
                spacing: 8 * root.u
                visible: userModel.count > 1
                layoutDirection: Qt.LeftToRight
                Repeater {
                    model: userModel
                    delegate: Rectangle {
                        width: nameLabel.implicitWidth + 24 * root.u
                        height: 30 * root.u
                        radius: height / 2
                        color: root.selName === model.name ? root.panel2 : "transparent"
                        border.width: 1
                        border.color: root.selName === model.name ? root.accent : root.line
                        Behavior on color { ColorAnimation { duration: 140 } }
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
                            cursorShape: Qt.PointingHandCursor
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
                Behavior on border.color { ColorAnimation { duration: 140 } }

                TextInput {
                    id: pw
                    anchors.left: parent.left
                    anchors.right: eye.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 16 * root.u
                    anchors.rightMargin: 8 * root.u
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: root.showPw ? TextInput.Normal : TextInput.Password
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
                    anchors.fill: pw
                    verticalAlignment: Text.AlignVCenter
                    visible: pw.text.length === 0
                    color: root.muted
                    font.pixelSize: 16 * root.u
                    font.family: "Geist"
                    text: "Password"
                }
                Text {
                    id: eye
                    anchors.right: parent.right
                    anchors.rightMargin: 14 * root.u
                    anchors.verticalCenter: parent.verticalCenter
                    color: eyeArea.containsMouse ? root.textColor : root.faint
                    font.pixelSize: 13 * root.u
                    font.family: "Geist"
                    text: root.showPw ? "Hide" : "Show"
                    MouseArea {
                        id: eyeArea
                        anchors.fill: parent
                        anchors.margins: -8
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showPw = !root.showPw
                    }
                }
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                visible: root.failed || (root.hasKeyboard && keyboard.capsLock)
                color: root.failed ? "#ff4f7a" : "#ffb45e"
                font.pixelSize: 13 * root.u
                font.family: "Geist"
                text: root.failed ? "That password didn’t work. Try again." : "Caps Lock is on"
            }

            // the sign-in button
            Rectangle {
                id: go
                width: parent.width
                height: 48 * root.u
                radius: 12 * root.u
                opacity: root.busy ? 0.6 : (goArea.containsMouse ? 0.92 : 1)
                scale: goArea.pressed ? 0.985 : 1
                Behavior on opacity { NumberAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 90 } }
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
                    id: goArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.tryLogin()
                }
            }
        }
    }

    // the line under the card
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: card.bottom
        anchors.topMargin: 22 * root.u
        color: root.faint
        font.pixelSize: 13 * root.u
        font.family: "Geist"
        text: "Lareon OS  ·  private by default"
    }

    // bottom left: session and keyboard layout
    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 40 * root.u
        anchors.bottomMargin: 32 * root.u
        spacing: 10 * root.u

        Rectangle {
            width: sessLabel.implicitWidth + 28 * root.u
            height: 36 * root.u
            radius: height / 2
            color: sessArea.containsMouse ? root.panel2 : "transparent"
            border.width: 1
            border.color: root.sessOpen ? root.accent : root.line
            visible: sessionModel.count > 1
            Text {
                id: sessLabel
                anchors.centerIn: parent
                color: root.textColor
                font.pixelSize: 13 * root.u
                font.family: "Geist"
                text: "Session: " + (sessNames.itemAt(root.sess) ? sessNames.itemAt(root.sess).text : "")
            }
            MouseArea {
                id: sessArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.sessOpen = !root.sessOpen
            }
        }
        // hidden helpers that read the session names
        Repeater {
            id: sessNames
            model: sessionModel
            delegate: Text {
                visible: false
                text: model.name
            }
        }

        Rectangle {
            width: layoutLabel.implicitWidth + 28 * root.u
            height: 36 * root.u
            radius: height / 2
            color: layoutArea.containsMouse ? root.panel2 : "transparent"
            border.width: 1
            border.color: root.line
            visible: root.layoutName !== ""
            Text {
                id: layoutLabel
                anchors.centerIn: parent
                color: root.textColor
                font.pixelSize: 13 * root.u
                font.family: "Geist"
                text: "Keyboard: " + root.layoutName
            }
            MouseArea {
                id: layoutArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const n = keyboard.layouts.length
                    keyboard.currentLayout = (keyboard.currentLayout + 1) % n
                }
            }
        }
    }

    // session list pops up above the button
    Rectangle {
        id: sessPopup
        visible: root.sessOpen && sessionModel.count > 1
        anchors.left: parent.left
        anchors.leftMargin: 40 * root.u
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 76 * root.u
        width: 240 * root.u
        height: sessList.count * 38 * root.u + 12 * root.u
        radius: 14 * root.u
        color: Qt.rgba(0.102, 0.094, 0.141, 0.97)
        border.width: 1
        border.color: root.line
        ListView {
            id: sessList
            anchors.fill: parent
            anchors.margins: 6 * root.u
            interactive: false
            model: sessionModel
            delegate: Rectangle {
                width: ListView.view.width
                height: 38 * root.u
                radius: 10 * root.u
                color: itemArea.containsMouse ? root.panel2 : "transparent"
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12 * root.u
                    color: index === root.sess ? root.accent : root.textColor
                    font.pixelSize: 14 * root.u
                    font.family: "Geist"
                    text: model.name
                }
                MouseArea {
                    id: itemArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.sess = index
                        root.sessOpen = false
                        pw.forceActiveFocus()
                    }
                }
            }
        }
    }

    // sleep, restart and shut down, bottom right
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 40 * root.u
        anchors.bottomMargin: 32 * root.u
        spacing: 10 * root.u

        Repeater {
            model: [
                { label: "Sleep", ok: sddm.canSuspend, act: 0 },
                { label: "Restart", ok: sddm.canReboot, act: 1 },
                { label: "Shut down", ok: sddm.canPowerOff, act: 2 }
            ]
            delegate: Rectangle {
                width: pLabel.implicitWidth + 28 * root.u
                height: 36 * root.u
                radius: height / 2
                color: pArea.containsMouse ? root.panel2 : "transparent"
                border.width: 1
                border.color: pArea.containsMouse ? root.accent : root.line
                visible: modelData.ok
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    id: pLabel
                    anchors.centerIn: parent
                    color: root.textColor
                    font.pixelSize: 13 * root.u
                    font.family: "Geist"
                    text: modelData.label
                }
                MouseArea {
                    id: pArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.act === 0) sddm.suspend()
                        else if (modelData.act === 1) sddm.reboot()
                        else sddm.powerOff()
                    }
                }
            }
        }
    }

    // everything eases in once
    ParallelAnimation {
        id: intro
        NumberAnimation { target: clockCol; property: "opacity"; to: 1; duration: 700; easing.type: Easing.OutCubic }
        NumberAnimation { target: card; property: "opacity"; to: 1; duration: 600; easing.type: Easing.OutCubic }
        NumberAnimation { target: cardShift; property: "y"; to: 0; duration: 600; easing.type: Easing.OutCubic }
    }

    Component.onCompleted: {
        pw.forceActiveFocus()
        intro.start()
    }
}
