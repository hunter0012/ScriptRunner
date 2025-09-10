import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import com.SRunner 1.0

ApplicationWindow {
    id: root
    width: expanded ? undocked_width : docked_width
    height: expanded ? undocked_height : docked_height
    // flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"
    visible: true

    onClosing: {
        savePosition()
        // accept the close
        // event.accept()
    }

    property int docked_height: 30
    property int docked_width: 15

    property int undocked_width: 250
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

    // Prevent collapsing when settings popup is open
    property bool settingsOpen: false

    // Corner radius properties
    property int cornerRadius: 4
    property int topLeftRadius: 5
    property int topRightRadius: 5
    property int bottomLeftRadius: 5
    property int bottomRightRadius: 5

    MousePositionProvider {
        id: mouseProvider
        onCursorPositionChanged: function(cursorPosition) {
            root.globalMouseX = cursorPosition.x
            root.globalMouseY = cursorPosition.y

            if (isDragging) {
                updateDragPosition(cursorPosition.x, cursorPosition.y)
            } else if (followMouse && !expanded) {
                followMousePosition(cursorPosition.x, cursorPosition.y)
            } else if (!settingsOpen) { // Only check mouse distance if settings not open
                checkMouseDistance()
            }
        }
    }

    Component.onCompleted: initializePosition()

    function initializePosition() {
        var savedX = settingsManager.getEdgeOffset("x")
        var savedY = settingsManager.getEdgeOffset("y")

        // Set position to saved values
        root.x = Math.max(0, Math.min(savedX, Screen.width - root.width))
        root.y = Math.max(0, Math.min(savedY, Screen.height - root.height))

        // Calculate the closest edge from loaded position
        screenEdge = calculateEdgeFromPosition(root.x, root.y)
        positionToEdge(screenEdge)
    }


    function calculateEdgeFromPosition(x, y) {
        var distToRight = Screen.width - (x + root.width)
        var distToLeft = x
        var distToTop = y
        var distToBottom = Screen.height - (y + root.height)

        var minDist = Math.min(distToRight, distToLeft, distToTop, distToBottom)

        if (minDist === distToRight) return "right"
        if (minDist === distToLeft) return "left"
        if (minDist === distToTop) return "top"
        return "bottom"
    }

    function savePosition() {
        // Save current position
        settingsManager.setEdgeOffset("x", root.x)
        settingsManager.setEdgeOffset("y", root.y)
    }

    function loadPosition() {
        var savedX = settingsManager.getEdgeOffset("x")
        var savedY = settingsManager.getEdgeOffset("y")

        // Check that values are within screen bounds
        root.x = Math.max(0, Math.min(savedX, Screen.width - root.width))
        root.y = Math.max(0, Math.min(savedY, Screen.height - root.height))
    }


    function positionToEdge(edge) {
        screenEdge = edge
        updateCornerRadius(edge)

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

    function updateCornerRadius(edge) {
        switch(edge) {
            case "right":
                topLeftRadius = cornerRadius
                topRightRadius = 0
                bottomLeftRadius = cornerRadius
                bottomRightRadius = 0
                break;
            case "left":
                topLeftRadius = 0
                topRightRadius = cornerRadius
                bottomLeftRadius = 0
                bottomRightRadius = cornerRadius
                break;
            case "top":
                topLeftRadius = 0
                topRightRadius = 0
                bottomLeftRadius = cornerRadius
                bottomRightRadius = cornerRadius
                break;
            case "bottom":
                topLeftRadius = cornerRadius
                topRightRadius = cornerRadius
                bottomLeftRadius = 0
                bottomRightRadius = 0
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
        // Don't collapse if settings are open or if we're dragging
        if (settingsOpen || !expanded || isDragging) return
        // Don't collapse if important
        if(root.important) return

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
        // Don't toggle if settings are open
        if (settingsOpen) return

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

    property bool important: false
    function setImportantState(isImportant){
        root.important = isImportant
        if(isImportant){
            console.log("stop menue from closing.")
        }else{
            console.log("allow menue to close.")
        }
    }

    // Main container with dynamic rounded corners
    Rectangle {
        id: container
        anchors.fill: parent
        color: expanded ? "#2C3E50" : (dragArea.containsMouse)? "#FFFF00": "#3498DB"
        radius: expanded ? 0 : cornerRadius // Only apply radius when not expanded

        // // Top-left corner mask
        Rectangle {
            width: docked_width/2
            height: docked_height/2
            color: parent.color
            visible: screenEdge === "left" || screenEdge === "top"
            radius: topLeftRadius
            anchors {
                top: parent.top
                left: parent.left
            }
        }

        // Top-right corner mask
        Rectangle {
            width: docked_width/2
            height: docked_height/2
            color: parent.color
            visible: screenEdge === "right" || screenEdge === "top"
            radius: topRightRadius
            anchors {
                top: parent.top
                right: parent.right
            }
        }

        // Bottom-left corner mask
        Rectangle {
            width: docked_width/2
            height: docked_height/2
            color: parent.color
            visible: screenEdge === "left" || screenEdge === "bottom"
            radius: bottomLeftRadius
            anchors {
                bottom: parent.bottom
                left: parent.left
            }
        }

        // Bottom-right corner mask
        Rectangle {
            width: docked_width/2
            height: docked_height/2
            color: parent.color
            visible: screenEdge === "right" || screenEdge === "bottom"
            radius: bottomRightRadius
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: !expanded && !settingsOpen // Disable dragging when settings are open

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
                savePosition()
            }

            onDoubleClicked: function() {
                toggleExpanded()
            }

        }

        MouseArea {
            id: clickArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: expanded && !settingsOpen // Disable clicking when settings are open
            onClicked: function(mouse) {
                mouse.accepted = false
            }
        }

        Text {
            text: "⚙️"
            font.pixelSize: 12
            anchors.centerIn: parent
            visible: !expanded && !settingsOpen // Hide gear icon when settings are open
            color: "white"
        }

        // Show a different indicator when settings are open
        Text {
            text: "📂"
            font.pixelSize: 12
            anchors.centerIn: parent
            visible: !expanded && settingsOpen
            color: "white"
        }

        Menue {
            id: menu
            anchors.fill: parent
            // visible: expanded && !settingsOpen // Hide menu when settings are open
            visible: expanded && !settingsOpen && !settings_popup.visible && !close_confirmation.visible
            onSettingsBtn: {
                // console.log("Settings clicked")
                settings_popup.visible = true
                settings_popup.z = 10
            }
            onCloseBtn: {
                // console.log("Close clicked")
                close_confirmation.visible = true
                close_confirmation.z = 10
            }
            onChangeImportantState: function(isImportant){
                // console.log("drop area...........")
                // console.log("isImportant : " + isImportant)
                setImportantState(isImportant);
            }
        }
    }

    // Modified Settings Popup
    Rectangle {
        id: settings_popup
        width: 250
        height: 300
        z: -1
        visible: false
        color: "#ffffff"
        // radius: 10
        border {
            width: 1
            color: "#cccccc"
        }
        // Add this property
         property bool modal: true

         // Add this to block mouse events from passing through
         MouseArea {
             anchors.fill: parent
             hoverEnabled: true
             onPressed: function(mouse) { mouse.accepted = true }
             onPositionChanged: function(mouse) { mouse.accepted = true }
             onReleased: function(mouse) { mouse.accepted = true }
         }
        // Main content of the popup
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Settings Panel"
                font.pixelSize: 20
                Layout.topMargin: 20
            }

            Item {
                Layout.fillHeight: true
            }

            // Close button
            Button {
                Layout.alignment: Qt.AlignRight
                text: "Close"
                onClicked: {
                    settings_popup.visible = false
                    settings_popup.z = -1
                    setImportantState(false);
                }
            }
        }
    }

    // Close confirmation dialog
    Rectangle {
        id: close_confirmation
        width: undocked_width
        height: undocked_height
        z: -1
        visible: false
        color: "#ffffff"
        // radius: 10
        border {
            width: 1
            color: "#cccccc"
        }
        // Add this property
        property bool modal: true

        // Add this to block mouse events from passing through
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPressed: mouse.accepted = true
            onPositionChanged: mouse.accepted = true
            onReleased: mouse.accepted = true
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Close Application?"
                font.pixelSize: 16
                Layout.topMargin: 20
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Button {
                    text: "Yes"
                    onClicked: {
                        Qt.quit()
                    }
                }

                Button {
                    text: "No"
                    onClicked: {
                        close_confirmation.visible = false
                        close_confirmation.z = -1
                    }
                }
            }
        }
    }
    // Mouse blocker to prevent clicks on underlying menu when dialogs are open
    Rectangle {
        id: mouseBlocker
        anchors.fill: parent
        color: "transparent"
        visible: settings_popup.visible || close_confirmation.visible
        z: 5 // Place between menu (z=0) and dialogs (z=10)

        // Consume all mouse events
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPressed: mouse.accepted = true
            onPositionChanged: mouse.accepted = true
            onReleased: mouse.accepted = true
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

            settings_popup.visible = false
            settings_popup.z = -1
            close_confirmation.visible = false
            close_confirmation.z = -1
        }
    }

    onScreenChanged: {
        if (expanded) ensureExpandedOnScreen()
    }
}
