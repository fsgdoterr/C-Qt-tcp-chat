import QtQuick
import QtQuick.Controls

Item {
    signal createChat(string name, int port);
    signal back();

    id: createChat
    focus: true
    Keys.onPressed: event => submitForm(event);

    Button {
        text: "Back"
        onClicked: createChat.back()
        anchors.left: createChat.left
        anchors.top: createChat.top
    }

    Column {
        spacing: 10
        anchors.centerIn: parent

        Text {
            text: "Create a chat"
        }

        Column {
            TextField {
                id: createChatNameField
                placeholderText: "Your name"
                onTextChanged: createChatNameValidationText.visible = false
            }

            Text {
                id: createChatNameValidationText
                text: "This is required field"
                color: "red"
                visible: false
                font.italic: true
                font.pixelSize: 11
            }
        }

        Column {
            TextField {
                id: createChatPortField
                placeholderText: "Port"
                onTextChanged: createChatPortValidationText.visible = false
            }

            Text {
                id: createChatPortValidationText
                text: "This is required field"
                color: "red"
                visible: false
                font.italic: true
                font.pixelSize: 11
            }
        }


        Button {
            id: createButton
            text: "Create"
            onClicked: {
                if(!createChat.validateFields()) return;
                createChat.createChat(createChatNameField.text, createChatPortField.text);
            }
        }
    }


    function validateFields() {
        if(!createChatNameField.text.length) {
            createChatNameValidationText.visible = true;
            return false;
        }

        if(!createChatPortField.text.length) {
            createChatPortValidationText.visible = true;
            return false;
        }

        return true;
    }

    function submitForm(event) {
        if(event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
            createButton.clicked();
        }
    }
}
