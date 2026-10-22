import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// The Lareon OS installer: Hello → Promise → Check → Language → Keyboard → Place → Look → Drive → Review → Install → Done.
// Everything that touches the computer goes through /usr/lib/lareon/lareon-install
// (run with sudo in the live session). It reports progress in a small file that
// this screen reads twice a second.
Item {
    id: flow

    readonly property var stepNames: [qsTr("Check"), qsTr("Language"), qsTr("Keyboard"), qsTr("Place"), qsTr("Look"), qsTr("Drive"), qsTr("Review"), qsTr("Install")]
    readonly property var pageKeys: ["hello", "promise", "check", "language", "keyboard", "place", "look", "drive", "review", "install", "done", "failed"]
    readonly property int pgPromise: 1
    readonly property int pgCheck: 2
    readonly property int pgDrive: 7
    readonly property int pgReview: 8
    readonly property int pgInstall: 9
    readonly property int pgDone: 10
    readonly property int pgFailed: 11
    property int page: Math.max(0, pageKeys.indexOf(Sys.startPage))

    // ---- what the person chooses
    property string language: "en"
    property string keyboard: "us"
    property bool keyboardTouched: false
    property bool understood: Sys.demo
    property string timeZone: "UTC"
    property bool zoneTouched: false
    property string theme: "dark"
    property string accent: "#ff7c1f"
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

    // Run a plain shell command (no root needed); callback(exitCode, stdout, stderr).
    function shell(cmd, callback) {
        if (Sys.demo) {
            Qt.callLater(callback, 0, "", "")
            return
        }
        const id = Sys.run("sh", ["-c", cmd])
        pending[id] = callback
    }
    function languageName() {
        const n = { en: "English", es: "Español", fr: "Français", de: "Deutsch", pt: "Português", it: "Italiano", ru: "Русский",
                    tr: "Türkçe", sv: "Svenska", ja: "日本語", ko: "한국어", zh: "中文", hi: "हिन्दी", ar: "العربية", fa: "فارسی",
                    sw: "Kiswahili", ary: "الدارجة" }
        return n[language] || language
    }

    // The keyboard that usually goes with each language (the person can change it).
    function layoutFor(lang) {
        const m = { en: "us", es: "es", fr: "fr", de: "de", pt: "pt", it: "it", ru: "ru", tr: "tr",
                    sv: "se", ja: "jp", ko: "kr", zh: "cn", hi: "in", ar: "ara", fa: "ir", sw: "us", ary: "ara" }
        return m[lang] || "us"
    }
    function zoneFor(lang) {
        const z = { en: "America/New_York", es: "Europe/Madrid", fr: "Europe/Paris", de: "Europe/Berlin",
                    pt: "Europe/Lisbon", it: "Europe/Rome", ru: "Europe/Moscow", tr: "Europe/Istanbul",
                    sv: "Europe/Stockholm", ja: "Asia/Tokyo", ko: "Asia/Seoul", zh: "Asia/Shanghai",
                    hi: "Asia/Kolkata", ar: "Asia/Riyadh", fa: "Asia/Tehran", sw: "Africa/Dar_es_Salaam", ary: "Africa/Algiers" }
        return z[lang] || "UTC"
    }
    onLanguageChanged: {
        if (!keyboardTouched) keyboard = layoutFor(language)
        if (!zoneTouched) timeZone = zoneFor(language)
    }
    Component.onCompleted: if (!zoneTouched) timeZone = zoneFor(language)

    function next() {
        if (page === pgReview) {
            startInstall()
        } else if (page < pgReview) {
            page++
        }
    }
    function back() {
        if (page > pgPromise && page < pgInstall) page--
    }

    function startInstall() {
        error = ""
        percent = 0
        stepText = qsTr("Getting ready")
        detail = ""
        installing = true
        page = pgInstall
        if (Sys.demo) return
        helperCall("install", { disk: disk, language: language, keyboard: keyboard, time_zone: timeZone, theme: theme, accent: accent }, function(code, out, err) {
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
        page = pgFailed
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
                flow.page = flow.pgDone
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
        steps: flow.page >= flow.pgCheck && flow.page < flow.pgDone ? flow.stepNames : []
        current: flow.page - flow.pgCheck
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

        HelloPage { lead: qsTr("Let’s put Lareon OS on this computer."); buttonText: qsTr("Get started"); hint: qsTr("It takes about ten minutes."); onGo: flow.next() }
        InstPromise { install: flow }
        InstCheck { install: flow }
        InstLanguage { install: flow }
        InstKeyboard { install: flow }
        InstZone { install: flow }
        InstLook { install: flow }
        InstDrive { install: flow }
        InstReview { install: flow }
        InstProgress { install: flow }
        InstDone { install: flow }
        InstFailedPanel { install: flow }
    }

    // ---- Back / Cancel / Continue
    RowLayout {
        id: foot
        visible: flow.page > 0 && flow.page < flow.pgInstall
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 64
        width: 820
        spacing: 10

        LButton {
            kind: "ghost"
            text: flow.page === flow.pgPromise ? qsTr("Not now") : "‹  " + qsTr("Back")
            onClicked: flow.page === flow.pgPromise ? Sys.quit(2) : flow.back()
        }
        Item { Layout.fillWidth: true }
        LButton {
            kind: "primary"
            size: 46
            text: flow.page === flow.pgReview ? qsTr("Erase and install") : qsTr("Continue") + "  ›"
            enabled: (flow.page !== flow.pgDrive || flow.disk !== "") && (flow.page !== flow.pgReview || flow.understood)
            onClicked: flow.next()
        }
    }
}
