import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property string zone: ""
    property bool ntp: true
    property bool clock24: true
    property string lang: "en_US.UTF-8"
    property var zones: []
    property var langs: []
    property string nowText: ""

    function load() {
        if (host.demo) {
            zone = "Europe/Stockholm"; zones = [{ label: "Europe/Stockholm", value: "Europe/Stockholm" }, { label: "America/New_York", value: "America/New_York" }]
            langs = [{ label: "English", value: "en_US.UTF-8" }, { label: "Svenska", value: "sv_SE.UTF-8" }]
            nowText = "21:04"
            return
        }
        const z = Sys.timeZones()
        zones = z.map(x => ({ label: x, value: x }))
        host.sh("timedatectl show -p Timezone -p NTP --value", function (c, out) {
            const l = out.trim().split("\n")
            zone = l[0] || ""
            ntp = (l[1] || "yes") === "yes"
        })
        const lc = host.iniGet(host.config("plasma-localerc"), ["Formats"], "LANG")
        lang = lc !== "" ? lc : (Sys.env("LANG") || "en_US.UTF-8")
        host.sh("locale -a", function (c, out) {
            const seen = {}
            const arr = []
            out.split("\n").forEach(l => {
                const v = l.trim()
                if (!/\.utf-?8$/i.test(v) || seen[v]) return
                seen[v] = true
                const name = Qt.locale(v.split(".")[0]).nativeLanguageName
                const country = Qt.locale(v.split(".")[0]).nativeTerritoryName
                arr.push({ label: (name ? name.charAt(0).toUpperCase() + name.slice(1) : v) + (country ? " (" + country + ")" : ""), value: v })
            })
            arr.sort((a, b) => a.label.localeCompare(b.label))
            langs = arr
        })
        host.sh("grep -h use24hFormat ~/.config/plasma-org.kde.plasma.desktop-appletsrc 2>/dev/null | head -1", function (c, out) {
            page.clock24 = out.indexOf("=1") < 0
            page.tick()
        })
        tick()
    }
    function tick() { nowText = Qt.formatTime(new Date(), clock24 ? "HH:mm" : "h:mm AP") }
    Component.onCompleted: load()
    Timer { interval: 1000; running: true; repeat: true; onTriggered: page.tick() }

    function setZone(v) {
        zone = v
        host.run("pkexec", ["timedatectl", "set-timezone", v], "", function (c) {
            page.host.say(c === 0 ? qsTr("Time zone set to %1").arg(v) : qsTr("Couldn’t change the time zone"))
        })
    }
    function setNtp(on) {
        ntp = on
        host.run("pkexec", ["timedatectl", "set-ntp", on ? "true" : "false"], "")
    }
    function set24(on) {
        clock24 = on
        const js = "for (const p of panels()) for (const w of p.widgets()) { if (w.type === 'org.kde.plasma.digitalclock') { w.currentConfigGroup = ['Appearance']; w.writeConfig('use24hFormat', '" + (on ? "2" : "1") + "'); } }"
        host.sh("busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell evaluateScript s " + host.q(js))
        tick()
    }
    function setLang(v) {
        lang = v
        const cmd = host.kw("plasma-localerc", ["Formats"], "LANG", v) + " && " + host.kw("plasma-localerc", ["Translations"], "LANGUAGE", v.split(".")[0])
        host.sh(cmd, function () { page.host.say(qsTr("Language saved. Log out and back in to use it everywhere.")) })
    }

    SCard {
        title: qsTr("Date & time")
        Text {
            text: page.nowText
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 40
            font.weight: Font.DemiBold
        }
        SRow {
            label: qsTr("Set the time automatically")
            hint: qsTr("Uses internet time.")
            LToggle { checked: page.ntp; onToggled: c => page.setNtp(c) }
        }
        SRow {
            label: qsTr("24-hour clock")
            LToggle { checked: page.clock24; onToggled: c => page.set24(c) }
        }
        SRow {
            label: qsTr("Time zone")
            SSelect {
                options: page.zones
                current: page.zone
                popupHeight: 320
                onPicked: v => page.setZone(v)
            }
        }
    }

    SCard {
        title: qsTr("Language & region")
        SRow {
            label: qsTr("Language and formats")
            hint: qsTr("Applies the next time you sign in.")
            SSelect {
                options: page.langs
                current: page.lang
                popupHeight: 320
                onPicked: v => page.setLang(v)
            }
        }
    }
}
