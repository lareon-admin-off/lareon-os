import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property bool dark: true
    property bool animations: true
    property real speed: 0.7
    property int dockSize: 62
    property bool dockHide: false
    property int cursorSize: 24
    property bool timeOfDay: true
    property string accentHex: ""
    property var pictures: []
    readonly property var accents: [
        { name: qsTr("Orange"), hex: "#ff7c1f" }, { name: qsTr("Pink"), hex: "#d94fc4" },
        { name: qsTr("Violet"), hex: "#a35cf5" }, { name: qsTr("Blue"), hex: "#3d8bff" },
        { name: qsTr("Green"), hex: "#2fbf7a" }, { name: qsTr("Red"), hex: "#ff4f5e" }
    ]

    function load() {
        const kg = host.config("kdeglobals")
        const lf = host.iniGet(kg, ["KDE"], "LookAndFeelPackage")
        dark = lf.indexOf("light") < 0
        const f = parseFloat(host.iniGet(kg, ["KDE"], "AnimationDurationFactor"))
        if (!isNaN(f)) {
            animations = f > 0
            if (f > 0) speed = f
        }
        const cs = parseInt(host.iniGet(host.config("kcminputrc"), ["Mouse"], "cursorSize"))
        if (!isNaN(cs)) cursorSize = cs
        accentHex = host.iniGet(kg, ["General"], "AccentColor") !== "" ? "custom" : "#ff7c1f"
        timeOfDay = Sys.readFile(Sys.homePath() + "/.config/lareon/timeofday.conf").indexOf("enabled=false") < 0
        const home = Sys.homePath() + "/Pictures"
        pictures = Sys.listFiles(home, ["*.png", "*.jpg", "*.jpeg", "*.webp"]).slice(0, 12).map(f => home + "/" + f)
    }
    function setAccent(hex) {
        accentHex = hex
        const rgb = [1, 3, 5].map(i => parseInt(hex.substr(i, 2), 16)).join(",")
        host.sh("plasma-apply-colorscheme --accent-color " + host.q(hex) + " || " + host.kw("kdeglobals", ["General"], "AccentColor", rgb),
                function () { page.host.say(qsTr("Accent colour changed")) })
    }
    function setTimeOfDay(on) {
        timeOfDay = on
        host.sh("lareon-timeofday " + (on ? "enable" : "disable"))
    }
    function setWallpaper(path) {
        timeOfDay = false
        host.sh("lareon-timeofday disable; plasma-apply-wallpaperimage " + host.q(path), function () { page.host.say(qsTr("Wallpaper changed")) })
    }
    Component.onCompleted: load()

    function setLook(wantDark) {
        dark = wantDark
        host.say(qsTr("Switching theme…"))
        host.sh("plasma-apply-lookandfeel -a " + (wantDark ? "org.lareon.desktop" : "org.lareon.desktop.light"), function (code) {
            if (code !== 0) host.say(qsTr("Couldn’t switch the theme"))
        })
    }

    function applyAnimations() {
        host.sh(host.kw("kdeglobals", ["KDE"], "AnimationDurationFactor", animations ? speed.toFixed(2) : "0") +
                " && (" + host.reconfigureKWin() + " || true)")
    }

    function panelScript(js) {
        host.sh("busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell evaluateScript s " + host.q(
            "var ps = panels(); for (var i = 0; i < ps.length; i++) { if (ps[i].location == 'left' || ps[i].location == 'right') { " + js + " } }"))
    }

    function setCursor(px) {
        cursorSize = px
        const theme = host.iniGet(host.config("kcminputrc"), ["Mouse"], "cursorTheme") || "breeze_cursors"
        host.sh("plasma-apply-cursortheme --size " + px + " " + host.q(theme), function (code) {
            host.say(code === 0 ? qsTr("Cursor size changed") : qsTr("Saved. It shows after you sign in again."))
        })
    }

    SCard {
        title: qsTr("Theme")
        note: qsTr("Switching takes a few seconds. Your windows stay open.")
        RowLayout {
            Layout.fillWidth: true
            spacing: 14
            Repeater {
                model: [ { name: qsTr("Dark"), isDark: true }, { name: qsTr("Light"), isDark: false } ]
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool isOn: page.dark === modelData.isDark
                    Layout.fillWidth: true
                    Layout.preferredHeight: 104
                    radius: 14
                    border.width: isOn ? 2 : 1
                    border.color: isOn ? Theme.accent : Theme.lines
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: modelData.isDark ? "#1a1824" : "#f4effb" }
                        GradientStop { position: 1.0; color: modelData.isDark ? "#13111b" : "#e6d9f5" }
                    }
                    // a little window, so the tile shows what you get
                    Rectangle {
                        x: 16
                        y: 16
                        width: 92
                        height: 52
                        radius: 8
                        color: modelData.isDark ? "#211e2d" : "#ffffff"
                        border.width: 1
                        border.color: modelData.isDark ? "#2b2838" : "#e0d4f0"
                        Rectangle { x: 8; y: 9; width: 40; height: 5; radius: 2.5; color: Theme.accent }
                        Rectangle { x: 8; y: 21; width: 60; height: 4; radius: 2; color: modelData.isDark ? "#3a3650" : "#d7c9ea" }
                        Rectangle { x: 8; y: 30; width: 48; height: 4; radius: 2; color: modelData.isDark ? "#3a3650" : "#d7c9ea" }
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.margins: 14
                        text: modelData.name
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: modelData.isDark ? Theme.text : "#1d1832"
                    }
                    scale: tapIt.pressed ? 0.98 : 1
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    TapHandler { id: tapIt; onTapped: page.setLook(modelData.isDark) }
                }
            }
        }
    }

    SCard {
        title: qsTr("Accent colour")
        note: qsTr("Buttons, selections and highlights in apps that follow the system colours.")
        Row {
            spacing: 12
            Repeater {
                model: page.accents
                delegate: Rectangle {
                    required property var modelData
                    width: 36
                    height: 36
                    radius: 18
                    color: modelData.hex
                    border.width: page.accentHex === modelData.hex ? 3 : 0
                    border.color: "white"
                    scale: ah.hovered ? 1.1 : 1
                    Behavior on scale { NumberAnimation { duration: 120 } }
                    HoverHandler { id: ah; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: page.setAccent(modelData.hex) }
                }
            }
        }
    }

    SCard {
        title: qsTr("Wallpaper")
        SRow {
            label: qsTr("Change with the time of day")
            hint: qsTr("The Lareon mountains follow your clock, from dawn to night. The lock screen follows too.")
            LToggle { checked: page.timeOfDay; onToggled: c => page.setTimeOfDay(c) }
        }
        Text {
            visible: page.pictures.length > 0
            text: qsTr("Or pick one of your pictures")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 13
        }
        Flow {
            Layout.fillWidth: true
            spacing: 10
            Repeater {
                model: page.pictures
                delegate: Rectangle {
                    required property string modelData
                    width: 120
                    height: 72
                    radius: 10
                    color: Theme.panel2
                    clip: true
                    Image {
                        anchors.fill: parent
                        source: "file://" + modelData
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: 240
                        asynchronous: true
                    }
                    TapHandler { onTapped: page.setWallpaper(modelData) }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                }
            }
        }
        Text {
            visible: page.pictures.length === 0
            text: qsTr("Put pictures in your Pictures folder and they show up here.")
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 13
        }
    }

    SCard {
        title: qsTr("Motion")
        SRow {
            label: qsTr("Smooth animations")
            hint: qsTr("Windows and menus glide instead of jumping.")
            LToggle {
                checked: page.animations
                onToggled: c => { page.animations = c; page.applyAnimations() }
            }
        }
        SRow {
            label: qsTr("Animation speed")
            opacity: page.animations ? 1 : 0.4
            Text { text: qsTr("Slower"); color: Theme.muted; font.family: Theme.font; font.pixelSize: 13 }
            SSlider {
                from: 1.3
                to: 0.3
                value: page.speed
                enabled: page.animations
                onMoved: v => page.speed = v
                onCommitted: v => { page.speed = v; page.applyAnimations() }
            }
            Text { text: qsTr("Faster"); color: Theme.muted; font.family: Theme.font; font.pixelSize: 13 }
        }
    }

    SCard {
        title: qsTr("Dock")
        SRow {
            label: qsTr("Hide the dock")
            hint: qsTr("It slides out when you move the pointer to the left edge.")
            LToggle {
                checked: page.dockHide
                onToggled: c => {
                    page.dockHide = c
                    page.panelScript("ps[i].hiding = '" + (c ? "autohide" : "none") + "';")
                }
            }
        }
        SRow {
            label: qsTr("Dock size")
            SSegment {
                current: page.dockSize
                options: [ { label: qsTr("Small"), value: 48 }, { label: qsTr("Normal"), value: 62 }, { label: qsTr("Large"), value: 76 } ]
                onPicked: v => {
                    page.dockSize = v
                    page.panelScript("ps[i].height = " + v + ";")
                }
            }
        }
    }

    SCard {
        title: qsTr("Pointer")
        SRow {
            label: qsTr("Cursor size")
            SSegment {
                current: page.cursorSize
                options: [ { label: qsTr("Small"), value: 24 }, { label: qsTr("Medium"), value: 32 }, { label: qsTr("Large"), value: 48 } ]
                onPicked: v => page.setCursor(v)
            }
        }
    }
}
