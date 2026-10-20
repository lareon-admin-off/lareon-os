import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property var sinks: []            // [{ name, label }]
    property string sink: ""
    property int outVolume: 50
    property bool outMuted: false
    property var sources: []
    property string source: ""
    property int inVolume: 50
    property bool inMuted: false
    property bool dnd: false
    property bool startupSound: true
    readonly property string autostartOverride: host.demo ? "" : Sys.homePath() + "/.config/autostart/lareon-startup-sound.desktop"

    function pct(v) {
        // pactl JSON volume: { "front-left": { value_percent: "65%" }, ... }
        for (const k in v) {
            const p = parseInt(String(v[k].value_percent))
            if (!isNaN(p)) return p
        }
        return 0
    }
    function parseDevices(out, wantMonitors) {
        let arr
        try { arr = JSON.parse(out) } catch (e) { return [] }
        return arr.filter(d => wantMonitors || String(d.name).indexOf(".monitor") < 0)
    }

    function load() {
        if (host.demo) {
            sinks = [{ name: "a", label: "Built-in speakers", volume: 65, mute: false }, { name: "b", label: "Headphones", volume: 40, mute: false }]
            sink = "a"; outVolume = 65
            sources = [{ name: "m", label: "Built-in microphone", volume: 80, mute: false }]
            source = "m"; inVolume = 80
            return
        }
        host.sh("pactl get-default-sink; pactl --format=json list sinks", function (code, out) {
            const nl = out.indexOf("\n")
            sink = out.substring(0, nl).trim()
            const devs = parseDevices(out.substring(nl + 1), true)
            sinks = devs.map(d => ({ name: d.name, label: d.description || d.name, volume: pct(d.volume), mute: d.mute === true }))
            const cur = sinks.filter(d => d.name === sink)[0]
            if (cur) { outVolume = cur.volume; outMuted = cur.mute }
        })
        host.sh("pactl get-default-source; pactl --format=json list sources", function (code, out) {
            const nl = out.indexOf("\n")
            source = out.substring(0, nl).trim()
            const devs = parseDevices(out.substring(nl + 1), false)
            sources = devs.map(d => ({ name: d.name, label: d.description || d.name, volume: pct(d.volume), mute: d.mute === true }))
            const cur = sources.filter(d => d.name === source)[0]
            if (cur) { inVolume = cur.volume; inMuted = cur.mute }
        })
        host.sh("busctl --user get-property org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications Inhibited", function (code, out) {
            dnd = out.indexOf("true") >= 0
        })
        startupSound = !Sys.exists(autostartOverride)
    }
    Component.onCompleted: load()

    function setOut(v) { outVolume = v; host.sh("pactl set-sink-volume @DEFAULT_SINK@ " + v + "%") }
    function setIn(v) { inVolume = v; host.sh("pactl set-source-volume @DEFAULT_SOURCE@ " + v + "%") }
    function pickOut(name) {
        sink = name
        host.sh("pactl set-default-sink " + host.q(name), function () { page.load() })
    }
    function pickIn(name) {
        source = name
        host.sh("pactl set-default-source " + host.q(name), function () { page.load() })
    }
    function setDnd(on) {
        dnd = on
        host.sh("busctl --user set-property org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications Inhibited b " + (on ? "true" : "false"))
    }
    function setStartup(on) {
        startupSound = on
        if (host.demo) return
        // a personal copy of the autostart entry, switched off, overrides the system one
        const dir = Sys.homePath() + "/.config/autostart"
        host.sh("mkdir -p " + host.q(dir) + " && " + (on
            ? "rm -f " + host.q(autostartOverride)
            : "printf '[Desktop Entry]\\nType=Application\\nName=Lareon startup sound\\nHidden=true\\n' > " + host.q(autostartOverride)))
    }

    SCard {
        title: qsTr("Output")
        SRow {
            visible: page.sinks.length > 1
            label: qsTr("Play sound through")
            SSelect {
                options: page.sinks.map(d => ({ label: d.label, value: d.name }))
                current: page.sink
                onPicked: v => page.pickOut(v)
            }
        }
        SRow {
            label: qsTr("Volume")
            Text { text: page.outVolume + "%"; color: Theme.muted; font.family: Theme.font; font.pixelSize: 13 }
            SSlider {
                from: 0
                to: 100
                value: page.outVolume
                enabled: !page.outMuted
                onMoved: v => page.outVolume = Math.round(v)
                onCommitted: v => page.setOut(Math.round(v))
            }
        }
        SRow {
            label: qsTr("Mute")
            LToggle {
                checked: page.outMuted
                onToggled: c => { page.outMuted = c; page.host.sh("pactl set-sink-mute @DEFAULT_SINK@ " + (c ? "1" : "0")) }
            }
        }
        SRow {
            label: qsTr("Test")
            hint: qsTr("Plays a short sound.")
            LButton {
                text: qsTr("Play sound")
                size: 36
                onClicked: Sys.startDetached("paplay", ["/usr/share/sounds/lareon/startup.wav"])
            }
        }
    }

    SCard {
        title: qsTr("Microphone")
        note: page.sources.length === 0 ? qsTr("No microphone found.") : ""
        SRow {
            visible: page.sources.length > 1
            label: qsTr("Listen with")
            SSelect {
                options: page.sources.map(d => ({ label: d.label, value: d.name }))
                current: page.source
                onPicked: v => page.pickIn(v)
            }
        }
        SRow {
            visible: page.sources.length > 0
            label: qsTr("Input volume")
            Text { text: page.inVolume + "%"; color: Theme.muted; font.family: Theme.font; font.pixelSize: 13 }
            SSlider {
                from: 0
                to: 100
                value: page.inVolume
                enabled: !page.inMuted
                onMoved: v => page.inVolume = Math.round(v)
                onCommitted: v => page.setIn(Math.round(v))
            }
        }
        SRow {
            visible: page.sources.length > 0
            label: qsTr("Mute microphone")
            LToggle {
                checked: page.inMuted
                onToggled: c => { page.inMuted = c; page.host.sh("pactl set-source-mute @DEFAULT_SOURCE@ " + (c ? "1" : "0")) }
            }
        }
    }

    SCard {
        title: qsTr("Quiet")
        SRow {
            label: qsTr("Do not disturb")
            hint: qsTr("Hide pop-up notifications until you turn this off.")
            LToggle {
                checked: page.dnd
                onToggled: c => page.setDnd(c)
            }
        }
        SRow {
            label: qsTr("Startup sound")
            hint: qsTr("Plays when you sign in.")
            LToggle {
                checked: page.startupSound
                onToggled: c => page.setStartup(c)
            }
        }
    }
}
