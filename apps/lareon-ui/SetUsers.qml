import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property string fullName: ""
    property string userName: ""
    property string hostName: ""
    property string newHost: ""
    property string pw1: ""
    property string pw2: ""

    function load() {
        if (host.demo) { fullName = "Lars"; userName = "lars"; hostName = "lareon"; newHost = "lareon"; return }
        userName = Sys.env("USER")
        host.sh("getent passwd \"$USER\" | cut -d: -f5 | cut -d, -f1; hostnamectl --static", function (c, out) {
            const l = out.trim().split("\n")
            page.fullName = l[0] || page.userName
            page.hostName = l[1] || ""
            page.newHost = page.hostName
        })
    }
    Component.onCompleted: load()

    function changePassword() {
        if (pw1.length < 4) { host.say(qsTr("Use at least 4 characters")); return }
        if (pw1 !== pw2) { host.say(qsTr("The two passwords don’t match")); return }
        host.run("pkexec", ["chpasswd"], userName + ":" + pw1 + "\n", function (c) {
            page.host.say(c === 0 ? qsTr("Password changed") : qsTr("Couldn’t change the password"))
            if (c === 0) { page.pw1 = ""; page.pw2 = ""; p1.text = ""; p2.text = "" }
        })
    }
    function renameComputer() {
        const n = newHost.toLowerCase().replace(/[^a-z0-9-]/g, "-").replace(/^-+|-+$/g, "")
        if (n === "") return
        host.run("pkexec", ["hostnamectl", "set-hostname", n], "", function (c) {
            if (c === 0) page.hostName = n
            page.host.say(c === 0 ? qsTr("Computer renamed") : qsTr("Couldn’t rename the computer"))
        })
    }

    SCard {
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            Rectangle {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                radius: 32
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: Theme.accent }
                    GradientStop { position: 0.6; color: Theme.magenta }
                    GradientStop { position: 1; color: Theme.violet }
                }
                Text {
                    anchors.centerIn: parent
                    text: (page.fullName || "?").charAt(0).toUpperCase()
                    color: "white"
                    font.family: Theme.font
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                }
            }
            ColumnLayout {
                spacing: 2
                Text { text: page.fullName; color: Theme.text; font.family: Theme.font; font.pixelSize: 20; font.weight: Font.Medium }
                Text { text: page.userName + qsTr("  ·  administrator"); color: Theme.muted; font.family: Theme.font; font.pixelSize: 13 }
            }
        }
    }

    SCard {
        title: qsTr("Change password")
        LField { id: p1; Layout.fillWidth: true; label: qsTr("New password"); echoMode: TextInput.Password; onEdited: v => page.pw1 = v }
        LField { id: p2; Layout.fillWidth: true; label: qsTr("Repeat it"); echoMode: TextInput.Password; onEdited: v => page.pw2 = v; onAccepted: page.changePassword() }
        LButton { text: qsTr("Change password"); kind: "primary"; onClicked: page.changePassword() }
    }

    SCard {
        title: qsTr("This computer")
        SRow {
            label: qsTr("Name")
            hint: qsTr("How it appears on your network.")
            LField { Layout.preferredWidth: 220; text: page.newHost; onEdited: v => page.newHost = v; onAccepted: page.renameComputer() }
            LButton { text: qsTr("Rename"); size: 38; enabled: page.newHost !== "" && page.newHost !== page.hostName; onClicked: page.renameComputer() }
        }
    }
}
