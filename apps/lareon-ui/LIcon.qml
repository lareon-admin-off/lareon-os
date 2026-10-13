import QtQuick

// An image icon that stays sharp at any size.
Image {
    property int size: 22
    width: size
    height: size
    sourceSize.width: size * 2
    sourceSize.height: size * 2
    fillMode: Image.PreserveAspectFit
    smooth: true
}
