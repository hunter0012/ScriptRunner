import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import com.SRunner 1.0

Rectangle {
    id: root
    width: 260
    height: 320
    color: "#2C3E50"
    radius: 0

    signal settingsBtn()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 2
        spacing: 8

        // Header with title and buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: "QUICK ACTIONS"
                font.bold: true
                font.pixelSize: 12
                color: "#ECF0F1"
                Layout.fillWidth: true
            }

            // Settings button
            Rectangle {
                id: settingsButton
                width: 26
                height: 26
                // radius: 13
                color: settingsMouseArea.pressed ? "#34495E" :
                       settingsMouseArea.containsMouse ? "#2C3E50" : "transparent"

                Text {
                    text: "⚙️"
                    font.pixelSize: 12
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: settingsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        settingsBtn()
                    }
                }
            }

            // Close button
            Rectangle {
                id: closeButton
                width: 26
                height: 26
                // radius: 13
                color: closeMouseArea.pressed ? "#C0392B" :
                       closeMouseArea.containsMouse ? "#A93226" : "transparent"

                Text {
                    text: "×"
                    color: "#ECF0F1"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:
                    {
                        // collapse()
                        console.log("Close clicked")
                        close_confirmation.visible = true
                        close_confirmation.z = 10
                    }
                }
            }
        }

        // Tab bar for categories
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: 0

                TabButton {
                    id: toolsTab
                    text: "Tools"
                    isCurrent: tabBar.currentIndex === 0
                    Layout.fillWidth: true
                    onClicked: tabBar.currentIndex = 0
                    radius: 0
                }

                TabButton {
                    id: mediaTab
                    text: "Media"
                    isCurrent: tabBar.currentIndex === 1
                    Layout.fillWidth: true
                    onClicked: tabBar.currentIndex = 1
                    radius: 0
                }

                TabButton {
                    id: systemTab
                    text: "System"
                    isCurrent: tabBar.currentIndex === 2
                    Layout.fillWidth: true
                    onClicked: tabBar.currentIndex = 2
                    radius: 0
                }
            }
        }

        // Tab content
        StackLayout {
            id: tabBar
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            // Tools tab
            GridLayout {
                columns: 4
                columnSpacing: 8
                rowSpacing: 8

                IconButton { icon: "🧮"; tooltip: "Calculator"; onClicked: Qt.openUrlExternally("calc.exe") }
                IconButton { icon: "📝"; tooltip: "Notepad"; onClicked: Qt.openUrlExternally("notepad.exe") }
                IconButton { icon: "📸"; tooltip: "Screenshot"; onClicked: console.log("Screenshot") }
                IconButton { icon: "⏰"; tooltip: "Timer"; onClicked: console.log("Timer") }
                IconButton { icon: "📅"; tooltip: "Calendar"; onClicked: console.log("Calendar") }
                IconButton { icon: "🎨"; tooltip: "Paint"; onClicked: console.log("Paint") }
                IconButton { icon: "📊"; tooltip: "Spreadsheet"; onClicked: console.log("Spreadsheet") }
                IconButton { icon: "📎"; tooltip: "Clipboard"; onClicked: console.log("Clipboard") }
            }

            // Media tab
            GridLayout {
                columns: 4
                columnSpacing: 8
                rowSpacing: 8

                IconButton {
                    icon: "🎵";
                    tooltip: "exe in cmd";
                    onClicked: {
                        collapse()
                        srunner.runExeInCmd("C:\\UserApps\\main.exe")
                    }
                }
                IconButton {
                    icon: "🎵";
                    tooltip: "exe silent or with gui";
                    onClicked: {
                        collapse()
                        srunner.runExe("C:\\UserApps\\keylicense.exe")
                    }
                }
                IconButton {
                    icon: "🎵";
                    tooltip: "exe silent";
                    onClicked: {
                        collapse()
                        srunner.runExe("C:\\UserApps\\crackme.exe")
                    }
                }
                IconButton {
                    icon: "🎵";
                    tooltip: "exe silent";
                    onClicked: {
                        collapse()
                        srunner.runExeAsAdmin("C:\\UserApps\\crackme.exe")
                    }
                }
                IconButton { icon: "🎬"; tooltip: "Video Player"; onClicked: console.log("Video Player") }
                IconButton { icon: "🖼️"; tooltip: "Photo Viewer"; onClicked: console.log("Photo Viewer") }
                IconButton { icon: "🎮"; tooltip: "Games"; onClicked: console.log("Games") }
                IconButton { icon: "🎙️"; tooltip: "Voice Recorder"; onClicked: console.log("Voice Recorder") }
                IconButton { icon: "📷"; tooltip: "Camera"; onClicked: console.log("Camera") }
                IconButton { icon: "📺"; tooltip: "Streaming"; onClicked: console.log("Streaming") }
                IconButton { icon: "🎧"; tooltip: "Audio Settings"; onClicked: console.log("Audio Settings") }
            }

            // System tab
            GridLayout {
                columns: 4
                columnSpacing: 8
                rowSpacing: 8

                IconButton { icon: "📁"; tooltip: "File Explorer"; onClicked: console.log("File Explorer") }
                IconButton { icon: "🌐"; tooltip: "Web Browser"; onClicked: console.log("Web Browser") }
                IconButton { icon: "🔒"; tooltip: "Security"; onClicked: console.log("Security") }
                IconButton { icon: "⚡"; tooltip: "Power Options"; onClicked: console.log("Power Options") }
                IconButton { icon: "🔧"; tooltip: "Settings"; onClicked: console.log("Settings") }
                IconButton { icon: "📡"; tooltip: "Network"; onClicked: console.log("Network") }
                IconButton { icon: "🖥️"; tooltip: "Display"; onClicked: console.log("Display") }
                IconButton { icon: "⌨️"; tooltip: "Keyboard"; onClicked: console.log("Keyboard") }
            }
        }
    }

    // Custom tab button component
    component TabButton: Rectangle {
        id: tabButton
        property string text: ""
        property bool isCurrent: false
        signal clicked()

        height: 30
        radius: 4
        color: tabMouseArea.pressed ? "#3498DB" :
               isCurrent ? "#2980B9" :
               tabMouseArea.containsMouse ? "#34495E" : "transparent"

        Label {
            text: tabButton.text
            color: "#ECF0F1"
            font.pixelSize: 11
            font.bold: isCurrent
            anchors.centerIn: parent
        }

        MouseArea {
            id: tabMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: tabButton.clicked()
        }
    }

    // Custom icon button component
    component IconButton: Rectangle {
        id: iconButton
        property string icon: ""
        property string tooltip: ""
        signal clicked()

        Layout.preferredWidth: 30
        Layout.preferredHeight: 30
        radius: 2
        color: iconMouseArea.pressed ? "#3498DB" :
               iconMouseArea.containsMouse ? "#2980B9" : "#34495E"

        Text {
            text: iconButton.icon
            font.pixelSize: 15
            anchors.centerIn: parent
        }

        MouseArea {
            id: iconMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: iconButton.clicked()
        }

        // Tooltip
        ToolTip {
            visible: iconMouseArea.containsMouse
            delay: 500
            text: iconButton.tooltip
        }
    }
}
