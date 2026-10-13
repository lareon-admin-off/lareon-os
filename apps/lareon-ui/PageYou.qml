import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// Step 2: the person's account on this computer.
Item {
    id: root
    property var setup

    property bool userNameEdited: false
    property bool hostNameEdited: false
    property string confirm: Sys.demo ? "demo-password" : ""

    readonly property bool nameOk: setup.fullName.trim().length > 0
    readonly property bool userOk: /^[a-z][a-z0-9_-]{0,31}$/.test(setup.userName)
    readonly property bool hostOk: /^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$/.test(setup.hostName)
    readonly property bool passLongEnough: setup.password.length >= 6
    readonly property bool passMatch: setup.password === confirm
    readonly property bool valid: nameOk && userOk && hostOk && passLongEnough && passMatch && setup.timeZone !== ""

    // "Alex Lund" -> "alex"
    function suggestUser(name) {
        const first = name.trim().toLowerCase().split(" ")[0] || ""
        let s = first.normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9_-]/g, "")
        if (s !== "" && !/^[a-z]/.test(s)) s = "u" + s
        return s.substring(0, 32)
    }

    function initials(name) {
        const parts = name.trim().split(/\s+/).filter(p => p.length > 0)
        if (parts.length === 0) return ""
        const a = parts[0].charAt(0)
        const b = parts.length > 1 ? parts[parts.length - 1].charAt(0) : ""
        return (a + b).toUpperCase()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Make your account")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            text: qsTr("This is how you sign in to this computer.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 16.5
        }

        RowLayout {
            Layout.topMargin: 34
            Layout.fillWidth: true
            spacing: 34

            // ---- picture
            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                spacing: 12
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 112
                    height: 112
                    radius: 56
                    clip: true
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Theme.accent }
                        GradientStop { position: 0.6; color: Theme.magenta }
                        GradientStop { position: 1.0; color: Theme.violet }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: root.setup.avatar === ""
                        text: root.initials(root.setup.fullName)
                        color: Theme.onAccent
                        font.family: Theme.font
                        font.pixelSize: 42
                        font.weight: Font.DemiBold
                    }
                    Image {
                        anchors.fill: parent
                        visible: root.setup.avatar !== ""
                        source: root.setup.avatar !== "" ? "file://" + root.setup.avatar : ""
                        fillMode: Image.PreserveAspectCrop
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Choose picture")
                    color: Theme.violet
                    font.family: Theme.font
                    font.pixelSize: 13.5
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: picker.open()
                    }
                }
            }

            // ---- fields
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                LField {
                    Layout.fillWidth: true
                    label: qsTr("Your name")
                    text: root.setup.fullName
                    onEdited: (value) => {
                        root.setup.fullName = value
                        if (!root.userNameEdited) root.setup.userName = root.suggestUser(value)
                        if (!root.hostNameEdited && root.setup.userName !== "") root.setup.hostName = root.setup.userName + "-computer"
                    }
                    Component.onCompleted: field.forceActiveFocus()
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    LField {
                        Layout.fillWidth: true
                        label: qsTr("Username")
                        text: root.setup.userName
                        invalid: root.setup.userName !== "" && !root.userOk
                        onEdited: (value) => { root.userNameEdited = true; root.setup.userName = value }
                    }
                    LField {
                        Layout.fillWidth: true
                        label: qsTr("Computer name")
                        text: root.setup.hostName
                        invalid: root.setup.hostName !== "" && !root.hostOk
                        onEdited: (value) => { root.hostNameEdited = true; root.setup.hostName = value }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    LField {
                        Layout.fillWidth: true
                        label: qsTr("Password")
                        echoMode: TextInput.Password
                        text: root.setup.password
                        onEdited: (value) => root.setup.password = value
                    }
                    LField {
                        Layout.fillWidth: true
                        label: qsTr("Type it again")
                        echoMode: TextInput.Password
                        text: root.confirm
                        invalid: root.confirm !== "" && !root.passMatch
                        onEdited: (value) => root.confirm = value
                    }
                }
                Text {
                    text: {
                        if (root.setup.userName !== "" && !root.userOk)
                            return qsTr("Usernames use small letters, numbers, - and _, and start with a letter.")
                        if (root.setup.hostName !== "" && !root.hostOk)
                            return qsTr("Computer names use small letters, numbers and -.")
                        if (root.setup.password === "")
                            return ""
                        if (!root.passLongEnough)
                            return qsTr("Use at least 6 characters.")
                        if (root.confirm === "")
                            return ""
                        return root.passMatch ? "● " + qsTr("Passwords match") : qsTr("The passwords don’t match.")
                    }
                    color: root.passMatch && root.passLongEnough && root.userOk && root.hostOk ? Theme.good : Theme.danger
                    font.family: Theme.font
                    font.pixelSize: 13
                }

                // time zone (needed for the clock and the time-of-day wallpaper)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 7
                    Text {
                        text: qsTr("Time zone")
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        leftPadding: 2
                    }
                    ComboBox {
                        id: tz
                        Layout.fillWidth: true
                        implicitHeight: 44
                        model: Sys.timeZones()
                        currentIndex: Math.max(0, model.indexOf(root.setup.timeZone))
                        onActivated: root.setup.timeZone = currentText
                        font.family: Theme.font
                        font.pixelSize: 15
                        editable: true
                        // type part of a name ("Boise", "Paris") and press Enter
                        onAccepted: {
                            const i = find(editText, Qt.MatchContains)
                            if (i >= 0) { currentIndex = i; root.setup.timeZone = textAt(i) }
                        }
                        palette.text: Theme.text
                        palette.buttonText: Theme.text
                        palette.base: Theme.bg
                        palette.window: Theme.panel
                        palette.highlight: Theme.accent
                        palette.highlightedText: Theme.onAccent
                        background: Rectangle {
                            radius: Theme.fieldRadius
                            color: Theme.bg
                            border.width: 1
                            border.color: tz.activeFocus ? Theme.accent : Theme.lines
                        }
                        popup.background: Rectangle { color: Theme.panel; border.color: Theme.lines; radius: 8 }
                        delegate: ItemDelegate {
                            width: tz.width
                            highlighted: tz.highlightedIndex === index
                            contentItem: Text {
                                text: modelData.replace(/_/g, " ")
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: 14
                            }
                            background: Rectangle { color: highlighted ? Theme.accentSoft : "transparent" }
                        }
                    }
                }
            }
        }
        Item { Layout.fillHeight: true }
    }

    // ---- picture picker: Plasma's built-in pictures
    Popup {
        id: picker
        anchors.centerIn: parent
        width: 560
        height: 420
        modal: true
        padding: 20
        background: Rectangle { color: Theme.panel; radius: Theme.radius; border.color: Theme.lines }
        contentItem: ColumnLayout {
            spacing: 14
            Text {
                text: qsTr("Choose a picture")
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 18
                font.weight: Font.DemiBold
            }
            GridView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: 104
                cellHeight: 104
                model: [""].concat(Sys.listFiles("/usr/share/plasma/avatars", ["*.png", "*.jpg", "*.svg"]))
                delegate: Item {
                    width: 104
                    height: 104
                    Rectangle {
                        anchors.centerIn: parent
                        width: 88
                        height: 88
                        radius: 44
                        color: Theme.panel2
                        border.width: root.setup.avatar === modelData ? 3 : 0
                        border.color: Theme.accent
                        clip: true
                        Text {
                            anchors.centerIn: parent
                            visible: modelData === ""
                            text: root.initials(root.setup.fullName) || "Aa"
                            color: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 26
                        }
                        Image {
                            anchors.fill: parent
                            anchors.margins: 3
                            visible: modelData !== ""
                            source: modelData !== "" ? "file://" + modelData : ""
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 176
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.setup.avatar = modelData; picker.close() }
                    }
                }
            }
        }
    }
}
