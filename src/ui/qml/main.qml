import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Lynx 1.0
import "components"

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1400
    height: 900
    title: "Lynx" + (editor.currentDocument ? 
           " - " + editor.currentDocument.fileName + 
           (editor.currentDocument.modified ? " •" : "") : "")
    
    // Atom One Dark Colors
    color: "#282C34"
    
    property bool sidebarVisible: false
    
    // File Dialogs
    FileDialog {
        id: fileOpenDialog
        fileMode: FileDialog.OpenFile
        onAccepted: {
            editor.openDocument(selectedFile.toString().replace("file://", ""))
        }
    }
    
    FileDialog {
        id: fileSaveDialog
        fileMode: FileDialog.SaveFile
        onAccepted: {
            if (editor.currentDocument) {
                editor.currentDocument.saveAs(selectedFile.toString().replace("file://", ""))
            }
        }
    }

    FolderDialog {
        id: folderOpenDialog
        title: "Open Folder"
        onAccepted: {
            var path = selectedFolder.toString().replace("file://", "")
            editor.openFolder(path)
        }
    }
    
    // Menu Bar
    menuBar: MenuBarComponent {}
    
    // Modal Overlay
    ModalOverlay {
        id: modalOverlay
        onCloseRequested: {
            findModal.close()
            replaceModal.close()
            goToLineModal.close()
            commandPalette.close()
        }
    }
    
    // Modals
    FindModal {
        id: findModal
    }
    
    ReplaceModal {
        id: replaceModal
    }
    
    GoToLineModal {
        id: goToLineModal
    }
    
    CommandPalette {
        id: commandPalette
    }
    
    // Global Shortcuts
    Shortcut {
        sequence: "Ctrl+F"
        onActivated: findModal.open()
    }
    
    Shortcut {
        sequence: "Ctrl+H"
        onActivated: replaceModal.open()
    }
    
    Shortcut {
        sequence: "Ctrl+G"
        onActivated: goToLineModal.open()
    }
    
    Shortcut {
        sequence: "Ctrl+Shift+P"
        onActivated: commandPalette.open()
    }

    Shortcut {
        sequence: "Ctrl+B"
        onActivated: sidebarVisible = !sidebarVisible
    }
    
    // Main Layout
    Item {
        anchors.fill: parent
        
        Sidebar {
            id: sidebar
            visible: sidebarVisible
            onOpenFolderRequested: folderOpenDialog.open()
        }
        
        // Main Content Area
        Item {
            id: mainContent
            anchors.left: parent.left
            anchors.leftMargin: sidebarVisible ? sidebar.width : 0
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            
            Behavior on anchors.leftMargin {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Tab Bar (multiple documents)
                TabBar {
                    id: tabBar
                    Layout.fillWidth: true
                    visible: editor.documents.length > 1
                    documents: editor.documents
                    currentDocument: editor.currentDocument
                    
                    onCloseDocumentRequested: function(document) {
                        editor.closeDocument(document)
                    }
                    
                    onSetActiveDocumentRequested: function(document) {
                        editor.setActiveDocument(document)
                    }
                }
                
                // Single Tab Header (one document)
                SingleTabHeader {
                    id: singleTabHeader
                    Layout.fillWidth: true
                    visible: editor.documents.length === 1
                    currentDocument: editor.currentDocument
                    
                    onCloseDocumentRequested: function(document) {
                        editor.closeDocument(document)
                    }
                }
                
                // Editor Area
                EditorArea {
                    id: editorArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentDocument: editor.currentDocument
                    
                    onCursorPositionChanged: {
                        statusBar.updateCursorPosition(editorArea.lineNumber, editorArea.columnNumber)
                    }
                }
                
                // Status Bar
                StatusBar {
                    id: statusBar
                    Layout.fillWidth: true
                    currentDocument: editor.currentDocument
                }
            }
        }
    }
    
    // Helper Functions
    function findNext() {
        if (!editor.currentDocument || findModal.searchText === "") return
        
        var matches = editor.currentDocument.search(findModal.searchText, false, false)
        if (matches.length === 0) return
        
        var match = editor.currentDocument.findNext(editorArea.cursorPosition)
        if (match.start !== undefined) {
            editorArea.selectText(match.start, match.end)
        }
    }

    function findPrevious() {
        if (!editor.currentDocument || findModal.searchText === "") return
        
        var matches = editor.currentDocument.search(findModal.searchText, false, false)
        if (matches.length === 0) return
        
        var match = editor.currentDocument.findPrevious(editorArea.cursorPosition)
        if (match.start !== undefined) {
            editorArea.selectText(match.start, match.end)
        }
    }

    function replaceCurrent() {
        if (!editor.currentDocument || !editorArea.hasSelection) return
        
        var success = editor.currentDocument.replaceCurrent(replaceModal.replaceText)
        if (success) {
            findNext()
        }
    }

    function replaceAll() {
        if (!editor.currentDocument || replaceModal.searchText === "") return
        
        var count = editor.currentDocument.replaceAll(
            replaceModal.searchText,
            replaceModal.replaceText,
            false,
            false
        )
        
        console.log("Replaced " + count + " occurrences")
        replaceModal.close()
    }
    
    function goToLine() {
        if (!editor.currentDocument) return
        
        var lineNumber = parseInt(goToLineModal.lineNumber)
        if (isNaN(lineNumber) || lineNumber < 1) return
        
        var position = editor.currentDocument.goToLine(lineNumber)
        editorArea.setCursorPosition(position)
        goToLineModal.close()
    }
    
    function executeCommand(action) {
        switch (action) {
            case "newFile":
                editor.newDocument()
                break
            case "openFile":
                fileOpenDialog.open()
                break
            case "openFolder":
                folderOpenDialog.open()
                break
            case "save":
                if (editor.currentDocument) {
                    editor.currentDocument.save()
                }
                break
            case "saveAs":
                fileSaveDialog.open()
                break
            case "find":
                findModal.open()
                break
            case "replace":
                replaceModal.open()
                break
            case "goToLine":
                goToLineModal.open()
                break
            case "toggleSidebar":
                sidebarVisible = !sidebarVisible
                break
        }
    }
}