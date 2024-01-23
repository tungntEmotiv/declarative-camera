// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtMultimedia
import QtQuick.Controls

ApplicationWindow {
    id : root
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
            imageCapture: ImageCapture {
                id: imageCapture
            }

            recorder: MediaRecorder {
                id: recorder
                quality: MediaRecorder.HighQuality
                mediaFormat {
                    fileFormat: MediaFormat.WMV
                    videoCodec: MediaFormat.VideoCodec.MPEG1
                }

                onRecorderStateChanged: {
                    console.log("onRecorderStateChanged: record state ", recorderState, " location ", outputLocation,
                                " actuallocation:",actualLocation )
                    switch (recorderState) {
                        case MediaRecorder.StoppedState:
                            videoPreview.sourceFile = actualLocation
                            break
                        default:
                            break
                    }
                }
            }
            videoOutput: viewfinder
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

            onApplySettings: (sAudioCodecIdx, sVideoCodecIdx, sQualityIdx, sFileFormatIdx) => {
                console.info("apply settings: sAudioCodecIdx: " + sAudioCodecIdx +
                             "sVideoCodecIdx: " + sVideoCodecIdx +
                             "sQualityIdx:" + sQualityIdx, "sFileFormatIdx:" + sFileFormatIdx)
                recorder.mediaFormat.audioCodec = sAudioCodecIdx
                recorder.mediaFormat.videoCodec = sVideoCodecIdx
                recorder.quality = sQualityIdx
                recorder.mediaFormat.fileFormat = sFileFormatIdx
            }

            onVideoCodecNFileFormatChanged: (sVideoCodecIdx, sFileFormatIdx) => {
                console.info("onVideoCodecNFileFormatChanged videoCodec: " + sVideoCodecIdx + "file format changed: " + sFileFormatIdx)
                recorder.mediaFormat.videoCodec = sVideoCodecIdx
                recorder.mediaFormat.fileFormat = sFileFormatIdx
                // check audio codec list updated
                videoControls.audioCodecModel = _private.getAudioCodecList()
            }
            onCameraDeviceChanged: {
                _private.getVideoFormats()
            }
        }
        // clock to show record times
        Text {
            text: parseInt(recorder.duration/1000) + " s"
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
        _private.initModel()
        _private.getVideoFormats()
    }


    QtObject {
        id: _private
        function getAudioCodecList() {
            var _listAudioCodecSupported = recorder.mediaFormat.supportedAudioCodecs(MediaFormat.Encode)
            var _listNameAudioCodecs = []
            for (var j= 0; j < _listAudioCodecSupported.length; j++) {
                var _audioCodecName = recorder.mediaFormat.audioCodecName(_listAudioCodecSupported[j])
                _listNameAudioCodecs.push(_audioCodecName)
            }
            return _listNameAudioCodecs
        }

        function getVideoFormats() {
            var _supportedVideoFormats = camera.cameraDevice.videoFormats
            for (var i = 0; i < _supportedVideoFormats.length; i++) {
                var _minFrameRate  = _supportedVideoFormats[i].minFrameRate
                var _maxFrameRate = _supportedVideoFormats[i].maxFrameRate
                var _resolution = _supportedVideoFormats[i].resolution
                var _pixelFormat = _supportedVideoFormats[i].pixelFormat
                console.log("minFrameRate ", _minFrameRate, ", maxFrameRate:", _maxFrameRate,
                            ", resolution :", _resolution, " pixelFormat:", _pixelFormat)
            }
        }

        function initModel() {
            //prepare models for videoControls
            // file format model
            var _listFormatSupported = recorder.mediaFormat.supportedFileFormats(MediaFormat.Encode)
            var _listNameFileFormats = []
            for (var i= 0; i < _listFormatSupported.length; i++) {
                var _supportedName = recorder.mediaFormat.fileFormatName(_listFormatSupported[i])
                _listNameFileFormats.push(_supportedName)
            }
            videoControls.fileFormatModel = _listNameFileFormats
            // video codec model
            var _listVideoCodecSupported = recorder.mediaFormat.supportedVideoCodecs(MediaFormat.Encode)
            var _listNameVideoCodecs = []
            for (var k= 0; k < _listVideoCodecSupported.length; k++) {
                var _videoCodecName = recorder.mediaFormat.videoCodecName(_listVideoCodecSupported[k])
                _listNameVideoCodecs.push(_videoCodecName)
            }
            videoControls.videoCodecModel = _listNameVideoCodecs
            // quality model
            videoControls.qualityModel = ["Very Low", "Low", "Normal", "High", "Very High"]

            // update audio codec
            videoControls.audioCodecModel = getAudioCodecList()
        }

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
    }

}
