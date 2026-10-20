import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property var screens: []          // [{ name, modeId, size, sizes, modes, scale, rotation }]
    property bool failed: false
    property bool nightOn: false
    property int nightTemp: 4500
    property string nightMode: "Times"
    property bool hasBrightness: false
    property int brightness: 50
    property int brightnessMax: 100

    function sizeKey(m) { return m.size.width + "x" + m.size.height }

    function parse(out) {
        let data
        try { data = JSON.parse(out) } catch (e) { failed = true; return }
        const list = []
        const outs = data.outputs || []
        for (let i = 0; i < outs.length; i++) {
            const o = outs[i]
            if (o.enabled === false) continue
            const modes = (o.modes || []).filter(m => m.size && m.size.width)
            let cur = null
            for (let k = 0; k < modes.length; k++) if (String(modes[k].id) === String(o.currentModeId)) cur = modes[k]
            list.push({
                name: o.name || ("Screen " + (i + 1)),
                modeId: cur ? String(cur.id) : "",
                curSize: cur ? sizeKey(cur) : "",
                curRate: cur ? Math.round(cur.refreshRate) : 0,
                modes: modes.map(m => ({ id: String(m.id), size: sizeKey(m), w: m.size.width, h: m.size.height, rate: Math.round(m.refreshRate) })),
                scale: Math.round((o.scale || 1) * 100),
                rotation: o.rotation || 1
            })
        }
        failed = list.length === 0
        screens = list
    }

    function load() {
        if (host.demo) {
            screens = [{
                name: "eDP-1", modeId: "1", curSize: "1920x1080", curRate: 60,
                modes: [
                    { id: "1", size: "1920x1080", w: 1920, h: 1080, rate: 60 },
                    { id: "2", size: "1920x1080", w: 1920, h: 1080, rate: 144 },
                    { id: "3", size: "1600x900", w: 1600, h: 900, rate: 60 },
                    { id: "4", size: "1280x720", w: 1280, h: 720, rate: 60 }
                ],
                scale: 100, rotation: 1
            }]
            nightOn = true
            hasBrightness = true
            brightness = 70
            return
        }
        host.sh("kscreen-doctor -j", function (code, out) {
            if (code !== 0) { failed = true; return }
            parse(out)
        })
        const kc = host.config("kwinrc")
        nightOn = host.iniGet(kc, ["NightColor"], "Active") === "true"
        const t = parseInt(host.iniGet(kc, ["NightColor"], "NightTemperature"))
        if (!isNaN(t)) nightTemp = t
        const m = host.iniGet(kc, ["NightColor"], "Mode")
        if (m !== "") nightMode = m
        const br = "busctl --user call org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl "
        host.sh(br + "brightnessMax", function (c1, o1) {
            const mx = parseInt(String(o1).replace(/^[a-z]+\s+/, ""))
            if (c1 !== 0 || isNaN(mx) || mx <= 0) return
            host.sh(br + "brightness", function (c2, o2) {
                const v = parseInt(String(o2).replace(/^[a-z]+\s+/, ""))
                if (c2 !== 0 || isNaN(v)) return
                brightnessMax = mx
                brightness = Math.round(v * 100 / mx)
                hasBrightness = true
            })
        })
    }
    Component.onCompleted: load()
    Timer { id: reloadSoon; interval: 1400; onTriggered: page.load() }

    function change(name, what) {
        host.sh("kscreen-doctor output." + name + "." + what, function (code) {
            if (code !== 0) host.say(qsTr("Couldn’t change the display"))
            reloadSoon.restart()
        })
    }
    function setNight() {
        host.sh(host.kw("kwinrc", ["NightColor"], "Active", nightOn ? "true" : "false") +
                " && " + host.kw("kwinrc", ["NightColor"], "Mode", nightMode) +
                " && " + host.kw("kwinrc", ["NightColor"], "NightTemperature", String(nightTemp)) +
                " && " + host.kw("kwinrc", ["NightColor"], "EveningBeginFixed", "2000") +
                " && " + host.kw("kwinrc", ["NightColor"], "MorningBeginFixed", "0700") +
                " && (" + host.reconfigureKWin() + " || true)")
    }
    function setBrightness(pct) {
        brightness = pct
        const v = Math.max(1, Math.round(pct * brightnessMax / 100))
        host.sh("busctl --user call org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl setBrightness i " + v)
    }

    SCard {
        visible: page.hasBrightness
        title: qsTr("Brightness")
        SRow {
            label: qsTr("Screen brightness")
            Text { text: page.brightness + "%"; color: Theme.muted; font.family: Theme.font; font.pixelSize: 13 }
            SSlider {
                from: 5
                to: 100
                value: page.brightness
                onMoved: v => page.brightness = Math.round(v)
                onCommitted: v => page.setBrightness(Math.round(v))
            }
        }
    }

    Repeater {
        model: page.screens
        delegate: SCard {
            id: card
            required property var modelData
            title: page.screens.length > 1 ? qsTr("Screen %1").arg(modelData.name) : qsTr("Screen")

            readonly property var sizes: {
                const seen = {}
                const out = []
                const ms = modelData.modes.slice().sort((a, b) => (b.w * b.h) - (a.w * a.h))
                for (let i = 0; i < ms.length; i++) {
                    if (seen[ms[i].size]) continue
                    seen[ms[i].size] = true
                    out.push({ label: ms[i].w + " × " + ms[i].h, value: ms[i].size })
                }
                return out
            }
            readonly property var rates: {
                const out = []
                const seen = {}
                for (let i = 0; i < modelData.modes.length; i++) {
                    const m = modelData.modes[i]
                    if (m.size !== modelData.curSize || seen[m.rate]) continue
                    seen[m.rate] = true
                    out.push({ label: m.rate + " Hz", value: m.id, rate: m.rate })
                }
                out.sort((a, b) => b.rate - a.rate)
                return out
            }

            SRow {
                label: qsTr("Resolution")
                SSelect {
                    options: card.sizes
                    current: modelData.curSize
                    onPicked: v => {
                        // keep the refresh rate if the new size has it, else the first mode of that size
                        let best = null
                        for (let i = 0; i < modelData.modes.length; i++) {
                            const m = modelData.modes[i]
                            if (m.size !== v) continue
                            if (best === null || Math.abs(m.rate - modelData.curRate) < Math.abs(best.rate - modelData.curRate)) best = m
                        }
                        if (best) page.change(modelData.name, "mode." + best.id)
                    }
                }
            }
            SRow {
                visible: card.rates.length > 1
                label: qsTr("Refresh rate")
                SSelect {
                    options: card.rates
                    current: modelData.modeId
                    onPicked: v => page.change(modelData.name, "mode." + v)
                }
            }
            SRow {
                label: qsTr("Size of everything")
                hint: qsTr("Make text and buttons bigger on a high-resolution screen.")
                SSegment {
                    current: modelData.scale
                    options: [ { label: "100%", value: 100 }, { label: "125%", value: 125 }, { label: "150%", value: 150 }, { label: "200%", value: 200 } ]
                    onPicked: v => page.change(modelData.name, "scale." + (v / 100).toFixed(2))
                }
            }
            SRow {
                label: qsTr("Orientation")
                SSegment {
                    current: modelData.rotation
                    options: [ { label: qsTr("Normal"), value: 1 }, { label: qsTr("Left"), value: 2 }, { label: qsTr("Flipped"), value: 4 }, { label: qsTr("Right"), value: 8 } ]
                    onPicked: v => page.change(modelData.name, "rotation." + (v === 1 ? "normal" : v === 2 ? "left" : v === 4 ? "inverted" : "right"))
                }
            }
        }
    }

    SCard {
        visible: page.failed && page.screens.length === 0
        title: qsTr("Screen")
        note: qsTr("Lareon couldn’t read the screen list here. This can happen in a virtual machine.")
        LButton {
            text: qsTr("Open display settings")
            onClicked: Sys.startDetached("systemsettings", ["kcm_kscreen"])
        }
    }

    SCard {
        title: qsTr("Night light")
        note: qsTr("Warmer colours in the evening are easier on the eyes.")
        SRow {
            label: qsTr("Night light")
            LToggle {
                checked: page.nightOn
                onToggled: c => { page.nightOn = c; page.setNight() }
            }
        }
        SRow {
            opacity: page.nightOn ? 1 : 0.4
            label: qsTr("When")
            SSegment {
                current: page.nightMode
                options: [ { label: qsTr("Evening (8 pm to 7 am)"), value: "Times" }, { label: qsTr("All day"), value: "Constant" } ]
                onPicked: v => { page.nightMode = v; page.setNight() }
            }
        }
        SRow {
            opacity: page.nightOn ? 1 : 0.4
            label: qsTr("Warmth")
            Text { text: page.nightTemp + " K"; color: Theme.muted; font.family: Theme.font; font.pixelSize: 13 }
            SSlider {
                from: 6000
                to: 2500
                value: page.nightTemp
                enabled: page.nightOn
                onMoved: v => page.nightTemp = Math.round(v / 100) * 100
                onCommitted: v => { page.nightTemp = Math.round(v / 100) * 100; page.setNight() }
            }
        }
    }
}
