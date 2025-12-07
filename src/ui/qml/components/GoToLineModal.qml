import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: goToLineModal
    x: (parent.width - width) / 2
    y: 80
    width: 400
    height: 120
    modal: false
    focus: true
    z: 101
    
    property string lineNumber: goToLineInput.text
    
    background: Rectangle {
        color: "#282C34"
        border.color: "#181A1F"
        border.width: 1
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        Text {
            text: "Go to Line"
            color: "#ABB2BF"
            font.family: "Consolas"
            font.pixelSize: 13
            font.bold: true
        }
        
        TextField {
            id: goToLineInput
            Layout.fillWidth: true
            placeholderText: "Line number..."
            color: "#ABB2BF"
            font.family: "Consolas"
            font.pixelSize: 13
            validator: IntValidator { bottom: 1; top: 999999 }
            
            background: Rectangle {
                color: "#21252B"
                border.color: goToLineInput.activeFocus ? "#528BFF" : "#181A1F"
                border.width: 1
            }
            
            onAccepted: mainWindow.goToLine()
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "Go"
                onClicked: mainWindow.goToLine()
                
                background: Rectangle {
                    implicitWidth: 80
                    implicitHeight: 28
                    color: parent.pressed ? "#4D78CC" : 
                           (parent.hovered ? "#4D78CC" : "#528BFF")
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#FFFFFF"
                    font.family: "Consolas"
                    font.pixelSize: 12
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
    
    Shortcut {
        sequence: "Escape"
        enabled: goToLineModal.visible
        onActivated: goToLineModal.close()
    }
}