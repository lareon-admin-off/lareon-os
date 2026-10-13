/* Lareon installer, step 1: Language.
   The 17 Lareon languages (docs/LANGUAGES.md) with their flags. Picking one
   switches the installer's language (when Calamares has a translation for it)
   and saves the choice for the new system in /tmp/lareon-language, which the
   Lareon install step copies over. */
import io.calamares.core 1.0
import io.calamares.ui 1.0

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: page

    // code, flag, own name, English name, patterns to find it in Calamares'
    // list (by English label), Calamares language to use if it has none.
    readonly property var languages: [
        { code: "en",  flag: "🇺🇸", name: "English",   en: "English",          match: ["^English$", "^English \\(United States\\)$"] },
        { code: "es",  flag: "🇪🇸", name: "Español",   en: "Spanish",          match: ["^Spanish$", "^Spanish \\(Spain\\)$", "^Spanish"] },
        { code: "fr",  flag: "🇫🇷", name: "Français",  en: "French",           match: ["^French"] },
        { code: "de",  flag: "🇩🇪", name: "Deutsch",   en: "German",           match: ["^German"] },
        { code: "pt",  flag: "🇵🇹", name: "Português", en: "Portuguese",       match: ["^Portuguese \\(Portugal\\)$", "^Portuguese"] },
        { code: "it",  flag: "🇮🇹", name: "Italiano",  en: "Italian",          match: ["^Italian"] },
        { code: "ru",  flag: "🇷🇺", name: "Русский",   en: "Russian",          match: ["^Russian"] },
        { code: "tr",  flag: "🇹🇷", name: "Türkçe",    en: "Turkish",          match: ["^Turkish"] },
        { code: "sv",  flag: "🇸🇪", name: "Svenska",   en: "Swedish",          match: ["^Swedish"] },
        { code: "ja",  flag: "🇯🇵", name: "日本語",     en: "Japanese",         match: ["^Japanese$", "^Japanese"] },
        { code: "ko",  flag: "🇰🇷", name: "한국어",     en: "Korean",           match: ["^Korean"] },
        { code: "zh",  flag: "🇨🇳", name: "中文",       en: "Mandarin Chinese", match: ["^Chinese \\(China\\)$", "^Chinese \\(Simplified", "^Chinese$"] },
        { code: "hi",  flag: "🇮🇳", name: "हिन्दी",      en: "Hindi",            match: ["^Hindi"] },
        { code: "ar",  flag: "🇸🇦", name: "العربية",    en: "Arabic",           match: ["^Arabic"] },
        { code: "fa",  flag: "🇮🇷", name: "فارسی",      en: "Farsi",            match: ["^Persian", "^Farsi"] },
        { code: "sw",  flag: "🇹🇿", name: "Kiswahili", en: "Swahili",          match: ["^Swahili"], fallback: "^English$" },
        { code: "ary", flag: "🇩🇿", name: "الدارجة",    en: "Darija",           match: ["^Moroccan"], fallback: "^Arabic" }
    ]

    property string selected: "en"
    property bool installerHasIt: true

    // Calamares' language list, read through an invisible Repeater.
    Item {
        visible: false
        Repeater {
            id: calLangs
            model: config.languagesModel
            delegate: Item { property string english: model.englishLabel }
        }
    }

    function findIndex(patterns) {
        for (const p of patterns) {
            const re = new RegExp(p)
            for (let i = 0; i < calLangs.count; ++i) {
                const it = calLangs.itemAt(i)
                if (it && re.test(it.english)) return i
            }
        }
        return -1
    }

    function choose(lang) {
        selected = lang.code
        let i = findIndex(lang.match)
        installerHasIt = i >= 0
        if (i < 0 && lang.fallback) i = findIndex([lang.fallback])
        if (i >= 0) config.localeIndex = i
        // remember the real choice (e.g. Darija) for the new system
        const xhr = new XMLHttpRequest()
        xhr.open("PUT", "file:///tmp/lareon-language")
        xhr.send(lang.code)
    }

    Component.onCompleted: {
        // start on whichever Lareon language the installer opened in
        const current = calLangs.itemAt(config.localeIndex)
        for (const l of languages) {
            if (current && l.match.some(p => new RegExp(p).test(current.english))) {
                selected = l.code
                break
            }
        }
        choose(languages.find(l => l.code === selected))
    }

    // background: the Lareon mountains, faded at the top
    Rectangle { anchors.fill: parent; color: "#13111b" }
    Image {
        anchors.fill: parent
        source: "file:///var/lib/lareon/timeofday/current.png"
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignBottom
        opacity: 0.38
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#13111b" }
            GradientStop { position: 0.35; color: "#13111b" }
            GradientStop { position: 0.85; color: "#0013111b" }
        }
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.topMargin: 78
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 72, 820)
        spacing: 0

        Text {
            text: qsTr("Choose your language")
            color: "#ece9f5"
            font.family: "Geist"
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr("This is used for the installer and for Lareon OS. You can change it later in Settings.")
            color: "#a7a4ba"
            font.family: "Geist"
            font.pixelSize: 16.5
        }

        GridLayout {
            Layout.topMargin: 34
            Layout.fillWidth: true
            columns: 4
            rowSpacing: 10
            columnSpacing: 10

            Repeater {
                model: page.languages
                Rectangle {
                    readonly property bool isSelected: modelData.code === page.selected
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 12
                    color: isSelected ? Qt.rgba(1, 0.486, 0.122, 0.08) : Qt.rgba(0.102, 0.094, 0.141, 0.92)
                    border.width: 1
                    border.color: isSelected ? "#ff7c1f" : (hover.containsMouse ? "#3a3648" : "#2b2838")
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 10
                        spacing: 12
                        Text {
                            text: modelData.flag
                            font.family: "Noto Color Emoji"
                            font.pixelSize: 26
                        }
                        Column {
                            Layout.fillWidth: true
                            Text {
                                width: parent.width
                                text: modelData.name
                                elide: Text.ElideRight
                                color: "#ece9f5"
                                font.family: "Geist"
                                font.pixelSize: 14.5
                                font.weight: Font.DemiBold
                            }
                            Text {
                                width: parent.width
                                text: modelData.en
                                elide: Text.ElideRight
                                color: "#74718a"
                                font.family: "Geist"
                                font.pixelSize: 12
                            }
                        }
                    }
                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: page.choose(modelData)
                    }
                }
            }
        }

        Text {
            Layout.topMargin: 16
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            visible: !page.installerHasIt
            text: qsTr("The installer itself isn’t translated into this language yet, so it shows in a close one. Lareon OS will use the language you chose.")
            color: "#a7a4ba"
            font.family: "Geist"
            font.pixelSize: 13.5
        }

        // the computer's requirements (storage, memory, power)
        Rectangle {
            Layout.topMargin: 16
            Layout.fillWidth: true
            Layout.preferredHeight: reqText.implicitHeight + 22
            radius: 8
            readonly property bool ok: config.requirementsModel.satisfiedRequirements
            color: ok ? Qt.rgba(0.30, 0.76, 0.54, 0.10) : Qt.rgba(1, 0.31, 0.48, 0.12)
            border.color: ok ? Qt.rgba(0.30, 0.76, 0.54, 0.35) : Qt.rgba(1, 0.31, 0.48, 0.45)
            Text {
                id: reqText
                anchors.fill: parent
                anchors.margins: 11
                anchors.leftMargin: 16
                wrapMode: Text.Wrap
                textFormat: Text.StyledText
                text: parent.ok
                      ? "✓  " + qsTr("This computer satisfies all of the recommended requirements for installing %1.").arg(Branding.string(Branding.ProductName))
                      : config.warningMessage
                color: parent.ok ? "#8fe0b8" : "#ffd0dc"
                font.family: "Geist"
                font.pixelSize: 13.5
            }
        }
    }

    function onActivate() {}
    function onLeave() {}
}
