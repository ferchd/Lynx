import QtQuick
import QtQuick.Controls

MenuBar {
    Menu {
        title: "&File"

    Action {
        text: "&New"
        shortcut: StandardKey.New
        onTriggered: editor.newDocument()
    }
    
    Action {
        text: "&Open..."
        shortcut: StandardKey.Open
        onTriggered: fileOpenDialog.open()
    }
    
    Action {
        text: "Open &Folder..."
        shortcut: "Ctrl+K Ctrl+O"
        onTriggered: folderOpenDialog.open()
    }
    
    MenuSeparator {}
        
        Action {
            text: "&Save"
            shortcut: StandardKey.Save
            enabled: editor.currentDocument !== null
            onTriggered: {
                if (editor.currentDocument) {
                    editor.currentDocument.save()
                }
            }
        }
        
        Action {
            text: "Save &As..."
            shortcut: StandardKey.SaveAs
            enabled: editor.currentDocument !== null
            onTriggered: fileSaveDialog.open()
        }
        
        Action {
            text: "Save A&ll"
            shortcut: "Ctrl+K S"
            onTriggered: console.log("Save All clicked")
        }
        
        MenuSeparator {}
        
        Action {
            text: "&Close Editor"
            shortcut: "Ctrl+W"
            enabled: editor.currentDocument !== null
            onTriggered: {
                if (editor.currentDocument) {
                    editor.closeDocument(editor.currentDocument)
                }
            }
        }
        
        Action {
            text: "Close Folde&r"
            shortcut: "Ctrl+K F"
            onTriggered: console.log("Close Folder clicked")
        }
        
        Action {
            text: "Clos&e All"
            onTriggered: {
                while (editor.documents.length > 0) {
                    editor.closeDocument(editor.documents[0])
                }
            }
        }
        
        MenuSeparator {}
        
        Action {
            text: "&Preferences"
            onTriggered: console.log("Preferences clicked")
        }
        
        MenuSeparator {}
        
        Action {
            text: "E&xit"
            shortcut: StandardKey.Quit
            onTriggered: Qt.quit()
        }
    }
    
    Menu {
        title: "&Edit"
        
        Action {
            text: "&Undo"
            shortcut: StandardKey.Undo
            enabled: editor.currentDocument ? editor.currentDocument.canUndo : false
            onTriggered: {
                if (editor.currentDocument) {
                    editor.currentDocument.undo()
                }
            }
        }
        
        Action {
            text: "&Redo"
            shortcut: StandardKey.Redo
            enabled: editor.currentDocument ? editor.currentDocument.canRedo : false
            onTriggered: {
                if (editor.currentDocument) {
                    editor.currentDocument.redo()
                }
            }
        }
        
        MenuSeparator {}
        
        Action {
            text: "Cu&t"
            shortcut: StandardKey.Cut
            enabled: editor.currentDocument !== null
            onTriggered: {
                if (textEditor.selectedText) {
                    textEditor.cut()
                }
            }
        }
        
        Action {
            text: "&Copy"
            shortcut: StandardKey.Copy
            enabled: editor.currentDocument !== null
            onTriggered: {
                if (textEditor.selectedText) {
                    textEditor.copy()
                }
            }
        }
        
        Action {
            text: "&Paste"
            shortcut: StandardKey.Paste
            enabled: editor.currentDocument !== null
            onTriggered: textEditor.paste()
        }
        
        MenuSeparator {}
        
        Action {
            text: "&Find"
            shortcut: StandardKey.Find
            enabled: editor.currentDocument !== null
            onTriggered: findModal.open()
        }
        
        Action {
            text: "Find and Re&place"
            shortcut: StandardKey.Replace
            enabled: editor.currentDocument !== null
            onTriggered: replaceModal.open()
        }
        
        MenuSeparator {}
        
        Action {
            text: "Select &All"
            shortcut: StandardKey.SelectAll
            enabled: editor.currentDocument !== null
            onTriggered: textEditor.selectAll()
        }
    }
    
    Menu {
        title: "&View"
        
        Action {
            text: "Command Palet&te..."
            shortcut: "Ctrl+Shift+P"
            onTriggered: commandPalette.open()
        }
        
        MenuSeparator {}
        
        Menu {
            title: "Appearance"
            
            Action {
                text: "Fullscreen"
                shortcut: "F11"
                onTriggered: mainWindow.visibility === Window.FullScreen ? 
                            mainWindow.visibility = Window.Windowed : 
                            mainWindow.visibility = Window.FullScreen
            }
            
            Action {
                text: "Zen Mode"
                shortcut: "Ctrl+K Z"
                onTriggered: console.log("Zen Mode clicked")
            }
        }
        
        MenuSeparator {}
        
        Action {
            text: "Explorer"
            shortcut: "Ctrl+Shift+E"
            checkable: true
            checked: true
            onTriggered: console.log("Explorer toggled: " + checked)
        }
        
        Action {
            text: "Search"
            shortcut: "Ctrl+Shift+F"
            onTriggered: findModal.open()
        }
        
        Action {
            text: "Source Control"
            shortcut: "Ctrl+Shift+G"
            onTriggered: console.log("Source Control clicked")
        }
        
        Action {
            text: "Run and Debug"
            shortcut: "Ctrl+Shift+D"
            onTriggered: console.log("Run and Debug clicked")
        }
        
        Action {
            text: "Extensions"
            shortcut: "Ctrl+Shift+X"
            onTriggered: console.log("Extensions clicked")
        }
    }
    
    Menu {
        title: "&Go"
        
        Action {
            text: "Back"
            shortcut: "Alt+Left"
            onTriggered: console.log("Back clicked")
        }
        
        Action {
            text: "Forward"
            shortcut: "Alt+Right"
            onTriggered: console.log("Forward clicked")
        }
        
        MenuSeparator {}
        
        Action {
            text: "Go to File..."
            shortcut: "Ctrl+P"
            onTriggered: commandPalette.open()
        }
        
        Action {
            text: "Go to Symbol in File..."
            shortcut: "Ctrl+Shift+O"
            onTriggered: console.log("Go to Symbol in File clicked")
        }
        
        Action {
            text: "Go to Symbol in Workspace..."
            shortcut: "Ctrl+T"
            onTriggered: console.log("Go to Symbol in Workspace clicked")
        }
        
        Action {
            text: "Go to Line/Column..."
            shortcut: "Ctrl+G"
            onTriggered: goToLineModal.open()
        }
        
        MenuSeparator {}
        
        Action {
            text: "Next Problem"
            shortcut: "F8"
            onTriggered: console.log("Next Problem clicked")
        }
        
        Action {
            text: "Previous Problem"
            shortcut: "Shift+F8"
            onTriggered: console.log("Previous Problem clicked")
        }
    }
    
    Menu {
        title: "&Run"
        
        Action {
            text: "Start Debugging"
            shortcut: "F5"
            onTriggered: console.log("Start Debugging clicked")
        }
        
        Action {
            text: "Run Without Debugging"
            shortcut: "Ctrl+F5"
            onTriggered: console.log("Run Without Debugging clicked")
        }
        
        Action {
            text: "Stop Debugging"
            shortcut: "Shift+F5"
            onTriggered: console.log("Stop Debugging clicked")
        }
        
        Action {
            text: "Restart Debugging"
            shortcut: "Ctrl+Shift+F5"
            onTriggered: console.log("Restart Debugging clicked")
        }
        
        MenuSeparator {}
        
        Action {
            text: "Open Configurations"
            onTriggered: console.log("Open Configurations clicked")
        }
        
        Action {
            text: "Add Configuration..."
            onTriggered: console.log("Add Configuration clicked")
        }
    }
    
    Menu {
        title: "&Terminal"
        
        Action {
            text: "New Terminal"
            shortcut: "Ctrl+`"
            onTriggered: console.log("New Terminal clicked")
        }
        
        Action {
            text: "Split Terminal"
            shortcut: "Ctrl+Shift+`"
            onTriggered: console.log("Split Terminal clicked")
        }
        
        MenuSeparator {}
        
        Action {
            text: "Run Task..."
            onTriggered: console.log("Run Task clicked")
        }
        
        Action {
            text: "Run Build Task..."
            shortcut: "Ctrl+Shift+B"
            onTriggered: console.log("Run Build Task clicked")
        }
    }
    
    Menu {
        title: "&Help"
        
        Action {
            text: "Welcome"
            onTriggered: console.log("Welcome clicked")
        }
        
        Action {
            text: "Documentation"
            onTriggered: console.log("Documentation clicked")
        }
        
        Action {
            text: "Show All Commands"
            shortcut: "Ctrl+Shift+P"
            onTriggered: commandPalette.open()
        }
        
        MenuSeparator {}
        
        Action {
            text: "Keyboard Shortcuts Reference"
            onTriggered: console.log("Keyboard Shortcuts Reference clicked")
        }
        
        Action {
            text: "Tips and Tricks"
            onTriggered: console.log("Tips and Tricks clicked")
        }
        
        MenuSeparator {}
        
        Action {
            text: "About Lynx Editor"
            onTriggered: console.log("About Lynx Editor clicked")
        }
    }
}