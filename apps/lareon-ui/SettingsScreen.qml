import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// Lareon Settings: the everyday settings in Lareon's own look. Anything not
// covered here opens in KDE's full Settings ("More settings").
Item {
    id: root

    property string current: Sys.args.page || "appearance"

    readonly property var pages: [
        { id: "appearance", title: qsTr("Appearance"), icon: "preferences-desktop-theme-global" },
        { id: "display",    title: qsTr("Display"),    icon: "preferences-desktop-display" },
        { id: "sound",      title: qsTr("Sound"),      icon: "preferences-desktop-sound" },
        { id: "network",    title: qsTr("Network"),    icon: "preferences-system-network" },
        { id: "bluetooth",  title: qsTr("Bluetooth"),  icon: "bluetooth", kcm: "kcm_bluetooth", blurb: qsTr("Pair headphones, keyboards, mice and phones.") },
        { id: "input",      title: qsTr("Keyboard & mouse"), icon: "input-keyboard", kcm: "kcm_keyboard", blurb: qsTr("Keyboard layouts, shortcuts, pointer speed and touchpad.") },
        { id: "power",      title: qsTr("Power"),      icon: "preferences-system-power-management", kcm: "kcm_powerdevilprofilesconfig", blurb: qsTr("Sleep, screen off and battery behaviour.") },
        { id: "users",      title: qsTr("Users"),      icon: "system-users", kcm: "kcm_users", blurb: qsTr("Your account, picture and password.") },
        { id: "privacy",    title: qsTr("Privacy"),    icon: "preferences-system-privacy", kcm: "kcm_recentFiles", blurb: qsTr("Recent files, history and what apps can see.") },
        { id: "updates",    title: qsTr("Updates"),    icon: "system-software-update" },
        { id: "about",      title: qsTr("About"),      icon: "help-about" }
    ]

    function pageInfo(id) {
        for (let i = 0; i < pages.length; i++) {
            if (pages[i].id === id) return pages[i]
        }
        return pages[0]
    }

    function iconUrl(name) {
        return "file:///usr/share/icons/Lareon/scalable/apps/" + name + ".svg"
    }

    // --- running programs, with a callback for each ---------------------------
    property var callbacks: ({})
    function sh(cmd, cb) {
        if (Sys.demo) {
            if (cb) cb(0, "", "")
            return
        }
        const id = Sys.run("sh", ["-c", cmd])
        if (cb) callbacks[id] = cb
    }
    Connections {
        target: Sys
        function onFinished(id, exitCode, out, err) {
            const cb = root.callbacks[id]
            if (cb) {
                delete root.callbacks[id]
                cb(exitCode, out, err)
            }
        }
    }

    // --- shared state ---------------------------------------------------------
    property bool dark: true
    property bool animations: true
    property real animSpeed: 0.7          // seconds-ish factor, lower is faster
    property real volume: 0.65
    property bool muted: false
    property bool wifiOn: true
    property var networks: []
    property string netMessage: ""
    property int uiScale: 100

    function loadAppearance() {
        const kg = Sys.readFile(Sys.homePath() + "/.config/kdeglobals")
        const m = kg.match(/LookAndFeelPackage=(.*)/)
        dark = !(m && m[1].indexOf("light") >= 0)
        const a = kg.match(/AnimationDurationFactor=([0-9.]+)/)
        if (a) {
            const f = parseFloat(a[1])
            animations = f > 0
            if (f > 0) animSpeed = f
        }
    }

    function setLook(wantDark) {
        dark = wantDark
        sh("plasma-apply-lookandfeel -a " + (wantDark ? "org.lareon.desktop" : "org.lareon.desktop.light"))
    }

    function applyAnimations() {
        const f = animations ? animSpeed.toFixed(2) : "0"
        sh("kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor " + f +
           " && (busctl --user call org.kde.KWin /KWin org.kde.KWin reconfigure || true)")
    }

    function loadVolume() {
        sh("wpctl get-volume @DEFAULT_AUDIO_SINK@", function (code, out) {
            const m = out.match(/Volume:\s*([0-9.]+)/)
            if (m) volume = Math.min(1, parseFloat(m[1]))
            muted = out.indexOf("MUTED") >= 0
        })
    }
    function setVolume(v) {
        volume = v
        sh("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ " + v.toFixed(2))
    }
    function setMuted(m) {
        muted = m
        sh("wpctl set-mute @DEFAULT_AUDIO_SINK@ " + (m ? "1" : "0"))
    }

    function loadNetworks() {
        if (Sys.demo) {
            wifiOn = true
            networks = [
                { ssid: "Home", signal: 82, secure: true, active: true },
                { ssid: "Café Lumière", signal: 61, secure: false, active: false },
                { ssid: "Neighbours", signal: 38, secure: true, active: false }
            ]
            return
        }
        sh("nmcli radio wifi", function (code, out) { wifiOn = out.trim() === "enabled" })
        sh("nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan no", function (code, out) {
            const seen = {}
            const list = []
            out.split("\n").forEach(function (line) {
                const p = line.split(":")
                if (p.length < 4 || p[1] === "" || seen[p[1]]) return
                seen[p[1]] = true
                list.push({ ssid: p[1], signal: parseInt(p[2]) || 0, secure: p[3] !== "", active: p[0] === "*" })
            })
            networks = list.slice(0, 8)
        })
    }
    function setWifi(on) {
        wifiOn = on
        sh("nmcli radio wifi " + (on ? "on" : "off"), function () { rescan.restart() })
    }
    function joinNetwork(ssid) {
        netMessage = qsTr("Connecting to %1…").arg(ssid)
        sh("nmcli dev wifi connect " + JSON.stringify(ssid), function (code) {
            netMessage = code === 0 ? qsTr("Connected to %1").arg(ssid)
                                    : qsTr("Couldn’t connect. Open Network details to enter a password.")
            loadNetworks()
        })
    }

    function setScale(pct) {
        uiScale = pct
        sh("kscreen-doctor output.1.scale." + (pct / 100).toFixed(2))
    }

    property string aboutOs: "Lareon OS"
    property string aboutKernel: ""
    property string aboutCpu: ""
    property string aboutMem: ""
    function loadAbout() {
        if (Sys.demo) {
            aboutOs = "Lareon OS 0.2.5"
            aboutKernel = "6.12.41"
            aboutCpu = "Sample CPU · 4 cores"
            aboutMem = "8.0 GB"
            return
        }
        const os = Sys.readFile("/etc/os-release")
        const n = os.match(/PRETTY_NAME="?([^"\n]*)"?/)
        if (n) aboutOs = n[1]
        const cpu = Sys.readFile("/proc/cpuinfo")
        const c = cpu.match(/model name\s*:\s*(.*)/)
        const cores = (cpu.match(/^processor/gm) || []).length
        aboutCpu = (c ? c[1] : qsTr("Processor")) + " · " + qsTr("%1 cores").arg(cores)
        const mem = Sys.readFile("/proc/meminfo").match(/MemTotal:\s*(\d+)/)
        if (mem) aboutMem = (parseInt(mem[1]) / 1048576).toFixed(1) + " GB"
        sh("uname -r", function (code, out) { aboutKernel = out.trim() })
    }

    Timer {
        id: rescan
        interval: 1500
        onTriggered: root.loadNetworks()
    }

    onCurrentChanged: {
        if (current === "sound") loadVolume()
        else if (current === "network") loadNetworks()
        else if (current === "about") loadAbout()
        else if (current === "appearance") loadAppearance()
    }
    Component.onCompleted: {
        loadAppearance()
        if (current === "sound") loadVolume()
        else if (current === "network") loadNetworks()
        else if (current === "about") loadAbout()
    }

    // --- look -------------------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        color: Theme.panel
    }
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 3
        z: 5
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.accent }
            GradientStop { position: 0.6; color: Theme.magenta }
            GradientStop { position: 1.0; color: Theme.violet }
        }
    }

    // a small row used by every page
    component Card: Rectangle {
        default property alias content: inner.data
        Layout.fillWidth: true
        implicitHeight: inner.implicitHeight + 36
        radius: 16
        color: Qt.rgba(0.129, 0.118, 0.176, 0.85)
        border.width: 1
        border.color: Theme.lines
        ColumnLayout {
            id: inner
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14
        }
    }
    component Lbl: Text {
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: 15
        font.weight: Font.Medium
    }
    component Muted: Text {
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 14
        wrapMode: Text.Wrap
    }
    component Track: Item {
        id: tr
        property real value: 0.5
        property real from: 0
        property real to: 1
        signal moved(real v)
        Layout.preferredWidth: 280
        Layout.preferredHeight: 28
        readonly property real frac: Math.max(0, Math.min(1, (value - from) / (to - from)))
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 6
            radius: 3
            color: Theme.lines
            Rectangle {
                width: parent.width * tr.frac
                height: parent.height
                radius: 3
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Theme.accent }
                    GradientStop { position: 1.0; color: Theme.magenta }
                }
            }
        }
        Rectangle {
            width: 18
            height: 18
            radius: 9
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
            x: tr.frac * (tr.width - width)
            scale: drag.pressed ? 1.15 : 1
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        }
        MouseArea {
            id: drag
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            function set(mx) {
                const f = Math.max(0, Math.min(1, mx / width))
                tr.moved(tr.from + f * (tr.to - tr.from))
            }
            onPressed: mouse => set(mouse.x)
            onPositionChanged: mouse => { if (pressed) set(mouse.x) }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ---- left rail ----
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 236
            color: Qt.rgba(0.075, 0.067, 0.106, 0.75)

            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: Theme.lines
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                anchors.topMargin: 20
                spacing: 2

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    Layout.bottomMargin: 10
                    radius: 19
                    color: Theme.panel2
                    border.width: 1
                    border.color: find.activeFocus ? Theme.accent : Theme.lines
                    TextInput {
                        id: find
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 14
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 14
                        clip: true
                        selectByMouse: true
                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            visible: find.text === ""
                            text: qsTr("Search settings")
                            color: Theme.faint
                            font: find.font
                        }
                    }
                }

                Repeater {
                    model: root.pages
                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool match: find.text === "" || modelData.title.toLowerCase().indexOf(find.text.toLowerCase()) >= 0
                        readonly property bool isOn: root.current === modelData.id
                        Layout.fillWidth: true
                        Layout.preferredHeight: match ? 42 : 0
                        visible: match
                        radius: 14
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: isOn ? Qt.rgba(1, 0.486, 0.122, 0.20) : (hov.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent") }
                            GradientStop { position: 1.0; color: isOn ? Qt.rgba(0.639, 0.361, 0.961, 0.16) : (hov.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent") }
                        }
                        border.width: isOn ? 1 : 0
                        border.color: Qt.rgba(1, 1, 1, 0.10)
                        HoverHandler { id: hov }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            spacing: 12
                            LIcon {
                                size: 26
                                source: root.iconUrl(modelData.icon)
                            }
                            Text {
                                Layout.fillWidth: true
                                text: modelData.title
                                color: isOn ? "white" : "#c9c6d8"
                                font.family: Theme.font
                                font.pixelSize: 15
                                font.weight: isOn ? Font.Medium : Font.Normal
                                elide: Text.ElideRight
                            }
                        }
                        TapHandler { onTapped: root.current = modelData.id }
                    }
                }

                Item { Layout.fillHeight: true }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 6
                    text: qsTr("More settings")
                    font.family: Theme.font
                    font.pixelSize: 14
                    color: moreHover.hovered ? Theme.accentHover : Theme.muted
                    HoverHandler { id: moreHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: Sys.startDetached("systemsettings", []) }
                }
            }
        }

        // ---- page ----
        Flickable {
            id: scroller
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: pageCol.implicitHeight + 72
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { }

            ColumnLayout {
                id: pageCol
                x: 38
                y: 34
                width: scroller.width - 76
                spacing: 14

                // fade the page in when it changes
                opacity: 1
                property string shown: root.current
                onShownChanged: fade.restart()
                NumberAnimation { id: fade; target: pageCol; property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }

                Text {
                    text: root.pageInfo(root.current).title
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                }

                // ----- appearance -----
                Muted {
                    visible: root.current === "appearance"
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    text: qsTr("How Lareon looks and feels.")
                }
                Card {
                    visible: root.current === "appearance"
                    Lbl { text: qsTr("Theme") }
                    RowLayout {
                        spacing: 14
                        Repeater {
                            model: [ { name: qsTr("Dark"), isDark: true }, { name: qsTr("Light"), isDark: false } ]
                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool isOn: root.dark === modelData.isDark
                                Layout.fillWidth: true
                                Layout.preferredHeight: 96
                                radius: 12
                                border.width: isOn ? 2 : 1
                                border.color: isOn ? Theme.accent : Theme.lines
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: modelData.isDark ? "#1a1824" : "#f4effb" }
                                    GradientStop { position: 1.0; color: modelData.isDark ? "#13111b" : "#e6d9f5" }
                                }
                                Text {
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 12
                                    text: modelData.name
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    color: modelData.isDark ? Theme.text : "#1d1832"
                                }
                                TapHandler { onTapped: root.setLook(modelData.isDark) }
                            }
                        }
                    }
                }
                Card {
                    visible: root.current === "appearance"
                    RowLayout {
                        Lbl { text: qsTr("Smooth animations"); Layout.fillWidth: true }
                        LToggle {
                            checked: root.animations
                            onToggled: c => { root.animations = c; root.applyAnimations() }
                        }
                    }
                    RowLayout {
                        opacity: root.animations ? 1 : 0.4
                        Lbl { text: qsTr("Animation speed"); Layout.fillWidth: true }
                        Muted { text: qsTr("Slower") }
                        Track {
                            from: 1.3
                            to: 0.3
                            value: root.animSpeed
                            enabled: root.animations
                            onMoved: v => { root.animSpeed = v; applyDelay.restart() }
                        }
                        Muted { text: qsTr("Faster") }
                    }
                    Timer { id: applyDelay; interval: 400; onTriggered: root.applyAnimations() }
                }
                Muted {
                    visible: root.current === "appearance"
                    Layout.fillWidth: true
                    text: qsTr("Switching theme takes a few seconds and keeps your windows open.")
                }

                // ----- display -----
                Muted {
                    visible: root.current === "display"
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    text: qsTr("Make everything bigger or smaller.")
                }
                Card {
                    visible: root.current === "display"
                    Lbl { text: qsTr("Scale") }
                    RowLayout {
                        spacing: 10
                        Repeater {
                            model: [100, 125, 150, 200]
                            delegate: LButton {
                                required property int modelData
                                text: modelData + "%"
                                kind: root.uiScale === modelData ? "primary" : "normal"
                                onClicked: root.setScale(modelData)
                            }
                        }
                    }
                }
                Card {
                    visible: root.current === "display"
                    Muted { Layout.fillWidth: true; text: qsTr("Resolution, refresh rate, multiple screens and night colour live in the full display settings.") }
                    LButton { text: qsTr("Open display settings"); onClicked: Sys.startDetached("systemsettings", ["kcm_kscreen"]) }
                }

                // ----- sound -----
                Muted {
                    visible: root.current === "sound"
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    text: qsTr("Volume for your speakers or headphones.")
                }
                Card {
                    visible: root.current === "sound"
                    RowLayout {
                        Lbl { text: qsTr("Volume"); Layout.fillWidth: true }
                        Muted { text: Math.round(root.volume * 100) + "%" }
                        Track {
                            value: root.volume
                            enabled: !root.muted
                            opacity: root.muted ? 0.4 : 1
                            onMoved: v => root.setVolume(v)
                        }
                    }
                    RowLayout {
                        Lbl { text: qsTr("Mute"); Layout.fillWidth: true }
                        LToggle {
                            checked: root.muted
                            onToggled: c => root.setMuted(c)
                        }
                    }
                }
                Card {
                    visible: root.current === "sound"
                    Muted { Layout.fillWidth: true; text: qsTr("Choose outputs and inputs, or change each app’s volume.") }
                    LButton { text: qsTr("Open sound settings"); onClicked: Sys.startDetached("systemsettings", ["kcm_pulseaudio"]) }
                }

                // ----- network -----
                Muted {
                    visible: root.current === "network"
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    text: qsTr("Wi-Fi and wired connections.")
                }
                Card {
                    visible: root.current === "network"
                    RowLayout {
                        Lbl { text: qsTr("Wi-Fi"); Layout.fillWidth: true }
                        LToggle {
                            checked: root.wifiOn
                            onToggled: c => root.setWifi(c)
                        }
                    }
                    Repeater {
                        model: root.wifiOn ? root.networks : []
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            radius: 12
                            color: nh.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            HoverHandler { id: nh; cursorShape: Qt.PointingHandCursor }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 12
                                LIcon { size: 22; source: root.iconUrl("network-wireless") }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.ssid
                                    color: Theme.text
                                    font.family: Theme.font
                                    font.pixelSize: 15
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: modelData.active ? qsTr("Connected") : (modelData.secure ? qsTr("Secured") : qsTr("Open"))
                                    color: modelData.active ? Theme.good : Theme.faint
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                }
                                Text {
                                    text: modelData.signal + "%"
                                    color: Theme.faint
                                    font.family: Theme.mono
                                    font.pixelSize: 12
                                }
                            }
                            TapHandler { onTapped: if (!modelData.active) root.joinNetwork(modelData.ssid) }
                        }
                    }
                    Muted {
                        Layout.fillWidth: true
                        visible: root.netMessage !== ""
                        text: root.netMessage
                    }
                }
                Card {
                    visible: root.current === "network"
                    Muted { Layout.fillWidth: true; text: qsTr("Enter a password, add a hidden network, or set up a wired connection or VPN.") }
                    LButton { text: qsTr("Network details"); onClicked: Sys.startDetached("systemsettings", ["kcm_networkmanagement"]) }
                }

                // ----- pages that open the matching KDE panel -----
                Card {
                    visible: root.pageInfo(root.current).kcm !== undefined
                    Lbl { text: root.pageInfo(root.current).title }
                    Muted { Layout.fillWidth: true; text: root.pageInfo(root.current).blurb || "" }
                    LButton {
                        text: qsTr("Open %1").arg(root.pageInfo(root.current).title)
                        kind: "primary"
                        onClicked: Sys.startDetached("systemsettings", [root.pageInfo(root.current).kcm])
                    }
                }

                // ----- updates -----
                Card {
                    visible: root.current === "updates"
                    Lbl { text: qsTr("Keep Lareon OS up to date") }
                    Muted { Layout.fillWidth: true; text: qsTr("Looking for updates needs no password. Installing asks for it once.") }
                    LButton {
                        text: qsTr("Check for updates")
                        kind: "primary"
                        onClicked: Sys.startDetached("lareon-ui", ["updates"])
                    }
                }

                // ----- about -----
                Card {
                    visible: root.current === "about"
                    RowLayout {
                        spacing: 18
                        LIcon { size: 64; source: Theme.logo }
                        ColumnLayout {
                            spacing: 2
                            Text {
                                text: root.aboutOs
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: 20
                                font.weight: Font.DemiBold
                            }
                            Muted { text: qsTr("Made by Lareon") }
                        }
                    }
                }
                Card {
                    visible: root.current === "about"
                    Repeater {
                        model: [
                            { k: qsTr("Processor"), v: root.aboutCpu },
                            { k: qsTr("Memory"), v: root.aboutMem },
                            { k: qsTr("Kernel"), v: root.aboutKernel }
                        ]
                        delegate: RowLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            Muted { text: modelData.k; Layout.preferredWidth: 110 }
                            Text {
                                Layout.fillWidth: true
                                text: modelData.v
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: 15
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
