import QtQuick
import QtQuick.Window
import Lareon

Window {
    id: win
    visible: true
    color: Sys.mode === "home" ? "transparent" : Theme.bg
    flags: Sys.mode === "home" ? (Qt.Window | Qt.FramelessWindowHint) : Qt.Window
    x: 96
    y: 52
    width: Sys.mode === "crash" ? 560 : Sys.mode === "updates" ? 640 : Sys.mode === "settings" ? 960 : Sys.mode === "home" ? 560 : 1920
    height: Sys.mode === "crash" ? Math.max(260, loader.item ? loader.item.implicitHeight : 300)
          : Sys.mode === "updates" ? 560 : Sys.mode === "settings" ? 640 : Sys.mode === "home" ? 680 : 1080
    visibility: Sys.mode === "updates" || Sys.mode === "settings" || Sys.mode === "home" ? Window.Windowed
              : Sys.windowed ? Window.Windowed : Window.FullScreen
    title: Sys.mode === "crash"
           ? qsTr("%1 closed unexpectedly").arg(Sys.args.name || qsTr("An app"))
           : Sys.mode === "install" ? qsTr("Install Lareon OS")
           : Sys.mode === "home" ? qsTr("Lareon Home")
           : Sys.mode === "updates" ? qsTr("Updates")
           : Sys.mode === "settings" ? qsTr("Settings")
     : qsTr("Lareon OS")

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: Sys.mode === "install" ? installScreen
                       : Sys.mode === "welcome" ? welcomeScreen
                       : Sys.mode === "install-failed" ? failedScreen
                       : Sys.mode === "crash" ? crashScreen
                       : Sys.mode === "home" ? homeScreen
                       : Sys.mode === "updates" ? updatesScreen
                       : Sys.mode === "settings" ? settingsScreen
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
    Component {
        id: welcomeScreen
        Item {
            readonly property real fit: Math.min(1, width / 1280, height / 800)
            WelcomeScreen {
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
    Component { id: settingsScreen; SettingsScreen {} }

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
