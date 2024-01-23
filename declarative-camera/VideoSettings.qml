import QtQuick
import QtQuick.Controls

Item {
    id: videoSettings
    property var audioCodecModel: []
    property var qualityModel: []
    property var fileFormatModel: []
    property var videoCodecModel: []
    property var cameraFormatModel: []

    signal discardButtonClicked()
    signal saveButtonClicked(var sAudioCodecIdx, var sVideoCodecIdx, var sQualityIdx, var sFileFormatIdx)
    // title
    Text {
        id: titleTxt
        height: 24
        width: contentWidth
        text: qsTr("Settings")
        font.pixelSize: 22
        font.bold: true
        anchors {
            top: parent.top
            topMargin: 24
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Flickable {
        id: container
        anchors {
            top: titleTxt.bottom
            topMargin: 24
            left: parent.left
            leftMargin: 8
            right: parent.right
            rightMargin: 8
            bottom: actionButtons.top
            bottomMargin: 40
        }

        contentHeight: containerCol.height
        Column {
            id: containerCol
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            // audio title
            Text {
                id: audioTitleTxt
                height: 24
                width: parent.width
                text: qsTr("Audio")
                font.pixelSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
            // audio settings
            Rectangle {
                id: audioSettings
                width: parent.width
                height: 80
                color: "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                border.color: "#B1B1B1"
                border.width: 1
                Text {
                    id: audioCodecTxt
                    text: qsTr("Audio codec")
                    height: 24
                    font.pixelSize: 16
                    font.bold: Font.Normal
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        top: parent.top
                        topMargin: 8
                    }
                }
                ComboBox {
                    id: audioCodecCob
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        right: parent.right
                        rightMargin: 8
                        top: audioCodecTxt.bottom
                        topMargin: 4
                    }
                    height: 40
                    width: parent.width - 16
                    model: audioCodecModel
                    currentIndex: 0
                }
            }

            // quality
            Rectangle {
                id: qualityItem
                width: parent.width
                height: 160
                color: "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                border.color: "#B1B1B1"
                border.width: 1
                Text {
                    id: qualityTxt
                    text: qsTr("Quality:")
                    height: 24
                    font.pixelSize: 16
                    font.bold: Font.Normal
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        top: parent.top
                        topMargin: 8
                    }
                }
                ComboBox {
                    id: qualityCb
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        right: parent.right
                        rightMargin: 8
                        top: qualityTxt.bottom
                        topMargin: 4
                    }
                    height: 40
                    width: parent.width - 16
                    model: qualityModel
                    currentIndex: 0
                }
                // file format
                Text {
                    id: fileFormatTxt
                    text: qsTr("File format:")
                    height: 24
                    font.pixelSize: 16
                    font.bold: Font.Normal
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        top: qualityCb.bottom
                        topMargin: 8
                    }
                }
                ComboBox {
                    id: fileFormatCb
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        right: parent.right
                        rightMargin: 8
                        top: fileFormatTxt.bottom
                        topMargin: 4
                    }
                    height: 40
                    width: parent.width - 16
                    model: fileFormatModel
                    currentIndex: 0
                    onCurrentIndexChanged: {
                        _private.checkAudioCodecListUpdate()
                    }
                }
            }

            // video title
            Text {
                id: videoTitle
                text: qsTr("Video")
                height: 24
                width: parent.width
                font.pixelSize: 16
                font.bold: Font.Normal
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
            // video settings
            Rectangle {
                id: videoContainer
                border.color: "#B1B1B1"
                border.width: 1
                color: "transparent"
                width: parent.width
                height: 160
                anchors.horizontalCenter: parent.horizontalCenter
                // camera format
                Text {
                    id: cameraFormatTxt
                    text: qsTr("Camera Format")
                    height: 24
                    font.pixelSize: 14
                    font.bold: Font.Normal
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        top: parent.top
                        topMargin: 8
                    }
                }
                ComboBox {
                    id: cameraFormatCb
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        right: parent.right
                        rightMargin: 8
                        top: cameraFormatTxt.bottom
                        topMargin: 4
                    }
                    height: 40
                    width: parent.width - 16
                    model: cameraFormatModel
                    currentIndex: 0
                }
                // video codec
                Text {
                    id: videoCodecTxt
                    text: qsTr("Video Codec:")
                    height: 24
                    font.pixelSize: 14
                    font.bold: Font.Normal
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        top: cameraFormatCb.bottom
                        topMargin: 8
                    }
                }
                ComboBox {
                    id: videoCodecCb
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        right: parent.right
                        rightMargin: 8
                        top: videoCodecTxt.bottom
                        topMargin: 4
                    }
                    height: 40
                    model: videoCodecModel
                    currentIndex: 0
                    onCurrentIndexChanged: {
                        _private.checkAudioCodecListUpdate()
                    }
                }
            }
        }
    }
    // action buttons
    Item {
        id: actionButtons
        anchors {
            left: parent.left
            leftMargin: 8
            right: parent.right
            rightMargin: 8
            bottom: parent.bottom
            bottomMargin: 40
        }
        height: 40
        Button {
            id: discardButton
            text: "<font color=\"black\"><b>Discard</b></font>"
            height: 40
            width: 96
            background: Rectangle {
                border.color: "#D5D5D5"
                border.width: 2
                color: "white"
                radius: 50
            }
            anchors {
                left: parent.left
                leftMargin: 8
                verticalCenter: parent.verticalCenter
            }
            onClicked: {
                // close popup
                discardButtonClicked()
            }
        }
        Button {
            text: "<font color=\"white\"><b>Save</b></font>"
            height: 40
            width: 80
            background: Rectangle {
                color: "#222222"
                radius: 50
            }
            anchors {
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            onClicked: {
                saveButtonClicked(audioCodecCob.currentIndex, videoCodecCb.currentIndex,
                                  qualityCb.currentIndex, fileFormatCb.currentIndex)
            }
        }
    }
}


