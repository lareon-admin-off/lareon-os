import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// The Lareon OS installer: Language → Keyboard → Drive → Install → Done.
// Everything that touches the computer goes through /usr/lib/lareon/lareon-install
// (run with sudo in the live session). It reports progress in a small file that
// this screen reads twice a second.
Item {
    id: flow

    readonly property var stepNames: [qsTr("Language"), qsTr("Keyboard"), qsTr("Drive"), qsTr("Install")]
    readonly property var pageKeys: ["language", "keyboard", "drive", "install", "done", "failed"]
    property int page: Math.max(0, pageKeys.indexOf(Sys.startPage))

    // ---- what the person chooses
    property string language: "en"
    property string keyboard: "us"
    property bool keyboardTouched: false
    property string disk: Sys.demo ? "/dev/sda" : ""
    property string diskName: Sys.demo ? "QEMU HARDDISK · 30.0 GB" : ""

    // ---- install state
    property real percent: Sys.demo ? 0.62 : 0
    property string stepText: Sys.demo ? qsTr("Copying Lareon OS to your drive") : qsTr("Getting ready")
    property string detail: ""
    property bool installing: false
    property string error: ""
    property string logTail: ""

    readonly property string helper: "/usr/lib/lareon/lareon-install"
    property var pending: ({})

    function helperCall(command, payload, callback) {
        if (Sys.demo) {
            Qt.callLater(callback, 0, "", "")
            return
        }
        const id = Sys.run("sudo", ["-n", helper, command], payload === undefined ? "" : JSON.stringify(payload))
        pending[id] = callback
    }
    Connections {
        target: Sys
        function onFinished(id, code, out, err) {
            const cb = flow.pending[id]
            if (cb) {
                delete flow.pending[id]
                cb(code, out, err)
            }
        }
    }

    // The keyboard that usually goes with each language (the person can change it).
    function layoutFor(lang) {
        const m = { en: "us", es: "es", fr: "fr", de: "de", pt: "pt", it: "it", ru: "ru", tr: "tr",
                    sv: "se", ja: "jp", ko: "kr", zh: "cn", hi: "in", ar: "ara", fa: "ir", sw: "us", ary: "ara" }
        return m[lang] || "us"
    }
    onLanguageChanged: if (!keyboardTouched) keyboard = layoutFor(language)

    function next() {
        if (page === 2) {
            startInstall()
        } else if (page < 2) {
            page++
        }
    }
    function back() {
        if (page > 0 && page < 3) page--
    }

    function startInstall() {
        error = ""
        percent = 0
        stepText = qsTr("Getting ready")
        detail = ""
        installing = true
        page = 3
        if (Sys.demo) return
        helperCall("install", { disk: disk, language: language, keyboard: keyboard }, function(code, out, err) {
            // The progress file normally ends the install first; this catches a helper that died.
            if (installing && code !== 0) fail(err.trim() !== "" ? err.trim() : qsTr("The installer stopped unexpectedly (error %1).").arg(code))
        })
        poll.start()
    }

    function fail(message) {
        poll.stop()
        installing = false
        error = message
        logTail = Sys.readFile("/tmp/lareon-install.log").split("\n").slice(-14).join("\n")
        page = 5
    }

    Timer {
        id: poll
        interval: 500
        repeat: true
        onTriggered: {
            const raw = Sys.readFile("/tmp/lareon-install-progress.json")
            if (raw === "") return
            let st
            try { st = JSON.parse(raw) } catch (e) { return }
            if (st.percent !== undefined) flow.percent = Math.max(flow.percent, st.percent / 100)
            if (st.step) flow.stepText = st.step
            flow.detail = st.detail || ""
            if (st.state === "done") {
                poll.stop()
                flow.installing = false
                flow.percent = 1
                flow.page = 4
            } else if (st.state === "failed") {
                flow.fail(st.message || qsTr("Something went wrong while installing."))
            }
        }
    }

    // ---- layout
    Scene { anchors.fill: parent }

    TopBar {
        id: top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        title: qsTr("Install Lareon OS")
        steps: flow.page < 4 ? flow.stepNames : []
        current: flow.page
    }

    StackLayout {
        id: pages
        anchors.top: top.bottom
        anchors.topMargin: 70
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: foot.top
        anchors.bottomMargin: 24
        width: 820
        currentIndex: flow.page

        InstLanguage { install: flow }
        InstKeyboard { install: flow }
        InstDrive { install: flow }
        InstProgress { install: flow }
        InstDone { install: flow }
        InstFailedPanel { install: flow }
    }

    // ---- Back / Cancel / Continue
    RowLayout {
        id: foot
        visible: flow.page < 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 64
        width: 820
        spacing: 10

        LButton {
            kind: "ghost"
            text: flow.page === 0 ? qsTr("Not now") : "‹  " + qsTr("Back")
            onClicked: flow.page === 0 ? Sys.quit(2) : flow.back()
        }
        Item { Layout.fillWidth: true }
        LButton {
            kind: "primary"
            size: 46
            text: flow.page === 2 ? qsTr("Erase and install") : qsTr("Continue") + "  ›"
            enabled: flow.page !== 2 || flow.disk !== ""
            onClicked: flow.next()
        }
    }
}
