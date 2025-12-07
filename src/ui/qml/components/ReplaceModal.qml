import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: replaceModal
    x: (parent.width - width) / 2
    y: 80
    width: 500
    height: 180
    modal: false
    focus: true
    z: 101
    
    property string searchText: replaceFindInput.text
    property string replaceText: replaceWithInput.text
    
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
            text: "Replace"
            color: "#ABB2BF"
            font.family: "Consolas"
            font.pixelSize: 13
            font.bold: true
        }
        
        TextField {
            id: replaceFindInput
            Layout.fillWidth: true
            placeholderText: "Find..."
            color: "#ABB2BF"
            font.family: "Consolas"
            font.pixelSize: 13
            
            background: Rectangle {
                color: "#21252B"
                border.color: replaceFindInput.activeFocus ? "#528BFF" : "#181A1F"
                border.width: 1
            }
        }
        
        TextField {
            id: replaceWithInput
            Layout.fillWidth: true
            placeholderText: "Replace with..."
            color: "#ABB2BF"
            font.family: "Consolas"
            font.pixelSize: 13
            
            background: Rectangle {
                color: "#21252B"
                border.color: replaceWithInput.activeFocus ? "#528BFF" : "#181A1F"
                border.width: 1
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Button {
                text: "Replace"
                onClicked: mainWindow.replaceCurrent()
                
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
                text: "Replace All"
                onClicked: mainWindow.replaceAll()
                
                background: Rectangle {
                    implicitWidth: 100
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
        replaceFindInput.forceActiveFocus()
        replaceFindInput.selectAll()
    }
    
    onClosed: {
        modalOverlay.visible = false
    }
    
    Shortcut {
        sequence: "Escape"
        enabled: replaceModal.visible
        onActivated: replaceModal.close()
    }
}