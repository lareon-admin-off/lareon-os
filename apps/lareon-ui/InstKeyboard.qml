import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// Step 2: keyboard layout. The list comes from the system's keyboard database.
Item {
    id: root
    property var install

    property string query: ""
    ListModel { id: layouts }

    readonly property var fallback: [
        { code: "us", name: "English (US)" }, { code: "gb", name: "English (UK)" },
        { code: "es", name: "Spanish" }, { code: "fr", name: "French" }, { code: "de", name: "German" },
        { code: "pt", name: "Portuguese" }, { code: "it", name: "Italian" }, { code: "ru", name: "Russian" },
        { code: "tr", name: "Turkish" }, { code: "se", name: "Swedish" }, { code: "jp", name: "Japanese" },
        { code: "kr", name: "Korean" }, { code: "cn", name: "Chinese" }, { code: "in", name: "Indian" },
        { code: "ara", name: "Arabic" }, { code: "ir", name: "Persian" }
    ]

    function load() {
        let list = []
        const text = Sys.readFile("/usr/share/X11/xkb/rules/base.lst")
        if (text !== "") {
            let inLayouts = false
            for (const line of text.split("\n")) {
                if (line.indexOf("!") === 0) { inLayouts = line.indexOf("! layout") === 0; continue }
                if (!inLayouts) continue
                const m = /^\s+(\S+)\s+(.+)$/.exec(line)
                if (m) list.push({ code: m[1], name: m[2] })
            }
        }
        if (list.length === 0) list = fallback
        layouts.clear()
        const q = query.trim().toLowerCase()
        for (const l of list) {
            if (q === "" || l.name.toLowerCase().indexOf(q) >= 0 || l.code.toLowerCase() === q) layouts.append(l)
        }
    }
    onQueryChanged: load()
    Component.onCompleted: load()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Choose your keyboard")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            text: qsTr("Pick the layout printed on your keys.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }

        LField {
            Layout.topMargin: 26
            Layout.fillWidth: true
            placeholder: qsTr("Search layouts")
            onEdited: (value) => root.query = value
        }

        LCard {
            Layout.topMargin: 14
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: 330
            clip: true

            ListView {
                id: list
                anchors.fill: parent
                anchors.margins: 1
                model: layouts
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                delegate: Rectangle {
                    width: list.width
                    height: 48
                    readonly property bool isSelected: model.code === root.install.keyboard
                    color: isSelected ? Theme.accentSoft : "transparent"
                    Rectangle { visible: index > 0; width: parent.width; height: 1; color: Theme.lines }
                    Rectangle { visible: parent.isSelected; width: 3; height: parent.height; color: Theme.accent }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18
                        Text {
                            Layout.fillWidth: true
                            text: model.name
                            elide: Text.ElideRight
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 15
                            font.weight: parent.parent.isSelected ? Font.DemiBold : Font.Normal
                        }
                        Text {
                            text: model.code
                            color: Theme.faint
                            font.family: Theme.mono
                            font.pixelSize: 13
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.install.keyboardTouched = true; root.install.keyboard = model.code }
                    }
                }
            }
        }
    }
}
