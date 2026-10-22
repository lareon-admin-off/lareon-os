import QtQuick
import Lareon

// Text filled with the Lareon gradient (orange → pink → violet), left to right.
// Drawn as thin slices of the same text, each in its own colour, so it works
// everywhere (also the installer's software renderer) and for every script.
Item {
    id: gt
    property string text: ""
    property int pixelSize: 40
    property int weight: Font.DemiBold
    property string family: Theme.font
    property int slices: 40
    property var stops: [[255, 124, 31], [217, 79, 196], [163, 92, 245]]

    implicitWidth: Math.ceil(measure.implicitWidth) + 2
    implicitHeight: Math.ceil(measure.implicitHeight)

    function colorAt(t) {
        const n = stops.length - 1
        const p = Math.max(0, Math.min(0.9999, t)) * n
        const i = Math.floor(p)
        const f = p - i
        const a = stops[i]
        const b = stops[i + 1]
        return Qt.rgba((a[0] + (b[0] - a[0]) * f) / 255, (a[1] + (b[1] - a[1]) * f) / 255, (a[2] + (b[2] - a[2]) * f) / 255, 1)
    }

    Text {
        id: measure
        visible: false
        text: gt.text
        font.family: gt.family
        font.pixelSize: gt.pixelSize
        font.weight: gt.weight
    }

    Repeater {
        model: gt.slices
        delegate: Item {
            required property int index
            x: Math.floor(index * gt.width / gt.slices)
            width: (index === gt.slices - 1 ? Math.ceil(gt.width) : Math.floor((index + 1) * gt.width / gt.slices)) - x
            height: gt.height
            clip: true
            Text {
                x: -parent.x
                text: gt.text
                color: gt.colorAt((parent.x + parent.width / 2) / Math.max(1, gt.width))
                font.family: gt.family
                font.pixelSize: gt.pixelSize
                font.weight: gt.weight
            }
        }
    }
}
