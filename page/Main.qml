import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.FluentWinUI3
ApplicationWindow {
    id: window
    property var vardata: globalFunc.vardata
    property real scaleFactor: vardata["resolution"]/1920
    property bool isFullScreen: vardata["resolution"] === Screen.width
    property var teamsData: globalFunc.getTeams()
    property var teamNames: globalFunc.getTeamNames()  // 按JSON原始顺序的团队名称列表
    property var todayScores: globalFunc.getTodayScores()
    property var dailyquote: vardata["Daily_quote"]
    palette {
        // 设置强调色（accent color）
        accent: "#00b7c3"
        // 其他可用的颜色属性：
        // window: "#FFFFFF"        // 窗口背景色
        // windowText: "#000000"    // 窗口文本色
        // base: "#FFFFFF"          // 基础色
        // text: "#000000"          // 文本色
        // button: "#F0F0F0"        // 按钮色
        // buttonText: "#000000"    // 按钮文本色
        // highlight: "#FF6B35"     // 高亮色
        // highlightedText: "#FFFFFF" // 高亮文本色
    }

    width: isFullScreen ? Screen.width : 1920 * scaleFactor
    height: isFullScreen ? Screen.height : 1080 * scaleFactor

    visible: true
    title: "计分系统"

    // 设置窗口属性
    flags: isFullScreen ? Qt.Window | Qt.FramelessWindowHint : Qt.Window

    // 禁止调整窗口大小
    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height

    // 全屏模式处理
    Component.onCompleted: {
        if (isFullScreen) {
            showFullScreen()
        } else {
            show()
        }
    }

    Rectangle{
        id:topR1
        width: parent.width
        height: 185*scaleFactor
        color:"#00000000"
        AnimatedText {
            id: animatedText
            onCurrentIndexChanged: {
                ani1.start()
                aniimg.currentFrame = 0
            }
        }
    }


    AnimatedImage{
        z:3
        id:aniimg
        width: 300*scaleFactor
        anchors.top:parent.top
        anchors.right: parent.right
        anchors.rightMargin: -222 * scaleFactor
        source: "file:./resources/saki.gif"
        fillMode: Image.PreserveAspectFit
        playing: false
        onFrameChanged: {
            if (currentFrame === frameCount - 1) {
                paused = true
                ani2.start()
            }
        }
        NumberAnimation{
            id:ani1
            target: aniimg
            property: "anchors.rightMargin"
            from: -222 * scaleFactor
            to: -100 * scaleFactor
            duration: 2000
            easing.type: Easing.InOutQuad
            onFinished: {
                aniimg.playing = true
                aniimg.paused = false
            }
        }
        NumberAnimation{
            id:ani2
            target: aniimg
            property: "anchors.rightMargin"
            to: -300 * scaleFactor
            duration: 2000
            easing.type: Easing.InOutQuad
        }
        Component.onCompleted: {
            if (vardata["sakiapper"] === false){
                destroy()
            }
        }

    }

    Loader{
        id:loaderpage
        anchors.top: topR1.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: mainpage
        onSourceComponentChanged: {
            if (loaderpage.sourceComponent === mainpage){
                topR1.visible= true
                loaderpage.anchors.topMargin = 0
            }
            else if (loaderpage.sourceComponent === chartpage){

                topR1.visible= false
            }
        }
    }

    Component{
        id: mainpage
        Item {
            id:mainpageitem
            width: 1590* scaleFactor
            height: 762* scaleFactor
            Rectangle{
                anchors.fill: parent
                radius: 16
                color: "#1e2836"
                opacity: 0.3
            }
            // 团队网格布局
            Flickable {
                id: chartFlickable
                anchors.fill: parent
                anchors.topMargin:10* scaleFactor
                anchors.bottomMargin:8* scaleFactor
                contentHeight: teamsGrid.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                GridLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    id: teamsGrid
                    columns: 4  // 每行4个小组
                    columnSpacing: 10 * scaleFactor
                    rowSpacing: 10 * scaleFactor
                    // 动态创建团队组件
                    Repeater {
                        model: teamNames  // 使用按JSON原始顺序的团队名称列表
                        TeamItem {
                            Layout.fillWidth: true  // 关键：让每个TeamItem填充可用宽度
                            Layout.preferredWidth: (chartFlickable.width - 20*scaleFactor - (teamsGrid.columnSpacing * 3)) / 4
                            teamName: modelData
                            members: teamsData[modelData] || []
                            scaleFactor: window.scaleFactor
                            todayScores: window.todayScores

                            onMemberClicked: function(memberName) {
                                handleMemberClick(memberName)
                            }
                        }
                    }
                }
            }
        }
    }
    Component{
        id: chartpage
        Item{
            width: 1590* scaleFactor
            height: 762* scaleFactor
            Rectangle{
                anchors.fill: parent
                radius: 16
                color: "#1e2836"
                opacity: 0.3
            }
            BarChart {
                anchors.fill: parent
            }
        }
    }


    Rectangle{
        height: 114 *scaleFactor
        anchors.bottom: parent.bottom
        RowLayout{
            spacing: 15*scaleFactor
            Item{
                width: 1*scaleFactor
            }
            Rectangle {
                height: 100*scaleFactor
                width: 100*scaleFactor
                color:"#4ca0e0"
                radius: 8
                Text {
                    text:"\uEC44"
                    anchors.centerIn: parent
                    font.family: "remixicon"
                    font.pixelSize: 64*scaleFactor
                    color: "#ffffff"
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        Qt.quit()
                    }
                }
            }
            Rectangle {
                height: 100*scaleFactor
                width: 100*scaleFactor
                color:"#4ca0e0"
                radius: 12*scaleFactor
                property string text: "\uEA96"
                Text {
                    text:parent.text
                    anchors.centerIn: parent
                    font.family: "remixicon"
                    font.pixelSize: 64*scaleFactor
                    color: "#ffffff"
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if (loaderpage.sourceComponent === mainpage){
                            loaderpage.sourceComponent= chartpage
                            parent.text= "\uEDE3"
                        }
                        else if (loaderpage.sourceComponent === chartpage){
                            loaderpage.sourceComponent= mainpage
                            parent.text= "\uEA96"
                        }
                    }
                }
            }
        }
    }


    // 处理成员点击
    function handleMemberClick(memberName) {
        var isScored = globalFunc.isMemberScored(memberName)

        if (isScored) {
            // 移除分数
            if (globalFunc.removeScore(memberName)) {
                console.log("移除分数:", memberName)
                refreshScores()
            }
        } else {
            // 添加分数
            if (globalFunc.addScore(memberName)) {
                console.log("添加分数:", memberName)
                refreshScores()
            }
        }
    }

    // 刷新分数数据
    function refreshScores() {
        todayScores = globalFunc.getTodayScores()
    }

    // 监听分数变化
    Connections {
        target: globalFunc
        function onScoreChanged() {
            window.refreshScores()
        }
    }
    Image{
        z:-1
        width: parent.width
        source: "file:./resources/blurred-image.png"
        fillMode: Image.PreserveAspectFit
    }


    Loader{
        id:openani
        source:"OpenAni.qml"
        anchors.fill: parent
        z:999
    }

    NumberAnimation {
        running: true
        target: window
        property: "opacity"
        from:0
        to: 1
        duration: 100
    }
}


