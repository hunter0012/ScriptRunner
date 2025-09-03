import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import com.SRunner 1.0

Popup {
    id: settingsPopup
    width: 320
    height: 420
    z: 10
    padding: 0

    // Modern background with subtle shadow
    background: Rectangle {
        color: "#2D3748"
        radius: 8
        border {
            width: 1
            color: Qt.lighter("#2D3748", 1.2)
        }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 12
            samples: 25
            color: "#80000000"
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
                        onClicked: settingsVisible = false
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
                padding: 16

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
                    }
                }

                // Behavior section
                SettingsSection {
                    title: "Behavior"

                    ColumnLayout {
                        width: parent.width
                        spacing: 8

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
                    onClicked: settingsVisible = false
                }

                // Apply button
                CustomButton {
                    text: "Apply"
                    backgroundColor: "#3182CE"
                    hoverColor: "#2B6CB0"
                    onClicked: {
                        console.log("Settings applied")
                        settingsVisible = false
                    }
                }
            }
        }
    }

    // Custom component for section headers
    Component {
        id: settingsSection

        ColumnLayout {
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
    }

    // Custom button component
    Component {
        id: customButton

        Button {
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
    }

    // Custom labeled combobox component
    Component {
        id: labeledComboBox

        RowLayout {
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
    }

    // Custom labeled slider component
    Component {
        id: labeledSlider

        ColumnLayout {
            property string label
            property real from: 0
            property real to: 100
            property real value: 50

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
    }

    // Custom labeled checkbox component
    Component {
        id: labeledCheckBox

        RowLayout {
            property string text: ""
            property bool checked: false

            Layout.fillWidth: true

            CheckBox {
                id: checkBox
                checked: parent.checked

                indicator: Rectangle {
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 3
                    color: checkBox.checked ? "#3182CE" : "#4A5568"
                    border.width: 1
                    border.color: checkBox.checked ? "#3182CE" : "#718096"

                    Image {
                        anchors.centerIn: parent
                        width: 10
                        height: 8
                        source: "checkmark.svg"
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
    }

    // Custom hotkey input component
    Component {
        id: labeledHotkey

        RowLayout {
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
}
