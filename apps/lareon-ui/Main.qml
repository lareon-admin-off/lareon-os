import QtQuick
import QtQuick.Window
import Lareon

Window {
    id: win
    visible: true
    color: Theme.bg
    width: Sys.mode === "crash" ? 560 : Sys.mode === "updates" ? 640 : 1920
    height: Sys.mode === "crash" ? Math.max(260, loader.item ? loader.item.implicitHeight : 300)
          : Sys.mode === "updates" ? 560 : 1080
    visibility: Sys.mode === "updates" ? Window.Windowed
              : Sys.windowed ? Window.Windowed : Window.FullScreen
    title: Sys.mode === "crash"
           ? qsTr("%1 closed unexpectedly").arg(Sys.args.name || qsTr("An app"))
           : Sys.mode === "install" ? qsTr("Install Lareon OS")
           : Sys.mode === "home" ? qsTr("Lareon Home")
           : Sys.mode === "updates" ? qsTr("Updates")
     : qsTr("Lareon OS")

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: Sys.mode === "install" ? installScreen
                       : Sys.mode === "install-failed" ? failedScreen
                       : Sys.mode === "crash" ? crashScreen
                       : Sys.mode === "home" ? homeScreen
                       : Sys.mode === "updates" ? updatesScreen
                       : setupScreen
    }

    // The setup screens are laid out for a 1280x800 screen. On a smaller one
    // (a VM window, a small laptop) the whole canvas shrinks to fit instead of
    // being cut off; on a bigger one it simply has more room.
    Component {
        id: setupScreen
        Item {
            readonly property real fit: Math.min(1, width / 1280, height / 800)
            SetupFlow {
                width: parent.width / parent.fit
                height: parent.height / parent.fit
                scale: parent.fit
                transformOrigin: Item.TopLeft
            }
        }
    }
    Component {
        id: installScreen
        Item {
            readonly property real fit: Math.min(1, width / 1280, height / 800)
            InstallFlow {
                width: parent.width / parent.fit
                height: parent.height / parent.fit
                scale: parent.fit
                transformOrigin: Item.TopLeft
            }
        }
    }
    Component { id: failedScreen; InstallFailed {} }
    Component { id: crashScreen; CrashDialog {} }
    Component { id: homeScreen; HomeScreen {} }
    Component { id: updatesScreen; UpdatesScreen {} }

    // Lareon Home closes when you click away from it
    property bool wasActive: false
    onActiveChanged: {
        if (active) {
            wasActive = true
        } else if (wasActive && Sys.mode === "home" && !Sys.windowed) {
            Sys.quit(0)
        }
    }
}
