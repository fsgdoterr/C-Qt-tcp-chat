import QtQuick
import QtQuick.Controls
import Backend

ApplicationWindow {
    signal connectToServerError();

    id: root
    visible: true
    width: 640
    height: 480

    StackView {
        id: router
        initialItem: mainMenuPage
        anchors.fill: parent
    }

    Page {
        id: mainMenuPage

        MainMenu {
            id: mainMenu
            anchors.fill: parent
            onCreateChat: router.push(createChatPage)
            onEnterChat: router.push(enterChatPage)
        }

    }

    Page {
        id: createChatPage
        visible: false

        CreateChat {
            id: createChat
            anchors.fill: parent
            onCreateChat: (name, port) => {
                backend.createServer(name, port);
                router.push(chatPage);
                chat.ipPort = backend.serverIpPort;
            }
            onBack: router.pop()
        }
    }

    Page {
        id: enterChatPage
        visible: false

        EnterChat {
            id: enterChat
            anchors.fill: parent
            onBack: router.pop()
            onEnterChat: (name, ipPort) => {
                if(backend.connectToServer(name, ipPort)) {
                    router.push(chatPage)
                    chat.ipPort = ipPort;

                }
            }

        }
    }

    Page {
        id: chatPage
        visible: false

        Chat {
            id: chat
            anchors.fill: parent
            model: messageModel
            onBack: {
                if(backend.isServer) {
                    backend.closeServer()
                } else {
                    backend.disconnectFromServer();
                }
                router.clear();
                router.push(mainMenuPage);
            }
            onSendMessage: (message) => {
                backend.sendMessage(message);
            }
        }
    }

    ListModel {
        id: messageModel
    }

    Backend {
        id: backend
        onNewMessage: (name, message) => {
            messageModel.append({"name":name, "message": message})
        }
        onConnectionError: {
            enterChat.connectionErrorVisible = true
        }
        onCloseSocketConnection: {
            router.clear();
            router.push(mainMenuPage);
        }
    }
}
