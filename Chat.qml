import QtQuick
import QtQuick.Controls

Item {
    signal back();
    signal sendMessage(string message);

    property alias ipPort: ipPortText.text
    property var model;

    id: chat

    focus:true;
    Keys.onPressed: event => sendForm(event);

    Row {
        id: topBar
        anchors.left: chat.left
        anchors.top: chat.top
        anchors.right: chat.right
        spacing: 10

        Button {
            text: "Back"
            onClicked: chat.back()
        }

        Text {
            anchors.verticalCenter: topBar.verticalCenter
            id: ipPortText
            text: ""
        }
    }

    ScrollView {
        anchors.left: chat.left
        anchors.right: chat.right
        anchors.top: topBar.bottom
        anchors.bottom: bottomBar.top
        anchors.margins: 10
        clip: true

        ListView {
            id: messageArea
            anchors.fill: parent
            model: chat.model
            delegate: Text {
                width: messageArea.width
                wrapMode: Text.Wrap
                text: name + ": " + message
            }
        }

    }

    Row {
        id: bottomBar
        spacing: 10
        anchors.left: chat.left
        anchors.right: chat.right
        anchors.bottom: chat.bottom
        anchors.margins: 10

        TextField {
            id: messageField
            width:parent.width - sendButton.width - 20
            anchors.verticalCenter: bottomBar.verticalCenter
        }

        Button {
            id: sendButton
            text: "Send"
            anchors.verticalCenter: bottomBar.verticalCenter

            onClicked: {
                chat.sendMessage(messageField.text)
                messageField.clear()
            }
        }

    }

    function sendForm(event) {
        if(event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
            sendButton.clicked();
        }
    }
}
