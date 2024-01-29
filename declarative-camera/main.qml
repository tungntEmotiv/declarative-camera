// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtMultimedia
import QtQuick.Controls

ApplicationWindow {
    id : root
    property var curPopupObject
    property int numRecord: 0
    visible: true
    title: "Declarative Camera"
    header: Item { height: 0 }
    menuBar: Item { height: 0 }
    color: "black"
    footer: Rectangle {
        id: footer
        color: root.color
        width: parent.width
        height: 0
    }

    function showPopup(popupName, params) {
        if (curPopupObject && curPopupObject.objectName === popupName) {
            curPopupObject.destroy()
        }

        if (typeof params === "undefined")
            params = {}
        var comp = Qt.createComponent("qrc:/" + popupName + ".qml")
        curPopupObject = comp.createObject(popupContainer, params)
        curPopupObject.closed.connect(function() {
            if (typeof (curPopupObject) !== "undefined") {
                curPopupObject.destroy()
            }
        })

        if (isAndroid)
            popupContainer.forceActiveFocus()

        return curPopupObject
    }

    Rectangle {
        id: cameraUI
        property int buttonsPanelLandscapeWidth: 328
        property int buttonsPanelPortraitHeight: 180
        anchors.fill: parent
        color: "black"
        state: "VideoCapture"
        onWidthChanged: {
            _private.setState()
        }
        states: [
            State {
                name: "PhotoCapture"
                StateChangeScript {
                    script: {
                        camera.start()
                    }
                }
            },
            State {
                name: "PhotoPreview"
            },
            State {
                name: "VideoCapture"
                StateChangeScript {
                    script: {
                        camera.start()
                    }
                }
            },
            State {
                name: "VideoPreview"
                StateChangeScript {
                    script: {
                        camera.stop()
                    }
                }
            }
        ]
        CaptureSession {
            id: captureSession
            camera: Camera {
                id: camera
            }
            audioInput: AudioInput {
                volume: 1
            }
            recorder: mediaRecorder
            videoOutput: viewfinder
            audioOutput: AudioOutput {
                    volume: 0.5
            }
            imageCapture: ImageCapture {
                id: imageCapture
            }
        }

        MediaRecorder {
            id: mediaRecorder
            onRecorderStateChanged: {
                switch (recorderState) {
                    case MediaRecorder.StoppedState:
                        _private.saveVideoMetaData(mediaRecorder.mediaFormat.audioCodec,
                                                   mediaRecorder.mediaFormat.videoCodec,
                                                   mediaRecorder.mediaFormat.fileFormat,
                                                   mediaRecorder.videoResolution,
                                                   mediaRecorder.videoFrameRate, mediaRecorder.duration)
                        // videoPreview.metaData = recorder.metaData
                        videoPreview.sourceFile = mediaRecorder.actualLocation
                        break
                    case MediaRecorder.RecordingState:
                        console.log("start record audio codec ", mediaRecorder.mediaFormat.audioCodec,
                                    "video codec :", mediaRecorder.mediaFormat.videoCodec,
                                    "fileformat:", mediaRecorder.mediaFormat.fileFormat,
                                    "resolution", mediaRecorder.videoResolution)
                        break
                    default:
                        break
                }
            }
        }

        PhotoPreview {
            id : photoPreview
            anchors.fill : parent
            onClosed: cameraUI.state = "PhotoCapture"
            visible: (cameraUI.state === "PhotoPreview")
            focus: visible
            source: imageCapture.preview
        }

        MediaPlayerView {
            id:videoPreview
            anchors.fill : parent
            mediaRecorder: mediaRecorder
            visible: (cameraUI.state === "VideoPreview")
            focus: visible
            onBackButtonClicked: {
                cameraUI.state = "VideoCapture"
            }
        }

        VideoOutput {
            id: viewfinder
            visible: ((cameraUI.state === "PhotoCapture") || (cameraUI.state === "VideoCapture"))
            anchors.fill : parent
            fillMode: VideoOutput.PreserveAspectFit
        }

        PhotoCaptureControls {
            id: stillControls
            state: "MobilePortrait"
            anchors.fill: parent

            buttonsPanelPortraitHeight: cameraUI.buttonsPanelPortraitHeight
            buttonsPanelWidth: cameraUI.buttonsPanelLandscapeWidth
            captureSession: captureSession
            visible: (cameraUI.state === "PhotoCapture")
            onPreviewSelected: cameraUI.state = "PhotoPreview"
            onVideoModeSelected: cameraUI.state = "VideoCapture"
            previewAvailable: imageCapture.preview.length !== 0
        }

        VideoCaptureControls {
            id: videoControls
            state: stillControls.state
            anchors.fill: parent
            buttonsWidth: stillControls.buttonsWidth
            buttonsPanelPortraitHeight: cameraUI.buttonsPanelPortraitHeight
            buttonsPanelWidth: cameraUI.buttonsPanelLandscapeWidth
            captureSession: captureSession
            visible: (cameraUI.state === "VideoCapture")
            onPreviewSelected: cameraUI.state = "VideoPreview"
            onPhotoModeSelected: cameraUI.state = "PhotoCapture"
        }
        // clock to show record times
        Text {
            text: parseInt(mediaRecorder.duration/1000) + " s"
            color: "white"
            width: contentWidth
            height: 24
            anchors {
                top: videoControls.top
                topMargin: 48
                horizontalCenter: videoControls.horizontalCenter
            }
            font {
                pixelSize: 24
                weight: Font.Bold
            }
            visible: (cameraUI.state === "VideoCapture")
        }
    }

    Component.onCompleted: {
        if (!isAndroid) {
            root.width = screen.width
            root.height = screen.height
        }
        _private.setState()
    }

    Item {
        id: popupContainer
        width: parent.width
        height: parent.height
        z: 99999
    }


    QtObject {
        id: _private

        function setState() {
            if (mobileUI) {
                if (root.width < root.height) {
                    stillControls.state = "MobilePortrait";
                } else {
                    stillControls.state  = "MobileLandscape";
                }
            } else {
                stillControls.state = "Other";
            }
            console.log("State: " + stillControls.state);
            stillControls.buttonsWidth = (stillControls.state === "MobilePortrait")
                    ? root.width/3.4 : 144
        }

        function saveVideoMetaData(sAudioCodecIdx, sVideoCodecIdx, sFileFormatIdx,
                                   sResolution, sFPS, sDuration) {
            console.log("saveVideoMetaData ", sAudioCodecIdx, "sVideoCodecIdx", sVideoCodecIdx, "resolution:", sResolution, "width:", sResolution.width)
            // set metadata
            var _displayResolution = sResolution.width + "x" + sResolution.height
            var _videoCodecName = mediaRecorder.mediaFormat.videoCodecName(sVideoCodecIdx)
            var _audioCodecName = mediaRecorder.mediaFormat.audioCodecName(sAudioCodecIdx)
            var _date = new Date().toDateString()
            var _duration = Math.round(sDuration*10/1000)/10

            mediaRecorder.metaData.insert(MediaMetaData.VideoFrameRate, sFPS)
            mediaRecorder.metaData.insert(MediaMetaData.Resolution, _displayResolution)
            mediaRecorder.metaData.insert(MediaMetaData.VideoCodec, _videoCodecName)
            mediaRecorder.metaData.insert(MediaMetaData.AudioCodec, _audioCodecName)
            mediaRecorder.metaData.insert(MediaMetaData.Date, _date)
            mediaRecorder.metaData.insert(MediaMetaData.Duration, _duration)
        }

    }

}
