import QtQuick
import QtQuick.Layouts
import Lareon

// Step 1: a quick look at this computer, so there are no surprises later.
Item {
    id: root
    property var install

    // state: "wait" | "ok" | "warn" | "info"
    property var rows: [
        { label: qsTr("Memory"), state: "wait", detail: qsTr("Checking…") },
        { label: qsTr("Storage"), state: "wait", detail: qsTr("Checking…") },
        { label: qsTr("Power"), state: "wait", detail: qsTr("Checking…") },
        { label: qsTr("Start-up type"), state: "wait", detail: qsTr("Checking…") },
        { label: qsTr("Internet"), state: "wait", detail: qsTr("Checking…") }
    ]
    function setRow(i, state, detail) {
        const copy = rows.slice()
        copy[i] = { label: copy[i].label, state: state, detail: detail }
        rows = copy
    }

    function run() {
        if (Sys.demo) {
            setRow(0, "ok", qsTr("4.0 GB"))
            setRow(1, "ok", qsTr("30 GB drive found"))
            setRow(2, "ok", qsTr("Plugged in"))
            setRow(3, "info", qsTr("UEFI"))
            setRow(4, "info", qsTr("Connected (you can also do this later)"))
            return
        }
        install.shell("awk '/MemTotal/{printf \"%d\", $2/1024}' /proc/meminfo", function (c, out) {
            const mb = parseInt(out)
            if (isNaN(mb)) setRow(0, "info", qsTr("Couldn’t tell"))
            else if (mb < 1800) setRow(0, "warn", qsTr("%1 GB. Lareon OS runs best with 4 GB or more.").arg((mb / 1024).toFixed(1)))
            else setRow(0, "ok", qsTr("%1 GB").arg((mb / 1024).toFixed(1)))
        })
        install.shell("lsblk -dbn -o SIZE,TYPE 2>/dev/null | awk '$2==\"disk\"{print $1}' | sort -n | tail -1", function (c, out) {
            const b = parseFloat(out)
            if (isNaN(b)) setRow(1, "warn", qsTr("No drive found yet. Next you can look again."))
            else if (b < 16e9) setRow(1, "warn", qsTr("The biggest drive is %1 GB. Lareon OS needs 16 GB.").arg((b / 1e9).toFixed(0)))
            else setRow(1, "ok", qsTr("%1 GB drive found").arg((b / 1e9).toFixed(0)))
        })
        install.shell("bat=$(ls /sys/class/power_supply 2>/dev/null | grep -c '^BAT'); ac=$(cat /sys/class/power_supply/A*/online 2>/dev/null | head -1); echo \"$bat $ac\"", function (c, out) {
            const p = out.trim().split(" ")
            if (p[0] === "0" || p[0] === "") setRow(2, "ok", qsTr("Desktop computer"))
            else if (p[1] === "1") setRow(2, "ok", qsTr("Plugged in"))
            else setRow(2, "warn", qsTr("Running on battery. Plug in before you continue."))
        })
        install.shell("[ -d /sys/firmware/efi ] && echo uefi || echo bios", function (c, out) {
            setRow(3, "info", out.trim() === "uefi" ? qsTr("UEFI (modern)") : qsTr("BIOS (older)"))
        })
        install.shell("ping -c1 -W2 1.1.1.1 >/dev/null 2>&1 && echo yes || echo no", function (c, out) {
            setRow(4, "info", out.trim() === "yes" ? qsTr("Connected. Installing doesn’t need it.") : qsTr("Not connected. Installing doesn’t need it; you can connect later."))
        })
    }
    Component.onCompleted: run()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Checking your computer")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            text: qsTr("A quick look, so there are no surprises later.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }

        LCard {
            Layout.topMargin: 30
            Layout.fillWidth: true
            Layout.preferredHeight: rowsCol.implicitHeight + 28
            ColumnLayout {
                id: rowsCol
                anchors.fill: parent
                anchors.margins: 14
                spacing: 4
                Repeater {
                    model: root.rows
                    delegate: RowLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        spacing: 14
                        Rectangle {
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            radius: 13
                            color: modelData.state === "ok" ? Qt.rgba(0.30, 0.76, 0.54, 0.2)
                                   : modelData.state === "warn" ? Qt.rgba(1, 0.70, 0.30, 0.2) : Theme.panel2
                            Text {
                                anchors.centerIn: parent
                                text: modelData.state === "ok" ? "✓" : modelData.state === "warn" ? "!" : modelData.state === "wait" ? "…" : "i"
                                color: modelData.state === "ok" ? Theme.good : modelData.state === "warn" ? "#ffb45e" : Theme.muted
                                font.family: Theme.font
                                font.pixelSize: 14
                                font.weight: Font.Bold
                            }
                        }
                        Text {
                            Layout.preferredWidth: 150
                            text: modelData.label
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 16
                            font.weight: Font.Medium
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelData.detail
                            color: modelData.state === "warn" ? "#ffcf9a" : Theme.muted
                            font.family: Theme.font
                            font.pixelSize: 15
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
        Item { Layout.fillHeight: true }
    }
}
