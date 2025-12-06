import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: tabBarContainer
    height: tabHeight
    color: "#1d1f21"
    
    // Propiedades que pueden ser establecidas desde fuera
    property real tabHeight: 35
    property var documents: []
    property var currentDocument: null
    
    Behavior on tabHeight {
        NumberAnimation { duration: 150 }
    }
    
    ListView {
        id: tabBar
        anchors.fill: parent
        orientation: ListView.Horizontal
        model: documents
        
        delegate: Rectangle {
            width: 180
            height: 35
            color: currentDocument === modelData ? "#282a2e" : "#1d1f21"
            
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
                    color: currentDocument === modelData ? "#ffffff" : "#8e9499"
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    width: parent.width - 60  // Ajustado para el botón de cierre
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
                                   (currentDocument === modelData ? "#8e9499" : "transparent")
                            font.pixelSize: 14
                            font.bold: true
                            anchors.centerIn: parent
                        }
                        
                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                // Emitir señal para cerrar documento
                                closeDocumentRequested(modelData)
                            }
                        }
                    }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    setActiveDocumentRequested(modelData)
                }
            }
        }
    }
    
    signal closeDocumentRequested(var document)
    signal setActiveDocumentRequested(var document)
}