import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sidebar
    width: 250
    height: parent.height
    color: "#21252B"
    z: 10
    
    signal openFolderRequested()
    
    // Border
    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: "#181A1F"
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#21252B"
            
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#181A1F"
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8
                
                Text {
                    text: editor.workspaceName || "No Folder"
                    color: "#ABB2BF"
                    font.family: "Consolas"
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                
                Rectangle {
                    width: 24
                    height: 24
                    radius: 2
                    color: refreshMouseArea.containsMouse ? "#2C313A" : "transparent"
                    
                    Text {
                        text: "↻"
                        color: "#ABB2BF"
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
        
        // File tree
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: editor.workspaceFolder !== ""
            clip: true
            
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 10
            }
            
            ListView {
                id: fileListView
                model: editor.fileTree
                clip: true
                
                delegate: Rectangle {
                    width: fileListView.width
                    height: 28
                    color: fileMouseArea.containsMouse ? "#2C313A" : "transparent"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8 + (modelData.level * 16)
                        anchors.rightMargin: 8
                        spacing: 6
                        
                        Text {
                            text: {
                                if (modelData.isFolder) {
                                    return modelData.expanded ? "▼" : "▶"
                                } else {
                                    var icon = modelData.icon
                                    if (icon === "python") return "🐍"
                                    if (icon === "javascript") return "📜"
                                    if (icon === "typescript") return "📘"
                                    if (icon === "rust") return "🦀"
                                    if (icon === "html") return "🌐"
                                    if (icon === "css") return "🎨"
                                    if (icon === "json") return "{}"
                                    if (icon === "markdown") return "📝"
                                    return "📄"
                                }
                            }
                            color: "#ABB2BF"
                            font.pixelSize: modelData.isFolder ? 9 : 12
                        }
                        
                        Text {
                            text: modelData.name
                            color: modelData.isFolder ? "#ABB2BF" : "#ABB2BF"
                            font.family: "Consolas"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                    
                    MouseArea {
                        id: fileMouseArea
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
        
        // Empty state
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: editor.workspaceFolder === ""
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16
                
                Text {
                    text: "📁"
                    font.pixelSize: 48
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "No folder opened"
                    color: "#5C6370"
                    font.family: "Consolas"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Rectangle {
                    width: 140
                    height: 32
                    radius: 3
                    color: openFolderMouseArea.pressed ? "#4D78CC" : 
                           (openFolderMouseArea.containsMouse ? "#4D78CC" : "#528BFF")
                    Layout.alignment: Qt.AlignHCenter
                    
                    Text {
                        text: "Open Folder"
                        color: "#FFFFFF"
                        font.family: "Consolas"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }
                    
                    MouseArea {
                        id: openFolderMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sidebar.openFolderRequested()
                    }
                }
            }
        }
    }
}