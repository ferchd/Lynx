import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Rectangle {
    id: sidebar
    color: "#1d1f21"
    border.color: "#181a1c"
    border.width: 1
    
    // Propiedades para controlar el estado del sidebar
    property bool collapsed: true  // Por defecto colapsado
    property int collapsedWidth: 50  // Ancho cuando está colapsado
    property int expandedWidth: 250  // Ancho cuando está expandido
    
    // Señal para notificar cambio de ancho (nombre diferente para evitar conflicto)
    signal sidebarWidthChanged(real newWidth)
    signal toggleRequested()
    signal openFolderRequested()
    
    // Ancho actual basado en el estado
    width: collapsed ? collapsedWidth : expandedWidth
    
    // Efecto de sombra para el sidebar
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 2
        verticalOffset: 0
        radius: 8
        samples: 17
        color: "#40000000"
    }
    
    // Transición suave para el cambio de ancho
    Behavior on width {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
    
    // Contenido principal
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Botón de toggle con efecto de hover
        Rectangle {
            id: toggleButton
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: toggleMouseArea.containsMouse ? "#2c3135" : "transparent"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                spacing: 12
                
                // Ícono de toggle con animación
                Rectangle {
                    id: toggleIcon
                    width: 24
                    height: 24
                    radius: 4
                    color: toggleMouseArea.containsMouse ? "#3c3c3c" : "transparent"
                    
                    Text {
                        text: sidebar.collapsed ? "▸" : "◂"
                        color: "#8e9499"
                        font.pixelSize: 16
                        font.bold: true
                        anchors.centerIn: parent
                    }
                }
                
                // Texto "Explorer" con efecto fade
                Text {
                    text: "EXPLORER"
                    color: "#8e9499"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    opacity: sidebar.collapsed ? 0 : 1
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
            
            MouseArea {
                id: toggleMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    sidebar.toggleRequested()
                }
            }
        }
        
        // Separador decorativo
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#181a1c"
        }
        
        // Contenido del sidebar con efecto fade
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            opacity: sidebar.collapsed ? 0 : 1
            visible: opacity > 0
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Encabezado del proyecto
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "transparent"
                    visible: editor.workspaceFolder !== ""
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 12
                        spacing: 8
                        
                        // Ícono del proyecto
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 4
                            color: "#0e639c"
                            
                            Text {
                                text: "📁"
                                color: "white"
                                font.pixelSize: 12
                                anchors.centerIn: parent
                            }
                        }
                        
                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            
                            Text {
                                text: editor.workspaceName
                                color: "#ffffff"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "Project"
                                color: "#8e9499"
                                font.pixelSize: 10
                            }
                        }
                        
                        // Botón de refresh
                        Rectangle {
                            id: refreshButton
                            width: 28
                            height: 28
                            radius: 4
                            color: refreshMouseArea.containsMouse ? "#3c3c3c" : "transparent"
                            
                            Text {
                                text: "↻"
                                color: "#8e9499"
                                font.pixelSize: 14
                                anchors.centerIn: parent
                            }
                            
                            MouseArea {
                                id: refreshMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: editor.refreshFileTree()
                            }
                        }
                    }
                }
                
                // Barra de búsqueda
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "transparent"
                    visible: editor.workspaceFolder !== ""
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 8
                        radius: 4
                        color: "#2c3135"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            
                            Text {
                                text: "🔍"
                                color: "#8e9499"
                                font.pixelSize: 12
                            }
                            
                            Text {
                                text: "Search files..."
                                color: "#6e7681"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: findModal.open()
                        }
                    }
                }
                
                // Lista de archivos
                ScrollView {
                    id: scrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: editor.workspaceFolder !== ""
                    
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    
                    ListView {
                        id: fileListView
                        width: scrollView.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        
                        model: editor.fileTree
                        
                        delegate: Rectangle {
                            width: fileListView.width
                            height: 32
                            color: mouseArea.containsMouse ? "#2c3135" : "transparent"
                            
                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8
                                anchors.left: parent.left
                                anchors.leftMargin: 12 + (modelData.level * 16)
                                
                                // Ícono
                                Rectangle {
                                    width: 20
                                    height: 20
                                    radius: 3
                                    color: "transparent"
                                    
                                    Text {
                                        text: {
                                            if (modelData.isFolder) {
                                                return modelData.expanded ? "▼" : "▶"
                                            } else {
                                                var icon = modelData.icon
                                                if (icon === "python") return "🐍"
                                                if (icon === "javascript") return "JS"
                                                if (icon === "typescript") return "TS"
                                                if (icon === "react") return "⚛"
                                                if (icon === "html") return "🌐"
                                                if (icon === "css") return "🎨"
                                                if (icon === "json") return "{}"
                                                if (icon === "markdown") return "📝"
                                                if (icon === "rust") return "🦀"
                                                return "📄"
                                            }
                                        }
                                        color: modelData.isFolder ? "#8e9499" : "#5293d7"
                                        font.pixelSize: modelData.isFolder ? 10 : 12
                                        anchors.centerIn: parent
                                    }
                                }
                                
                                // Nombre del archivo/carpeta
                                Text {
                                    text: modelData.name
                                    color: modelData.isFolder ? "#8e9499" : "#c5c8c6"
                                    font.pixelSize: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    elide: Text.ElideRight
                                    width: fileListView.width - (12 + (modelData.level * 16) + 40)
                                }
                            }
                            
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.isFolder) {
                                        editor.toggleFileTreeNode(modelData.path)
                                    } else {
                                        editor.openDocument(modelData.path)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Mensaje cuando no hay carpeta abierta
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    visible: editor.workspaceFolder === ""
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 12
                        
                        Rectangle {
                            width: 48
                            height: 48
                            radius: 8
                            color: "#2c3135"
                            Layout.alignment: Qt.AlignHCenter
                            
                            Text {
                                text: "📁"
                                color: "#8e9499"
                                font.pixelSize: 24
                                anchors.centerIn: parent
                            }
                        }
                        
                        Text {
                            text: "No folder opened"
                            color: "#8e9499"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        // Botón con efecto
                        Rectangle {
                            id: openFolderButton
                            width: 140
                            height: 32
                            radius: 4
                            color: openFolderMouseArea.containsMouse ? "#0e639c" : "#007acc"
                            Layout.alignment: Qt.AlignHCenter
                            
                            Row {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Text {
                                    text: "📂"
                                    color: "white"
                                    font.pixelSize: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                Text {
                                    text: "Open Folder"
                                    color: "white"
                                    font.pixelSize: 12
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            MouseArea {
                                id: openFolderMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: sidebar.openFolderRequested()
                            }
                            
                            // Efecto de sombra usando layer
                            layer.enabled: openFolderMouseArea.containsMouse
                            layer.effect: DropShadow {
                                transparentBorder: true
                                horizontalOffset: 0
                                verticalOffset: 2
                                radius: 8
                                samples: 17
                                color: "#40000000"
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Área de redimensionamiento (solo visible cuando está expandido)
    Rectangle {
        id: resizeHandle
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 6
        color: "transparent"
        visible: !sidebar.collapsed
        opacity: resizeMouseArea.containsMouse ? 1 : 0.5
        
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
        
        // Línea vertical para el handle
        Rectangle {
            width: 2
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            color: resizeMouseArea.containsMouse || resizeMouseArea.pressed ? 
                   "#007acc" : "#3c3c3c"
        }
        
        MouseArea {
            id: resizeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeHorCursor
            preventStealing: true
            property real initialWidth: 0
            property real initialMouseX: 0
            
            onPressed: {
                initialWidth = sidebar.expandedWidth
                initialMouseX = mouseX
            }
            
            onPositionChanged: {
                if (pressed) {
                    var delta = mouseX - initialMouseX
                    var newWidth = Math.max(180, Math.min(400, initialWidth + delta))
                    
                    if (newWidth !== sidebar.expandedWidth) {
                        sidebar.expandedWidth = newWidth
                        sidebar.sidebarWidthChanged(newWidth)
                    }
                }
            }
        }
    }
}