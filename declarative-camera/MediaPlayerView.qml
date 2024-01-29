import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
    id: mediaPlayerView
    property url sourceFile: ""
    required property var mediaRecorder
    property var metaData: ({})
    signal backButtonClicked()

    Popup {
        id: mediaError
        anchors.centerIn: Overlay.overlay
        Text {
            id: mediaErrorText
        }
    }

    // Popup {
    //     id: videoDetailPopup
    //     anchors.centerIn: parent
    //     width: (parent.width - 48)
    //     height: parent.height - 200
    //     topPadding: 40
    //     modal: true
    //     focus: true
    //     closePolicy: Popup.CloseOnPressOutside
    //     background: Rectangle {
    //         color: "white"
    //         radius: 10
    //         anchors.fill: parent
    //     }
    //     contentItem: VideoDetails {
    //         id: videoDetails
    //         anchors.fill: parent
    //         sourceFile: mediaPlayerView.sourceFile
    //         videoMetaData: metaData
    //     }
    // }

    MediaPlayer {
        id: mediaPlayer
        videoOutput: videoOutput
        audioOutput: AudioOutput {
            id: audio
            muted: playbackControl.muted
            volume: playbackControl.volume
        }
        onErrorOccurred: {
            console.log("playback error: ", mediaPlayer.errorString)
            mediaErrorText.text = mediaPlayer.errorString
            mediaError.open()
        }
        source: Qt.resolvedUrl(mediaPlayerView.sourceFile)
    }

    VideoOutput {
        id: videoOutput
        anchors {
            top: parent.top
            bottom: playbackControl.top
            left: parent.left
            right: parent.right
        }
        orientation: isAndroid ? 90 : 0 // TODO (Tung Nguyen): check why always rotation 90 on android
    }

    // playback control
    PlaybackControl {
        id: playbackControl
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        mediaPlayer: mediaPlayer
    }

    Button {
        id: backButton
        icon {
            width: 24
            height: 24
            source: "qrc:/images/ic-back.svg"
        }
        anchors {
            top: parent.top
            topMargin: 8
            left: parent.left
            leftMargin: 8
        }
        onClicked: {
            backButtonClicked()
        }
    }

    // Button meta data
    Button {
        icon {
            width: 24
            height: 24
            source: "qrc:/images/ic-info-blue.svg"
        }
        anchors {
            top: parent.top
            topMargin: 8
            right: parent.right
            rightMargin: 8
        }
        onClicked: {
            // show popup meta data
            root.showPopup("VideoDetailsPopup", {"sourceFile": sourceFile, "videoMetaData": mediaRecorder.metaData})
        }
    }

}
