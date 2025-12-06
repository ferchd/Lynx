import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects
import Lynx 1.0
import "components"

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "Lynx" + (editor.currentDocument ? 
           " - " + editor.currentDocument.fileName + 
           (editor.currentDocument.modified ? " •" : "") : "")
    
    color: "#1d1f21"

    property bool sidebarVisible: false
    
    // Fondo oscuro semitransparente para modales
    ModalOverlay {
        id: modalOverlay
        onCloseRequested: {
            findModal.close()
            replaceModal.close()
            goToLineModal.close()
            commandPalette.close()
        }
    }
    
    // Barra de menús superior completa
    menuBar: MenuBarComponent {}
    
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
    
    // Modal de Buscar
    FindModal {
        id: findModal
        onOpened: modalOverlay.visible = true
        onClosed: modalOverlay.visible = false
    }
    
    // Modal de Reemplazar
    ReplaceModal {
        id: replaceModal
        onOpened: modalOverlay.visible = true
        onClosed: modalOverlay.visible = false
    }

    // Modal de Ir a Línea
    GoToLineModal {
        id: goToLineModal
        onOpened: modalOverlay.visible = true
        onClosed: modalOverlay.visible = false
    }

    // Command Palette (Paleta de Comandos)
    CommandPalette {
        id: commandPalette
        onOpened: modalOverlay.visible = true
        onClosed: modalOverlay.visible = false
    }
    
    // Modelo de comandos para la paleta
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
            name: "Toggle Terminal"
            shortcut: "Ctrl+`"
            action: "toggleTerminal"
        }
        ListElement {
            name: "Toggle Sidebar"
            shortcut: "Ctrl+B"
            action: "toggleSidebar"
        }
    }
    
    // Función para filtrar comandos
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
    
    // Modelo filtrado para la lista de comandos
    ListModel {
        id: filteredCommands
    }
    
    // Función para ejecutar el comando seleccionado
    function executeSelectedCommand() {
        if (commandList.currentIndex >= 0) {
            var command = filteredCommands.get(commandList.currentIndex)
            
            switch (command.action) {
                case "newFile":
                    editor.newDocument()
                    break
                case "openFile":
                    fileOpenDialog.open()
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
                case "toggleTerminal":
                    console.log("Toggle Terminal")
                    break
                case "toggleSidebar":
                    console.log("Toggle Sidebar")
                    break
            }
            
            commandPalette.close()
        }
    }
    
    function findNext() {
        if (!editor.currentDocument || findInput.text === "") return
        
        var matches = editor.currentDocument.search(
            findInput.text,
            caseSensitiveCheck.checked,
            wholeWordCheck.checked
        )
        
        if (matches.length === 0) {
            console.log("No matches found")
            return
        }
        
        var match = editor.currentDocument.findNext(textEditor.cursorPosition)
        if (match.start !== undefined) {
            textEditor.select(match.start, match.end)
            textEditor.cursorPosition = match.end
        }
    }

    function findPrevious() {
        if (!editor.currentDocument || findInput.text === "") return
        
        var matches = editor.currentDocument.search(
            findInput.text,
            caseSensitiveCheck.checked,
            wholeWordCheck.checked
        )
        
        if (matches.length === 0) return
        
        var match = editor.currentDocument.findPrevious(textEditor.cursorPosition)
        if (match.start !== undefined) {
            textEditor.select(match.start, match.end)
            textEditor.cursorPosition = match.start
        }
    }

    function replaceCurrent() {
        if (!editor.currentDocument || textEditor.selectedText === "") return
        
        var success = editor.currentDocument.replaceCurrent(replaceWithInput.text)
        if (success) {
            findNext()
        }
    }

    function replaceAll() {
        if (!editor.currentDocument || replaceFindInput.text === "") return
        
        var count = editor.currentDocument.replaceAll(
            replaceFindInput.text,
            replaceWithInput.text,
            replaceCaseSensitiveCheck.checked,
            replaceWholeWordCheck.checked
        )
        
        console.log("Replaced " + count + " occurrences")
        replaceModal.close()
    }
    
    function goToLine() {
        if (!editor.currentDocument) return
        
        var lineNumber = parseInt(goToLineInput.text)
        if (isNaN(lineNumber) || lineNumber < 1) return
        
        var position = editor.currentDocument.goToLine(lineNumber)
        textEditor.cursorPosition = position
        goToLineModal.close()
    }
    
    // Atajos de teclado globales
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
        onActivated: {
            sidebar.toggleRequested()
        }
    }
    
    Row {
        anchors.fill: parent
        spacing: 0
        
        Sidebar {
            id: sidebar
            height: parent.height
            onToggleRequested: {
                sidebar.collapsed = !sidebar.collapsed
            }
            onOpenFolderRequested: {
                folderOpenDialog.open()
            }
            onSidebarWidthChanged: {
                // Actualizar el ancho expandido si es necesario
            }
        }
        
        // Separador visual
        Rectangle {
            width: 1
            height: parent.height
            color: "#181a1c"
            visible: !sidebar.collapsed
        }
        
        // Contenido principal que se expande/contrae dinámicamente
        Item {
            id: mainContent
            width: parent.width - (sidebar.collapsed ? sidebar.collapsedWidth : sidebar.expandedWidth)
            height: parent.height
            
            // El contenido principal se ajusta automáticamente
            Column {
                anchors.fill: parent
                spacing: 0
                
                // Tab bar
                TabBar {
                    id: tabBar
                    width: parent.width
                    height: editor.documents.length > 1 ? 35 : 0
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
                
                // Single tab header
                SingleTabHeader {
                    id: singleTabHeader
                    width: parent.width
                    height: editor.documents.length === 1 ? 35 : 0
                    visible: editor.documents.length === 1
                    currentDocument: editor.currentDocument
                    
                    onCloseDocumentRequested: function(document) {
                        editor.closeDocument(document)
                    }
                }
                
                // Editor area
                EditorArea {
                    id: editorArea
                    width: parent.width
                    height: parent.height - 
                           (editor.documents.length > 1 ? tabBar.height : 0) -
                           (editor.documents.length === 1 ? singleTabHeader.height : 0) -
                           statusBar.height
                    currentDocument: editor.currentDocument
                    
                    onCursorPositionChanged: {
                        updateCursorPosition()
                    }
                }
                
                // Status bar
                StatusBar {
                    id: statusBar
                    width: parent.width
                    height: 22
                    currentDocument: editor.currentDocument
                    cursorPositionText: cursorPosition.text
                }
            }
        }
    }
    
    // Función para actualizar la posición del cursor
    function updateCursorPosition() {
        if (!editor.currentDocument) return
        
        var text = textEditor.text
        var cursorPos = textEditor.cursorPosition
        var textBeforeCursor = text.substring(0, cursorPos)
        var lines = textBeforeCursor.split('\n')
        var line = lines.length
        var column = lines[lines.length - 1].length + 1
        
        cursorPosition.text = "Ln " + line + ", Col " + column
    }
}