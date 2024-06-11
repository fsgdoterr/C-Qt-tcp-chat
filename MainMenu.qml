import QtQuick
import QtQuick.Controls

Item {
    signal enterChat();
    signal createChat();

    id: mainMenu

    Column {
        spacing: 10
        anchors.centerIn: parent

        Button {
            text: "Enter the chat"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: mainMenu.enterChat()
        }

        Button {
            text: "Create a chat"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: mainMenu.createChat()
        }
    }
}
