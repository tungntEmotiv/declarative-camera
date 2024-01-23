// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtMultimedia
import QtQuick.Layouts
import QtQuick.Controls

FocusScope {
    id : captureControls
    property CaptureSession captureSession
    property bool previewAvailable : false
    property var audioCodecModel: []
    property var qualityModel: []
    property var fileFormatModel: []
    property var videoCodecModel: []
    property var cameraFormatModel: []

    property int buttonsmargin: 8
    property int buttonsPanelWidth
    property int buttonsPanelPortraitHeight
    property int buttonsWidth

    signal previewSelected
    signal photoModeSelected
    signal fileFormatSelected(var fileFormat)
    signal applySettings(var sAudioCodecIdx, var sVideoCodecIdx, var sQualityIdx, var sFileFormatIdx)
    signal videoCodecNFileFormatChanged(var sVideoCodecIdx, var sFileFormatIdx)
    signal cameraDeviceChanged()

    Rectangle {
        id: buttonPaneShadow
        width: parent.width
        color: Qt.rgba(0.08, 0.08, 0.08, 1)

        GridLayout {
            id: buttonsColumn
            anchors.margins: buttonsmargin
            flow: captureControls.state === "MobilePortrait"
                  ? GridLayout.LeftToRight : GridLayout.TopToBottom

            // button record
            Item {
                implicitWidth: buttonsWidth
                height: 70
                CameraButton {
                    text: "Record"
                    anchors.fill: parent
                    visible: captureSession.recorder.recorderState !== MediaRecorder.RecordingState
                    onClicked: captureSession.recorder.record()
                }
            }
            // settings buttons
            Item {
                implicitWidth: captureSession.recorder.recorderState !== MediaRecorder.RecordingState ? buttonsWidth : 0
                height: 70
                CameraButton {
                    id: settingsButton
                    text: "Settings"
                    anchors.fill: parent
                    visible: captureSession.recorder.recorderState !== MediaRecorder.RecordingState && (fileFormatModel.length > 0)
                    onClicked: {
                        // open popup settings
                        settingPopup.open()
                    }
                }
            }
            // button stop
            Item {
                implicitWidth: stopButton.visible? buttonsWidth : 0
                height: 70
                CameraButton {
                    id: stopButton
                    text: "Stop"
                    anchors.fill: parent
                    visible: captureSession.recorder.recorderState === MediaRecorder.RecordingState
                    onClicked: captureSession.recorder.stop()
                }
            }
            // button view
            Item {
                implicitWidth: buttonsWidth
                height: 70
                CameraButton {
                    text: "View"
                    anchors.fill: parent
                    onClicked: captureControls.previewSelected()
                    //don't show View button during recording
                    visible: captureSession.recorder.actualLocation && !stopButton.visible
                }
            }
        }

        GridLayout {
            id: bottomColumn
            anchors.margins: buttonsmargin
            flow: captureControls.state === "MobilePortrait"
                  ? GridLayout.LeftToRight : GridLayout.TopToBottom

            CameraListButton {
                implicitWidth: buttonsWidth
                onValueChanged: {
                    cameraDeviceChanged()
                    captureSession.camera.cameraDevice = value
                }
                state: captureControls.state
            }

            CameraButton {
                text: "Switch to Photo"
                implicitWidth: buttonsWidth
                onClicked: captureControls.photoModeSelected()
            }

            CameraButton {
                id: quitButton
                text: "Quit"
                implicitWidth: buttonsWidth
                onClicked: Qt.quit()
            }
        }
    }

    Popup {
        id: settingPopup
        anchors.centerIn: parent
        width: (parent.width - 48)
        height: parent.height - 120
        modal: true
        focus: true
        closePolicy: Popup.CloseOnPressOutside
        background: Rectangle {
            color: "white"
            radius: 10
            anchors.fill: parent
        }
        contentItem: VideoSettings {
            id: videoSettings
            anchors.fill: parent
            audioCodecModel: captureControls.audioCodecModel
            videoCodecModel: captureControls.videoCodecModel
            qualityModel: captureControls.qualityModel
            fileFormatModel: captureControls.fileFormatModel
            onDiscardButtonClicked: {
                settingPopup.close()
            }
            onSaveButtonClicked: (sAudioCodecIdx, sVideoCodecIdx, sQualityIdx, sFileFormatIdx) =>{
                // save settings
                applySettings(sAudioCodecIdx, sVideoCodecIdx, sQualityIdx, sFileFormatIdx)
                settingPopup.close()
            }
            onVideoCodecNFileFormatChanged: (sVideoCodecIdx, sFileFormatIdx) => {
                videoCodecNFileFormatChanged(sVideoCodecIdx, sFileFormatIdx)
            }
        }
    }

    ZoomControl {
        x : 0
        y : captureControls.state === "MobilePortrait" ? -buttonPaneShadow.height : 0
        width : 100
        height: parent.height

        currentZoom: captureSession.camera.zoomFactor
        maximumZoom: captureSession.camera.maximumZoomFactor
        onZoomTo: (sTarget) => {
            captureSession.camera.zoomFactor  = sTarget
        }
    }

    FlashControl {
        x : 10
        y : captureControls.state === "MobilePortrait" ?
                parent.height - (buttonPaneShadow.height + height) : parent.height - height

        cameraDevice: captureSession.camera
    }

    states: [
        State {
            name: "MobilePortrait"
            PropertyChanges {
                target: buttonPaneShadow
                width: parent.width
                height: buttonsPanelPortraitHeight
            }
            PropertyChanges {
                target: buttonsColumn
                height: captureControls.buttonsPanelPortraitHeight / 2 - buttonsmargin
            }
            PropertyChanges {
                target: bottomColumn
                height: captureControls.buttonsPanelPortraitHeight / 2 - buttonsmargin
            }
            AnchorChanges {
                target: buttonPaneShadow
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }
            AnchorChanges {
                target: buttonsColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
            }
            AnchorChanges {
                target: bottomColumn;
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }
        },
        State {
            name: "MobileLandscape"
            PropertyChanges {
                target: buttonPaneShadow
                width: buttonsPanelWidth
                height: parent.height
            }
            PropertyChanges {
                target: buttonsColumn
                height: parent.height
                width: buttonPaneShadow.width / 2
            }
            PropertyChanges {
                target: bottomColumn
                height: parent.height
                width: buttonPaneShadow.width / 2
            }
            AnchorChanges {
                target: buttonPaneShadow
                anchors.top: parent.top
                anchors.right: parent.right
            }
            AnchorChanges {
                target: buttonsColumn;
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left;
            }
            AnchorChanges {
                target: bottomColumn;
                anchors.top: parent.top;
                anchors.bottom: parent.bottom;
                anchors.right: parent.right;
            }
        },
        State {
            name: "Other"
            PropertyChanges {
                target: buttonPaneShadow;
                width: bottomColumn.width + 16;
                height: parent.height;
            }
            AnchorChanges {
                target: buttonPaneShadow;
                anchors.top: parent.top;
                anchors.right: parent.right;
            }
            AnchorChanges {
                target: buttonsColumn;
                anchors.top: parent.top
                anchors.right: parent.right
            }
            AnchorChanges {
                target: bottomColumn;
                anchors.bottom: parent.bottom;
                anchors.right: parent.right;
            }
        }
    ]
}
