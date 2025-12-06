import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: singleTabHeader
    height: tabHeight
    color: "#1d1f21"
    
    // Propiedades
    property real tabHeight: 35
    property var currentDocument: null
    
    Behavior on tabHeight {
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
            color: currentDocument && currentDocument.modified ? "#5293d7" : "transparent"
            anchors.verticalCenter: parent.verticalCenter
            visible: currentDocument && currentDocument.modified
        }
        
        // Nombre del archivo
        Text {
            text: currentDocument ? currentDocument.fileName : ""
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
                        closeDocumentRequested(currentDocument)
                    }
                }
            }
        }
    }
    
    signal closeDocumentRequested(var document)
}