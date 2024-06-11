import QtQuick
import QtQuick.Controls

Item {
    signal back();
    signal enterChat(string name, string ipPort);

    property alias connectionErrorVisible: enterChatConnectionErrorText.visible;

    id: enterChat
    focus: true
    Keys.onPressed: event => submitForm(event);

    Button {
        text: "Back"
        onClicked: enterChat.back();
        anchors.left: enterChat.left
        anchors.top: enterChat.top
    }

    Column {
        spacing: 10
        anchors.centerIn: parent

        Text {
            text: "Enter the chat"
        }

        Column {
            TextField {
                id: enterChatNameField
                placeholderText: "Your name"
                onTextChanged: {
                    enterChatNameValidationText.visible = false
                    enterChat.connectionErrorVisible = false;
                }
            }

            Text {
                id: enterChatNameValidationText
                text: "This is required field"
                color: "red"
                visible: false
                font.italic: true
                font.pixelSize: 11
            }
        }

        Column {
            TextField {
                id: enterChatIpPortField
                placeholderText: "Ip:Port"
                onTextChanged: {
                    enterChatIpPortValidationText.visible = false
                    enterChat.connectionErrorVisible = false;
                }
            }

            Text {
                id: enterChatIpPortValidationText
                text: "This is required field"
                color: "red"
                visible: false
                font.italic: true
                font.pixelSize: 11
            }
        }

        Button {
            id: enterButton
            text: "Enter"
            onClicked: {
                if(!enterChat.validateFields()) return;
                enterChat.connectionErrorVisible = false;
                enterChat.enterChat(enterChatNameField.text, enterChatIpPortField.text);
            }
        }
        Text {
            id:  enterChatConnectionErrorText
            text: "Connection error"
            color: "red"
            visible: false
            font.italic: true
            font.pixelSize: 11
        }
    }

    function validateFields() {
        if(!enterChatNameField.text.length) {
            enterChatNameValidationText.visible = true;
            return false;
        }

        if(!enterChatIpPortField.text.length) {
            enterChatIpPortValidationText.visible = true;
            return false;
        }

        return true;
    }

    function submitForm(event) {
        if(event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
            enterButton.clicked();
        }
    }
}
