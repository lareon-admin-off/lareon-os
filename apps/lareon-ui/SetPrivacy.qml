import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property bool autolock: true
    property int lockMin: 5
    property bool lockOnResume: true

    readonly property var lockOptions: [
        { label: qsTr("1 minute"), value: 1 }, { label: qsTr("5 minutes"), value: 5 },
        { label: qsTr("10 minutes"), value: 10 }, { label: qsTr("30 minutes"), value: 30 }
    ]

    function load() {
        if (host.demo) return
        const rc = host.config("kscreenlockerrc")
        autolock = host.iniGet(rc, ["Daemon"], "Autolock") !== "false"
        const t = parseInt(host.iniGet(rc, ["Daemon"], "Timeout"))
        lockMin = isNaN(t) ? 5 : t
        lockOnResume = host.iniGet(rc, ["Daemon"], "LockOnResume") !== "false"
    }
    Component.onCompleted: load()

    function save() {
        host.sh(host.kw("kscreenlockerrc", ["Daemon"], "Autolock", autolock ? "true" : "false")
                + " && " + host.kw("kscreenlockerrc", ["Daemon"], "Timeout", String(lockMin))
                + " && " + host.kw("kscreenlockerrc", ["Daemon"], "LockOnResume", lockOnResume ? "true" : "false")
                + "; qdbus6 org.freedesktop.ScreenSaver /ScreenSaver configure >/dev/null 2>&1; true",
                function () { page.host.say(qsTr("Saved")) })
    }
    function clearRecent() {
        host.sh("rm -f ~/.local/share/recently-used.xbel; rm -f ~/.local/share/RecentDocuments/*; qdbus6 org.kde.klipper /klipper clearClipboardHistory >/dev/null 2>&1; true",
                function () { page.host.say(qsTr("Recent files and clipboard history cleared")) })
    }

    SCard {
        title: qsTr("Our promise")
        note: qsTr("Lareon OS has no telemetry. It doesn’t send usage data, crash reports or a device ID anywhere. Your apps only talk to the internet when you use them.")
    }

    SCard {
        title: qsTr("Lock screen")
        SRow {
            label: qsTr("Lock when idle")
            LToggle { checked: page.autolock; onToggled: c => { page.autolock = c; page.save() } }
        }
        SRow {
            visible: page.autolock
            label: qsTr("Lock after")
            SSelect { options: page.lockOptions; current: page.lockMin; onPicked: v => { page.lockMin = v; page.save() } }
        }
        SRow {
            label: qsTr("Lock when waking from sleep")
            LToggle { checked: page.lockOnResume; onToggled: c => { page.lockOnResume = c; page.save() } }
        }
        LButton { text: qsTr("Lock now"); size: 36; onClicked: Sys.startDetached("/usr/lib/lareon/lock-session", []) }
    }

    SCard {
        title: qsTr("Clean up")
        note: qsTr("Forget the files you opened recently and what you copied.")
        LButton { text: qsTr("Clear recent files and clipboard"); size: 36; onClicked: page.clearRecent() }
    }
}
