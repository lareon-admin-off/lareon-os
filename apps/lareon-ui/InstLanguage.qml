import QtQuick
import QtQuick.Layouts
import Lareon

// Step 1: language (also the language of the new computer).
Item {
    id: root
    property var install

    readonly property var languages: [
        { code: "en",  flag: "🇺🇸", name: "English" },
        { code: "es",  flag: "🇪🇸", name: "Español" },
        { code: "fr",  flag: "🇫🇷", name: "Français" },
        { code: "de",  flag: "🇩🇪", name: "Deutsch" },
        { code: "pt",  flag: "🇵🇹", name: "Português" },
        { code: "it",  flag: "🇮🇹", name: "Italiano" },
        { code: "ru",  flag: "🇷🇺", name: "Русский" },
        { code: "tr",  flag: "🇹🇷", name: "Türkçe" },
        { code: "sv",  flag: "🇸🇪", name: "Svenska" },
        { code: "ja",  flag: "🇯🇵", name: "日本語" },
        { code: "ko",  flag: "🇰🇷", name: "한국어" },
        { code: "zh",  flag: "🇨🇳", name: "中文" },
        { code: "hi",  flag: "🇮🇳", name: "हिन्दी" },
        { code: "ar",  flag: "🇸🇦", name: "العربية" },
        { code: "fa",  flag: "🇮🇷", name: "فارسی" },
        { code: "sw",  flag: "🇹🇿", name: "Kiswahili" },
        { code: "ary", flag: "🇩🇿", name: "الدارجة" }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Welcome to Lareon OS")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            text: qsTr("Choose the language for your computer.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }

        GridLayout {
            Layout.topMargin: 30
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 10
            columnSpacing: 10

            Repeater {
                model: root.languages
                delegate: LCard {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    selected: root.install.language === modelData.code

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        spacing: 12
                        Text {
                            text: modelData.flag
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.emoji
                            font.pixelSize: 22
                        }
                        Text {
                            text: modelData.name
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 16
                            font.weight: root.install.language === modelData.code ? Font.DemiBold : Font.Normal
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.install.language = modelData.code
                    }
                }
            }
        }
        Item { Layout.fillHeight: true }
    }
}
