// BarChart.qml (Fixed Version with Synchronized Flickable)
import QtQuick
import QtQuick.Controls.FluentWinUI3

Item {
    id: root

    // --- Public API ---
    anchors.fill: parent

    // --- Layout Constants ---
    property int pageMargin: 40
    property int topBarHeight: 40
    property int chartTopMargin: 60
    property int chartBottomMargin: 120

    // --- Internal State & Models ---
    property int maxCount: 0
    property var dynamicTeamColors:({})
    ListModel { id: chartModel }

    // --- Color Palette ---
    property var colorPalette: [
        "#2196F3", "#4CAF50", "#FFC107", "#F44336",
        "#9C27B0", "#00BCD4", "#E91E63", "#FF9800"
    ]

    // --- UI Components ---

    ComboBox {
        id: rangeSelector
        x: 20 * scaleFactor
        y: 690 * scaleFactor
        width: 200 * scaleFactor
        font {
            pixelSize: 16 * scaleFactor
            family: "微软雅黑"
        }
        model: ["总数据", "最近两周数据", "当天数据"]
        currentIndex: 0
        onCurrentIndexChanged: {
            const days = [0, 14, 1][currentIndex];
            loadChartData(days);
        }
    }

    // 图表绘制核心区域
    Item {
        y:-80* scaleFactor
        id: chartArea
        width: root.width - (2 * root.pageMargin * scaleFactor)
        height: root.height
        anchors.horizontalCenter: parent.horizontalCenter
        // 滑动区域 - 包含柱子和姓名标签
        Flickable {
            id: chartFlickable
            anchors.fill: parent
            contentWidth: chartContent.width
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            // 图表内容容器（包含柱子和姓名标签）
            Item {
                id: chartContent
                width: Math.max(chartFlickable.width, chartModel.count * (minBarWidth + minBarSpacing) + minBarSpacing)
                height: chartFlickable.height

                property real minBarWidth: 90 * scaleFactor
                property real minBarSpacing: 30 * scaleFactor
                property real barWidth: Math.max(minBarWidth, (chartFlickable.width - minBarSpacing) / chartModel.count - minBarSpacing)
                property real barSpacing: minBarSpacing

                // 条形柱子生成器
                Repeater {
                    model: chartModel
                    delegate: Rectangle {
                        id: barDelegate
                        property real targetHeight: (maxCount > 0 ? (count / maxCount) * 600 * scaleFactor : 0)
                        // property real targetHeight: (maxCount > 0 ? (count / maxCount) * (chartContent.height - 70 * scaleFactor) : 0)
                        property real animatedHeight: 0

                        x: chartContent.barSpacing + index * (chartContent.barWidth + chartContent.barSpacing)
                        y: chartContent.height - 40 * scaleFactor - animatedHeight // 调整Y坐标，为姓名标签预留空间
                        width: chartContent.barWidth
                        height: animatedHeight
                        color: "#00000000"
                        border.color: root.dynamicTeamColors[team]
                        radius: 4 * scaleFactor

                        Rectangle {
                            anchors.fill: parent
                            color: root.dynamicTeamColors[team]
                            opacity: 0.3
                        }

                        // 分数标签 (柱子顶上)
                        Text {
                            text: count
                            font.pixelSize: 18 * scaleFactor
                            color: "#333333"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.top
                            anchors.bottomMargin: 4 * scaleFactor
                        }

                        // 姓名标签 (柱子下方)
                        Text {
                            text: name
                            font.pixelSize: 18 * scaleFactor
                            color: "#333333"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.bottom
                            anchors.topMargin: 8 * scaleFactor
                        }

                        // 组件创建完成时启动动画
                        Component.onCompleted: barAnimation.start()

                        NumberAnimation {
                            id: barAnimation
                            target: barDelegate
                            property: "animatedHeight"
                            from: 0
                            to: targetHeight
                            duration: 500
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    // --- Logic ---

    /**
     * 加载并处理图表数据
     * @param {int} days - 要查询的天数 (0 表示所有)
     */
    function loadChartData(days) {
        // 1. 获取数据
        const data = globalFunc.calculateScore(days);

        // 清理旧状态
        chartModel.clear();
        maxCount = 0;

        if (!data || data.length === 0) {
            dynamicTeamColors = {};
            return;
        }

        // 2. 动态构建团队颜色映射
        const newTeamColors = {};
        let colorIndex = 0;
        for (const item of data) {
            if (!newTeamColors.hasOwnProperty(item.team)) {
                newTeamColors[item.team] = colorPalette[colorIndex % colorPalette.length];
                colorIndex++;
            }
        }
        dynamicTeamColors = newTeamColors;

        // 3. 计算Y轴最大值
        const max = Math.max(...data.map(item => item.count));
        maxCount = (max > 0) ? (Math.ceil(max / 5) * 5) : 10;

        // 4. 将处理后的数据填充到模型
        for (const item of data) {
            chartModel.append({
                "name": item.name,
                "count": item.count,
                "team": item.team
            });
        }
    }

    // 组件首次加载完成时，加载默认数据
    Component.onCompleted: {
        loadChartData(0);
    }
}
