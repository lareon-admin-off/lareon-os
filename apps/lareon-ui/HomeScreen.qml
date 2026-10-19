import QtQuick
import QtQuick.Controls.Basic
import Lareon

// Lareon Home: one place for search and every app. Opened from the Lareon mark
// in the dock (or Meta+Space). Type to search, Enter starts the first match,
// Esc closes.
Item {
    id: root

    property var allApps: []
    property string query: ""
    readonly property string home: "/usr/lib/lareon/"

    // Sample data for --demo and screenshots
    readonly property var demoApps: [
        { id: "a", name: "Lareon", icon: "file:///usr/share/icons/hicolor/256x256/apps/lareon.png", path: "" },
        { id: "b", name: "Ember", icon: "file:///usr/share/icons/hicolor/256x256/apps/lareon-ember.png", path: "" },
        { id: "c", name: "Files", icon: "", path: "" },
        { id: "d", name: "Terminal", icon: "", path: "" },
        { id: "e", name: "Settings", icon: "", path: "" },
        { id: "f", name: "Software", icon: "", path: "" },
        { id: "g", name: "Text Editor", icon: "", path: "" },
        { id: "h", name: "Calculator", icon: "", path: "" }
    ]

    function refilter() {
        shown.clear()
        const q = root.query.trim().toLowerCase()
        for (let i = 0; i < root.allApps.length; ++i) {
            const a = root.allApps[i]
            if (q === "" || a.name.toLowerCase().indexOf(q) >= 0
                    || (a.comment || "").toLowerCase().indexOf(q) >= 0) {
                shown.append({ appId: a.id, appName: a.name, appIcon: a.icon, appPath: a.path })
            }
        }
    }

    function start(path) {
        if (path === "") {
            return
        }
        Sys.startDetached(root.home + "launch-app", [path])
        Sys.quit(0)
    }

    function runTool(program, args) {
        Sys.startDetached(program, args)
        Sys.quit(0)
    }

    ListModel { id: shown }

    Connections {
        target: Sys
        function onFinished(id, exitCode, out, err) {
            if (id !== loadId) {
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

    property int loadId: -1
    Component.onCompleted: {
        if (Sys.demo) {
            root.allApps = root.demoApps
            root.refilter()
        } else {
            loadId = Sys.run(root.home + "lareon-apps", [])
        }
        search.forceActiveFocus()
    }

    // background: the Lareon night with soft glows
    Rectangle {
        anchors.fill: parent
        color: Theme.bg
    }
    Rectangle {
        width: parent.width * 0.7
        height: width
        radius: width / 2
        x: -width * 0.35
        y: parent.height - height * 0.55
        color: Qt.rgba(1, 0.486, 0.122, 0.10)
    }
    Rectangle {
        width: parent.width * 0.6
        height: width
        radius: width / 2
        x: parent.width - width * 0.6
        y: -height * 0.5
        color: Qt.rgba(0.639, 0.361, 0.961, 0.12)
    }

    // click on empty space closes
    MouseArea {
        anchors.fill: parent
        onClicked: Sys.quit(0)
    }

    Column {
        id: column
        width: Math.min(root.width - 80, 1040)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.max(48, root.height * 0.08)
        spacing: 36

        // search
        Rectangle {
            width: Math.min(parent.width, 560)
            height: 52
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 26
            color: Theme.panel
            border.width: search.activeFocus ? 2 : 1
            border.color: search.activeFocus ? Theme.accent : Theme.lines

            TextInput {
                id: search
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.text
                selectionColor: Theme.accent
                selectedTextColor: Theme.textOnAccent
                font.family: Theme.font
                font.pixelSize: 18
                clip: true
                onTextChanged: {
                    root.query = text
                    root.refilter()
                    grid.currentIndex = 0
                }
                Keys.onReturnPressed: {
                    if (shown.count > 0) {
                        root.start(shown.get(Math.max(0, grid.currentIndex)).appPath)
                    }
                }
                Keys.onEscapePressed: Sys.quit(0)
                Keys.onDownPressed: grid.moveCurrentIndexDown()
                Keys.onUpPressed: grid.moveCurrentIndexUp()
            }
            Text {
                anchors.fill: parent
                anchors.leftMargin: 24
                verticalAlignment: Text.AlignVCenter
                visible: search.text.length === 0
                color: Theme.faint
                font.family: Theme.font
                font.pixelSize: 18
                text: qsTr("Search apps")
            }
        }

        // the apps
        GridView {
            id: grid
            width: parent.width
            height: Math.max(160, root.height - column.y - 36 - 52 - 36 - 96)
            clip: true
            model: shown
            cellWidth: Math.floor(width / Math.max(3, Math.floor(width / 150)))
            cellHeight: 140
            currentIndex: 0
            highlightMoveDuration: 0
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            highlight: Rectangle {
                radius: 16
                color: Theme.accentSoft
                border.width: 1
                border.color: Theme.accentRing
            }

            delegate: Item {
                width: grid.cellWidth
                height: grid.cellHeight
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    Item {
                        width: 64
                        height: 64
                        anchors.horizontalCenter: parent.horizontalCenter
                        LIcon {
                            anchors.fill: parent
                            size: 64
                            source: model.appIcon === "" ? "" : (model.appIcon.indexOf("file:") === 0 ? model.appIcon : "file://" + model.appIcon)
                            visible: model.appIcon !== ""
                        }
                        Rectangle {
                            anchors.fill: parent
                            radius: 16
                            visible: model.appIcon === ""
                            color: Theme.panel2
                            border.width: 1
                            border.color: Theme.lines
                            Text {
                                anchors.centerIn: parent
                                text: model.appName.charAt(0).toUpperCase()
                                color: Theme.accent
                                font.family: Theme.font
                                font.pixelSize: 28
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                    Text {
                        width: grid.cellWidth - 20
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.Wrap
                        text: model.appName
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 14
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: grid.currentIndex = index
                    onClicked: root.start(model.appPath)
                }
            }

            Text {
                anchors.centerIn: parent
                visible: shown.count === 0
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: 16
                text: root.query === "" ? qsTr("Looking for apps…") : qsTr("No apps match “%1”.").arg(root.query)
            }
        }
    }

    // bottom bar
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 34
        spacing: 12

        Repeater {
            model: [
                { label: qsTr("Updates"), cmd: "lareon-ui", args: ["updates"] },
                { label: qsTr("Settings"), cmd: "systemsettings", args: [] },
                { label: qsTr("Lock"), cmd: "loginctl", args: ["lock-session"] },
                { label: qsTr("Restart"), cmd: "systemctl", args: ["reboot"] },
                { label: qsTr("Shut down"), cmd: "systemctl", args: ["poweroff"] }
            ]
            delegate: Rectangle {
                width: pillText.implicitWidth + 32
                height: 38
                radius: 19
                color: pillArea.containsMouse ? Theme.lines : Theme.panel
                border.width: 1
                border.color: Theme.lines
                Text {
                    id: pillText
                    anchors.centerIn: parent
                    text: modelData.label
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
                MouseArea {
                    id: pillArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.runTool(modelData.cmd, modelData.args)
                }
            }
        }
    }
}
