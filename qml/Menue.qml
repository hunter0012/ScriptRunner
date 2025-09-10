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
    focus: true
    visible: !fileDropOverlay.visible // Hide menu when drop overlay is visible

    signal settingsBtn()
    signal closeBtn()
    signal changeImportantState(var isImportant)

    property bool dropModeActive: fileDropOverlay.visible

    function openDropArea(action) {
        // console.log("ssssssssssssss")
        root.changeImportantState(true)
        fileDropOverlay.openWithAction(action)
    }

    Keys.onEscapePressed: {
        if (fileDropOverlay.visible) {
            fileDropOverlay.visible = false
        } else {
            root.closeBtn()
        }
        changeImportantState(false)
    }

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
                color: settingsMouseArea.pressed ? "#34495E" :
                       settingsMouseArea.containsMouse ? "#2C3E50" : "transparent"
                scale: settingsMouseArea.pressed ? 0.95 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }

                Text {
                    text: "⚙️"
                    font.pixelSize: 12
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: settingsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: function(mouse) {
                        root.settingsBtn()
                        root.changeImportantState(true)
                    }
                }
            }

            // Close button
            Rectangle {
                id: closeButton
                width: 26
                height: 26
                color: closeMouseArea.pressed ? "#C0392B" :
                       closeMouseArea.containsMouse ? "#A93226" : "transparent"
                scale: closeMouseArea.pressed ? 0.95 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }

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
                    onClicked: function(mouse) {
                        root.closeBtn()
                        root.changeImportantState(false)
                    }
                }
            }
        }

        // Visual indicator for drop mode
        Rectangle {
            visible: root.dropModeActive
            Layout.alignment: Qt.AlignHCenter
            width: 100
            height: 4
            color: "#3498DB"
            radius: 2
        }

        // Tab bar for categories
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: actionManager.categoriesKeys.length

                    TabButton {
                        text: actionManager.categoriesKeys[index].charAt(0).toUpperCase() +
                              actionManager.categoriesKeys[index].slice(1)
                        isCurrent: tabBar.currentIndex === index
                        Layout.fillWidth: true
                        onClicked: tabBar.currentIndex = index
                    }
                }
            }
        }

        // Tab content - Dynamic from action manager
        StackLayout {
            id: tabBar
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            Repeater {
                model: Object.keys(actionManager.categorizedActions)

                GridLayout {
                    columns: 2//Math.max(2, Math.floor(parent.width / 40))
                    columnSpacing: 8
                    rowSpacing: 8
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Repeater {
                        model: actionManager.categorizedActions[modelData] // category actions
                        delegate: IconButton {
                            icon: modelData.icon
                            tooltip: modelData.name
                            actionName: modelData.name  // Pass the action name
                            onClicked: {
                                if (modelData.type === "exe_with_input") {
                                    // Needs a file from user → open overlay
                                    fileDropOverlay.openWithAction(modelData)
                                } else {
                                    // exe and exe_in_cmd (with static_file) → run directly
                                    actionManager.executeAction(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Full-screen drop area
    Rectangle {
        id: fileDropOverlay
        anchors.fill: parent
        color: "#AA2C3E50"  // Semi-transparent version of menu background
        visible: false
        opacity: visible ? 1 : 0
        z: 100
        Behavior on opacity { NumberAnimation { duration: 150 } }

        property var currentAction: null

        signal canceled()
        signal fileDropped(string filePath)

        // Drop area that covers the entire menu


        // Visual indicator for drop zone
        Rectangle {
            id: dropIndicator
            anchors.centerIn: parent
            width: parent.width - 4
            height: parent.height - 4
            // radius: 10
            color: "#2C3E50"
            border.color: "#3498DB"
            border.width: 2

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 15

                Text {
                    text: "📁"
                    font.pixelSize: 40
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    id: dropText
                    text: fileDropOverlay.currentAction ? "Drop a file for " + fileDropOverlay.currentAction.name : "Drop a file"
                    color: "#ECF0F1"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Label {
                    text: fileDropOverlay.currentAction?.description || "..."
                    color: "#BDC3C7"
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }
        }
        DropArea {
            id: fullDropArea
            anchors.fill: parent
            z: 1000
            onEntered: function(drag) {
                // console.log("mouse enter")
                if (drag.hasUrls) {
                    dropIndicator.border.color = "#27AE60" // Green highlight when file is over drop area
                    dropIndicator.border.width = 3
                    dropText.text = "Release to process file"
                }
            }

            onExited: function() {
                // console.log("mouse exit")
                dropIndicator.border.color = "#3498DB"
                dropIndicator.border.width = 2
                dropText.text = "Drop file here"
            }

            onDropped: function(drop) {
                if (drop.hasUrls) {
                    var filePath = drop.urls[0].toString()
                    if (filePath.startsWith("file:///")) {
                        filePath = filePath.substring(8)
                    } else if (filePath.startsWith("file://")) {
                        filePath = filePath.substring(7)
                    }
                    filePath = decodeURIComponent(filePath) // ✅ normalize path

                    if (fileDropOverlay.currentAction) {
                        actionManager.executeActionWithFile(fileDropOverlay.currentAction.id, filePath)
                    }

                    fileDropOverlay.visible = false
                    root.changeImportantState(false)
                    dropIndicator.border.color = "#3498DB"
                    dropIndicator.border.width = 2
                    dropText.text = "Drop file here"
                }
            }
        }
        // Close button for drop overlay
        Rectangle {
            id: closeDropButton
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            width: 30
            height: 30
            color: closeDropMouseArea.pressed ? "#C0392B" :
                   closeDropMouseArea.containsMouse ? "#A93226" : "#2C3E50"
            //radius: 15
            border.color: "#ECF0F1"
            border.width: 1

            Text {
                text: "×"
                color: "#ECF0F1"
                font.pixelSize: 18
                font.bold: true
                anchors.centerIn: parent
            }

            MouseArea {
                id: closeDropMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: function(mouse) {
                    fileDropOverlay.visible = false
                    fileDropOverlay.canceled()
                    root.changeImportantState(false)
                }
            }
        }


        function openWithAction(action) {
            console.log("action : " + JSON.stringify(action))

            root.changeImportantState(true)
            if (action && typeof action.id !== "undefined") {
                currentAction = action
                visible = true
            } else {
                console.error("Invalid action provided to fileDropOverlay")
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
        Behavior on color { ColorAnimation { duration: 150 } }

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
            onClicked: function(mouse) { tabButton.clicked() }
        }
    }

    // Custom icon button component
    component IconButton: Rectangle {
        id: iconButton
        property string icon: ""
        property string tooltip: ""
        property string actionName: ""  // Added property for action name
        signal clicked()

        Layout.fillWidth: true  // Make button fill available width
        Layout.preferredHeight: 30  // Increased height to accommodate text
        radius: 2
        color: iconMouseArea.pressed ? "#3498DB" :
            iconMouseArea.containsMouse ? "#2980B9" : "#34495E"
        scale: iconMouseArea.pressed ? 0.95 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 8

            Text {
                text: iconButton.icon
                font.pixelSize: 15
            }

            Text {
                text: iconButton.actionName  // Show action name
                color: "#ECF0F1"
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        MouseArea {
            id: iconMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: function(mouse) { iconButton.clicked() }
        }

        // Custom ToolTip
        ToolTip {
            id: tooltip
            visible: iconMouseArea.containsMouse && iconButton.tooltip
            delay: 500
            text: iconButton.tooltip

            background: Rectangle {
                color: "#34495E"
                radius: 3
                border.color: "#2980B9"
            }

            contentItem: Text {
                text: tooltip.text
                color: "#ECF0F1"
                font.pixelSize: 10
            }
        }
    }

    Component.onCompleted: forceActiveFocus()
}
