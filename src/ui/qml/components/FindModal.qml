import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

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