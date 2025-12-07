import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: tabBarContainer
    height: 35
    color: "#21252B"
    
    property var documents: []
    property var currentDocument: null
    
    signal closeDocumentRequested(var document)
    signal setActiveDocumentRequested(var document)
    
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#181A1F"
    }
    
    ListView {
        id: tabBar
        anchors.fill: parent
        orientation: ListView.Horizontal
        model: documents
        clip: true
        spacing: 0
        
        delegate: Rectangle {
            width: 180
            height: 35
            color: currentDocument === modelData ? "#282C34" : "#21252B"
            
            Rectangle {
                visible: currentDocument === modelData
                anchors.bottom: parent.bottom
                width: parent.width
                height: 2
                color: "#528BFF"
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                spacing: 8
                
                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: "#528BFF"
                    visible: modelData.modified
                }
                
                Text {
                    text: modelData.fileName
                    color: currentDocument === modelData ? "#ABB2BF" : "#5C6370"
                    font.family: "Consolas"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    elide: Text.ElideMiddle
                }
                
                Rectangle {
                    width: 20
                    height: 20
                    radius: 2
                    color: closeMouseArea.containsMouse ? "#E06C75" : "transparent"
                    
                    Text {
                        text: "×"
                        color: closeMouseArea.containsMouse ? "#FFFFFF" : "#5C6370"
                        font.pixelSize: 16
                        anchors.centerIn: parent
                    }
                    
                    MouseArea {
                        id: closeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: closeDocumentRequested(modelData)
                    }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                z: -1
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: setActiveDocumentRequested(modelData)
            }
        }
    }
}