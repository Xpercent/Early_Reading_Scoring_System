import QtQuick
import QtQuick.Controls.FluentWinUI3
import QtQuick.Layouts
Item {
    id: textContainer
    width: parent.width
    anchors.centerIn: parent

    // --- 公共属性 ---
    // 将动画参数提取为属性，方便统一修改和管理
    property int fadeInDuration: 1200
    property int pauseDuration: vardata["quote_time"]
    property int fadeOutDuration: 1200
    property bool running: true // 提供一个外部开关来控制动画

    property var daily_quotes: dailyquote
    property int currentIndex: 0

    Text {
        id: quoteText
        text: daily_quotes[currentIndex]
        color: "#ffffff"
        opacity: 0 // 初始透明度为0，等待动画使其显示
        lineHeight: 1.4
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.centerIn: parent
        font {
            pixelSize: 55 * scaleFactor
            family: "微软雅黑"
        }
    }
    Rectangle {
        id: progressBar
        width: 1400 * scaleFactor
        height: 6 * scaleFactor
        color: "#40000000"
        radius: 16 * scaleFactor
        anchors {
            top: quoteText.bottom
            topMargin: 30 * scaleFactor
            horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: progressIndicator
            width: 1400 * scaleFactor
            height: 6 * scaleFactor
            color: "#60ffffff"
            radius: parent.radius

            transform: Scale {
                id: progressScale
                origin.x: 0
                xScale: 0
            }
        }
    }

    // --- 统一的动画控制器 (核心优化) ---
    // 使用一个总的动画循环来同步控制文本和进度条
    SequentialAnimation {
        id: masterAnimation
        running: textContainer.running // 绑定到外部控制属性
        loops: Animation.Infinite

        // 动画的每一轮循环
        ParallelAnimation {
            // 1. 文本动画: 顺序执行 淡入 -> 暂停 -> 淡出
            SequentialAnimation {
                NumberAnimation {
                    target: quoteText
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: fadeInDuration
                    easing.type: Easing.InOutQuad
                }
                PauseAnimation { duration: pauseDuration }
                NumberAnimation {
                    target: quoteText
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: fadeOutDuration
                    easing.type: Easing.InOutQuad
                }
            }

            // 2. 进度条动画: 在整个文本动画期间，线性地从0增长到1
            NumberAnimation {
                target: progressScale
                property: "xScale"
                from: 0
                to: 1
                // 动画总时长 = 淡入 + 暂停 + 淡出，不再需要硬编码
                duration: fadeInDuration + pauseDuration + fadeOutDuration
                easing.type: Easing.Linear
            }
        }

        // 在一轮动画（文本淡出后）结束时，更新内容并重置进度条
        ScriptAction {
            script: {
                // 更新文本索引
                currentIndex = (currentIndex + 1) % daily_quotes.length;
                // 为下一轮循环重置进度条（虽然动画会从0开始，但显式重置更清晰）
                progressScale.xScale = 0;
            }
        }
    }
}


