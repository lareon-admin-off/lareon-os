import QtQuick
import QtQuick.Layouts
import Lareon

ColumnLayout {
    id: page
    property var host
    spacing: 14
    property string version: ""

    Component.onCompleted: {
        if (host.demo) { version = "Lareon OS 0.2"; return }
        const t = Sys.readFile("/etc/os-release")
        const m = t.match(/^PRETTY_NAME="?([^"\n]*)"?/m)
        version = m ? m[1] : "Lareon OS"
    }

    SCard {
        title: page.version
        note: qsTr("Updates are checked only when you ask, and installed only when you say so.")
        RowLayout {
            spacing: 10
            LButton { text: qsTr("Check for updates"); kind: "primary"; onClicked: Sys.startDetached("lareon-ui", ["updates"]) }
            LButton { text: qsTr("Open Software"); onClicked: Sys.startDetached("plasma-discover", []) }
        }
    }
}
