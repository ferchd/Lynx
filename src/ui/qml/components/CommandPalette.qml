import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: commandPalette
    x: (parent.width - width) / 2
    y: 80
    width: 600
    height: 400
    modal: false
    focus: true
    z: 101
    
    background: Rectangle {
        color: "#282C34"
        border.color: "#181A1F"
        border.width: 1
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        TextField {
            id: commandInput
            Layout.fillWidth: true
            placeholderText: "Type a command..."
            color: "#ABB2BF"
            font.family: "Consolas"
            font.pixelSize: 13
            
            background: Rectangle {
                color: "#21252B"
                border.color: commandInput.activeFocus ? "#528BFF" : "#181A1F"
                border.width: 1
            }
            
            onTextChanged: filterCommands()
            onAccepted: executeSelectedCommand()
        }
        
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ListView {
                id: commandList
                model: filteredCommands
                spacing: 2
                
                delegate: Rectangle {
                    width: parent.width
                    height: 32
                    color: commandList.currentIndex === index ? "#2C313A" : "transparent"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 16
                        
                        Text {
                            text: modelData.name
                            color: commandList.currentIndex === index ? "#ABB2BF" : "#5C6370"
                            font.family: "Consolas"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: modelData.shortcut
                            color: "#5C6370"
                            font.family: "Consolas"
                            font.pixelSize: 11
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onEntered: commandList.currentIndex = index
                        onClicked: {
                            commandList.currentIndex = index
                            executeSelectedCommand()
                        }
                    }
                }
                
                highlight: Rectangle {
                    color: "#2C313A"
                }
            }
        }
    }
    
    ListModel {
        id: commandsModel
        
        ListElement {
            name: "New File"
            shortcut: "Ctrl+N"
            action: "newFile"
        }
        ListElement {
            name: "Open File..."
            shortcut: "Ctrl+O"
            action: "openFile"
        }
        ListElement {
            name: "Open Folder..."
            shortcut: "Ctrl+Shift+O"
            action: "openFolder"
        }
        ListElement {
            name: "Save"
            shortcut: "Ctrl+S"
            action: "save"
        }
        ListElement {
            name: "Save As..."
            shortcut: "Ctrl+Shift+S"
            action: "saveAs"
        }
        ListElement {
            name: "Find"
            shortcut: "Ctrl+F"
            action: "find"
        }
        ListElement {
            name: "Replace"
            shortcut: "Ctrl+H"
            action: "replace"
        }
        ListElement {
            name: "Go to Line..."
            shortcut: "Ctrl+G"
            action: "goToLine"
        }
        ListElement {
            name: "Toggle Sidebar"
            shortcut: "Ctrl+B"
            action: "toggleSidebar"
        }
    }
    
    ListModel {
        id: filteredCommands
    }
    
    function filterCommands() {
        var filter = commandInput.text.toLowerCase()
        filteredCommands.clear()
        
        for (var i = 0; i < commandsModel.count; i++) {
            var command = commandsModel.get(i)
            if (command.name.toLowerCase().includes(filter)) {
                filteredCommands.append(command)
            }
        }
        
        if (filteredCommands.count > 0) {
            commandList.currentIndex = 0
        }
    }
    
    function executeSelectedCommand() {
        if (commandList.currentIndex >= 0) {
            var command = filteredCommands.get(commandList.currentIndex)
            mainWindow.executeCommand(command.action)
            commandPalette.close()
        }
    }
    
    onOpened: {
        modalOverlay.visible = true
        commandInput.text = ""
        filterCommands()
        commandInput.forceActiveFocus()
    }
    
    onClosed: {
        modalOverlay.visible = false
    }
    
    Shortcut {
        sequence: "Escape"
        enabled: commandPalette.visible
        onActivated: commandPalette.close()
    }
    
    Shortcut {
        sequence: "Down"
        enabled: commandPalette.visible
        onActivated: {
            if (commandList.currentIndex < filteredCommands.count - 1) {
                commandList.currentIndex++
            }
        }
    }
    
    Shortcut {
        sequence: "Up"
        enabled: commandPalette.visible
        onActivated: {
            if (commandList.currentIndex > 0) {
                commandList.currentIndex--
            }
        }
    }
}