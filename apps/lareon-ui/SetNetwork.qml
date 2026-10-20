import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property var wired: []           // [{ device, state, name, ip, connected }]
    property var wifiDevices: []     // device names
    property bool wifiOn: true
    property bool scanning: false
    property var networks: []        // [{ ssid, signal, secure, active, saved }]
    property string asking: ""       // network waiting for a password
    property string pass: ""
    property string busyWith: ""
    property bool loaded: false

    function load() {
        if (host.demo) {
            wired = [{ device: "enp0s1", state: "connected", name: "Wired connection 1", ip: "192.168.64.5/24", connected: true }]
            wifiDevices = ["wlan0"]
            networks = [
                { ssid: "Home", signal: 82, secure: true, active: true, saved: true },
                { ssid: "Café Lumière", signal: 61, secure: false, active: false, saved: false },
                { ssid: "Neighbours", signal: 38, secure: true, active: false, saved: false }
            ]
            loaded = true
            return
        }
        host.sh("nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev status; echo '#RADIO'; nmcli radio wifi; echo '#SAVED'; nmcli -t -f NAME,TYPE con show", function (code, out) {
            const parts = out.split("#RADIO")
            const radioSaved = (parts[1] || "").split("#SAVED")
            wifiOn = radioSaved[0].trim() === "enabled"
            const saved = {}
            radioSaved[1] && radioSaved[1].split("\n").forEach(l => {
                const p = l.split(":")
                if (p.length >= 2 && p[p.length - 1].indexOf("wireless") >= 0) saved[p.slice(0, -1).join(":")] = true
            })
            const w = []
            const wf = []
            parts[0].split("\n").forEach(l => {
                const p = l.split(":")
                if (p.length < 3) return
                if (p[1] === "ethernet") w.push({ device: p[0], state: p[2], name: p[3] || "", ip: "", connected: p[2] === "connected" })
                else if (p[1] === "wifi") wf.push(p[0])
            })
            wifiDevices = wf
            wired = w
            loaded = true
            w.forEach((d, i) => {
                if (!d.connected) return
                host.sh("nmcli -g IP4.ADDRESS dev show " + host.q(d.device), function (c2, o2) {
                    const copy = page.wired.slice()
                    copy[i] = Object.assign({}, copy[i], { ip: o2.split("\n")[0].trim() })
                    page.wired = copy
                })
            })
            if (wf.length > 0 && wifiOn) scan(saved)
        })
    }

    property var savedNames: ({})
    function scan(saved) {
        if (saved) savedNames = saved
        scanning = true
        host.sh("nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan auto", function (code, out) {
            scanning = false
            const seen = {}
            const list = []
            out.split("\n").forEach(l => {
                // escaped colons inside names look like \:
                const p = l.replace(/\\:/g, "\u0001").split(":").map(x => x.replace(/\u0001/g, ":"))
                if (p.length < 4 || p[1] === "" || seen[p[1]]) return
                seen[p[1]] = true
                list.push({ ssid: p[1], signal: parseInt(p[2]) || 0, secure: p[3] !== "" && p[3] !== "--", active: p[0] === "*", saved: page.savedNames[p[1]] === true })
            })
            list.sort((a, b) => (b.active - a.active) || (b.signal - a.signal))
            networks = list.slice(0, 12)
        })
    }

    Component.onCompleted: load()

    function setWifi(on) {
        wifiOn = on
        host.sh("nmcli radio wifi " + (on ? "on" : "off"), function () { page.load() })
    }
    function join(ssid, password) {
        busyWith = ssid
        const args = ["dev", "wifi", "connect", ssid]
        if (password !== "") { args.push("password"); args.push(password) }
        host.run("nmcli", args, "", function (code, out, err) {
            busyWith = ""
            if (code === 0) {
                host.say(qsTr("Connected to %1").arg(ssid))
                asking = ""
                pass = ""
            } else if (password === "" && page.networks.filter(n => n.ssid === ssid && n.secure).length > 0) {
                asking = ssid          // it needs a password
            } else {
                host.say(qsTr("Couldn’t connect. Check the password."))
            }
            page.load()
        })
    }
    function forget(ssid) {
        host.run("nmcli", ["connection", "delete", "id", ssid], "", function () {
            host.say(qsTr("Forgot %1").arg(ssid))
            page.load()
        })
    }

    SCard {
        title: qsTr("Cable")
        note: page.loaded && page.wired.length === 0 ? qsTr("No network cable port found.") : ""
        Repeater {
            model: page.wired
            delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 12
                LIcon { size: 24; source: host.icon("network-wired") }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: modelData.connected ? qsTr("Connected by cable") : qsTr("Cable not connected")
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 15
                    }
                    Text {
                        visible: modelData.connected
                        text: (modelData.name !== "" ? modelData.name : modelData.device) + (modelData.ip !== "" ? "  ·  " + modelData.ip : "")
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 13
                    }
                }
                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: modelData.connected ? Theme.good : Theme.faint
                }
            }
        }
    }

    SCard {
        title: qsTr("Wi-Fi")
        note: page.loaded && page.wifiDevices.length === 0
              ? qsTr("This computer has no Wi-Fi adapter, or it isn’t visible here (a virtual machine usually uses the cable). A USB Wi-Fi adapter will show up here by itself.")
              : ""
        SRow {
            visible: page.wifiDevices.length > 0
            label: qsTr("Wi-Fi")
            LToggle {
                checked: page.wifiOn
                onToggled: c => page.setWifi(c)
            }
        }
        Text {
            visible: page.wifiDevices.length > 0 && page.wifiOn && page.scanning && page.networks.length === 0
            text: qsTr("Looking for networks…")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 14
        }
        Repeater {
            model: page.wifiDevices.length > 0 && page.wifiOn ? page.networks : []
            delegate: ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: 12
                    color: nh.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    HoverHandler { id: nh; cursorShape: Qt.PointingHandCursor }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 12
                        LIcon { size: 22; source: host.icon("network-wireless") }
                        Text {
                            Layout.fillWidth: true
                            text: modelData.ssid
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 15
                            elide: Text.ElideRight
                        }
                        Text {
                            text: page.busyWith === modelData.ssid ? qsTr("Connecting…")
                                  : modelData.active ? qsTr("Connected")
                                  : modelData.saved ? qsTr("Saved")
                                  : modelData.secure ? qsTr("Secured") : qsTr("Open")
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
                        LButton {
                            visible: modelData.saved || modelData.active
                            text: qsTr("Forget")
                            kind: "ghost"
                            size: 30
                            onClicked: page.forget(modelData.ssid)
                        }
                    }
                    TapHandler {
                        onTapped: {
                            if (modelData.active) return
                            if (!modelData.saved && modelData.secure) page.asking = (page.asking === modelData.ssid ? "" : modelData.ssid)
                            else page.join(modelData.ssid, "")
                        }
                    }
                }
                RowLayout {
                    visible: page.asking === modelData.ssid
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    spacing: 10
                    LField {
                        Layout.fillWidth: true
                        placeholder: qsTr("Password for %1").arg(modelData.ssid)
                        echoMode: TextInput.Password
                        onEdited: v => page.pass = v
                        onAccepted: page.join(modelData.ssid, page.pass)
                    }
                    LButton {
                        text: qsTr("Connect")
                        kind: "primary"
                        onClicked: page.join(modelData.ssid, page.pass)
                    }
                }
            }
        }
        LButton {
            visible: page.wifiDevices.length > 0 && page.wifiOn
            text: page.scanning ? qsTr("Looking…") : qsTr("Look again")
            kind: "ghost"
            size: 34
            onClicked: page.scan(null)
        }
    }

    SCard {
        title: qsTr("More")
        SRow {
            label: qsTr("Airplane mode")
            hint: qsTr("Turns off Wi-Fi and Bluetooth.")
            LToggle {
                checked: !page.wifiOn
                onToggled: c => {
                    page.host.sh("nmcli radio all " + (c ? "off" : "on") + (c ? "; rfkill block bluetooth" : "; rfkill unblock bluetooth"), function () { page.load() })
                }
            }
        }
        SRow {
            label: qsTr("Other connections")
            hint: qsTr("VPNs, a fixed address, DNS or a hidden network.")
            LButton {
                text: qsTr("Edit connections")
                size: 36
                onClicked: Sys.startDetached("systemsettings", ["kcm_networkmanagement"])
            }
        }
    }
}
