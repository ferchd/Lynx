import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: singleTabHeader
    height: 35
    color: "#21252B"
    
    property var currentDocument: null
    
    signal closeDocumentRequested(var document)
    
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
        
        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: "#528BFF"
            visible: currentDocument && currentDocument.modified
        }
        
        Text {
            text: currentDocument ? currentDocument.fileName : ""
            color: "#ABB2BF"
            font.family: "Consolas"
            font.pixelSize: 12
            font.bold: true
            Layout.fillWidth: true
        }
        
        Item { Layout.fillWidth: true }
        
        Rectangle {
            width: 24
            height: 24
            radius: 2
            color: singleCloseMouseArea.containsMouse ? "#E06C75" : "transparent"
            
            Text {
                text: "×"
                color: singleCloseMouseArea.containsMouse ? "#FFFFFF" : "#5C6370"
                font.pixelSize: 18
                anchors.centerIn: parent
            }
            
            MouseArea {
                id: singleCloseMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: closeDocumentRequested(currentDocument)
            }
        }
    }
}