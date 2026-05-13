import QtQuick 6.5
import QtQuick.Window 6.5

Window {
    width: 400
    height: 400
    visible: true
    color: "blue"
    
    Text {
        anchors.centerIn: parent
        text: "IS THIS BLUE?"
        color: "white"
        font.pixelSize: 40
    }
}
