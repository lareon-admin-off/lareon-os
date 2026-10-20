import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property var browsers: []
    property string browser: ""
    property var fileManagers: []
    property string fileManager: ""

    // Finds installed apps that handle a MIME type: calls cb([{label,value}])
    function handlers(mime, cb) {
        host.sh("for f in /usr/share/applications/*.desktop; do grep -q \"^MimeType=.*" + mime + "\" \"$f\" && printf '%s|%s\\n' \"$(basename \"$f\")\" \"$(grep -m1 '^Name=' \"$f\" | cut -d= -f2)\"; done", function (c, out) {
            const seen = {}
            const arr = []
            out.split("\n").forEach(l => {
                const p = l.split("|")
                if (p.length < 2 || seen[p[0]]) return
                seen[p[0]] = true
                arr.push({ label: p[1], value: p[0] })
            })
            cb(arr)
        })
    }
    function load() {
        if (host.demo) {
            browsers = [{ label: "Ember", value: "ember.desktop" }, { label: "Firefox", value: "firefox-esr.desktop" }]
            browser = "ember.desktop"
            fileManagers = [{ label: "Files", value: "org.kde.dolphin.desktop" }]
            fileManager = "org.kde.dolphin.desktop"
            return
        }
        handlers("x-scheme-handler/https", arr => { page.browsers = arr })
        host.sh("xdg-settings get default-web-browser", function (c, out) { page.browser = out.trim() })
        handlers("inode/directory", arr => { page.fileManagers = arr })
        host.sh("xdg-mime query default inode/directory", function (c, out) { page.fileManager = out.trim() })
    }
    Component.onCompleted: load()

    function setBrowser(v) {
        browser = v
        host.sh("xdg-settings set default-web-browser " + host.q(v), function () { page.host.say(qsTr("Default browser saved")) })
    }
    function setFiles(v) {
        fileManager = v
        host.sh("xdg-mime default " + host.q(v) + " inode/directory", function () { page.host.say(qsTr("Default file manager saved")) })
    }

    SCard {
        title: qsTr("Default apps")
        SRow {
            label: qsTr("Web browser")
            SSelect { options: page.browsers; current: page.browser; onPicked: v => page.setBrowser(v) }
        }
        SRow {
            label: qsTr("Files")
            SSelect { options: page.fileManagers; current: page.fileManager; onPicked: v => page.setFiles(v) }
        }
    }

    SCard {
        title: qsTr("Get more apps")
        note: qsTr("Lareon Software has thousands of free apps. Nothing is installed without you asking.")
        RowLayout {
            spacing: 10
            LButton { text: qsTr("Open Software"); kind: "primary"; onClicked: Sys.startDetached("plasma-discover", []) }
            LButton { text: qsTr("Check for updates"); onClicked: Sys.startDetached("lareon-ui", ["updates"]) }
        }
    }

    SCard {
        title: qsTr("Startup")
        note: qsTr("Apps that open by themselves when you sign in.")
        LButton { text: qsTr("Manage startup apps"); size: 36; onClicked: Sys.startDetached("systemsettings", ["kcm_autostart"]) }
    }
}
