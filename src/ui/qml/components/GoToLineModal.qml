import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Popup {
    id: goToLineModal
    x: (parent.width - width) / 2
    y: 100
    width: 300
    height: 100
    modal: false
    focus: true
    z: 101
    
    background: Rectangle {
        color: "#252526"
        border.color: "#3c3c3c"
        radius: 4
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 4
            radius: 16
            samples: 33
            color: "#40000000"
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        
        Text {
            text: "Go to Line"
            color: "#cccccc"
            font.pixelSize: 14
            font.bold: true
        }
        
        TextField {
            id: goToLineInput
            Layout.fillWidth: true
            placeholderText: "Line number..."
            color: "#cccccc"
            background: Rectangle {
                color: "#3c3c3c"
                border.color: "#007acc"
                border.width: 1
                radius: 2
            }
            validator: IntValidator { bottom: 1; top: 999999 }
            
            onAccepted: {
                goToLine()
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            
            Item {
                Layout.fillWidth: true
            }
            
            Button {
                text: "Cancel"
                onClicked: goToLineModal.close()
                background: Rectangle {
                    color: "#3c3c3c"
                    radius: 2
                }
                contentItem: Text {
                    text: parent.text
                    color: "#cccccc"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            Button {
                text: "Go"
                onClicked: goToLine()
                background: Rectangle {
                    color: "#0e639c"
                    radius: 2
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    
    onOpened: {
        modalOverlay.visible = true
        goToLineInput.forceActiveFocus()
        goToLineInput.selectAll()
    }
    
    onClosed: {
        modalOverlay.visible = false
    }
}