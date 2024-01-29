import QtQuick
import QtQuick.Window

Window {
    id: root
    visible: true
    title: "Media recorder"

    Rectangle {
        anchors.fill: parent
        opacity: 0.5
        border.color: "black"
        border.width: 1
        radius: 3
        Text {
            anchors.fill: parent
            anchors.margins: 20
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("The example is not usable without the permissions.\n"
                       + "Please grant all requested permissions and restart the application.")
        }
    }
}
