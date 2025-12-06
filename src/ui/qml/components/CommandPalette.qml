import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Popup {
    id: commandPalette
    x: (parent.width - width) / 2
    y: 50
    width: 600
    height: 400
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
        anchors.margins: 10
        
        TextField {
            id: commandInput
            Layout.fillWidth: true
            placeholderText: "Type a command name..."
            color: "#cccccc"
            background: Rectangle {
                color: "#3c3c3c"
                border.color: "#007acc"
                border.width: 1
                radius: 2
            }
            
            onTextChanged: {
                filterCommands()
            }
            
            onAccepted: {
                executeSelectedCommand()
            }
        }
        
        ListView {
            id: commandList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: filteredCommands
            clip: true
            
            delegate: Rectangle {
                width: parent.width
                height: 30
                color: commandList.currentIndex === index ? "#094771" : "transparent"
                
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.name
                    color: "#cccccc"
                    font.pixelSize: 12
                }
                
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.shortcut
                    color: "#6e7681"
                    font.pixelSize: 10
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        commandList.currentIndex = index
                        executeSelectedCommand()
                    }
                }
            }
            
            highlight: Rectangle {
                color: "#094771"
                radius: 2
            }
        }
    }
    
    onOpened: {
        modalOverlay.visible = true
        commandInput.forceActiveFocus()
        commandInput.selectAll()
        commandList.currentIndex = 0
    }
    
    onClosed: {
        modalOverlay.visible = false
    }
}