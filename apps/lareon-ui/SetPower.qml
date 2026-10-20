import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property bool hasBattery: false
    property int batteryPct: 0
    property string batteryState: ""
    property int screenOffMin: 10      // 0 = never
    property int suspendMin: 0         // 0 = never
    property string profile: ""
    property bool hasProfiles: false

    readonly property var minuteOptions: [
        { label: qsTr("1 minute"), value: 1 }, { label: qsTr("5 minutes"), value: 5 },
        { label: qsTr("10 minutes"), value: 10 }, { label: qsTr("15 minutes"), value: 15 },
        { label: qsTr("30 minutes"), value: 30 }, { label: qsTr("1 hour"), value: 60 },
        { label: qsTr("Never"), value: 0 }
    ]

    function load() {
        if (host.demo) { hasBattery = true; batteryPct = 78; batteryState = "Discharging"; hasProfiles = true; profile = "balanced"; suspendMin = 30; return }
        const rc = host.config("powerdevilrc")
        const so = host.iniGet(rc, ["AC", "Display"], "TurnOffDisplayIdleTimeoutSec")
        const sn = host.iniGet(rc, ["AC", "Display"], "TurnOffDisplayWhenIdle")
        screenOffMin = sn === "false" ? 0 : (so !== "" ? Math.round(parseInt(so) / 60) : 10)
        const ss = host.iniGet(rc, ["AC", "SuspendAndShutdown"], "AutoSuspendIdleTimeoutSec")
        const sa = host.iniGet(rc, ["AC", "SuspendAndShutdown"], "AutoSuspendAction")
        suspendMin = (sa === "0" || ss === "") ? 0 : Math.round(parseInt(ss) / 60)
        host.sh("cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1; echo '#P'; powerprofilesctl get 2>/dev/null", function (c, out) {
            const parts = out.split("#P")
            const l = parts[0].trim().split("\n")
            hasBattery = l[0] !== "" && !isNaN(parseInt(l[0]))
            if (hasBattery) { batteryPct = parseInt(l[0]); batteryState = l[1] || "" }
            profile = (parts[1] || "").trim()
            hasProfiles = profile !== ""
        })
    }
    Component.onCompleted: load()

    function save(profileGroup) {
        const groups = ["AC", "Battery"]
        let cmd = ""
        groups.forEach(g => {
            cmd += host.kw("powerdevilrc", [g, "Display"], "TurnOffDisplayWhenIdle", screenOffMin > 0 ? "true" : "false") + "; "
            if (screenOffMin > 0) cmd += host.kw("powerdevilrc", [g, "Display"], "TurnOffDisplayIdleTimeoutSec", String(screenOffMin * 60)) + "; "
            cmd += host.kw("powerdevilrc", [g, "SuspendAndShutdown"], "AutoSuspendAction", suspendMin > 0 ? "1" : "0") + "; "
            if (suspendMin > 0) cmd += host.kw("powerdevilrc", [g, "SuspendAndShutdown"], "AutoSuspendIdleTimeoutSec", String(suspendMin * 60)) + "; "
        })
        cmd += "systemctl --user restart plasma-powerdevil.service"
        host.sh(cmd, function () { page.host.say(qsTr("Power settings saved")) })
    }

    SCard {
        visible: page.hasBattery
        title: qsTr("Battery")
        RowLayout {
            Layout.fillWidth: true
            spacing: 14
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 12
                radius: 6
                color: Theme.lines
                Rectangle {
                    width: parent.width * page.batteryPct / 100
                    height: parent.height
                    radius: 6
                    color: page.batteryPct < 20 ? Theme.danger : Theme.good
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }
            }
            Text {
                text: page.batteryPct + "%  ·  " + (page.batteryState === "Charging" ? qsTr("Charging") : page.batteryState === "Full" ? qsTr("Full") : qsTr("On battery"))
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 14
            }
        }
    }

    SCard {
        title: qsTr("Saving power")
        SRow {
            label: qsTr("Turn off the screen after")
            SSelect {
                options: page.minuteOptions
                current: page.screenOffMin
                onPicked: v => { page.screenOffMin = v; page.save() }
            }
        }
        SRow {
            label: qsTr("Go to sleep after")
            hint: qsTr("When nothing has happened for a while.")
            SSelect {
                options: page.minuteOptions
                current: page.suspendMin
                onPicked: v => { page.suspendMin = v; page.save() }
            }
        }
    }

    SCard {
        visible: page.hasProfiles
        title: qsTr("Performance")
        SRow {
            label: qsTr("Power mode")
            SSegment {
                options: [
                    { label: qsTr("Saver"), value: "power-saver" },
                    { label: qsTr("Balanced"), value: "balanced" },
                    { label: qsTr("Performance"), value: "performance" }
                ]
                current: page.profile
                onPicked: v => { page.profile = v; page.host.sh("powerprofilesctl set " + v) }
            }
        }
    }

    SCard {
        title: qsTr("Turn off")
        RowLayout {
            spacing: 10
            LButton { text: qsTr("Sleep"); onClicked: page.host.sh("systemctl suspend") }
            LButton { text: qsTr("Restart"); onClicked: page.host.sh("systemctl reboot") }
            LButton { text: qsTr("Shut down"); kind: "primary"; onClicked: page.host.sh("systemctl poweroff") }
        }
    }
}
