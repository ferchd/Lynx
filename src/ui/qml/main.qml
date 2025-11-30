import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Lynx 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "Lynx Editor - Prueba Inicial"
    
    readonly property color bgPrimary: "#282C34"
    readonly property color bgSecondary: "#21252B"
    readonly property color fgPrimary: "#ABB2BF"
    readonly property color accent: "#528BFF"
    
    // Layout principal
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Barra superior
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: bgSecondary
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                
                Text {
                    text: "🦁 LYNX EDITOR"
                    color: fgPrimary
                    font.pixelSize: 18
                    font.bold: true
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Nuevo Archivo"
                    onClicked: editor.new_document()
                }
                
                ComboBox {
                    width: 200
                    model: ["Software Dev", "Cybersecurity", "Network Eng"]
                    onCurrentIndexChanged: {
                        const profiles = ["software_dev", "cybersecurity", "network_engineer"]
                        profileManager.set_profile(profiles[currentIndex])
                    }
                }
            }
        }
        
        // Área principal
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: bgPrimary
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: 20
                
                TextEdit {
                    id: editorText
                    width: parent.width
                    color: fgPrimary
                    font.pixelSize: 14
                    font.family: "Monospace"
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true
                    
                    text: "¡Bienvenido a Lynx Editor! 🦁\n\n" +
                          "Esta es una prueba inicial del editor.\n" +
                          "Puedes comenzar a escribir aquí...\n\n" +
                          "Características incluidas:\n" +
                          "• Piece Table para edición eficiente\n" +
                          "• Sistema de perfiles profesional\n" +
                          "• Soporte LSP integrado\n" +
                          "• Terminal PTY completo\n" +
                          "• Debugger con DAP\n" +
                          "• Plugin system\n" +
                          "• Performance optimization"
                }
            }
        }
        
        // Barra de estado
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: bgSecondary
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                
                Text {
                    text: "🔵 Listo"
                    color: fgPrimary
                    font.pixelSize: 12
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: "UTF-8"
                    color: fgPrimary
                    font.pixelSize: 12
                }
                
                Text {
                    text: "Ln 1, Col 1"
                    color: fgPrimary
                    font.pixelSize: 12
                }
            }
        }
    }
}