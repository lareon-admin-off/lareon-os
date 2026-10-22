import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// First-start setup: Hello → Wi-Fi → You → Lareon account → Look → Style → Privacy → Tour → All set.
// Runs once, full screen, before any desktop exists. Everything that changes
// the system goes through /usr/lib/lareon/setup-helper (run with sudo; the
// setup account is only allowed to run that one program).
Item {
    id: flow

    readonly property var stepNames: [qsTr("Wi-Fi"), qsTr("You"), qsTr("Lareon account"), qsTr("Look"), qsTr("Style"), qsTr("Privacy")]
    readonly property var pageKeys: ["hello", "wifi", "you", "lareon", "look", "style", "privacy", "tour", "done"]
    readonly property int pgPrivacy: 6
    readonly property int pgTour: 7
    readonly property int pgDone: 8
    property int page: Math.max(0, pageKeys.indexOf(Sys.startPage))

    // ---- what the person chooses
    property string language: "en"
    property string fullName: Sys.demo ? "Alex Lund" : ""
    property string userName: Sys.demo ? "alex" : ""
    property string hostName: Sys.demo ? "alex-laptop" : ""
    property string password: Sys.demo ? "demo-password" : ""
    property string timeZone: "UTC"
    property string avatar: ""
    property string lareonEmail: ""
    property string theme: "dark"
    property bool timeOfDay: true
    property bool followSun: false
    property string crashReports: "ask"
    property bool autoUpdates: true
    property string accent: "#ff7c1f"
    property string motion: "lively"
    property bool startupSound: true
    property string connectedTo: Sys.demo ? "Larsonia-Home" : ""

    // ---- running state
    property bool busy: false
    property string busyText: ""
    property string error: ""

    readonly property string helper: "/usr/lib/lareon/setup-helper"
    property var pending: ({})

    // Run a helper command; callback(exitCode, stdout, stderr).
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

    function firstName() {
        const n = fullName.trim()
        return n === "" ? "" : n.split(" ")[0]
    }

    function next() {
        error = ""
        if (page === pgPrivacy) {
            apply()
        } else if (page < pageKeys.length - 1) {
            page++
        }
    }
    function back() {
        error = ""
        if (page > 0 && page < pgTour) page--
    }

    // Create the account and save every choice.
    function apply() {
        busy = true
        busyText = qsTr("Setting up your account…")
        helperCall("apply", {
            language: language,
            full_name: fullName.trim(),
            user_name: userName,
            password: password,
            host_name: hostName,
            time_zone: timeZone,
            avatar: avatar,
            lareon_email: lareonEmail.trim(),
            theme: theme,
            time_of_day: timeOfDay,
            follow_sun: followSun,
            crash_reports: crashReports,
            auto_updates: autoUpdates,
            accent: accent,
            motion: motion,
            startup_sound: startupSound
        }, function(code, out, err) {
            busy = false
            if (code === 0) {
                page = pgTour
            } else {
                error = err.trim() !== "" ? err.trim() : qsTr("Something went wrong saving your account (error %1).").arg(code)
            }
        })
    }

    // Leave setup: the helper switches the sign-in screen to the new account,
    // then this session ends and the desktop starts.
    function finish() {
        busy = true
        busyText = qsTr("Starting Lareon OS…")
        helperCall("finish", {}, function(code, out, err) {
            Sys.quit(code === 0 ? 0 : 3)
        })
    }

    Component.onCompleted: {
        const look = Sys.readFile("/var/lib/lareon/look")
        const lt = look.match(/^theme=(dark|light)$/m)
        const la = look.match(/^accent=(#[0-9a-fA-F]{6})$/m)
        if (lt) theme = lt[1]
        if (la) accent = la[1]
        const saved = Sys.readFile("/var/lib/lareon/language").trim()
        if (saved !== "") language = saved
        const tz = Sys.readFile("/etc/timezone").trim()
        timeZone = (tz !== "" && tz !== "Etc/UTC") ? tz : guessZone(language)
    }

    // A sensible first guess per language; the person can change it.
    function guessZone(lang) {
        const zones = {
            en: "America/New_York", es: "Europe/Madrid", fr: "Europe/Paris", de: "Europe/Berlin",
            pt: "Europe/Lisbon", it: "Europe/Rome", ru: "Europe/Moscow", tr: "Europe/Istanbul",
            sv: "Europe/Stockholm", ja: "Asia/Tokyo", ko: "Asia/Seoul", zh: "Asia/Shanghai",
            hi: "Asia/Kolkata", ar: "Asia/Riyadh", fa: "Asia/Tehran", sw: "Africa/Dar_es_Salaam",
            ary: "Africa/Algiers"
        }
        return zones[lang] || "UTC"
    }

    // ---- layout
    Scene { anchors.fill: parent }

    TopBar {
        id: top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        title: qsTr("Set up Lareon OS")
        steps: flow.page > 0 && flow.page < flow.pgTour ? flow.stepNames : []
        current: flow.page - 1
    }

    StackLayout {
        id: pages
        anchors.top: top.bottom
        anchors.topMargin: 78
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: foot.top
        anchors.bottomMargin: 24
        width: 820
        currentIndex: flow.page

        HelloPage { onGo: flow.next() }
        PageWifi { setup: flow }
        PageYou { id: youPage; setup: flow }
        PageLareon { setup: flow }
        PageLook { setup: flow }
        PageStyle { setup: flow }
        PagePrivacy { setup: flow }
        PageTour { setup: flow }
        PageDone { setup: flow }
    }

    // ---- error message
    Rectangle {
        visible: flow.error !== ""
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: foot.top
        anchors.bottomMargin: 14
        width: 820
        height: errText.implicitHeight + 24
        radius: 10
        color: Qt.rgba(0.85, 0.23, 0.38, 0.16)
        border.color: Qt.rgba(1, 0.31, 0.48, 0.45)
        Text {
            id: errText
            anchors.fill: parent
            anchors.margins: 12
            text: flow.error
            wrapMode: Text.Wrap
            color: "#ffd0dc"
            font.family: Theme.font
            font.pixelSize: 14
        }
    }

    // ---- Back / Skip / Continue
    RowLayout {
        id: foot
        visible: flow.page > 0 && flow.page < flow.pgDone
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 64
        width: 820
        spacing: 10

        LButton {
            kind: "ghost"
            text: "‹  " + qsTr("Back")
            visible: flow.page > 0 && flow.page < flow.pgTour
            onClicked: flow.back()
        }
        Item { Layout.fillWidth: true }
        LButton {
            kind: "ghost"
            text: qsTr("Skip for now")
            visible: flow.page === 1 && flow.connectedTo === ""
            onClicked: flow.next()
        }
        LButton {
            kind: flow.page === 3 && flow.lareonEmail.trim() === "" ? "normal" : "primary"
            text: flow.page === 3 && flow.lareonEmail.trim() === "" ? qsTr("Skip") : (flow.page === flow.pgTour ? qsTr("Finish") : qsTr("Continue")) + "  ›"
            enabled: !flow.busy && (flow.page !== 2 || youPage.valid)
            onClicked: flow.next()
        }
    }

    // ---- busy overlay
    Rectangle {
        anchors.fill: parent
        visible: flow.busy
        color: Qt.rgba(0.075, 0.067, 0.106, 0.82)
        MouseArea { anchors.fill: parent }
        Column {
            anchors.centerIn: parent
            spacing: 20
            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: flow.busy
            }
            Text {
                text: flow.busyText
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 17
            }
        }
    }
}
