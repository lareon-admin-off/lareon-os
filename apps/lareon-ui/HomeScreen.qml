import QtQuick
import QtQuick.Controls.Basic
import Lareon

// Lareon Home: a small glass panel next to the dock with search, pinned apps
// and every app. Opened from the Lareon mark in the dock (or Meta+Space).
// Type to search, Enter opens the first match, Esc closes.
Item {
    id: root

    property var allApps: []
    property string query: ""
    property int loadId: -1
    readonly property string tools: "/usr/lib/lareon/"
    readonly property var pinnedIds: [
        "lareon.desktop", "ember.desktop", "org.kde.dolphin.desktop",
        "org.kde.konsole.desktop", "org.kde.discover.desktop", "org.kde.systemsettings.desktop"
    ]

    readonly property var demoApps: [
        { id: "lareon.desktop", name: "Lareon", icon: "file:///usr/share/icons/hicolor/256x256/apps/lareon.png", path: "" },
        { id: "ember.desktop", name: "Ember", icon: "file:///usr/share/icons/hicolor/256x256/apps/lareon-ember.png", path: "" },
        { id: "org.kde.dolphin.desktop", name: "Files", icon: "", path: "" },
        { id: "org.kde.konsole.desktop", name: "Terminal", icon: "", path: "" },
        { id: "org.kde.discover.desktop", name: "Software", icon: "", path: "" },
        { id: "org.kde.systemsettings.desktop", name: "Settings", icon: "", path: "" },
        { id: "a", name: "Calculator", icon: "", path: "" },
        { id: "b", name: "Documents", icon: "", path: "" },
        { id: "c", name: "Monitor", icon: "", path: "" },
        { id: "d", name: "Photos", icon: "", path: "" },
        { id: "e", name: "Screenshots", icon: "", path: "" },
        { id: "f", name: "Text Editor", icon: "", path: "" }
    ]

    readonly property string greeting: {
        const h = new Date().getHours()
        return h < 5 ? qsTr("Good night") : h < 12 ? qsTr("Good morning") : h < 18 ? qsTr("Good afternoon") : qsTr("Good evening")
    }

    function iconUrl(p) {
        return p === "" ? "" : (p.indexOf("file:") === 0 ? p : "file://" + p)
    }

    function refilter() {
        pinned.clear()
        shown.clear()
        const q = root.query.trim().toLowerCase()
        for (let i = 0; i < root.allApps.length; ++i) {
            const a = root.allApps[i]
            const row = { appId: a.id, appName: a.name, appIcon: a.icon, appPath: a.path }
            if (q === "") {
                if (root.pinnedIds.indexOf(a.id) >= 0) {
                    pinned.append(row)
                } else {
                    shown.append(row)
                }
            } else if (a.name.toLowerCase().indexOf(q) >= 0 || (a.comment || "").toLowerCase().indexOf(q) >= 0) {
                shown.append(row)
            }
        }
    }

    function firstPath() {
        if (pinned.count > 0 && root.query === "") {
            return pinned.get(0).appPath
        }
        return shown.count > 0 ? shown.get(0).appPath : ""
    }

    function start(path) {
        if (path === "") {
            return
        }
        Sys.startDetached(root.tools + "launch-app", [path])
        Sys.quit(0)
    }

    function runTool(program, args) {
        Sys.startDetached(program, args)
        Sys.quit(0)
    }

    ListModel { id: pinned }
    ListModel { id: shown }

    Connections {
        target: Sys
        function onFinished(id, exitCode, out, err) {
            if (id !== root.loadId) {
                return
            }
            try {
                root.allApps = JSON.parse(out)
            } catch (e) {
                root.allApps = []
            }
            root.refilter()
        }
    }

    Component.onCompleted: {
        if (Sys.demo) {
            root.allApps = root.demoApps
            root.refilter()
        } else {
            loadId = Sys.run(root.tools + "lareon-apps", [])
        }
        search.forceActiveFocus()
    }

    // the glass panel
    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 22
        color: Qt.rgba(0.106, 0.094, 0.149, 0.96)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.12)
        clip: true

        // brand gradient edge, like the Lareon app
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 3
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Theme.accent }
                GradientStop { position: 0.6; color: Theme.magenta }
                GradientStop { position: 1.0; color: Theme.violet }
            }
        }
        // soft glow behind the header
        Rectangle {
            width: parent.width * 0.9
            height: width
            radius: width / 2
            x: parent.width * 0.35
            y: -height * 0.72
            color: Qt.rgba(0.639, 0.361, 0.961, 0.10)
        }

        Column {
            anchors.fill: parent
            anchors.margins: 22
            anchors.topMargin: 26
            spacing: 18

            Text {
                text: root.greeting
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 24
                font.weight: Font.DemiBold
            }

            Rectangle {
                width: parent.width
                height: 44
                radius: 22
                color: Theme.bg
                border.width: search.activeFocus ? 2 : 1
                border.color: search.activeFocus ? Theme.accent : Theme.lines

                TextInput {
                    id: search
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.text
                    selectionColor: Theme.accent
                    selectedTextColor: Theme.textOnAccent
                    font.family: Theme.font
                    font.pixelSize: 16
                    clip: true
                    onTextChanged: {
                        root.query = text
                        root.refilter()
                    }
                    Keys.onReturnPressed: root.start(root.firstPath())
                    Keys.onEscapePressed: Sys.quit(0)
                }
                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    verticalAlignment: Text.AlignVCenter
                    visible: search.text.length === 0
                    color: Theme.faint
                    font.family: Theme.font
                    font.pixelSize: 16
                    text: qsTr("Search apps")
                }
            }

            Flickable {
                id: scroller
                width: parent.width
                height: parent.height - y - footer.height - 18
                contentWidth: width
                contentHeight: body.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Column {
                    id: body
                    width: scroller.width
                    spacing: 14

                    Text {
                        visible: pinned.count > 0
                        text: qsTr("Pinned")
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    Grid {
                        visible: pinned.count > 0
                        columns: 3
                        columnSpacing: 10
                        rowSpacing: 10
                        Repeater {
                            model: pinned
                            delegate: Rectangle {
                                width: (body.width - 20) / 3
                                height: 76
                                radius: 14
                                color: pinArea.containsMouse ? Theme.panel2 : Theme.panel
                                border.width: 1
                                border.color: pinArea.containsMouse ? Theme.accentRing : Theme.lines
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    LIcon {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        size: 36
                                        source: root.iconUrl(model.appIcon)
                                        visible: model.appIcon !== ""
                                    }
                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 36
                                        height: 36
                                        radius: 10
                                        visible: model.appIcon === ""
                                        color: Theme.panel2
                                        border.width: 1
                                        border.color: Theme.lines
                                        Text {
                                            anchors.centerIn: parent
                                            text: model.appName.charAt(0).toUpperCase()
                                            color: Theme.accent
                                            font.family: Theme.font
                                            font.pixelSize: 16
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                    Text {
                                        width: parent.parent.width - 12
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                        text: model.appName
                                        color: Theme.text
                                        font.family: Theme.font
                                        font.pixelSize: 12
                                    }
                                }
                                MouseArea {
                                    id: pinArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.start(model.appPath)
                                }
                            }
                        }
                    }

                    Text {
                        visible: shown.count > 0
                        text: root.query === "" ? qsTr("All apps") : qsTr("Results")
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    Grid {
                        columns: 4
                        columnSpacing: 0
                        rowSpacing: 4
                        Repeater {
                            model: shown
                            delegate: Rectangle {
                                width: body.width / 4
                                height: 92
                                radius: 14
                                color: appArea.containsMouse ? Theme.panel : "transparent"
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 7
                                    LIcon {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        size: 44
                                        source: root.iconUrl(model.appIcon)
                                        visible: model.appIcon !== ""
                                    }
                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 44
                                        height: 44
                                        radius: 12
                                        visible: model.appIcon === ""
                                        color: Theme.panel2
                                        border.width: 1
                                        border.color: Theme.lines
                                        Text {
                                            anchors.centerIn: parent
                                            text: model.appName.charAt(0).toUpperCase()
                                            color: Theme.accent
                                            font.family: Theme.font
                                            font.pixelSize: 20
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                    Text {
                                        width: parent.parent.width - 10
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                        text: model.appName
                                        color: Theme.text
                                        font.family: Theme.font
                                        font.pixelSize: 12
                                    }
                                }
                                MouseArea {
                                    id: appArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.start(model.appPath)
                                }
                            }
                        }
                    }

                    Text {
                        visible: pinned.count === 0 && shown.count === 0
                        text: root.query === "" ? qsTr("Looking for apps…") : qsTr("No apps match “%1”.").arg(root.query)
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 14
                    }
                }
            }
        }

        // footer: updates on the left, power on the right
        Item {
            id: footer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 22
            anchors.bottomMargin: 18
            height: 38

            Rectangle {
                anchors.left: parent.left
                width: upText.implicitWidth + 28
                height: parent.height
                radius: height / 2
                color: upArea.containsMouse ? Theme.lines : "transparent"
                border.width: 1
                border.color: Theme.lines
                Text {
                    id: upText
                    anchors.centerIn: parent
                    text: qsTr("Updates")
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 13
                }
                MouseArea {
                    id: upArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.runTool("lareon-ui", ["updates"])
                }
            }

            Row {
                anchors.right: parent.right
                spacing: 8
                Repeater {
                    model: [
                        { label: qsTr("Lock"), cmd: "loginctl", args: ["lock-session"] },
                        { label: qsTr("Restart"), cmd: "systemctl", args: ["reboot"] },
                        { label: qsTr("Shut down"), cmd: "systemctl", args: ["poweroff"] }
                    ]
                    delegate: Rectangle {
                        width: pwText.implicitWidth + 24
                        height: 38
                        radius: 19
                        color: pwArea.containsMouse ? Theme.lines : "transparent"
                        border.width: 1
                        border.color: Theme.lines
                        Text {
                            id: pwText
                            anchors.centerIn: parent
                            text: modelData.label
                            color: Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 12
                        }
                        MouseArea {
                            id: pwArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.runTool(modelData.cmd, modelData.args)
                        }
                    }
                }
            }
        }
    }
}
