#include "SRunner.h"
#include <QDebug>
#include <QDir>

#ifdef Q_OS_WIN
#include <windows.h>
#include <shellapi.h>
#endif

SRunner::SRunner(QObject *parent)
    : QObject(parent)
    , m_process(new QProcess(this))
{
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            [this](int exitCode, QProcess::ExitStatus exitStatus) {
                QString command = m_process->program() + " " + m_process->arguments().join(" ");
                emit executionFinished(command, exitCode);
            });

    connect(m_process, &QProcess::errorOccurred,
            [this](QProcess::ProcessError error) {
                QString command = m_process->program() + " " + m_process->arguments().join(" ");
                emit executionError(command, m_process->errorString());
            });
}

void SRunner::runExe(const QString &path)
{
    QString cleanedPath = path.trimmed();
    if (cleanedPath.isEmpty()) {
        emit executionError(path, "Empty path provided");
        return;
    }

    emit executionStarted(cleanedPath);

    if (!QFile::exists(cleanedPath)) {
        emit executionError(cleanedPath, "File does not exist");
        return;
    }

    m_process->start(cleanedPath, QStringList());
}

void SRunner::runExeInCmd(const QString &path)
{
    QString cleanedPath = path.trimmed();
    if (cleanedPath.isEmpty()) {
        emit executionError(path, "Empty path provided");
        return;
    }

    emit executionStarted(cleanedPath);

    if (!QFile::exists(cleanedPath)) {
        emit executionError(cleanedPath, "File does not exist");
        return;
    }

#ifdef Q_OS_WIN
    QString command = "cmd.exe";
    QStringList arguments;
    arguments << "/c" << "start" << "\"\"";

    // Extract directory and filename
    QFileInfo fileInfo(cleanedPath);
    QString directory = fileInfo.absolutePath();
    QString filename = fileInfo.fileName();

    arguments << filename;

    m_process->setWorkingDirectory(directory);
    m_process->start(command, arguments);
#else
    // For non-Windows systems, use xterm or similar
    m_process->start("xterm", QStringList() << "-e" << cleanedPath);
#endif
}

void SRunner::runExeAsAdmin(const QString &path)
{
    QString cleanedPath = path.trimmed();
    if (cleanedPath.isEmpty()) {
        emit executionError(path, "Empty path provided");
        return;
    }

    emit executionStarted(cleanedPath);

    if (!QFile::exists(cleanedPath)) {
        emit executionError(cleanedPath, "File does not exist");
        return;
    }

#ifdef Q_OS_WIN
    // Use ShellExecute to run as admin on Windows
    HINSTANCE result = ShellExecuteW(
        NULL,
        L"runas",
        reinterpret_cast<const WCHAR*>(cleanedPath.utf16()),
        NULL,
        NULL,
        SW_SHOWNORMAL
        );

    // Fix: Use proper pointer comparison instead of casting to int
    if (reinterpret_cast<intptr_t>(result) <= 32) {
        emit executionError(cleanedPath, "Failed to execute as administrator");
    }
#else
    // For Linux/macOS, use pkexec or sudo (this is simplified)
    m_process->start("pkexec", QStringList() << cleanedPath);
#endif
}

void SRunner::executeCommand(const QString &command)
{
    QString cleanedCommand = command.trimmed();
    if (cleanedCommand.isEmpty()) {
        emit executionError(command, "Empty command provided");
        return;
    }

    emit executionStarted(cleanedCommand);

#ifdef Q_OS_WIN
    m_process->start("cmd.exe", QStringList() << "/c" << cleanedCommand);
#else
    m_process->start("sh", QStringList() << "-c" << cleanedCommand);
#endif
}
