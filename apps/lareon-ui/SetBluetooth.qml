import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property bool present: true
    property bool powered: false
    property bool scanning: false
    property bool loaded: false
    property string busyWith: ""
    property var devices: []      // [{ mac, name, paired, connected }]

    function load() {
        if (host.demo) {
            powered = true; loaded = true
            devices = [
                { mac: "AA:01", name: "Lareon Buds", paired: true, connected: true },
                { mac: "AA:02", name: "Desk keyboard", paired: true, connected: false },
                { mac: "AA:03", name: "Phone", paired: false, connected: false }
            ]
            return
        }
        host.sh("bluetoothctl show 2>&1; echo '#DEV'; bluetoothctl devices 2>&1; echo '#PAIRED'; bluetoothctl devices Paired 2>&1; echo '#CONN'; bluetoothctl devices Connected 2>&1", function (code, out) {
            const secs = out.split(/#(?:DEV|PAIRED|CONN)\n/)
            loaded = true
            present = secs[0].indexOf("Powered:") >= 0
            powered = secs[0].indexOf("Powered: yes") >= 0
            const names = {}
            const order = []
            function parse(txt, fn) {
                (txt || "").split("\n").forEach(l => {
                    const m = l.match(/^Device ([0-9A-Fa-f:]{17}) (.*)$/)
                    if (m) fn(m[1], m[2])
                })
            }
            parse(secs[1], (mac, name) => { names[mac] = { mac: mac, name: name, paired: false, connected: false }; order.push(mac) })
            parse(secs[2], mac => { if (names[mac]) names[mac].paired = true })
            parse(secs[3], mac => { if (names[mac]) names[mac].connected = true })
            const list = order.map(m => names[m]).filter(d => d.name.replace(/[-:]/g, "").toUpperCase() !== d.mac.replace(/:/g, ""))
            list.sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))
            devices = list
        })
    }
    Component.onCompleted: load()

    Timer {
        id: poll
        interval: 3000
        repeat: true
        running: page.powered && page.scanning
        onTriggered: page.load()
    }
    Timer {
        id: stopScan
        interval: 20000
        onTriggered: page.scan(false)
    }

    function setPower(on) {
        powered = on
        host.sh((on ? "rfkill unblock bluetooth; sleep 1; " : "") + "bluetoothctl power " + (on ? "on" : "off"), function () { page.load() })
    }
    function scan(on) {
        scanning = on
        if (on) {
            host.sh("timeout 20 bluetoothctl --timeout 20 scan on", function () { page.scanning = false; page.load() })
            stopScan.restart()
        }
    }
    function act(d) {
        busyWith = d.mac
        let cmd
        if (d.connected) cmd = "bluetoothctl disconnect " + d.mac
        else if (d.paired) cmd = "bluetoothctl connect " + d.mac
        else cmd = "bluetoothctl --agent NoInputNoOutput pair " + d.mac + " && bluetoothctl trust " + d.mac + " && bluetoothctl connect " + d.mac
        host.sh(cmd, function (code) {
            busyWith = ""
            if (code !== 0 && !d.connected) page.host.say(qsTr("Couldn’t connect to %1").arg(d.name))
            page.load()
        })
    }
    function remove(d) {
        host.sh("bluetoothctl remove " + d.mac, function () { page.load() })
    }

    SCard {
        title: qsTr("Bluetooth")
        note: page.loaded && !page.present ? qsTr("No Bluetooth adapter found on this computer.") : ""
        SRow {
            visible: page.present
            label: qsTr("Bluetooth")
            hint: page.powered ? qsTr("On. Visible to nearby devices while this window is open.") : qsTr("Off")
            LToggle {
                checked: page.powered
                onToggled: c => page.setPower(c)
            }
        }
    }

    SCard {
        visible: page.present && page.powered
        title: qsTr("Devices")
        note: page.devices.length === 0 ? qsTr("Nothing here yet. Put your device in pairing mode, then choose Look for devices.") : ""
        Repeater {
            model: page.devices
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: 12
                color: dh.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                HoverHandler { id: dh }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 12
                    LIcon { size: 22; source: host.icon("bluetooth") }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 15
                            elide: Text.ElideRight
                        }
                        Text {
                            text: page.busyWith === modelData.mac ? qsTr("Working…")
                                  : modelData.connected ? qsTr("Connected")
                                  : modelData.paired ? qsTr("Paired") : qsTr("Not paired")
                            color: modelData.connected ? Theme.good : Theme.faint
                            font.family: Theme.font
                            font.pixelSize: 12
                        }
                    }
                    LButton {
                        visible: modelData.paired
                        text: qsTr("Forget")
                        kind: "ghost"
                        size: 32
                        onClicked: page.remove(modelData)
                    }
                    LButton {
                        text: modelData.connected ? qsTr("Disconnect") : modelData.paired ? qsTr("Connect") : qsTr("Pair")
                        size: 32
                        enabled: page.busyWith === ""
                        onClicked: page.act(modelData)
                    }
                }
            }
        }
        LButton {
            text: page.scanning ? qsTr("Looking…") : qsTr("Look for devices")
            kind: "primary"
            size: 36
            enabled: !page.scanning
            onClicked: page.scan(true)
        }
    }
}
