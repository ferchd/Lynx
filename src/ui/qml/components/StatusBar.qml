import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: statusBar
    height: 22
    color: "#21252B"
    
    property var currentDocument: null
    property string cursorText: "Ln 1, Col 1"
    
    function updateCursorPosition(line, col) {
        cursorText = "Ln " + line + ", Col " + col
    }
    
    // Top border
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: "#181A1F"
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 16
        
        Text {
            id: cursorPosition
            text: cursorText
            color: "#ABB2BF"
            font.family: "Consolas"
            font.pixelSize: 11
        }
        
        Text {
            text: currentDocument ? currentDocument.language.toUpperCase() : ""
            color: "#ABB2BF"
            font.family: "Consolas"
            font.pixelSize: 11
        }
        
        Item { Layout.fillWidth: true }
        
        Text {
            text: "UTF-8"
            color: "#5C6370"
            font.family: "Consolas"
            font.pixelSize: 11
        }
        
        Text {
            text: "LF"
            color: "#5C6370"
            font.family: "Consolas"
            font.pixelSize: 11
        }
        
        Text {
            text: "Spaces: 4"
            color: "#5C6370"
            font.family: "Consolas"
            font.pixelSize: 11
        }
    }
}