import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: dialog
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel

    property string title: "Select File"
    property bool selectFolder: false
    property var nameFilters: ["All files (*.*)"]
    property string selectedFile: ""

    ColumnLayout {
        width: parent.width
        spacing: 10

        Label {
            text: dialog.title
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        TextField {
            id: filePathField
            Layout.fillWidth: true
            placeholderText: selectFolder ? "Enter folder path" : "Enter file path"
            text: selectedFile
            onTextChanged: selectedFile = text
        }

        Button {
            text: "Browse..."
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                // For now, we'll just use a text input since native file dialogs
                // have compatibility issues. In a real application, you might want
                // to use a platform-specific file dialog via C++.
                filePathField.text = "C:/path/to/your/file.txt"; // Placeholder
            }
        }
    }

    onAccepted: {
        if (selectedFile) {
            // Remove file:// prefix if present
            if (selectedFile.startsWith("file:///")) {
                selectedFile = selectedFile.substring(8);
            } else if (selectedFile.startsWith("file://")) {
                selectedFile = selectedFile.substring(7);
            }
        }
    }
}
