import sys
from pathlib import Path
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType

from ui.controllers.document_controller import DocumentController
from ui.controllers.editor_application import EditorApplication

def main():
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Lynx")
    app.setApplicationName("Lynx")
    
    qmlRegisterType(DocumentController, "Lynx", 1, 0, "DocumentController")
    
    editor = EditorApplication()
    
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("editor", editor)
    
    qml_file = Path(__file__).parent / "ui" / "qml" / "main.qml"
    
    if not qml_file.exists():
        print(f"Error: {qml_file} not found")
        return -1
    
    engine.load(QUrl.fromLocalFile(str(qml_file)))
    
    if not engine.rootObjects():
        return -1
    
    return app.exec()

if __name__ == "__main__":
    sys.exit(main())