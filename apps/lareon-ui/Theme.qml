pragma Singleton
import QtQuick

// Lareon brand kit colours and type (artwork/brand/README.md).
QtObject {
    readonly property color bg: "#13111b"
    readonly property color panel: "#1a1824"
    readonly property color panel2: "#211e2d"
    readonly property color lines: "#2b2838"
    readonly property color text: "#ece9f5"
    readonly property color muted: "#a7a4ba"
    readonly property color faint: "#74718a"
    readonly property color accent: "#ff7c1f"
    readonly property color accentHover: "#ff8f3d"
    readonly property color onAccent: "#13111b"
    readonly property color violet: "#a35cf5"
    readonly property color magenta: "#d94fc4"
    readonly property color danger: "#ff4f7a"
    readonly property color good: "#4cc38a"

    readonly property color accentSoft: Qt.rgba(1, 0.486, 0.122, 0.10)
    readonly property color accentRing: Qt.rgba(1, 0.486, 0.122, 0.18)

    readonly property string font: "Geist"
    readonly property string mono: "Geist Mono"
    readonly property string emoji: "Noto Color Emoji"

    readonly property int radius: 12
    readonly property int fieldRadius: 9

    // Exact brand-kit files, installed by the lareon-branding package
    readonly property url logo: "file:///usr/share/icons/hicolor/scalable/apps/lareon.svg"
    function productLogo(name) {
        return "file:///usr/share/icons/hicolor/256x256/apps/lareon-" + name + ".png"
    }
    // Breeze icons from the system icon theme, by file
    function breeze(category, name, size) {
        return "file:///usr/share/icons/breeze-dark/" + category + "/" + size + "/" + name + ".svg"
    }
}
