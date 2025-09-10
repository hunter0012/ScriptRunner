import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import com.SRunner 1.0
import Qt.labs.settings 1.0

Popup {
    id: settingsPopup
    width: 320
    height: 420
    z: 10
    padding: 0
    visible: false

    signal changeImportantState(var isImportant)
    // Modern background with subtle shadow
    background: Rectangle {
        color: "#2D3748"
        radius: 8
        border {
            width: 1
            color: Qt.lighter("#2D3748", 1.2)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header with gradient background
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            radius: 8
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#4A5568" }
                GradientStop { position: 1.0; color: "#2D3748" }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 12

                Label {
                    text: "Settings"
                    font.bold: true
                    font.pixelSize: 16
                    color: "white"
                    Layout.fillWidth: true
                }

                // Modern close button
                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: closeSettingsMouseArea.pressed ? "#E53E3E" :
                           closeSettingsMouseArea.containsMouse ? "#C53030" : "transparent"

                    Text {
                        text: "×"
                        color: "white"
                        font.pixelSize: 20
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: closeSettingsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: function(mouse) {
                            settingsPopup.visible = false
                        }
                    }
                }
            }
        }

        // Settings content area
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 4
            clip: true

            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: parent.width
                spacing: 20
                // padding: 16

                // Appearance section
                SettingsSection {
                    title: "Appearance"

                    ColumnLayout {
                        width: parent.width
                        spacing: 12

                        LabeledComboBox {
                            label: "Theme:"
                            model: ["Dark", "Light", "System"]
                            currentIndex: 0
                        }

                        LabeledSlider {
                            label: "Icon Size:"
                            from: 40
                            to: 60
                            value: 48
                        }

                        LabeledColorPicker {
                            label: "Docked Color:"
                            color: settingsManager.dockedColor
                            onColorChanged: settingsManager.setDockedColor(color)
                        }

                        LabeledColorPicker {
                            label: "Expanded Color:"
                            color: settingsManager.expandedColor
                            onColorChanged: settingsManager.setExpandedColor(color)
                        }

                        LabeledSlider {
                            label: "Corner Radius:"
                            from: 0
                            to: 10
                            value: settingsManager.cornerRadius
                            onValueChanged: settingsManager.setCornerRadius(value)
                        }
                    }
                }

                // Behavior section
                SettingsSection {
                    title: "Behavior"

                    ColumnLayout {
                        width: parent.width
                        spacing: 8

                        LabeledComboBox {
                            label: "Screen Edge:"
                            model: ["Right", "Left", "Top", "Bottom"]
                            currentIndex: {
                                switch(settingsManager.screenEdge) {
                                    case "right": return 0;
                                    case "left": return 1;
                                    case "top": return 2;
                                    case "bottom": return 3;
                                    default: return 0;
                                }
                            }
                            onCurrentIndexChanged: {
                                var edges = ["right", "left", "top", "bottom"];
                                settingsManager.setScreenEdge(edges[currentIndex]);
                            }
                        }

                        LabeledCheckBox {
                            text: "Follow Mouse"
                            checked: settingsManager.followMouse
                            onCheckedChanged: settingsManager.setFollowMouse(checked)
                        }

                        LabeledCheckBox {
                            text: "Start with system"
                            checked: false
                        }

                        LabeledCheckBox {
                            text: "Minimize to system tray"
                            checked: true
                        }

                        LabeledCheckBox {
                            text: "Show tooltips"
                            checked: true
                        }
                    }
                }

                // Hotkeys section
                SettingsSection {
                    title: "Hotkeys"

                    ColumnLayout {
                        width: parent.width
                        spacing: 10

                        LabeledHotkey {
                            label: "Show panel:"
                            hotkey: "Ctrl+Shift+Q"
                        }

                        LabeledHotkey {
                            label: "Screenshot:"
                            hotkey: "Ctrl+Shift+S"
                        }
                    }
                }
            }
        }

        // Footer with action buttons
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "transparent"

            RowLayout {
                anchors.centerIn: parent
                spacing: 12

                // Cancel button
                CustomButton {
                    text: "Cancel"
                    backgroundColor: "#4A5568"
                    hoverColor: "#718096"
                    onClicked: settingsPopup.visible = false
                }

                // Apply button
                CustomButton {
                    text: "Apply"
                    backgroundColor: "#3182CE"
                    hoverColor: "#2B6CB0"
                    onClicked: {
                        settingsManager.saveSettings()
                        settingsPopup.visible = false
                    }
                }
            }
        }
    }

    // Custom component for section headers
    component SettingsSection: ColumnLayout {
        property string title

        Layout.fillWidth: true
        spacing: 8

        Label {
            text: title
            font.bold: true
            font.pixelSize: 14
            color: "#E2E8F0"
            topPadding: 4
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#4A5568"
            opacity: 0.6
        }
    }

    // Custom button component
    component CustomButton: Button {
        property color backgroundColor: "#4A5568"
        property color hoverColor: Qt.lighter(backgroundColor, 1.2)

        implicitWidth: 80
        implicitHeight: 32

        background: Rectangle {
            radius: 4
            color: parent.hovered ? hoverColor : backgroundColor
        }

        contentItem: Text {
            text: parent.text
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 12
        }
    }

    // Custom labeled combobox component
    component LabeledComboBox: RowLayout {
        property string label
        property var model
        property int currentIndex: 0

        Layout.fillWidth: true

        Label {
            text: label
            font.pixelSize: 12
            color: "#CBD5E0"
            Layout.preferredWidth: 80
        }

        ComboBox {
            Layout.fillWidth: true
            model: parent.model
            currentIndex: parent.currentIndex

            background: Rectangle {
                color: "#4A5568"
                radius: 4
                border.width: 1
                border.color: "#718096"
            }

            contentItem: Text {
                text: parent.displayText
                color: "white"
                font.pixelSize: 11
                verticalAlignment: Text.AlignVCenter
                leftPadding: 8
            }

            popup: Popup {
                y: parent.height
                width: parent.width
                implicitHeight: contentItem.implicitHeight

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: parent.parent.model
                    currentIndex: parent.parent.currentIndex

                    delegate: ItemDelegate {
                        width: parent.width
                        text: modelData
                        font.pixelSize: 11
                        highlighted: parent.currentIndex === index

                        background: Rectangle {
                            color: highlighted ? "#3182CE" : "transparent"
                        }
                    }
                }

                background: Rectangle {
                    color: "#4A5568"
                    radius: 4
                    border.width: 1
                    border.color: "#718096"
                }
            }
        }
    }

    // Custom labeled slider component
    component LabeledSlider: ColumnLayout {
        property string label
        property real from: 0
        property real to: 100
        property real value: 50
        property alias slider: sliderControl

        Layout.fillWidth: true
        spacing: 6

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: label
                font.pixelSize: 12
                color: "#CBD5E0"
                Layout.preferredWidth: 80
            }

            Label {
                text: Math.round(value)
                font.pixelSize: 11
                color: "#CBD5E0"
                Layout.alignment: Qt.AlignRight
            }
        }

        Slider {
            id: sliderControl
            Layout.fillWidth: true
            from: parent.from
            to: parent.to
            value: parent.value

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 4
                color: "#4A5568"
                radius: 2

                Rectangle {
                    width: parent.visualPosition * parent.width
                    height: parent.height
                    color: "#3182CE"
                    radius: 2
                }
            }

            handle: Rectangle {
                x: parent.visualPosition * (parent.width - width)
                y: (parent.height - height) / 2
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: parent.pressed ? "#E2E8F0" : "#FFFFFF"
                border.width: 1
                border.color: "#A0AEC0"
            }
        }
    }

    // Custom labeled checkbox component
    component LabeledCheckBox: RowLayout {
        property string text: ""
        property bool checked: false

        Layout.fillWidth: true

        CheckBox {
            id: checkBox
            checked: parent.checked
            onCheckedChanged: parent.checked = checked

            indicator: Rectangle {
                implicitWidth: 16
                implicitHeight: 16
                radius: 3
                color: checkBox.checked ? "#3182CE" : "#4A5568"
                border.width: 1
                border.color: checkBox.checked ? "#3182CE" : "#718096"

                Text {
                    text: "✓"
                    color: "white"
                    font.pixelSize: 10
                    font.bold: true
                    anchors.centerIn: parent
                    visible: checkBox.checked
                }
            }
        }

        Label {
            text: parent.text
            font.pixelSize: 12
            color: "#CBD5E0"
            Layout.fillWidth: true
        }
    }

    // Custom color picker component
    component LabeledColorPicker: RowLayout {
        property string label: ""
        property color color: "white"
        signal colorChanged(color newColor)

        Layout.fillWidth: true

        Label {
            text: label
            font.pixelSize: 12
            color: "#CBD5E0"
            Layout.preferredWidth: 80
        }

        Rectangle {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 24
            color: parent.color
            border.width: 1
            border.color: "#718096"
            radius: 3

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Simple color picker - in real app, use ColorDialog
                    var colors = ["#3498DB", "#2C3E50", "#E74C3C", "#27AE60", "#F39C12", "#9B59B6"];
                    var currentIndex = colors.indexOf(parent.parent.color.toString().toUpperCase());
                    var newIndex = (currentIndex + 1) % colors.length;
                    parent.parent.color = colors[newIndex];
                    parent.parent.colorChanged(colors[newIndex]);
                }
            }
        }

        Label {
            text: parent.color.toString()
            font.pixelSize: 10
            color: "#CBD5E0"
        }
    }

    // Custom hotkey input component
    component LabeledHotkey: RowLayout {
        property string label: ""
        property string hotkey: ""

        Layout.fillWidth: true

        Label {
            text: label
            font.pixelSize: 12
            color: "#CBD5E0"
            Layout.preferredWidth: 80
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            color: "#4A5568"
            radius: 4
            border.width: 1
            border.color: "#718096"

            Label {
                text: parent.parent.hotkey
                color: "#CBD5E0"
                font.pixelSize: 11
                padding: 6
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
