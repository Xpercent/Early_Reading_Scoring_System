import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: teamItem
    property string teamName: ""
    property var members: []
    property real scaleFactor: 1.0
    property var todayScores: []

    signal memberClicked(string memberName)
    height: 178 * scaleFactor

    color: "#00000000"
    border.color: "#e0e0e0"
    border.width: 1
    radius: 16 * scaleFactor

    Column {
        anchors.fill: parent
        anchors.margins: 10 * scaleFactor
        spacing: 10 * scaleFactor
        // 成员网格
        GridLayout {
            width: parent.width
            columns: 2
            columnSpacing: 10 * scaleFactor
            rowSpacing: 10 * scaleFactor
            Repeater {
                model: members
                Rectangle {
                    id: memberButton

                    property string memberName: modelData
                    property bool isScored: todayScores.indexOf(memberName) !== -1

                    Layout.fillWidth: true
                    Layout.preferredHeight: 73 * scaleFactor
                    color: isScored ? "#c8e6c9" : "#f0f0f0"
                    border.color: isScored ? "#4caf50" : "transparent"
                    border.width: 2
                    radius: 8 * scaleFactor

                    Text {
                        anchors.centerIn: parent
                        text: memberName
                        font.pixelSize: 28 * scaleFactor
                        color: parent.isScored ? "#2e7d32" : "#333"
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            teamItem.memberClicked(memberButton.memberName)
                        }
                    }

                    // 点击动画
                    SequentialAnimation {
                        id: clickAnimation

                        PropertyAnimation {
                            target: memberButton
                            property: "scale"
                            to: 0.95
                            duration: 100
                        }
                        PropertyAnimation {
                            target: memberButton
                            property: "scale"
                            to: 1.0
                            duration: 100
                        }
                    }

                    Connections {
                        target: mouseArea
                        function onClicked() {
                            clickAnimation.start()
                        }
                    }
                }
            }
        }
    }
}


