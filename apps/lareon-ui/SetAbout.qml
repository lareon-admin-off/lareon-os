import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14

    property var rows: []

    function osField(txt, key) {
        const m = txt.match(new RegExp("^" + key + "=\"?([^\"\\n]*)\"?", "m"))
        return m ? m[1] : ""
    }
    function load() {
        if (host.demo) {
            rows = [
                { k: qsTr("Computer"), v: "lareon" }, { k: qsTr("System"), v: "Lareon OS 0.2" },
                { k: qsTr("Based on"), v: "Debian GNU/Linux 13" }, { k: qsTr("Desktop"), v: "KDE Plasma 6" },
                { k: qsTr("Processor"), v: "Apple Silicon (emulated)" }, { k: qsTr("Memory"), v: "4.0 GB" },
                { k: qsTr("Storage"), v: "12 GB used of 64 GB" }
            ]
            return
        }
        const os = Sys.readFile("/etc/os-release")
        host.sh("hostname; uname -r; grep -m1 'model name' /proc/cpuinfo | cut -d: -f2; free -h --si | awk '/Mem:/{print $2}'; df -h --output=used,size / | tail -1; echo \"$XDG_SESSION_TYPE\"; plasmashell --version 2>/dev/null; cat /etc/debian_version", function (c, out) {
            const l = out.split("\n")
            const df = (l[4] || "").trim().split(/\s+/)
            page.rows = [
                { k: qsTr("Computer"), v: l[0] },
                { k: qsTr("System"), v: page.osField(os, "PRETTY_NAME") },
                { k: qsTr("Based on"), v: "Debian " + (l[7] || "").trim() },
                { k: qsTr("Desktop"), v: (l[6] || "").replace("plasmashell", "KDE Plasma").trim() },
                { k: qsTr("Kernel"), v: l[1] },
                { k: qsTr("Processor"), v: (l[2] || "").trim() },
                { k: qsTr("Memory"), v: l[3] },
                { k: qsTr("Storage"), v: df.length >= 2 ? qsTr("%1 used of %2").arg(df[0]).arg(df[1]) : "" },
                { k: qsTr("Session"), v: l[5] }
            ].filter(r => r.v && String(r.v).trim() !== "")
        })
    }
    Component.onCompleted: load()

    SCard {
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            LIcon { size: 56; source: Theme.logo }
            ColumnLayout {
                spacing: 2
                Text { text: "Lareon OS"; color: Theme.text; font.family: Theme.font; font.pixelSize: 22; font.weight: Font.DemiBold }
                Text { text: qsTr("Private by default. Made to feel like yours."); color: Theme.muted; font.family: Theme.font; font.pixelSize: 13 }
            }
        }
    }

    SCard {
        title: qsTr("Your computer")
        Repeater {
            model: page.rows
            delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true
                Text { Layout.preferredWidth: 130; text: modelData.k; color: Theme.muted; font.family: Theme.font; font.pixelSize: 14 }
                Text { Layout.fillWidth: true; text: modelData.v; color: Theme.text; font.family: Theme.font; font.pixelSize: 14; elide: Text.ElideRight }
            }
        }
        LButton {
            text: qsTr("Copy this info")
            size: 34
            onClicked: {
                Sys.copyText(page.rows.map(r => r.k + ": " + r.v).join("\n"))
                page.host.say(qsTr("Copied"))
            }
        }
    }

    SCard {
        title: qsTr("Something not working?")
        note: qsTr("Run the checkup to see what’s wrong and how to fix it.")
        LButton { text: qsTr("Run checkup"); size: 36; onClicked: Sys.startDetached("konsole", ["-e", "lareon-doctor"]) }
    }
}
