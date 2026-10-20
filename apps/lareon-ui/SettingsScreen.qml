import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// Lareon Settings: the settings people actually change, in Lareon's own look.
// Every page does its job itself; KDE's full Settings is only a fallback.
Item {
    id: root

    property string current: Sys.args.page || "appearance"
    readonly property bool demo: Sys.demo

    readonly property var pages: [
        { id: "appearance", title: qsTr("Appearance"),        icon: "preferences-desktop-theme-global" },
        { id: "display",    title: qsTr("Display"),           icon: "preferences-desktop-display" },
        { id: "sound",      title: qsTr("Sound"),             icon: "preferences-desktop-sound" },
        { id: "network",    title: qsTr("Network"),           icon: "preferences-system-network" },
        { id: "bluetooth",  title: qsTr("Bluetooth"),         icon: "bluetooth" },
        { id: "input",      title: qsTr("Keyboard & mouse"),  icon: "input-keyboard" },
        { id: "power",      title: qsTr("Power"),             icon: "preferences-system-power-management" },
        { id: "time",       title: qsTr("Time & language"),   icon: "preferences-system-time" },
        { id: "apps",       title: qsTr("Apps"),              icon: "applications-all" },
        { id: "users",      title: qsTr("Users"),             icon: "system-users" },
        { id: "privacy",    title: qsTr("Privacy & security"), icon: "preferences-system-privacy" },
        { id: "updates",    title: qsTr("Updates"),           icon: "system-software-update" },
        { id: "about",      title: qsTr("About"),             icon: "help-about" }
    ]

    function pageInfo(id) {
        for (let i = 0; i < pages.length; i++) {
            if (pages[i].id === id) return pages[i]
        }
        return pages[0]
    }
    function icon(name) {
        return "file:///usr/share/icons/Lareon/scalable/apps/" + name + ".svg"
    }

    // --- tools every page uses -----------------------------------------------
    // shell-quote one value
    function q(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }
    // kwriteconfig6 command: kw("kwinrc", ["NightColor"], "Active", "true")
    function kw(file, groups, key, value) {
        let c = "kwriteconfig6 --file " + q(file)
        for (let i = 0; i < groups.length; i++) c += " --group " + q(groups[i])
        return c + " --key " + q(key) + " " + q(value)
    }
    function reconfigureKWin() {
        return "busctl --user call org.kde.KWin /KWin org.kde.KWin reconfigure"
    }
    // tiny INI reader: iniGet(text, ["AC", "Display"], "Key")
    function iniGet(text, groups, key) {
        const want = groups.map(g => "[" + g + "]").join("")
        let inGroup = false
        const lines = String(text).split("\n")
        for (let i = 0; i < lines.length; i++) {
            const l = lines[i].trim()
            if (l.charAt(0) === "[") {
                inGroup = (l === want)
            } else if (inGroup) {
                const eq = l.indexOf("=")
                if (eq > 0 && l.substring(0, eq).trim() === key) return l.substring(eq + 1).trim()
            }
        }
        return ""
    }
    function config(name) {
        return Sys.readFile(Sys.homePath() + "/.config/" + name)
    }

    // run a shell command; cb(exitCode, out, err) when it finishes
    property var callbacks: ({})
    function sh(cmd, cb) {
        if (demo) {
            if (cb) Qt.callLater(cb, 0, "", "")
            return
        }
        const id = Sys.run("sh", ["-c", cmd])
        if (cb) callbacks[id] = cb
    }
    // run a program without a shell (safe for passwords and names); optional stdin
    function run(prog, args, input, cb) {
        if (demo) {
            if (cb) Qt.callLater(cb, 0, "", "")
            return
        }
        const id = Sys.run(prog, args, input || "")
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

    // a short message at the bottom ("Saved", "Couldn't connect")
    property string toastText: ""
    function say(text) {
        toastText = text
        toastOut.stop()
        toastIn.restart()
        toastTimer.restart()
    }

    // --- chrome -------------------------------------------------------------------
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

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ---- left rail ----
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 244
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
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
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

                ListView {
                    id: rail
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 2
                    model: root.pages
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool match: find.text === "" || modelData.title.toLowerCase().indexOf(find.text.toLowerCase()) >= 0
                        readonly property bool isOn: root.current === modelData.id
                        width: ListView.view.width
                        height: match ? 40 : 0
                        visible: match
                        radius: 14
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: isOn ? Qt.rgba(1, 0.486, 0.122, 0.20) : (hov.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent") }
                            GradientStop { position: 1.0; color: isOn ? Qt.rgba(0.639, 0.361, 0.961, 0.16) : (hov.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent") }
                        }
                        border.width: isOn ? 1 : 0
                        border.color: Qt.rgba(1, 1, 1, 0.10)
                        HoverHandler { id: hov; cursorShape: Qt.PointingHandCursor }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            spacing: 12
                            LIcon {
                                size: 26
                                source: root.icon(modelData.icon)
                            }
                            Text {
                                Layout.fillWidth: true
                                text: modelData.title
                                color: isOn ? "white" : "#c9c6d8"
                                font.family: Theme.font
                                font.pixelSize: 14
                                font.weight: isOn ? Font.Medium : Font.Normal
                                elide: Text.ElideRight
                            }
                        }
                        TapHandler { onTapped: root.current = modelData.id }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 4
                    text: qsTr("More settings")
                    font.family: Theme.font
                    font.pixelSize: 13
                    color: moreHover.hovered ? Theme.accentHover : Theme.faint
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
            contentHeight: pageCol.implicitHeight + 80
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { }

            ColumnLayout {
                id: pageCol
                x: 38
                y: 34
                width: scroller.width - 76
                spacing: 14

                Text {
                    text: root.pageInfo(root.current).title
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                }

                Loader {
                    id: pageLoader
                    Layout.fillWidth: true
                    sourceComponent: {
                        switch (root.current) {
                        case "display": return pgDisplay
                        case "sound": return pgSound
                        case "network": return pgNetwork
                        case "bluetooth": return pgBluetooth
                        case "input": return pgInput
                        case "power": return pgPower
                        case "time": return pgTime
                        case "apps": return pgApps
                        case "users": return pgUsers
                        case "privacy": return pgPrivacy
                        case "updates": return pgUpdates
                        case "about": return pgAbout
                        default: return pgAppearance
                        }
                    }
                    opacity: 0
                    onLoaded: fadeIn.restart()
                    NumberAnimation { id: fadeIn; target: pageLoader; property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    // toast
    Rectangle {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 122
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        height: 40
        width: toastLabel.implicitWidth + 36
        radius: 20
        color: Qt.rgba(0.13, 0.12, 0.18, 0.97)
        border.width: 1
        border.color: Theme.lines
        opacity: 0
        z: 10
        Text {
            id: toastLabel
            anchors.centerIn: parent
            text: root.toastText
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 14
        }
        NumberAnimation { id: toastIn; target: toast; property: "opacity"; to: 1; duration: 160 }
        NumberAnimation { id: toastOut; target: toast; property: "opacity"; to: 0; duration: 300 }
        Timer { id: toastTimer; interval: 2600; onTriggered: toastOut.start() }
    }

    Component { id: pgAppearance; SetAppearance { host: root } }
    Component { id: pgDisplay; SetDisplay { host: root } }
    Component { id: pgSound; SetSound { host: root } }
    Component { id: pgNetwork; SetNetwork { host: root } }
    Component { id: pgBluetooth; SetBluetooth { host: root } }
    Component { id: pgInput; SetInput { host: root } }
    Component { id: pgPower; SetPower { host: root } }
    Component { id: pgTime; SetTime { host: root } }
    Component { id: pgApps; SetApps { host: root } }
    Component { id: pgUsers; SetUsers { host: root } }
    Component { id: pgPrivacy; SetPrivacy { host: root } }
    Component { id: pgUpdates; SetUpdates { host: root } }
    Component { id: pgAbout; SetAbout { host: root } }
}
