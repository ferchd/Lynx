import QtQuick

Rectangle {
    id: modalOverlay
    anchors.fill: parent
    color: "#80000000"
    visible: false
    z: 100
    
    signal closeRequested()
    
    opacity: visible ? 1.0 : 0.0
    
    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: closeRequested()
    }
}