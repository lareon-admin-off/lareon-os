import QtQuick
import QtQuick.Window
import Lareon

Window {
    id: win
    visible: true
    color: Theme.bg
    width: Sys.mode === "crash" ? 560 : 1920
    height: Sys.mode === "crash" ? Math.max(260, loader.item ? loader.item.implicitHeight : 300) : 1080
    visibility: Sys.windowed ? Window.Windowed : Window.FullScreen
    title: Sys.mode === "crash"
           ? qsTr("%1 closed unexpectedly").arg(Sys.args.name || qsTr("An app"))
           : qsTr("Lareon OS")

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: Sys.mode === "install-failed" ? failedScreen
                       : Sys.mode === "crash" ? crashScreen
                       : setupScreen
    }

    Component { id: setupScreen; SetupFlow {} }
    Component { id: failedScreen; InstallFailed {} }
    Component { id: crashScreen; CrashDialog {} }
}
