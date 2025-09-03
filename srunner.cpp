#include "srunner.h"

#include <QProcess>
#include <Windows.h>
#include <processthreadsapi.h>
#include <qdebug.h>

SRunner::SRunner(QObject *parent)
    : QObject{parent}
{}

void SRunner::runExeInCmd(const QString &exePath)
{
    qDebug() << "Executing:" << exePath;

    // Build the command: run EXE, print Complete, wait for key, then close CMD
    QString cmdLine = QString("/C \"%1 && echo Complete && pause\"").arg(exePath);

    // Convert to wide string
    std::wstring wcmdLine = cmdLine.toStdWString();

    STARTUPINFOW si = { sizeof(si) };
    PROCESS_INFORMATION pi = {};

    BOOL success = CreateProcessW(
        L"C:\\Windows\\System32\\cmd.exe", // Application = cmd.exe
        wcmdLine.data(),                   // Command line arguments
        nullptr,
        nullptr,
        FALSE,
        CREATE_NEW_CONSOLE,                // New console window
        nullptr,
        nullptr,
        &si,
        &pi
        );

    if (!success) {
        qDebug() << "Failed to launch CMD:" << GetLastError();
        return;
    }

    qDebug() << "CMD window launched";

    // Close handles (CMD process keeps running)
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
}


// void SRunner::runExe(const QString &exePath)
// {
//     qDebug() << "Executing:" << exePath;

//     // Build a command line: run your EXE, then echo Complete, then pause
//     QString command = QString("%1 && echo Complete && pause").arg(exePath);

//     // Start cmd.exe with /K to keep window open
//     QProcess::startDetached("cmd.exe", QStringList() << "/K" << command);

//     qDebug() << "CMD window launched";
//     emit finished();
// }
void SRunner::runExe(const QString &exePath)
{
    // Create a QProcess instance on the heap so it lives after this function
    QProcess *process = new QProcess(this);

    // Merge stdout and stderr so we can read all output
    process->setProcessChannelMode(QProcess::MergedChannels);

    // Connect signals to handle output and completion
    connect(process, &QProcess::readyReadStandardOutput, [process]() {
        QByteArray output = process->readAllStandardOutput();
        qDebug() << "Output:" << output;
    });

    connect(process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            [this, process](int exitCode, QProcess::ExitStatus exitStatus) {
                Q_UNUSED(exitStatus);
                qDebug() << "Process finished with code:" << exitCode;
                emit finished();          // Notify QML or other parts of app
                process->deleteLater();   // Clean up
            });

    // Start the process asynchronously
    process->start(exePath);

    if (!process->waitForStarted(1000)) { // just wait 1s to see if it started
        qDebug() << "Failed to start:" << exePath;
        process->deleteLater();
        return;
    }

    qDebug() << "Process started asynchronously";
}

