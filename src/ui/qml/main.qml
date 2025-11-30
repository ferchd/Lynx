import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects
import Lynx 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "Lynx Editor" + (editor.currentDocument ? 
           " - " + editor.currentDocument.fileName + 
           (editor.currentDocument.modified ? " •" : "") : "")
    
    color: "#1d1f21"
    
    // Fondo oscuro semitransparente para modales
    Rectangle {
        id: modalOverlay
        anchors.fill: parent
        color: "#80000000"
        visible: false
        z: 100
        
        // Efecto de desenfoque para el contenido detrás del modal
        layer.enabled: true
        layer.effect: FastBlur {
            radius: 16
        }
        
        // Cerrar modal al hacer clic en el overlay
        MouseArea {
            anchors.fill: parent
            onClicked: {
                findModal.close()
                replaceModal.close()
                goToLineModal.close()
                commandPalette.close()
            }
        }
    }
    
    // Barra de menús superior completa
    menuBar: MenuBar {
        Menu {
            title: "&File"
            
            Action {
                text: "&New"
                shortcut: StandardKey.New
                onTriggered: editor.newDocument()
            }
            
            Action {
                text: "New &Window"
                shortcut: "Ctrl+Shift+N"
                onTriggered: console.log("New Window clicked")
            }
            
            Action {
                text: "&Open..."
                shortcut: StandardKey.Open
                onTriggered: fileOpenDialog.open()
            }
            
            Action {
                text: "Open &Folder..."
                shortcut: "Ctrl+K Ctrl+O"
                onTriggered: console.log("Open Folder clicked")
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
    
    // Modal de Buscar
    Popup {
        id: findModal
        x: (parent.width - width) / 2
        y: 100
        width: 400
        height: 120
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
                text: "Find"
                color: "#cccccc"
                font.pixelSize: 14
                font.bold: true
            }
            
            TextField {
                id: findInput
                Layout.fillWidth: true
                placeholderText: "Find in file..."
                color: "#cccccc"
                background: Rectangle {
                    color: "#3c3c3c"
                    border.color: "#007acc"
                    border.width: 1
                    radius: 2
                }
                
                onAccepted: {
                    findNext()
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                
                CheckBox {
                    id: caseSensitiveCheck
                    text: "Match Case"
                    checked: false
                    indicator: Rectangle {
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 3
                        color: caseSensitiveCheck.checked ? "#007acc" : "#3c3c3c"
                        border.color: caseSensitiveCheck.checked ? "#007acc" : "#666666"
                        
                        Text {
                            text: "✓"
                            color: "white"
                            font.pixelSize: 12
                            anchors.centerIn: parent
                            visible: caseSensitiveCheck.checked
                        }
                    }
                    
                    contentItem: Text {
                        text: caseSensitiveCheck.text
                        color: "#cccccc"
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: caseSensitiveCheck.indicator.width + caseSensitiveCheck.spacing
                    }
                }
                
                CheckBox {
                    id: wholeWordCheck
                    text: "Whole Word"
                    checked: false
                    indicator: Rectangle {
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 3
                        color: wholeWordCheck.checked ? "#007acc" : "#3c3c3c"
                        border.color: wholeWordCheck.checked ? "#007acc" : "#666666"
                        
                        Text {
                            text: "✓"
                            color: "white"
                            font.pixelSize: 12
                            anchors.centerIn: parent
                            visible: wholeWordCheck.checked
                        }
                    }
                    
                    contentItem: Text {
                        text: wholeWordCheck.text
                        color: "#cccccc"
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: wholeWordCheck.indicator.width + wholeWordCheck.spacing
                    }
                }
                
                Item {
                    Layout.fillWidth: true
                }
                
                Button {
                    text: "Previous"
                    onClicked: findPrevious()
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
                
                Button {
                    text: "Next"
                    onClicked: findNext()
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
                
                Button {
                    text: "Replace"
                    onClicked: replaceModal.open()
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
    }
    
    // Modal de Reemplazar
    Popup {
        id: replaceModal
        x: (parent.width - width) / 2
        y: 100
        width: 400
        height: 160
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
                text: "Replace"
                color: "#cccccc"
                font.pixelSize: 14
                font.bold: true
            }
            
            TextField {
                id: replaceFindInput
                Layout.fillWidth: true
                placeholderText: "Find..."
                color: "#cccccc"
                background: Rectangle {
                    color: "#3c3c3c"
                    border.color: "#007acc"
                    border.width: 1
                    radius: 2
                }
            }
            
            TextField {
                id: replaceWithInput
                Layout.fillWidth: true
                placeholderText: "Replace with..."
                color: "#cccccc"
                background: Rectangle {
                    color: "#3c3c3c"
                    border.color: "#007acc"
                    border.width: 1
                    radius: 2
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                
                CheckBox {
                    id: replaceCaseSensitiveCheck
                    text: "Match Case"
                    checked: false
                    indicator: Rectangle {
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 3
                        color: replaceCaseSensitiveCheck.checked ? "#007acc" : "#3c3c3c"
                        border.color: replaceCaseSensitiveCheck.checked ? "#007acc" : "#666666"
                        
                        Text {
                            text: "✓"
                            color: "white"
                            font.pixelSize: 12
                            anchors.centerIn: parent
                            visible: replaceCaseSensitiveCheck.checked
                        }
                    }
                    
                    contentItem: Text {
                        text: replaceCaseSensitiveCheck.text
                        color: "#cccccc"
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: replaceCaseSensitiveCheck.indicator.width + replaceCaseSensitiveCheck.spacing
                    }
                }
                
                CheckBox {
                    id: replaceWholeWordCheck
                    text: "Whole Word"
                    checked: false
                    indicator: Rectangle {
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 3
                        color: replaceWholeWordCheck.checked ? "#007acc" : "#3c3c3c"
                        border.color: replaceWholeWordCheck.checked ? "#007acc" : "#666666"
                        
                        Text {
                            text: "✓"
                            color: "white"
                            font.pixelSize: 12
                            anchors.centerIn: parent
                            visible: replaceWholeWordCheck.checked
                        }
                    }
                    
                    contentItem: Text {
                        text: replaceWholeWordCheck.text
                        color: "#cccccc"
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: replaceWholeWordCheck.indicator.width + replaceWholeWordCheck.spacing
                    }
                }
                
                Item {
                    Layout.fillWidth: true
                }
                
                Button {
                    text: "Replace"
                    onClicked: replaceCurrent()
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
                
                Button {
                    text: "Replace All"
                    onClicked: replaceAll()
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
            replaceFindInput.forceActiveFocus()
            replaceFindInput.selectAll()
        }
        
        onClosed: {
            modalOverlay.visible = false
        }
    }
    
    // Modal de Ir a Línea
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
    
    // Command Palette (Paleta de Comandos)
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
    
    // Funciones para buscar y reemplazar
    function findNext() {
        if (!editor.currentDocument || findInput.text === "") return
        
        var text = textEditor.text
        var searchText = findInput.text
        var options = "g"
        
        if (!caseSensitiveCheck.checked) options += "i"
        
        var regex = new RegExp(searchText, options)
        var match = regex.exec(text.substring(textEditor.cursorPosition))
        
        if (match) {
            textEditor.select(textEditor.cursorPosition + match.index, 
                             textEditor.cursorPosition + match.index + match[0].length)
        } else {
            // Buscar desde el inicio
            match = regex.exec(text)
            if (match) {
                textEditor.select(match.index, match.index + match[0].length)
            }
        }
    }
    
    function findPrevious() {
        if (!editor.currentDocument || findInput.text === "") return
        
        var text = textEditor.text
        var searchText = findInput.text
        var options = "g"
        
        if (!caseSensitiveCheck.checked) options += "i"
        
        var regex = new RegExp(searchText, options)
        var matches = []
        var match
        
        while ((match = regex.exec(text)) !== null) {
            matches.push(match)
        }
        
        // Encontrar el match anterior al cursor
        for (var i = matches.length - 1; i >= 0; i--) {
            if (matches[i].index < textEditor.cursorPosition) {
                textEditor.select(matches[i].index, matches[i].index + matches[i][0].length)
                return
            }
        }
        
        // Si no hay match anterior, ir al último
        if (matches.length > 0) {
            var lastMatch = matches[matches.length - 1]
            textEditor.select(lastMatch.index, lastMatch.index + lastMatch[0].length)
        }
    }
    
    function replaceCurrent() {
        if (!editor.currentDocument || textEditor.selectedText === "") return
        
        textEditor.insert(textEditor.selectionStart, replaceWithInput.text)
        findNext()
    }
    
    function replaceAll() {
        if (!editor.currentDocument || replaceFindInput.text === "") return
        
        var text = textEditor.text
        var searchText = replaceFindInput.text
        var replaceText = replaceWithInput.text
        var options = "g"
        
        if (!replaceCaseSensitiveCheck.checked) options += "i"
        
        var regex = new RegExp(searchText, options)
        var newText = text.replace(regex, replaceText)
        
        textEditor.text = newText
        replaceModal.close()
    }
    
    function goToLine() {
        if (!editor.currentDocument) return
        
        var lineNumber = parseInt(goToLineInput.text)
        if (isNaN(lineNumber) || lineNumber < 1) return
        
        var text = textEditor.text
        var lines = text.split('\n')
        
        if (lineNumber > lines.length) {
            lineNumber = lines.length
        }
        
        var position = 0
        for (var i = 0; i < lineNumber - 1; i++) {
            position += lines[i].length + 1 // +1 for newline
        }
        
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
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Sidebar estilo Atom con capacidad de redimensionar
        Item {
            id: sidebarContainer
            Layout.preferredWidth: 220
            Layout.minimumWidth: 150
            Layout.maximumWidth: 400
            Layout.fillHeight: true
            
            // Sidebar principal
            Rectangle {
                id: sidebar
                anchors.fill: parent
                color: "#1d1f21"
                border.color: "#181a1c"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                    // Encabezado minimalista
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "transparent"
                        
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            anchors.verticalCenter: parent.verticalCenter
                            text: "PROJECT"
                            color: "#8e9499"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }
                    
                    // Lista de archivos estilo Atom
                    ScrollView {
                        id: scrollView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        // El contenido del ScrollView se ajusta automáticamente al ancho del sidebar
                        contentWidth: listView.width
                        contentHeight: listView.contentHeight
                        
                        ListView {
                            id: listView
                            width: scrollView.width
                            anchors.left: parent.left
                            anchors.right: parent.right
                            model: [
                                {name: "github", type: "folder", expanded: true, level: 0},
                                {name: "git", type: "folder", expanded: false, level: 1},
                                {name: "bin", type: "folder", expanded: false, level: 1},
                                {name: "docs", type: "folder", expanded: false, level: 1},
                                {name: "graphql", type: "folder", expanded: false, level: 1},
                                {name: "img", type: "folder", expanded: false, level: 1},
                                {name: "keymaps", type: "folder", expanded: false, level: 1},
                                {name: "lib", type: "folder", expanded: true, level: 1},
                                {name: "atom", type: "folder", expanded: false, level: 2},
                                {name: "containers", type: "folder", expanded: false, level: 2},
                                {name: "controllers", type: "folder", expanded: false, level: 2},
                                {name: "_generated_", type: "folder", expanded: false, level: 2},
                                {name: "changed-file-controller.js", type: "file", level: 2},
                                {name: "commit-controller.js", type: "file", level: 2},
                                {name: "commit-detail-controller.js", type: "file", level: 2},
                                {name: "commit-preview-controller.js", type: "file", level: 2},
                                {name: "conflict-controller.js", type: "file", level: 2},
                                {name: "editor-conflict-controller.js", type: "file", level: 2},
                                {name: "git-tab-controller.js", type: "file", level: 2},
                                {name: "github-tab-controller.js", type: "file", level: 2},
                                {name: "issue-timeline-controller.js", type: "file", level: 2},
                                {name: "issue-detail-controller.js", type: "file", level: 2},
                                {name: "issue-list-controller.js", type: "file", level: 2},
                                {name: "issue-searches-controller.js", type: "file", level: 2},
                                {name: "multi-file-patch-controller.js", type: "file", level: 2}
                            ]
                            delegate: Rectangle {
                                width: listView.width
                                height: 24
                                color: mouseArea.containsMouse ? "#2c3135" : "transparent"
                                
                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 6
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10 + (modelData.level * 12) // Padding + sangría por nivel
                                    
                                    // Ícono de carpeta/archivo
                                    Text {
                                        text: {
                                            if (modelData.type === "folder") {
                                                return modelData.expanded ? "▼" : "▶"
                                            } else {
                                                // Diferentes íconos para diferentes tipos de archivos
                                                if (modelData.name.endsWith(".js")) return "•"
                                                if (modelData.name.endsWith(".json")) return "{}"
                                                return "•"
                                            }
                                        }
                                        color: modelData.type === "folder" ? "#8e9499" : "#5293d7"
                                        font.pixelSize: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    // Nombre del archivo/carpeta - CON ELIPSIS PARA TEXTO LARGO
                                    Text {
                                        text: modelData.name
                                        color: modelData.type === "folder" ? "#8e9499" : "#c5c8c6"
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                        width: parent.parent.width - (10 + (modelData.level * 12) + 30) // Ancho disponible
                                    }
                                }
                                
                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        // Aquí puedes añadir la lógica para expandir/contraer carpetas
                                        // o abrir archivos
                                        console.log("Clicked:", modelData.name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Área para redimensionar el sidebar
            Rectangle {
                id: resizeHandle
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 5
                color: "transparent"
                
                MouseArea {
                    id: resizeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeHorCursor
                    preventStealing: true
                    property real initialWidth: 0
                    property real initialMouseX: 0
                    
                    onPressed: {
                        initialWidth = sidebarContainer.width
                        initialMouseX = mouseX
                    }
                    
                    onPositionChanged: {
                        if (pressed) {
                            var delta = mouseX - initialMouseX
                            var newWidth = initialWidth + delta
                            
                            // Aplicar límites
                            if (newWidth >= sidebarContainer.Layout.minimumWidth && 
                                newWidth <= sidebarContainer.Layout.maximumWidth) {
                                sidebarContainer.Layout.preferredWidth = newWidth
                            }
                        }
                    }
                }
            }
        }
        
        // Contenido principal
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            
            // Tab bar - Solo visible cuando hay más de un archivo abierto
            Rectangle {
                id: tabBarContainer
                Layout.fillWidth: true
                Layout.preferredHeight: editor.documents.length > 1 ? 35 : 0
                visible: editor.documents.length > 1
                color: "#1d1f21"
                
                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 150 }
                }
                
                ListView {
                    id: tabBar
                    anchors.fill: parent
                    orientation: ListView.Horizontal
                    model: editor.documents
                    
                    delegate: Rectangle {
                        width: 180
                        height: 35
                        color: editor.currentDocument === modelData ? "#282a2e" : "#1d1f21"
                        
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 5
                            spacing: 8
                            
                            // Indicador de cambios sin guardar (punto)
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: modelData.modified ? "#5293d7" : "transparent"
                                anchors.verticalCenter: parent.verticalCenter
                                visible: modelData.modified
                            }
                            
                            // Nombre del archivo
                            Text {
                                text: modelData.fileName
                                color: editor.currentDocument === modelData ? "#ffffff" : "#8e9499"
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            Item {
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter
                                
                                // Botón de cierre (siempre visible)
                                Rectangle {
                                    id: closeButton
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: closeMouseArea.containsMouse ? "#e51400" : "transparent"
                                    anchors.centerIn: parent
                                    
                                    Text {
                                        text: "×"
                                        color: closeMouseArea.containsMouse ? "#ffffff" : 
                                               (editor.currentDocument === modelData ? "#8e9499" : "transparent")
                                        font.pixelSize: 14
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                    
                                    MouseArea {
                                        id: closeMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            editor.closeDocument(modelData)
                                        }
                                    }
                                }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: editor.setActiveDocument(modelData)
                        }
                    }
                }
            }
            
            // Barra de título cuando solo hay un documento
            Rectangle {
                id: singleTabHeader
                Layout.fillWidth: true
                Layout.preferredHeight: editor.documents.length === 1 ? 35 : 0
                visible: editor.documents.length === 1
                color: "#1d1f21"
                
                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 150 }
                }
                
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 8
                    
                    // Indicador de cambios sin guardar (punto)
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: editor.currentDocument && editor.currentDocument.modified ? "#5293d7" : "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        visible: editor.currentDocument && editor.currentDocument.modified
                    }
                    
                    // Nombre del archivo
                    Text {
                        text: editor.currentDocument ? editor.currentDocument.fileName : ""
                        color: "#c5c8c6"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 13
                        font.bold: true
                    }
                    
                    // Botón de cierre
                    Item {
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            id: singleCloseButton
                            width: 16
                            height: 16
                            radius: 8
                            color: singleCloseMouseArea.containsMouse ? "#e51400" : "transparent"
                            anchors.centerIn: parent
                            
                            Text {
                                text: "×"
                                color: singleCloseMouseArea.containsMouse ? "#ffffff" : "#8e9499"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.centerIn: parent
                            }
                            
                            MouseArea {
                                id: singleCloseMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (editor.currentDocument) {
                                        editor.closeDocument(editor.currentDocument)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Editor con números de línea
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                
                // Área de números de línea
                ScrollView {
                    id: lineNumberScroll
                    Layout.preferredWidth: 50
                    Layout.fillHeight: true
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    
                    TextArea {
                        id: lineNumbers
                        width: 50
                        font.family: "Monospace"
                        font.pixelSize: 13
                        color: "#6e7681"
                        background: Rectangle { color: "#1d1f21" }
                        readOnly: true
                        selectByMouse: false
                        wrapMode: TextEdit.NoWrap
                        
                        property int lineCount: 1
                        
                        function updateLineNumbers() {
                            var text = textEditor.text
                            var lines = text.split('\n').length
                            lineCount = Math.max(1, lines)
                            
                            var numbers = ""
                            for (var i = 1; i <= lineCount; i++) {
                                numbers += i + "\n"
                            }
                            lineNumbers.text = numbers
                        }
                        
                        Component.onCompleted: {
                            updateLineNumbers()
                        }
                    }
                }
                
                // Separador entre números de línea y editor
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: "#2d2d30"
                }
                
                // Editor principal
                ScrollView {
                    id: editorScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    // Sincronizar el scroll vertical con los números de línea
                    ScrollBar.vertical.onPositionChanged: {
                        lineNumberScroll.ScrollBar.vertical.position = ScrollBar.vertical.position
                    }
                    
                    TextArea {
                        id: textEditor
                        text: editor.currentDocument ? editor.currentDocument.text : ""
                        font.family: "Monospace"
                        font.pixelSize: 13
                        color: "#c5c8c6"
                        background: Rectangle { color: "#1d1f21" }
                        selectByMouse: true
                        wrapMode: TextEdit.NoWrap
                        
                        // Manejar cambios de texto
                        onTextChanged: {
                            lineNumbers.updateLineNumbers()
                            updateCursorPosition()
                            
                            if (editor.currentDocument && !updatingFromDocument) {
                                // Aquí deberías actualizar el documento en el modelo
                                // Por ahora solo actualizamos los números de línea
                            }
                        }
                        
                        // Actualizar posición del cursor
                        onCursorPositionChanged: {
                            updateCursorPosition()
                        }
                        
                        property bool updatingFromDocument: false
                        
                        Connections {
                            target: editor.currentDocument
                            function onTextChanged() {
                                if (editor.currentDocument) {
                                    textEditor.updatingFromDocument = true
                                    textEditor.text = editor.currentDocument.text
                                    textEditor.updatingFromDocument = false
                                    lineNumbers.updateLineNumbers()
                                }
                            }
                        }
                    }
                }
            }
            
            // Barra de estado
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 22
                color: "#2c3135"
                
                RowLayout {
                    anchors.fill: parent
                    spacing: 20
                    
                    // Lenguaje del archivo
                    Text {
                        Layout.leftMargin: 10
                        text: editor.currentDocument ? editor.currentDocument.language : ""
                        color: "#8e9499"
                        font.pixelSize: 10
                    }
                    
                    // Información de línea y columna
                    Text {
                        id: cursorPosition
                        text: "Ln 1, Col 1"
                        color: "#8e9499"
                        font.pixelSize: 10
                    }
                    
                    // Espaciador
                    Item {
                        Layout.fillWidth: true
                    }
                    
                    // Encoding y tipo de línea
                    Text {
                        text: "UTF-8"
                        color: "#8e9499"
                        font.pixelSize: 10
                    }
                    
                    Text {
                        text: "LF"
                        color: "#8e9499"
                        font.pixelSize: 10
                        Layout.rightMargin: 10
                    }
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