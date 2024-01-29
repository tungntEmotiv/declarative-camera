import QtQuick
import QtQuick.Controls
import QtMultimedia

Popup {
    id: videoDetailsPopup

    objectName: "VideoDetailsPopup"
    property var videoMetaData: ({})
    property url sourceFile
    modal: true
    focus: true
    width: root.width - 48
    height: root.height - 240
    x: (root.width - width ) / 2
    y: (root.height - height)/2

    padding: 0
    closePolicy: Popup.NoAutoClose
    enter: Transition {
        NumberAnimation { id: animIn; property: "y"; from: (root.height + height)/2 ; to: (root.height - height)/2 ; duration: 300 }
    }

    background: Rectangle {
        width: videoDetailsPopup.width
        height: videoDetailsPopup.height
        color: "white"
        radius: 4
    }

    contentItem: Column {
        spacing: 16
        width: parent.width
        Text {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.Bold
            font.pixelSize: 28
            color: "#222222"
            text: "Video Details"
        }

        Text {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.Normal
            font.pixelSize: 16
            height: contentHeight
            wrapMode: Text.WordWrap
            color: "#222222"
            text: "Title: " + utils.getFileName(sourceFile)
        }
        Text {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.Normal
            font.pixelSize: 16
            height: contentHeight
            color: "#222222"
            text: "Size: " + utils.getSizeOfFile(sourceFile) + " kbyte"
        }
        Text {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.Normal
            font.pixelSize: 16
            height: contentHeight
            color: "#222222"
            text: "Duration: " + videoMetaData.value(MediaMetaData.Duration) + " seconds"
        }
        Text {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.Normal
            font.pixelSize: 16
            height: contentHeight
            color: "#222222"
            text: "Resolution: " + videoMetaData.value(MediaMetaData.Resolution)
        }
        Text {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.Normal
            font.pixelSize: 16
            height: contentHeight
            color: "#222222"
            text: "Video codec: " + videoMetaData.value(MediaMetaData.VideoCodec)
        }
        Text {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.Normal
            font.pixelSize: 16
            height: contentHeight
            color: "#222222"
            text: "Video frame rate: " +videoMetaData.value(MediaMetaData.VideoFrameRate)
        }
        Text {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.Normal
            font.pixelSize: 16
            height: contentHeight
            color: "#222222"
            text: "Audio codec: " + videoMetaData.value(MediaMetaData.AudioCodec)
        }
        Text {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.Normal
            font.pixelSize: 16
            height: contentHeight
            color: "#222222"
            text: "Date: " + videoMetaData.value(MediaMetaData.Date)
        }
        Button {
            id: cancelButton
            text: "<font color=\"black\"><b>Cancel</b></font>"
            height: 40
            width: 120
            background: Rectangle {
                border.color: "#D5D5D5"
                border.width: 2
                color: "white"
                radius: 50
            }
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            onClicked: {
                // close popup
                videoDetailsPopup.close()
            }
        }
    }

    Component.onCompleted: {
        videoDetailsPopup.open()
    }
}
