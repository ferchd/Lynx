import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: modalOverlay
    anchors.fill: parent
    color: "#80000000"
    visible: false
    z: 100
    
    layer.enabled: true
    layer.effect: FastBlur {
        radius: 16
    }

    signal closeRequested()
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            closeRequested()
        }
    }
}