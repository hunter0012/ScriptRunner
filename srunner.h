#ifndef SRUNNER_H
#define SRUNNER_H

#include <QObject>

class SRunner : public QObject
{
    Q_OBJECT
public:
    explicit SRunner(QObject *parent = nullptr);


    // Make this function callable from QML
    Q_INVOKABLE void runExe(const QString &exePath);
    Q_INVOKABLE void runExeInCmd(const QString &exePath);
    Q_INVOKABLE void runExeAsAdmin(const QString &exePath);
signals:
    void finished(); // optional signal to notify QML when done
};

#endif // SRUNNER_H
