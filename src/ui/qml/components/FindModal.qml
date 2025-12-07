import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: findModal
    x: (parent.width - width) / 2
    y: 80
    width: 500
    height: 120
    modal: false
    focus: true
    z: 101
    
    property string searchText: findInput.text
    
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
            text: "Find"
            color: "#ABB2BF"
            font.family: "Consolas"
            font.pixelSize: 13
            font.bold: true
        }
        
        TextField {
            id: findInput
            Layout.fillWidth: true
            placeholderText: "Search..."
            color: "#ABB2BF"
            font.family: "Consolas"
            font.pixelSize: 13
            
            background: Rectangle {
                color: "#21252B"
                border.color: findInput.activeFocus ? "#528BFF" : "#181A1F"
                border.width: 1
            }
            
            onAccepted: mainWindow.findNext()
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Button {
                text: "Previous"
                onClicked: mainWindow.findPrevious()
                
                background: Rectangle {
                    implicitWidth: 90
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
            
            Button {
                text: "Next"
                onClicked: mainWindow.findNext()
                
                background: Rectangle {
                    implicitWidth: 90
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
            
            Item { Layout.fillWidth: true }
        }
    }
    
    onOpened: {
        modalOverlay.visible = true
        findInput.forceActiveFocus()
        findInput.selectAll()
    }
    
    onClosed: {
        modalOverlay.visible = false
    }
    
    Shortcut {
        sequence: "Escape"
        enabled: findModal.visible
        onActivated: findModal.close()
    }
}