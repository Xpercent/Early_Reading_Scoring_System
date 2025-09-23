import QtQuick
Item {
    anchors.fill: parent
    Rectangle{
        id:rec
        anchors.fill: parent
        color: "#141414"
    }
    Item{
        anchors.fill: parent
        id: open
        Rectangle{
            anchors.fill: parent
            color: "#141414"
        }
        Image {
            anchors.centerIn: parent
            // width: 3000 *scaleFactor
            width: parent.width
            source: "file:./resources/4kopen.png"
            fillMode: Image.PreserveAspectFit
        }
        Image {
            anchors.centerIn: parent
            width: 700 *scaleFactor
            source: "file:./resources/图片2.png"
            fillMode: Image.PreserveAspectFit
        }
    }


    OpacityAnimator{
        target: open
        from: 0
        to: 1
        running: true
        duration: 400
        onFinished: {
            rec.destroy()
            pp.start()
        }
    }

    SequentialAnimation{
        id:pp
        PauseAnimation { duration: 800}
        ParallelAnimation{
            ScaleAnimator{
                target: open
                from: 1
                to: 2 // 放大倍数
                duration: 400
                easing.type: Easing.InOutQuart
            }
            OpacityAnimator{
                target: open
                from:1
                to: 0
                duration: 400
                easing.type: Easing.InOutQuart
            }
            onFinished: {
                openani.destroy()
            }
        }
    }

}


