import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    height: 22
    color: "#2c3135"
    
    // Propiedades
    property var currentDocument: null
    property string cursorPositionText: "Ln 1, Col 1"
    
    RowLayout {
        anchors.fill: parent
        spacing: 20
        
        Text {
            Layout.leftMargin: 10
            text: currentDocument ? currentDocument.language : ""
            color: "#8e9499"
            font.pixelSize: 10
        }
        
        Text {
            id: cursorPosition
            text: cursorPositionText
            color: "#8e9499"
            font.pixelSize: 10
        }
        
        Item {
            Layout.fillWidth: true
        }
        
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