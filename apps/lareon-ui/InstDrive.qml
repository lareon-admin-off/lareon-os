import QtQuick
import QtQuick.Layouts
import Lareon

// Step 3: which drive to install on. The whole drive is erased.
Item {
    id: root
    property var install

    property bool scanning: false
    property string status: ""
    ListModel { id: drives }

    function scan() {
        drives.clear()
        if (Sys.demo) {
            drives.append({ path: "/dev/sda", label: "QEMU HARDDISK", gb: 30.0, kind: "SATA", ok: true, reason: "" })
            drives.append({ path: "/dev/sdb", label: "Samsung SSD 970", gb: 512.1, kind: "NVMe", ok: true, reason: "" })
            drives.append({ path: "/dev/sdc", label: "USB Flash Drive", gb: 8.0, kind: "USB", ok: false, reason: qsTr("Too small (needs 16 GB)") })
            return
        }
        scanning = true
        status = ""
        install.helperCall("disks", undefined, function(code, out, err) {
            scanning = false
            if (code !== 0) {
                status = qsTr("Couldn’t look for drives.")
                return
            }
            let data
            try { data = JSON.parse(out) } catch (e) { data = { disks: [] } }
            for (const d of data.disks) drives.append(d)
            // choose the only usable drive for the person
            let usable = []
            for (let i = 0; i < drives.count; ++i) if (drives.get(i).ok) usable.push(drives.get(i))
            if (usable.length === 1 && install.disk === "") {
                install.disk = usable[0].path
                install.diskName = usable[0].label + " · " + usable[0].gb.toFixed(1) + " GB"
            }
        })
    }
    Component.onCompleted: scan()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Where should Lareon OS go?")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            text: qsTr("Lareon OS uses the whole drive you pick.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }

        ColumnLayout {
            Layout.topMargin: 26
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: drives
                delegate: LCard {
                    required property int index
                    required property string path
                    required property string label
                    required property real gb
                    required property string kind
                    required property bool ok
                    required property string reason
                    Layout.fillWidth: true
                    Layout.preferredHeight: 76
                    selected: root.install.disk === path
                    opacity: ok ? 1 : 0.5

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 18

                        // a drawn drive: rounded body with a small light
                        Rectangle {
                            Layout.preferredWidth: 46
                            Layout.preferredHeight: 30
                            radius: 8
                            color: Theme.panel2
                            border.width: 1
                            border.color: root.install.disk === path ? Theme.accent : Theme.lines
                            Rectangle {
                                width: 6; height: 6; radius: 3
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                color: root.install.disk === path ? Theme.accent : Theme.faint
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3
                            Text {
                                text: label !== "" ? label : path
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: 17
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: ok ? gb.toFixed(1) + " GB  ·  " + kind + "  ·  " + path : reason
                                color: ok ? Theme.muted : Theme.danger
                                font.family: Theme.font
                                font.pixelSize: 13
                            }
                        }
                        LRadio { checked: root.install.disk === path; visible: ok }
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: ok
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.install.disk = path
                            root.install.diskName = (label !== "" ? label : path) + " · " + gb.toFixed(1) + " GB"
                        }
                    }
                }
            }

            Text {
                visible: drives.count === 0
                text: root.scanning ? qsTr("Looking for drives…") : qsTr("No drive was found to install on.")
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: 16
            }
        }

        // the warning
        Rectangle {
            Layout.topMargin: 22
            Layout.fillWidth: true
            Layout.preferredHeight: warn.implicitHeight + 28
            radius: 10
            color: Qt.rgba(0.85, 0.23, 0.38, 0.12)
            border.color: Qt.rgba(1, 0.31, 0.48, 0.4)
            border.width: 1
            Text {
                id: warn
                anchors.fill: parent
                anchors.margins: 14
                wrapMode: Text.Wrap
                color: "#ffd0dc"
                font.family: Theme.font
                font.pixelSize: 14
                text: root.install.disk === ""
                      ? qsTr("Choose a drive. Everything on it will be erased.")
                      : qsTr("Everything on %1 will be erased when you continue.").arg(root.install.diskName)
            }
        }

        RowLayout {
            Layout.topMargin: 10
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: root.status
                color: Theme.danger
                font.family: Theme.font
                font.pixelSize: 14
            }
            LButton {
                kind: "ghost"
                size: 34
                text: qsTr("Look again")
                enabled: !root.scanning
                onClicked: root.scan()
            }
        }
        Item { Layout.fillHeight: true }
    }
}
