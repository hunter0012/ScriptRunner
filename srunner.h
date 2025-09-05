#ifndef SRUNNER_H
#define SRUNNER_H

#include <QObject>
#include <QProcess>

class SRunner : public QObject
{
    Q_OBJECT

public:
    explicit SRunner(QObject *parent = nullptr);

    Q_INVOKABLE void runExe(const QString &path);
    Q_INVOKABLE void runExeInCmd(const QString &path);
    Q_INVOKABLE void runExeAsAdmin(const QString &path);
    Q_INVOKABLE void executeCommand(const QString &command);

signals:
    void executionStarted(const QString &command);
    void executionFinished(const QString &command, int exitCode);
    void executionError(const QString &command, const QString &error);

private:
    QProcess *m_process;
};

#endif // SRUNNER_H
