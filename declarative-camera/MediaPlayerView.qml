import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
    id: mediaPlayerView
    property string sourceFile: ""
    signal backButtonClicked()

    Popup {
        id: mediaError
        anchors.centerIn: Overlay.overlay
        Text {
            id: mediaErrorText
        }
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
            left: parent.left
        }
        onClicked: {
            backButtonClicked()
        }
    }

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
        orientation: 90 // TODO (Tung Nguyen): check why always rotation 90
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

}
