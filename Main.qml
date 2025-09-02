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

    property int docked_height: 30
    property int docked_width: 15


    property int undocked_width: 220
    property int undocked_height: 300
    property int closeThreshold: 100

    property bool expanded: false
    property bool followMouse: false
    property bool isDragging: false
    property string screenEdge: "right" // right, left, top, bottom

    property real globalMouseX: 0
    property real globalMouseY: 0
    property real savedY: 0
    property real savedX: 0
    property real dragStartX: 0
    property real dragStartY: 0
    property real windowStartX: 0
    property real windowStartY: 0

    // Edge snapping thresholds
    property int edgeSnapThreshold: 50 // pixels from edge to snap
    property bool snappingToEdge: false

    MousePositionProvider {
        id: mouseProvider
        onCursorPositionChanged: function(cursorPosition) {
            root.globalMouseX = cursorPosition.x
            root.globalMouseY = cursorPosition.y

            if (isDragging) {
                updateDragPosition(cursorPosition.x, cursorPosition.y)
            } else if (followMouse && !expanded) {
                followMousePosition(cursorPosition.x, cursorPosition.y)
            } else {
                checkMouseDistance()
            }
        }
    }

    Component.onCompleted: initializePosition()

    function initializePosition() {
        positionToEdge(screenEdge)
    }

    function positionToEdge(edge) {
        screenEdge = edge
        console.log("new edge : " + edge)
        switch(edge) {
            case "right":
                root.x = Screen.width - (expanded ? undocked_width : docked_width)
                root.docked_height = 30
                root.docked_width = 15
                break;
            case "left":
                root.x = 0
                root.docked_height = 30
                root.docked_width = 15
                break;
            case "top":
                root.y = 0
                root.docked_height = 15
                root.docked_width = 30
                break;
            case "bottom":
                root.y = Screen.height - height
                root.docked_height = 15
                root.docked_width = 30
                break;
        }
    }

    function updateDragPosition(cursorX, cursorY) {
        var dx = cursorX - dragStartX
        var dy = cursorY - dragStartY
        var newX = windowStartX + dx
        var newY = windowStartY + dy

        // Check for edge snapping during drag
        var snappedEdge = checkEdgeSnapping(newX, newY)

        if (snappedEdge) {
            // Snap to edge
            switch(snappedEdge) {
                case "right":
                    newX = Screen.width - width
                    break;
                case "left":
                    newX = 0
                    break;
                case "top":
                    newY = 0
                    break;
                case "bottom":
                    newY = Screen.height - height
                    break;
            }
            snappingToEdge = true
        } else {
            snappingToEdge = false
            // Regular boundary checking
            newX = Math.max(0, Math.min(newX, Screen.width - root.width))
            newY = Math.max(0, Math.min(newY, Screen.height - root.height))
        }

        root.x = newX
        root.y = newY
    }

    function checkEdgeSnapping(x, y) {
        // Check right edge
        if (Screen.width - (x + width) < edgeSnapThreshold && Screen.width - (x + width) >= 0) {
            return "right"
        }
        // Check left edge
        if (x < edgeSnapThreshold && x >= 0) {
            return "left"
        }
        // Check top edge
        if (y < edgeSnapThreshold && y >= 0) {
            return "top"
        }
        // Check bottom edge
        if (Screen.height - (y + height) < edgeSnapThreshold && Screen.height - (y + height) >= 0) {
            return "bottom"
        }
        return ""
    }

    function followMousePosition(cursorX, cursorY) {
        if (!expanded && followMouse) {
            if (screenEdge === "top" || screenEdge === "bottom") {
                // Follow mouse X when on top or bottom edges
                var newX = cursorX - root.width / 2
                newX = Math.max(0, Math.min(newX, Screen.width - root.width))
                if (newX !== root.x) {
                    root.x = newX
                }
            } else {
                // Follow mouse Y when on left or right edges
                var newY = cursorY - root.height / 2
                newY = Math.max(0, Math.min(newY, Screen.height - root.height))
                if (newY !== root.y) {
                    root.y = newY
                }
            }
        }
    }

    function ensureExpandedOnScreen() {
        if (!expanded) return

        var newX = root.x
        var newY = root.y

        if (newX + root.width > Screen.width) newX = Screen.width - root.width
        if (newX < 0) newX = 0
        if (newY + root.height > Screen.height) newY = Screen.height - root.height
        if (newY < 0) newY = 0

        if (newX !== root.x) root.x = newX
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
        // positionToEdge(screenEdge)
    }

    function toggleExpanded() {
        expanded = !expanded
        if (expanded) ensureExpandedOnScreen()
    }

    function detectScreenEdge() {
        // If we're already snapping to an edge, use that edge
        if (snappingToEdge) {
            if (root.x <= 0) return "left"
            if (root.x >= Screen.width - width) return "right"
            if (root.y <= 0) return "top"
            if (root.y >= Screen.height - height) return "bottom"
        }

        var centerX = root.x + root.width / 2
        var centerY = root.y + root.height / 2

        var distToRight = Screen.width - centerX
        var distToLeft = centerX
        var distToTop = centerY
        var distToBottom = Screen.height - centerY

        var minDist = Math.min(distToRight, distToLeft, distToTop, distToBottom)

        if (minDist === distToRight) return "right"
        if (minDist === distToLeft) return "left"
        if (minDist === distToTop) return "top"
        return "bottom"
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
                snappingToEdge = false
            }

            onPositionChanged: function(mouse) {
                if (pressed && isDragging) updateDragPosition(root.globalMouseX, root.globalMouseY)
            }

            onReleased: function() {
                isDragging = false
                screenEdge = detectScreenEdge()
                positionToEdge(screenEdge)
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

            // Screen position buttons
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                spacing: 4

                // Left position button
                Rectangle {
                    id: leftButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26
                    radius: 3
                    color: leftMouseArea.pressed ? "#34495E" :
                           leftMouseArea.containsMouse ? "#2C3E50" : "#34495E"
                    border.width: 2
                    border.color: screenEdge === "left" ? "#3498DB" : "#2C3E50"

                    Text {
                        text: "←"
                        color: "#ECF0F1"
                        font.pixelSize: 11
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: leftMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: positionToEdge("left")
                    }
                }

                // Top position button
                Rectangle {
                    id: topButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26
                    radius: 3
                    color: topMouseArea.pressed ? "#34495E" :
                           topMouseArea.containsMouse ? "#2C3E50" : "#34495E"
                    border.width: 2
                    border.color: screenEdge === "top" ? "#3498DB" : "#2C3E50"

                    Text {
                        text: "↑"
                        color: "#ECF0F1"
                        font.pixelSize: 11
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: topMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: positionToEdge("top")
                    }
                }

                // Bottom position button
                Rectangle {
                    id: bottomButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26
                    radius: 3
                    color: bottomMouseArea.pressed ? "#34495E" :
                           bottomMouseArea.containsMouse ? "#2C3E50" : "#34495E"
                    border.width: 2
                    border.color: screenEdge === "bottom" ? "#3498DB" : "#2C3E50"

                    Text {
                        text: "↓"
                        color: "#ECF0F1"
                        font.pixelSize: 11
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: bottomMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: positionToEdge("bottom")
                    }
                }

                // Right position button
                Rectangle {
                    id: rightButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26
                    radius: 3
                    color: rightMouseArea.pressed ? "#34495E" :
                           rightMouseArea.containsMouse ? "#2C3E50" : "#34495E"
                    border.width: 2
                    border.color: screenEdge === "right" ? "#3498DB" : "#2C3E50"

                    Text {
                        text: "→"
                        color: "#ECF0F1"
                        font.pixelSize: 11
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: rightMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: positionToEdge("right")
                    }
                }
            }

            // Follow mode button with dynamic text
            Rectangle {
                id: followButton
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                radius: 3
                color: followMouseArea.pressed ? (followMouse ? "#27AE60" : "#7F8C8D") :
                       followMouseArea.containsMouse ? (followMouse ? "#229954" : "#95A5A6") :
                       (followMouse ? "#27AE60" : "#7F8C8D")
                border.width: 1
                border.color: followMouse ? "#229954" : "#95A5A6"

                Text {
                    text: {
                        if (!followMouse) return "Enable Follow"
                        if (screenEdge === "top" || screenEdge === "bottom") return "Following Mouse X"
                        return "Following Mouse Y"
                    }
                    color: "#ECF0F1"
                    font.pixelSize: 11
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: followMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: followMouse = !followMouse
                }
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

            // Spacer to push bottom buttons down
            Item {
                Layout.fillHeight: true
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
            savedX = root.x
            ensureExpandedOnScreen()
        } else {
            root.y = savedY
            root.x = savedX
        }
    }

    onScreenChanged: {
        if (expanded) ensureExpandedOnScreen()
    }
}
