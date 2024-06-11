#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QNetworkInterface>
#include <QHostAddress>
#include <QDebug>

class Backend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isServer READ isServer NOTIFY isServerChanged)
    Q_PROPERTY(QString serverIpPort READ serverIpPort NOTIFY serverIpPortChanged)

public:
    explicit Backend(QObject *parent = nullptr);
    Q_INVOKABLE void createServer(const QString &name, int port);
    Q_INVOKABLE bool connectToServer(const QString &name, const QString &ipPort);
    Q_INVOKABLE void sendMessage(const QString &message);
    Q_INVOKABLE void closeServer();
    Q_INVOKABLE void disconnectFromServer();
    bool isServer() const { return m_isServer; }
    QString serverIpPort() const;

signals:
    void newMessage(const QString &name, const QString &message);
    void isServerChanged();
    void serverIpPortChanged();
    void connectionError();
    void closeSocketConnection();

private slots:
    void onNewConnection();
    void onReadyRead();
    void onDisconnected();
    void onSocketError(QAbstractSocket::SocketError socketError);

private:
    QTcpServer *m_server;
    QTcpSocket *m_socket;
    QList<QTcpSocket*> m_clients;
    QString m_name;
    bool m_isServer;
};

#endif // BACKEND_H
