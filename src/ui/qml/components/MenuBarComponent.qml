import QtQuick
import QtQuick.Controls

MenuBar {
    id: menuBar
    
    background: Rectangle {
        color: "#21252B"
        
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "#181A1F"
        }
    }
    
    delegate: MenuBarItem {
        id: menuBarItem
        
        contentItem: Text {
            text: menuBarItem.text
            font.pixelSize: 13
            font.family: "Consolas"
            opacity: enabled ? 1.0 : 0.5
            color: menuBarItem.highlighted ? "#ABB2BF" : "#5C6370"
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            opacity: enabled ? 1 : 0.3
            color: menuBarItem.highlighted ? "#2C313A" : "transparent"
        }
    }
    
    // File Menu
    Menu {
        title: "File"
        
        delegate: MenuItem {
            id: menuItem
            
            contentItem: Text {
                text: menuItem.text
                font.pixelSize: 12
                font.family: "Consolas"
                opacity: enabled ? 1.0 : 0.5
                color: menuItem.highlighted ? "#ABB2BF" : "#5C6370"
            }
            
            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 28
                opacity: enabled ? 1 : 0.3
                color: menuItem.highlighted ? "#2C313A" : "transparent"
            }
        }
        
        background: Rectangle {
            implicitWidth: 200
            color: "#282C34"
            border.color: "#181A1F"
            border.width: 1
        }
        
        Action {
            text: "New File"
            shortcut: StandardKey.New
            onTriggered: editor.newDocument()
        }
        
        Action {
            text: "Open File..."
            shortcut: StandardKey.Open
            onTriggered: fileOpenDialog.open()
        }
        
        Action {
            text: "Open Folder..."
            shortcut: "Ctrl+Shift+O"
            onTriggered: folderOpenDialog.open()
        }
        
        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: "#181A1F"
            }
        }
        
        Action {
            text: "Save"
            shortcut: StandardKey.Save
            enabled: editor.currentDocument !== null
            onTriggered: {
                if (editor.currentDocument) {
                    editor.currentDocument.save()
                }
            }
        }
        
        Action {
            text: "Save As..."
            shortcut: StandardKey.SaveAs
            enabled: editor.currentDocument !== null
            onTriggered: fileSaveDialog.open()
        }
        
        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: "#181A1F"
            }
        }
        
        Action {
            text: "Close Editor"
            shortcut: "Ctrl+W"
            enabled: editor.currentDocument !== null
            onTriggered: {
                if (editor.currentDocument) {
                    editor.closeDocument(editor.currentDocument)
                }
            }
        }
        
        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: "#181A1F"
            }
        }
        
        Action {
            text: "Exit"
            shortcut: StandardKey.Quit
            onTriggered: Qt.quit()
        }
    }
    
    // Edit Menu
    Menu {
        title: "Edit"
        
        delegate: MenuItem {
            id: editMenuItem
            
            contentItem: Text {
                text: editMenuItem.text
                font.pixelSize: 12
                font.family: "Consolas"
                opacity: enabled ? 1.0 : 0.5
                color: editMenuItem.highlighted ? "#ABB2BF" : "#5C6370"
            }
            
            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 28
                opacity: enabled ? 1 : 0.3
                color: editMenuItem.highlighted ? "#2C313A" : "transparent"
            }
        }
        
        background: Rectangle {
            implicitWidth: 200
            color: "#282C34"
            border.color: "#181A1F"
            border.width: 1
        }
        
        Action {
            text: "Undo"
            shortcut: StandardKey.Undo
            enabled: editor.currentDocument ? editor.currentDocument.canUndo : false
            onTriggered: {
                if (editor.currentDocument) {
                    editor.currentDocument.undo()
                }
            }
        }
        
        Action {
            text: "Redo"
            shortcut: StandardKey.Redo
            enabled: editor.currentDocument ? editor.currentDocument.canRedo : false
            onTriggered: {
                if (editor.currentDocument) {
                    editor.currentDocument.redo()
                }
            }
        }
        
        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: "#181A1F"
            }
        }
        
        Action {
            text: "Find"
            shortcut: StandardKey.Find
            enabled: editor.currentDocument !== null
            onTriggered: findModal.open()
        }
        
        Action {
            text: "Replace"
            shortcut: StandardKey.Replace
            enabled: editor.currentDocument !== null
            onTriggered: replaceModal.open()
        }
        
        Action {
            text: "Go to Line..."
            shortcut: "Ctrl+G"
            enabled: editor.currentDocument !== null
            onTriggered: goToLineModal.open()
        }
    }
    
    // View Menu
    Menu {
        title: "View"
        
        delegate: MenuItem {
            id: viewMenuItem
            
            contentItem: Text {
                text: viewMenuItem.text
                font.pixelSize: 12
                font.family: "Consolas"
                opacity: enabled ? 1.0 : 0.5
                color: viewMenuItem.highlighted ? "#ABB2BF" : "#5C6370"
            }
            
            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 28
                opacity: enabled ? 1 : 0.3
                color: viewMenuItem.highlighted ? "#2C313A" : "transparent"
            }
        }
        
        background: Rectangle {
            implicitWidth: 200
            color: "#282C34"
            border.color: "#181A1F"
            border.width: 1
        }
        
        Action {
            text: "Command Palette..."
            shortcut: "Ctrl+Shift+P"
            onTriggered: commandPalette.open()
        }
        
        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: "#181A1F"
            }
        }
        
        Action {
            text: "Toggle Sidebar"
            shortcut: "Ctrl+B"
            onTriggered: mainWindow.sidebarVisible = !mainWindow.sidebarVisible
        }
        
        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: "#181A1F"
            }
        }
        
        Action {
            text: "Fullscreen"
            shortcut: "F11"
            onTriggered: {
                mainWindow.visibility === Window.FullScreen ? 
                mainWindow.visibility = Window.Windowed : 
                mainWindow.visibility = Window.FullScreen
            }
        }
    }
}