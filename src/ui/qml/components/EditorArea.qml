import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: editorArea
    spacing: 0
    
    property var currentDocument: null
    property int lineNumber: 1
    property int columnNumber: 1
    property int cursorPosition: textEditor.cursorPosition
    property bool hasSelection: textEditor.selectedText.length > 0

    
    function selectText(start, end) {
        textEditor.select(start, end)
        textEditor.cursorPosition = end
    }
    
    function setCursorPosition(position) {
        textEditor.cursorPosition = position
    }
    
    // Line Numbers
    ScrollView {
        id: lineNumberScroll
        Layout.preferredWidth: 50
        Layout.fillHeight: true
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        
        TextArea {
            id: lineNumbers
            width: 50
            font.family: "Consolas"
            font.pixelSize: 13
            color: "#5C6370"
            background: Rectangle {
                color: "#282C34"
            }
            readOnly: true
            selectByMouse: false
            wrapMode: TextEdit.NoWrap
            verticalAlignment: TextEdit.AlignTop
            rightPadding: 8
            
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
    
    // Separator
    Rectangle {
        Layout.preferredWidth: 1
        Layout.fillHeight: true
        color: "#181A1F"
    }
    
    // Main Editor
    ScrollView {
        id: editorScroll
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        
        ScrollBar.vertical.onPositionChanged: {
            lineNumberScroll.ScrollBar.vertical.position = ScrollBar.vertical.position
        }
        
        TextArea {
            id: textEditor
            text: currentDocument ? currentDocument.text : ""
            font.family: "Consolas"
            font.pixelSize: 13
            color: "#ABB2BF"
            
            background: Rectangle {
                color: "#282C34"
            }
            
            selectByMouse: true
            selectByKeyboard: true
            wrapMode: TextEdit.NoWrap
            
            // Atom One Dark selection colors
            selectionColor: "#3E4451"
            selectedTextColor: "#ABB2BF"
            
            // Blinking cursor
            cursorDelegate: Rectangle {
                width: 2
                color: "#528BFF"
                visible: textEditor.cursorVisible
                
                SequentialAnimation on visible {
                    loops: Animation.Infinite
                    running: textEditor.focus
                    
                    PropertyAnimation {
                        to: true
                        duration: 500
                    }
                    PropertyAnimation {
                        to: false
                        duration: 500
                    }
                }
            }
            
            property bool internalChange: false
            
            onTextChanged: {
                if (!internalChange && currentDocument) {
                    currentDocument.setText(text)
                }
                
                lineNumbers.updateLineNumbers()
                updateCursorInfo()
            }
            
            onCursorPositionChanged: {
                updateCursorInfo()
            }
            
            function updateCursorInfo() {
                var text = textEditor.text
                var cursorPos = textEditor.cursorPosition
                var textBeforeCursor = text.substring(0, cursorPos)
                var lines = textBeforeCursor.split('\n')
                
                editorArea.lineNumber = lines.length
                editorArea.columnNumber = lines[lines.length - 1].length + 1
                editorArea.cursorPositionChanged()
            }
        }
    }
}