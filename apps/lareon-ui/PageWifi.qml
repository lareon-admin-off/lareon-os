import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// Step 1: Wi-Fi. Lists networks via the helper (nmcli) and connects.
Item {
    id: root
    property var setup

    property bool scanning: false
    property bool wired: false
    property int selected: -1
    property string status: ""
    ListModel { id: nets }

    function scan() {
        if (Sys.demo) {
            nets.clear()
            nets.append({ ssid: "Larsonia-Home", signal: 92, secure: true })
            nets.append({ ssid: "Larsonia-Guest", signal: 70, secure: true })
            nets.append({ ssid: "CoffeeHouse 5G", signal: 48, secure: true })
            nets.append({ ssid: "Neighbour_2.4", signal: 30, secure: true })
            selected = 0
            return
        }
        scanning = true
        setup.helperCall("wifi-list", undefined, function(code, out, err) {
            scanning = false
            if (code !== 0) {
                status = qsTr("Couldn’t look for networks. You can skip this and connect later.")
                return
            }
            let data
            try { data = JSON.parse(out) } catch (e) { data = { networks: [] } }
            nets.clear()
            for (const n of data.networks) nets.append(n)
            wired = data.wired === true
            setup.connectedTo = data.connected || ""
        })
    }

    function connectTo(ssid, password) {
        status = qsTr("Connecting to %1…").arg(ssid)
        setup.helperCall("wifi-connect", { ssid: ssid, password: password }, function(code, out, err) {
            if (code === 0) {
                setup.connectedTo = ssid
                status = ""
                selected = -1
            } else {
                status = qsTr("Couldn’t connect to %1. Check the password and try again.").arg(ssid)
            }
        })
    }

    function signalIcon(s) {
        const level = s > 75 ? 100 : s > 50 ? 75 : s > 25 ? 50 : 25
        return Theme.breeze("status", "network-wireless-connected-" + level, 22)
    }

    Component.onCompleted: scan()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Connect to the internet")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            Layout.maximumWidth: 680
            text: root.wired
                  ? qsTr("You’re connected with a cable, so you can continue.")
                  : qsTr("Lareon OS checks for updates and lets you sign in to your Lareon account. You can also do this later.")
            wrapMode: Text.Wrap
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
            lineHeight: 1.2
        }

        LCard {
            Layout.topMargin: 34
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(120, Math.min(list.contentHeight + 2, 400))
            clip: true

            ListView {
                id: list
                anchors.fill: parent
                anchors.margins: 1
                model: nets
                interactive: contentHeight > height
                delegate: Column {
                    id: row
                    width: list.width
                    readonly property bool isSelected: index === root.selected
                    readonly property bool isConnected: model.ssid === root.setup.connectedTo

                    Rectangle {
                        width: parent.width
                        height: 56
                        color: row.isSelected ? Theme.accentSoft : "transparent"
                        Rectangle { visible: index > 0; width: parent.width; height: 1; color: Theme.lines }
                        Rectangle { visible: row.isSelected; width: 3; height: parent.height; color: Theme.accent }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 18
                            anchors.rightMargin: 18
                            spacing: 14
                            LIcon { size: 22; source: root.signalIcon(model.signal) }
                            Text {
                                text: model.ssid
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: 15
                                font.weight: row.isSelected || row.isConnected ? Font.DemiBold : Font.Normal
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: row.isConnected ? qsTr("Connected") : (model.secure ? qsTr("Secured") : qsTr("Open"))
                                color: row.isConnected ? Theme.good : Theme.faint
                                font.family: Theme.font
                                font.pixelSize: 13
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.status = ""
                                if (row.isConnected) return
                                if (!model.secure) root.connectTo(model.ssid, "")
                                else root.selected = index
                            }
                        }
                    }
                    // password + Connect, under the chosen network
                    Item {
                        visible: row.isSelected
                        width: parent.width
                        height: visible ? 62 : 0
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 54
                            anchors.rightMargin: 18
                            anchors.bottomMargin: 18
                            spacing: 10
                            LField {
                                id: pw
                                Layout.fillWidth: true
                                placeholder: qsTr("Wi-Fi password")
                                echoMode: TextInput.Password
                                text: Sys.demo ? "password" : ""
                                onAccepted: root.connectTo(model.ssid, pw.text)
                            }
                            LButton {
                                kind: "primary"
                                size: 44
                                text: qsTr("Connect")
                                onClicked: root.connectTo(model.ssid, pw.text)
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: nets.count === 0
                text: root.scanning ? qsTr("Looking for networks…") : qsTr("No Wi-Fi networks found.")
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: 15
            }
        }

        RowLayout {
            Layout.topMargin: 14
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: root.status
                color: root.status.indexOf("Couldn") === 0 ? Theme.danger : Theme.muted
                font.family: Theme.font
                font.pixelSize: 14
                wrapMode: Text.Wrap
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
