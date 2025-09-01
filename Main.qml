import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import com.example 1.0

ApplicationWindow {
    id: root
    width: expanded ? undocked_width : docked_width
    height: expanded ? undocked_height : docked_height
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: true

    property int docked_width: 15
    property int undocked_width: 220
    property int docked_height: 30
    property int undocked_height: 300
    property int closeThreshold: 100

    property bool expanded: false
    property bool followMouseY: false
    property bool isDragging: false

    property real globalMouseX: 0
    property real globalMouseY: 0
    property real savedY: 0
    property real dragStartX: 0
    property real dragStartY: 0
    property real windowStartX: 0
    property real windowStartY: 0

    MousePositionProvider {
        id: mouseProvider
        onCursorPositionChanged: function(cursorPosition) {
            root.globalMouseX = cursorPosition.x
            root.globalMouseY = cursorPosition.y

            if (isDragging) {
                updateDragPosition(cursorPosition.y)
            } else if (followMouseY && !expanded) {
                followMouse(cursorPosition.y)
            } else {
                checkMouseDistance()
            }
        }
    }

    Component.onCompleted: initializePosition()

    function initializePosition() {
        root.x = Screen.width - docked_width
        root.y = (Screen.height - height) / 2
        savedY = root.y
    }

    function updateDragPosition(cursorY) {
        var dy = cursorY - dragStartY
        var newY = windowStartY + dy
        root.y = Math.max(0, Math.min(newY, Screen.height - root.height))
    }

    function followMouse(cursorY) {
        var newY = cursorY - root.height / 2
        root.y = Math.max(0, Math.min(newY, Screen.height - root.height))
    }

    function ensureExpandedOnScreen() {
        if (!expanded) return

        var newY = root.y
        if (newY + root.height > Screen.height) newY = Screen.height - root.height
        if (newY < 0) newY = 0

        if (newY !== root.y) root.y = newY
    }

    function checkMouseDistance() {
        if (!expanded || isDragging) return

        var mouseInside = globalMouseX >= root.x && globalMouseX <= root.x + root.width &&
                           globalMouseY >= root.y && globalMouseY <= root.y + root.height
        if (mouseInside) return

        var dx = 0, dy = 0
        if (globalMouseX < root.x) dx = root.x - globalMouseX
        else if (globalMouseX > root.x + root.width) dx = globalMouseX - (root.x + root.width)

        if (globalMouseY < root.y) dy = root.y - globalMouseY
        else if (globalMouseY > root.y + root.height) dy = globalMouseY - (root.y + root.height)

        var distance = Math.sqrt(dx * dx + dy * dy)
        if (distance > closeThreshold) collapse()
    }

    function collapse() {
        expanded = false
        root.x = Screen.width - docked_width
    }

    function toggleExpanded() {
        expanded = !expanded
        if (expanded) ensureExpandedOnScreen()
    }

    // Main container with simple rounded corners
    Rectangle {
        id: container
        anchors.fill: parent
        color: expanded ? "#2C3E50" : "#3498DB"
        radius: expanded ? 10 : 0 // Only round corners when expanded

        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: !expanded

            onPressed: function(mouse) {
                isDragging = true
                dragStartX = root.globalMouseX
                dragStartY = root.globalMouseY
                windowStartX = root.x
                windowStartY = root.y
            }

            onPositionChanged: function(mouse) {
                if (pressed && isDragging) updateDragPosition(root.globalMouseY)
            }

            onReleased: function() {
                isDragging = false
            }

            onDoubleClicked: function() {
                toggleExpanded()
            }
        }

        MouseArea {
            id: clickArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: expanded
            onClicked: function(mouse) {
                mouse.accepted = false
            }
        }

        Text {
            text: "⚙️"
            font.pixelSize: 12
            anchors.centerIn: parent
            visible: !expanded
            color: "white"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6
            visible: expanded

            Label {
                text: "QUICK ACTIONS"
                font.bold: true
                font.pixelSize: 11
                color: "#ECF0F1"
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 8
            }

            // Action buttons with sharper design
            Rectangle {
                id: calcButton
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                radius: 3
                color: calcMouseArea.pressed ? "#34495E" :
                       calcMouseArea.containsMouse ? "#2C3E50" : "#34495E"
                border.width: 1
                border.color: "#2C3E50"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 8

                    Text {
                        text: "🧮"
                        font.pixelSize: 12
                        color: "#ECF0F1"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: "Calculator"
                        color: "#ECF0F1"
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: calcMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Qt.openUrlExternally("calc.exe")
                }
            }

            Rectangle {
                id: screenshotButton
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                radius: 3
                color: screenshotMouseArea.pressed ? "#34495E" :
                       screenshotMouseArea.containsMouse ? "#2C3E50" : "#34495E"
                border.width: 1
                border.color: "#2C3E50"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 8

                    Text {
                        text: "📸"
                        font.pixelSize: 12
                        color: "#ECF0F1"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: "Screenshot"
                        color: "#ECF0F1"
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: screenshotMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: console.log("Screenshot functionality would go here")
                }
            }

            Rectangle {
                id: notepadButton
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                radius: 3
                color: notepadMouseArea.pressed ? "#34495E" :
                       notepadMouseArea.containsMouse ? "#2C3E50" : "#34495E"
                border.width: 1
                border.color: "#2C3E50"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 8

                    Text {
                        text: "📝"
                        font.pixelSize: 12
                        color: "#ECF0F1"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: "Notepad"
                        color: "#ECF0F1"
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: notepadMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Qt.openUrlExternally("notepad.exe")
                }
            }

            Rectangle {
                id: browserButton
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                radius: 3
                color: browserMouseArea.pressed ? "#34495E" :
                       browserMouseArea.containsMouse ? "#2C3E50" : "#34495E"
                border.width: 1
                border.color: "#2C3E50"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 8

                    Text {
                        text: "🌐"
                        font.pixelSize: 12
                        color: "#ECF0F1"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: "Browser"
                        color: "#ECF0F1"
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: browserMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Qt.openUrlExternally("https://www.google.com")
                }
            }

            Rectangle {
                id: explorerButton
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                radius: 3
                color: explorerMouseArea.pressed ? "#34495E" :
                       explorerMouseArea.containsMouse ? "#2C3E50" : "#34495E"
                border.width: 1
                border.color: "#2C3E50"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 8

                    Text {
                        text: "📁"
                        font.pixelSize: 12
                        color: "#ECF0F1"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: "File Explorer"
                        color: "#ECF0F1"
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: explorerMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Qt.openUrlExternally("explorer.exe")
                }
            }

            // Spacer to push bottom buttons down
            Item {
                Layout.fillHeight: true
            }

            // Bottom action buttons
            Rectangle {
                id: followButton
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                radius: 3
                color: followMouseArea.pressed ? (followMouseY ? "#27AE60" : "#7F8C8D") :
                       followMouseArea.containsMouse ? (followMouseY ? "#229954" : "#95A5A6") :
                       (followMouseY ? "#27AE60" : "#7F8C8D")
                border.width: 1
                border.color: followMouseY ? "#229954" : "#95A5A6"

                Text {
                    text: followMouseY ? "Disable Follow" : "Enable Follow"
                    color: "#ECF0F1"
                    font.pixelSize: 11
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: followMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: followMouseY = !followMouseY
                }
            }

            Rectangle {
                id: closeButton
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                radius: 3
                color: closeMouseArea.pressed ? "#C0392B" :
                       closeMouseArea.containsMouse ? "#A93226" : "#E74C3C"
                border.width: 1
                border.color: "#C0392B"

                Text {
                    text: "Close"
                    color: "#ECF0F1"
                    font.pixelSize: 11
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: collapse()
                }
            }
        }
    }

    onExpandedChanged: {
        if (expanded) {
            savedY = root.y
            root.width = undocked_width
            root.x = Screen.width - undocked_width
            ensureExpandedOnScreen()
        } else {
            root.y = savedY
            root.width = docked_width
            root.x = Screen.width - docked_width
        }
    }

    onScreenChanged: {
        if (expanded) ensureExpandedOnScreen()
    }
}
