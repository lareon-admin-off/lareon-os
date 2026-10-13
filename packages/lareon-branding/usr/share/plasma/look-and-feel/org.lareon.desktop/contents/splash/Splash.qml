import QtQuick

// Lareon sign-in splash: the Lareon mark and a brand-gradient progress bar.
Rectangle {
    id: root
    color: "#13111b"

    property int stage

    onStageChanged: {
        if (stage === 2) {
            introAnimation.running = true
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        Image {
            id: logo
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -24
            source: "images/lareon-icon.svg"
            sourceSize.width: 144
            sourceSize.height: 144
            smooth: true
        }

        Rectangle {
            id: track
            anchors.top: logo.bottom
            anchors.topMargin: 36
            anchors.horizontalCenter: parent.horizontalCenter
            width: 168
            height: 4
            radius: 2
            color: "#2b2838"

            Rectangle {
                width: Math.max(0, Math.min(1, (root.stage - 1) / 5)) * track.width
                height: track.height
                radius: 2
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#ff7c1f" }
                    GradientStop { position: 0.6; color: "#d94fc4" }
                    GradientStop { position: 1.0; color: "#a35cf5" }
                }
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: 500
        easing.type: Easing.InOutQuad
    }
}
