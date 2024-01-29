import QtQuick
import QtQuick.Controls
import QtMultimedia

Popup {
    id: videoSettingsPopup
    modal: true
    objectName: "VideoSettingsPopup"

    required property MediaRecorder recorder
    required property Camera camera
    property cameraFormat currCameraFormat

    function populateModels() {
        console.log("populateModels")
        audioCodecModel.populate()
        videoCodecModel.populate()
        fileFormatModel.populate()
        cameraFormatModel.populate()
    }

    focus: true
    width: root.width - 48
    height: root.height - 120
    x: (root.width - width ) / 2
    y: (root.height - height)/2

    padding: 24
    closePolicy: Popup.NoAutoClose

    background: Rectangle {
        width: videoSettingsPopup.width
        height: videoSettingsPopup.height
        color: "white"
        radius: 4
    }
    contentItem: Item {
        id: videoSettings

        anchors.fill: parent

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
            flickableDirection: Flickable.VerticalFlick
            clip:true
            boundsBehavior: Flickable.StopAtBounds
            boundsMovement: Flickable.StopAtBounds

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
                        id: audioCodecCb
                        anchors {
                            left: parent.left
                            leftMargin: 8
                            right: parent.right
                            rightMargin: 8
                            top: audioCodecTxt.bottom
                            topMargin: 4
                        }
                        textRole: "displayName"
                        valueRole: "code"
                        height: 40
                        width: parent.width - 16
                        model: audioCodecModel
                        currentIndex: 0
                        onActivated:{
                            recorder.mediaFormat.audioCodec = currentValue}
                    }
                    ListModel {
                        id: audioCodecModel
                        function populate() {
                            audioCodecModel.clear()
                            audioCodecModel.append({"displayName": "Unspecified", "code": MediaFormat.AudioCodec.Unspecified})
                            var cs = recorder.mediaFormat.supportedAudioCodecs(MediaFormat.Encode)
                            for (var c of cs)
                                audioCodecModel.append({"displayName": recorder.mediaFormat.audioCodecName(c), "code": c})
                            audioCodecCb.currentIndex = cs.indexOf(recorder.mediaFormat.audioCodec) + 1
                        }
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
                        textRole: "displayName"
                        valueRole: "code"
                        width: parent.width - 16
                        model: ListModel {
                            ListElement { displayName: "Very low"; code: MediaRecorder.VeryLowQuality }
                            ListElement { displayName: "Low"; code: MediaRecorder.LowQuality }
                            ListElement { displayName: "Normal"; code: MediaRecorder.NormalQuality }
                            ListElement { displayName: "High"; code: MediaRecorder.HighQuality }
                            ListElement { displayName: "Very high"; code: MediaRecorder.VeryHighQuality }
                        }
                        onActivated: {
                            recorder.quality = currentValue
                        }
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
                        textRole: "displayName"
                        valueRole: "code"
                        model: fileFormatModel
                        onActivated: {
                            recorder.mediaFormat.fileFormat = currentValue
                        }
                    }

                    ListModel {
                        id: fileFormatModel
                        function populate() {
                            fileFormatModel.clear()
                            fileFormatModel.append({"displayName": "Unspecified", "code": MediaFormat.UnspecifiedFormat})
                            var cs = recorder.mediaFormat.supportedFileFormats(MediaFormat.Encode)
                            for (var c of cs)
                                fileFormatModel.append({"displayName": recorder.mediaFormat.fileFormatName(c), "code": c})
                            fileFormatCb.currentIndex = cs.indexOf(recorder.mediaFormat.fileFormat) + 1
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
                    property int currentVideoFormat: cameraFormatCb.currentIndex
                    id: videoContainer
                    border.color: "#B1B1B1"
                    border.width: 1
                    color: "transparent"
                    width: parent.width
                    height: 240
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
                        textRole: "displayName"
                        valueRole: "value"
                        model: cameraFormatModel
                        currentIndex: 0
                        onActivated: {
                            fpsItem.currFPSVal = currentValue.minFrameRate
                            fpsSlider.from = currentValue.minFrameRate
                            fpsSlider.to = currentValue.maxFrameRate
                            fpsSlider.value = currentValue.minFrameRate
                            var supportCameraFormats = camera.cameraDevice.videoFormats
                            for (var ele of supportCameraFormats) {
                                var _minFrameRate  = ele.minFrameRate
                                var _maxFrameRate = ele.maxFrameRate
                                var _resolution = ele.resolution
                                var _pixelFormat = ele.pixelFormat
                                if (_minFrameRate === currentValue.minFrameRate &&
                                        _maxFrameRate === currentValue.maxFrameRate &&
                                        _resolution === currentValue.resolution &&
                                        _pixelFormat === currentValue.pixelFormat) {
                                    camera.cameraFormat = ele
                                    break
                                }
                            }
                            recorder.videoResolution = currentValue.resolution
                        }
                    }

                    ListModel {
                        id: cameraFormatModel
                        function populate() {
                            cameraFormatModel.clear()
                            var _currIdx = 0
                            var supportCameraFormats = camera.cameraDevice.videoFormats
                            for (var ele of supportCameraFormats) {

                                var _minFrameRate  = ele.minFrameRate
                                var _maxFrameRate = ele.maxFrameRate
                                var _resolution = ele.resolution
                                var _pixelFormat = ele.pixelFormat

                                if (_minFrameRate === camera.cameraFormat.minFrameRate &&
                                        _maxFrameRate === camera.cameraFormat.maxFrameRate &&
                                        _resolution === camera.cameraFormat.resolution &&
                                        _pixelFormat === camera.cameraFormat.pixelFormat) {
                                    cameraFormatCb.currentIndex = _currIdx
                                    fpsItem.currFPSVal = _minFrameRate
                                    fpsSlider.from = _minFrameRate
                                    fpsSlider.to = _maxFrameRate
                                    fpsSlider.value = _minFrameRate
                                }

                                var _pixelFormatStr = utils.pixelFormatToString(_pixelFormat)
                                var _displayName = utils.toFormattedString(ele)
                                cameraFormatModel.append({"displayName": _displayName, "resolution": _resolution,
                                                            "minFrameRate":_minFrameRate, "maxFrameRate":_maxFrameRate,
                                                            "pixelFormat": _pixelFormat, "value": ele})
                                _currIdx +=1
                            }
                        }
                    }

                    // fps
                    Text {
                        id: fpsTxt
                        text: qsTr("Frames per second")
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
                    Item {
                        id: fpsItem
                        property int currFPSVal: 0
                        height: 32
                        anchors {
                            left: parent.left
                            leftMargin: 8
                            right: parent.right
                            rightMargin: 8
                            top: fpsTxt.bottom
                            topMargin: 8
                        }
                        TextField {
                            id: fpsVal
                            width: 48
                            height: 32
                            text: fpsItem.currFPSVal
                            readOnly: true
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                            }
                            leftInset: 4
                            font.pixelSize: 14
                            font.bold: Font.Normal
                        }

                        Slider {
                            id: fpsSlider
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: fpsVal.right
                                leftMargin: 16
                                right: parent.right
                            }
                            from: 0
                            to: 30
                            // value: cameraFormatModel.get(cameraFormatCb.currentIndex).minFrameRate
                            stepSize: 1
                            onValueChanged: {
                                fpsItem.currFPSVal = value
                            }
                        }

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
                            top: fpsItem.bottom
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
                        textRole: "displayName"
                        model: videoCodecModel
                        valueRole: "code"
                        onActivated: {
                            recorder.mediaFormat.videoCodec = currentValue
                        }
                    }

                    ListModel {
                        id: videoCodecModel
                        function populate() {
                            videoCodecModel.clear()
                            videoCodecModel.append({"displayName": "Unspecified", "code": MediaFormat.VideoCodec.Unspecified})
                            var cs = recorder.mediaFormat.supportedVideoCodecs(MediaFormat.Encode)
                            for (var c of cs)
                                videoCodecModel.append({"displayName": recorder.mediaFormat.videoCodecName(c), "code": c})
                            videoCodecCb.currentIndex = cs.indexOf(recorder.mediaFormat.videoCodec) + 1
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
                text: "<font color=\"black\"><b>Exit</b></font>"
                height: 40
                width: 96
                background: Rectangle {
                    border.color: "#D5D5D5"
                    border.width: 2
                    color: "white"
                    radius: 50
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                onClicked: {
                    recorder.videoFrameRate = fpsItem.currFPSVal
                    // close popup
                    videoSettingsPopup.close()
                }
            }
        }

    }
    Component.onCompleted: {
        videoSettingsPopup.open()
        populateModels()
    }

}


