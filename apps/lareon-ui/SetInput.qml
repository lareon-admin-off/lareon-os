import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property string layouts: "us"          // comma list
    property bool tapToClick: true
    property bool naturalScroll: false
    property real pointerSpeed: 0          // -1 .. 1
    property bool hasTouchpad: false
    property bool loaded: false

    readonly property var known: [
        { label: "English (US)", value: "us" }, { label: "English (UK)", value: "gb" },
        { label: "Deutsch", value: "de" }, { label: "Français", value: "fr" },
        { label: "Español", value: "es" }, { label: "Italiano", value: "it" },
        { label: "Português", value: "pt" }, { label: "Nederlands", value: "nl" },
        { label: "Svenska", value: "se" }, { label: "Norsk", value: "no" },
        { label: "Dansk", value: "dk" }, { label: "Suomi", value: "fi" },
        { label: "Polski", value: "pl" }, { label: "Čeština", value: "cz" },
        { label: "Türkçe", value: "tr" }, { label: "Русский", value: "ru" },
        { label: "Українська", value: "ua" }, { label: "العربية", value: "ara" },
        { label: "עברית", value: "il" }, { label: "日本語", value: "jp" },
        { label: "한국어", value: "kr" }
    ]
    function nameOf(code) {
        for (let i = 0; i < known.length; i++) if (known[i].value === code) return known[i].label
        return code
    }
    readonly property var layoutList: layouts.split(",").filter(x => x !== "")

    function load() {
        if (host.demo) { layouts = "us,de"; hasTouchpad = true; tapToClick = true; loaded = true; return }
        const kx = host.config("kxkbrc")
        const l = host.iniGet(kx, ["Layout"], "LayoutList")
        layouts = l !== "" ? l : "us"
        const inp = host.config("kcminputrc")
        const t = host.iniGet(inp, ["Libinput", "Touchpad"], "TapToClick")
        const ns = host.iniGet(inp, ["Libinput", "Touchpad"], "NaturalScroll")
        tapToClick = t !== "false"
        naturalScroll = ns === "true"
        host.sh("ls /sys/class/input/*/name 2>/dev/null | xargs cat 2>/dev/null | grep -ic touchpad", function (c, out) {
            hasTouchpad = parseInt(out) > 0
            loaded = true
        })
    }
    Component.onCompleted: load()

    function saveLayouts(list) {
        layouts = list.join(",")
        const cmd = host.kw("kxkbrc", ["Layout"], "LayoutList", layouts)
            + " && " + host.kw("kxkbrc", ["Layout"], "Use", "true")
            + " && " + host.kw("kxkbrc", ["Layout"], "VariantList", list.map(() => "").join(","))
            + " && busctl --user emit /Layouts org.kde.keyboard reloadConfig"
        host.sh(cmd, function () { page.host.say(qsTr("Keyboard layouts saved")) })
    }
    function addLayout(code) {
        if (layoutList.indexOf(code) >= 0) return
        saveLayouts(layoutList.concat([code]))
    }
    function removeLayout(code) {
        if (layoutList.length <= 1) return
        saveLayouts(layoutList.filter(x => x !== code))
    }
    function setLibinput(key, val) {
        // remember it for next sign-in, and apply it to the touchpads right now
        const prop = key === "TapToClick" ? "tapToClick" : "naturalScroll"
        host.sh(host.kw("kcminputrc", ["Libinput", "Touchpad"], key, val ? "true" : "false")
                + "; for d in $(busctl --user tree org.kde.KWin --list 2>/dev/null | grep '/org/kde/KWin/InputDevice/event'); do "
                + "busctl --user set-property org.kde.KWin $d org.kde.KWin.InputDevice " + prop + " b " + (val ? "true" : "false") + " >/dev/null 2>&1; done; true")
    }

    SCard {
        title: qsTr("Keyboard layouts")
        note: qsTr("Switch between layouts with Meta + Space.")
        Repeater {
            model: page.layoutList
            delegate: RowLayout {
                required property string modelData
                Layout.fillWidth: true
                spacing: 12
                LIcon { size: 22; source: host.icon("input-keyboard") }
                Text {
                    Layout.fillWidth: true
                    text: page.nameOf(modelData)
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 15
                }
                Text {
                    text: modelData
                    color: Theme.faint
                    font.family: Theme.mono
                    font.pixelSize: 12
                }
                LButton {
                    visible: page.layoutList.length > 1
                    text: qsTr("Remove")
                    kind: "ghost"
                    size: 30
                    onClicked: page.removeLayout(modelData)
                }
            }
        }
        SRow {
            label: qsTr("Add a layout")
            SSelect {
                options: page.known.filter(k => page.layoutList.indexOf(k.value) < 0)
                placeholder: qsTr("Choose a language…")
                onPicked: v => page.addLayout(v)
            }
        }
    }

    SCard {
        title: qsTr("Touchpad")
        note: page.loaded && !page.hasTouchpad ? qsTr("No touchpad found. These settings apply when one is connected.") : ""
        SRow {
            label: qsTr("Tap to click")
            LToggle {
                checked: page.tapToClick
                onToggled: c => { page.tapToClick = c; page.setLibinput("TapToClick", c) }
            }
        }
        SRow {
            label: qsTr("Natural scrolling")
            hint: qsTr("Content follows your fingers, like on a phone.")
            LToggle {
                checked: page.naturalScroll
                onToggled: c => { page.naturalScroll = c; page.setLibinput("NaturalScroll", c) }
            }
        }
    }

    SCard {
        title: qsTr("Shortcuts you’ll use")
        Repeater {
            model: [
                { keys: "Meta", what: qsTr("Open the app menu") },
                { keys: "Meta + Space", what: qsTr("Switch keyboard layout") },
                { keys: "Alt + Tab", what: qsTr("Switch between windows") },
                { keys: "Meta + L", what: qsTr("Lock the screen") },
                { keys: "Print", what: qsTr("Take a screenshot") }
            ]
            delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: modelData.what
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 14
                }
                Rectangle {
                    implicitWidth: kt.implicitWidth + 20
                    implicitHeight: 26
                    radius: 8
                    color: Theme.panel2
                    border.width: 1
                    border.color: Theme.lines
                    Text {
                        id: kt
                        anchors.centerIn: parent
                        text: modelData.keys
                        color: Theme.muted
                        font.family: Theme.mono
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}
