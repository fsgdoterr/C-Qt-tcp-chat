#include "backend.h"

Backend::Backend(QObject *parent) : QObject(parent), m_server(nullptr), m_socket(nullptr), m_isServer(false) {}

void Backend::createServer(const QString &name, int port)
{
    // If a server already exists, close and delete it.
    if (m_server) {
        m_server->close();
        delete m_server;
    }

    m_name = name;
    m_isServer = true;
    m_server = new QTcpServer(this);

    connect(m_server, &QTcpServer::newConnection, this, &Backend::onNewConnection);

    // Start listening on the specified port. Emit signals if successful.
    if (m_server->listen(QHostAddress::Any, port)) {
        emit isServerChanged();
        emit serverIpPortChanged();
    }
}

bool Backend::connectToServer(const QString &name, const QString &ipPort)
{
    // Split the ipPort string into IP address and port.
    QStringList parts = ipPort.split(":");
    if (parts.size() != 2) {
        qDebug() << "connecion error";
        emit connectionError();
        return false;
    }

    QString ip = parts[0];
    int port = parts[1].toInt();

    m_name = name;
    m_isServer = false;
    m_socket = new QTcpSocket(this);

    connect(m_socket, &QTcpSocket::readyRead, this, &Backend::onReadyRead);
    connect(m_socket, &QTcpSocket::disconnected, this, &Backend::onDisconnected);
    connect(m_socket, QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::errorOccurred), this, &Backend::onSocketError);

    qDebug() << "starting connection...";

    // Attempt to connect to the specified host and port.
    m_socket->connectToHost(ip, port);
    bool isConnected = m_socket->waitForConnected(3000);
    if(!isConnected) {
        qDebug() << "connecion error";
        emit connectionError();
    }
    return isConnected;
}

void Backend::sendMessage(const QString &message)
{
    QByteArray data = QString("%1: %2\n").arg(m_name, message).toUtf8();

    // If server, send message to all connected clients.
    if (m_isServer) {
        for (QTcpSocket *client : m_clients) {
            client->write(data);
        }
        emit newMessage(m_name, message);
    } else if (m_socket) {
        // If client, send message to the server.
        m_socket->write(data);
    }
}

void Backend::closeServer()
{
    // Close and delete the server, clear the client list, and update the server state.
    if (m_server) {
        m_server->close();
        qDeleteAll(m_clients);
        m_clients.clear();
        delete m_server;
        m_server = nullptr;
        emit isServerChanged();
    }
    m_isServer = false;
}

void Backend::disconnectFromServer()
{
    // Disconnect and delete the client socket.
    if (m_socket) {
        m_socket->disconnectFromHost();
        delete m_socket;
        m_socket = nullptr;
    }
}

void Backend::onDisconnected()
{
    qDebug() << "disconnected from server";
    emit closeSocketConnection();
}

void Backend::onSocketError(QAbstractSocket::SocketError socketError)
{
    qDebug() << "socket error occurred:" << socketError;
    emit closeSocketConnection();
}

void Backend::onNewConnection()
{
    qDebug() << "new connection";
    QTcpSocket *client = m_server->nextPendingConnection();
    connect(client, &QTcpSocket::readyRead, this, &Backend::onReadyRead);
    m_clients.append(client);
}

void Backend::onReadyRead()
{
    qDebug() << "ready to read some data...";
    QTcpSocket *senderSocket = qobject_cast<QTcpSocket*>(sender());
    if(!senderSocket) {
        qDebug() << "sender socket is null";
        return;
    }

    qDebug() << "Bytes available: " << senderSocket->bytesAvailable();

    // Read data from the socket line by line.
    while (senderSocket->canReadLine()) {
        QString line = QString::fromUtf8(senderSocket->readLine()).trimmed();

        int colonIndex = line.indexOf(':');
        if(colonIndex != -1) {
            QString name = line.left(colonIndex).trimmed();
            QString message = line.mid(colonIndex + 1).trimmed();

            emit newMessage(name, message);
        }

        // If server, relay the message to all connected clients.
        if(m_isServer) {
            QByteArray data = QString(line + "\n").toUtf8();

            qDebug() << "server sending message to clients...";

            for (QTcpSocket *client : m_clients) {
                client->write(data);
            }
        }
    }
}

QString Backend::serverIpPort() const
{
    // Return the server's IP address and port.
    if (!m_server) return QString();
    QString ipAddress;
    for (const QHostAddress &address : QNetworkInterface::allAddresses()) {
        if (address.protocol() == QAbstractSocket::IPv4Protocol && address != QHostAddress(QHostAddress::LocalHost)) {
            ipAddress = address.toString();
            break;
        }
    }
    return QString("%1:%2").arg(ipAddress).arg(m_server->serverPort());
}
