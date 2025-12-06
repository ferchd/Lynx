import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 0
    
    // Propiedades
    property var currentDocument: null
    
    ScrollView {
        id: lineNumberScroll
        Layout.preferredWidth: 50
        Layout.fillHeight: true
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        
        TextArea {
            id: lineNumbers
            width: 50
            font.family: "Monospace"
            font.pixelSize: 13
            color: "#6e7681"
            background: Rectangle { color: "#1d1f21" }
            readOnly: true
            selectByMouse: false
            wrapMode: TextEdit.NoWrap
            
            property int lineCount: 1
            
            function updateLineNumbers() {
                var text = textEditor.text
                var lines = text.split('\n').length
                lineCount = Math.max(1, lines)
                
                var numbers = ""
                for (var i = 1; i <= lineCount; i++) {
                    numbers += i + "\n"
                }
                lineNumbers.text = numbers
            }
            
            Component.onCompleted: {
                updateLineNumbers()
            }
        }
    }
    
    Rectangle {
        Layout.preferredWidth: 1
        Layout.fillHeight: true
        color: "#2d2d30"
    }
    
    ScrollView {
        id: editorScroll
        Layout.fillWidth: true
        Layout.fillHeight: true
        
        ScrollBar.vertical.onPositionChanged: {
            lineNumberScroll.ScrollBar.vertical.position = ScrollBar.vertical.position
        }
        
        TextArea {
            id: textEditor
            text: currentDocument ? currentDocument.text : ""
            font.family: "Monospace"
            font.pixelSize: 13
            color: "#c5c8c6"
            background: Rectangle { color: "#1d1f21" }
            selectByMouse: true
            wrapMode: TextEdit.NoWrap
            
            property bool internalChange: false
            
            onTextChanged: {
                if (!internalChange && currentDocument) {
                    currentDocument.setText(text)
                }
                
                lineNumbers.updateLineNumbers()
                cursorPositionChanged()
            }
            
            onCursorPositionChanged: {
                cursorPositionChanged()
            }
        }
    }
    
    // Señal para notificar cambios en la posición del cursor
    signal cursorPositionChanged()
    
    // Función para actualizar el texto del editor
    function updateText(newText) {
        textEditor.internalChange = true
        textEditor.text = newText
        textEditor.internalChange = false
        lineNumbers.updateLineNumbers()
    }
}