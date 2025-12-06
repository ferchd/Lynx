import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

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