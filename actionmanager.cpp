#include "ActionManager.h"
#include <QFile>
#include <QJsonDocument>
#include <QDebug>
#include <QDir>
#include <QProcess>
#include <QCoreApplication>
#include <QRegularExpression>
#include <windows.h>


ActionManager::ActionManager(QObject *parent)
    : QObject(parent)
{
}

bool ActionManager::loadActions(const QString &filePath)
{
    QString actualPath = filePath;

    if (!QFile::exists(actualPath)) {
        QStringList possiblePaths = {
            QDir::currentPath() + "/" + filePath,
            QDir::currentPath() + "/qml/" + filePath,
            QCoreApplication::applicationDirPath() + "/" + filePath,
            QCoreApplication::applicationDirPath() + "/qml/" + filePath
        };

        for (const QString &path : possiblePaths) {
            if (QFile::exists(path)) {
                actualPath = path;
                break;
            }
        }
    }

    QFile file(actualPath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open actions file:" << actualPath;
        emit actionsLoaded(false);
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isNull() || !doc.isObject()) {
        qWarning() << "Invalid JSON format:" << actualPath;
        emit actionsLoaded(false);
        return false;
    }

    QJsonObject root = doc.object();
    if (!root.contains("actions") || !root["actions"].isArray()) {
        qWarning() << "No actions array found in JSON";
        emit actionsLoaded(false);
        return false;
    }

    m_allActions = root["actions"].toArray();
    parseActions(m_allActions);

    emit actionsLoaded(true);
    emit actionsChanged();
    qDebug() << "Actions loaded from" << actualPath;
    return true;
}

void ActionManager::parseActions(const QJsonArray &actions)
{
    m_categories.clear();

    for (const QJsonValue &value : actions) {
        if (!value.isObject()) continue;
        QJsonObject action = value.toObject();
        QString category = action.value("category").toString("tools");
        m_categories[category].append(action);
    }
}

QVariantMap ActionManager::categorizedActions() const
{
    QVariantMap map;
    for (auto it = m_categories.constBegin(); it != m_categories.constEnd(); ++it) {
        map[it.key()] = it.value().toVariantList();
    }
    return map;
}

QStringList  ActionManager::categoriesKeys() const
{
    return m_categories.keys();
}

QJsonObject ActionManager::getAction(const QString &actionId) const
{
    for (const QJsonValue &val : m_allActions) {
        if (!val.isObject()) continue;
        QJsonObject action = val.toObject();
        if (action.value("id").toString() == actionId) return action;
    }
    return QJsonObject();
}

void ActionManager::executeAction(const QString &actionId)
{
    QJsonObject action = getAction(actionId);
    if (action.isEmpty()) {
        qWarning() << "Action not found:" << actionId;
        emit actionExecuted(actionId, false);
        return;
    }

    // Check if action requires inputs
    if (action.contains("inputs") && action["inputs"].isArray()) {
        QJsonArray inputs = action["inputs"].toArray();
        if (!inputs.isEmpty()) {
            emit actionWithInputsRequired(actionId, inputs);
            return;
        }
    }

    // Execute simple action
    QString command = action.value("command").toString();
    QString type = action.value("type").toString();

    bool success = executeCommand(command, type, "");
    qDebug() << "Executed action:" << actionId << "success:" << success;
    emit actionExecuted(actionId, success);
}

void ActionManager::executeActionWithInputs(const QString &actionId, const QVariantMap &inputs)
{
    QJsonObject action = getAction(actionId);
    if (action.isEmpty()) {
        qWarning() << "Action not found:" << actionId;
        emit actionExecuted(actionId, false);
        return;
    }

    QString commandTemplate = action.value("command").toString();
    QString type = action.value("type").toString();

    // Build the final command by replacing placeholders
    // qWarning() << "inputs :" << inputs["file"];
    QString finalCommand = buildCommand(commandTemplate, inputs);
    qWarning() << "finalCommand :" << finalCommand;

    bool success = executeCommand(finalCommand, type, "\""+inputs["file"].toString()+"\"");
    qDebug() << "Executed action with inputs:" << actionId << "command:" << finalCommand << "success:" << success;
    emit actionExecuted(actionId, success);
}

void ActionManager::executeActionWithFile(const QString &actionId, const QString &filePath)
{
    QJsonObject action = getAction(actionId);
    if (action.isEmpty()) {
        qWarning() << "Action not found:" << actionId;
        emit actionExecuted(actionId, false);
        return;
    }

    QVariantMap inputs;
    inputs["file"] = filePath;

    // Check if there are other inputs needed
    if (action.contains("inputs") && action["inputs"].isArray()) {
        QJsonArray inputDefs = action["inputs"].toArray();
        bool hasOtherInputs = false;

        for (const QJsonValue &inputVal : inputDefs) {
            if (inputVal.isObject()) {
                QJsonObject input = inputVal.toObject();
                QString inputId = input.value("id").toString();
                if (inputId != "file") {
                    hasOtherInputs = true;
                    break;
                }
            }
        }

        if (hasOtherInputs) {
            // Show input dialog for other inputs
            emit actionWithInputsRequired(actionId, inputDefs);
            return;
        }
    }

    // Execute with just the file input
    executeActionWithInputs(actionId, inputs);
}

QString ActionManager::buildCommand(const QString &templateStr, const QVariantMap &inputs) const
{
    QString result = templateStr;

    // Replace placeholders like {variable}
    QRegularExpression re("\\{([^}]+)\\}");
    QRegularExpressionMatchIterator it = re.globalMatch(templateStr);

    while (it.hasNext()) {
        QRegularExpressionMatch match = it.next();
        QString placeholder = match.captured(1);
        QString value = inputs.value(placeholder).toString();

        // Handle special cases for boolean flags
        if (value == "true" || value == "false") {
            // Look for true_value and false_value in the input definition
            // This would require more context, so we'll handle it in the QML side
        }

        result.replace("{" + placeholder + "}", escapeArgument(value));
    }

    return result;
}

QString ActionManager::escapeArgument(const QString &arg) const
{
    if (arg.isEmpty()) return "\"\"";

    // Simple escaping - wrap in quotes if contains spaces
    if (arg.contains(' ') || arg.contains('\t')) {
        return "\"" + arg + "\"";
    }

    return arg;
}





























bool ActionManager::executeCommand(const QString &command, const QString &type, const QString &inputValue)
{
    if (command.isEmpty()) {
        qWarning() << "Empty command";
        return false;
    }

    qDebug() << "Executing command:" << command << "type:" << type << "input:" << inputValue;

    bool success = false;
    bool hasInput = !inputValue.isEmpty();

    if (type == "exe") {
        // Execute the command directly (for simple executables like calc.exe)
        // Input values are ignored for "exe" type since they don't expect arguments
        success = QProcess::startDetached(command);

    } else if (type == "exe_with_args") {
        if (hasInput) {
            // For actions with inputs, combine command with input value
            QString fullCommand = command;
            // Escape spaces in file paths
            QString escapedInput = inputValue;
            if (escapedInput.contains(" ")) {
                escapedInput = "\"" + escapedInput + "\"";
            }
            fullCommand += " " + escapedInput;
            success = QProcess::startDetached(fullCommand);
        } else {
            // No input provided, execute the command without arguments
            success = QProcess::startDetached(command);
        }

    } else if (type == "exe_in_cmd") {
        qDebug() << "try to open cmd window with command:" << command;

        // Use /k to keep open, then pause and close after key press
        QString fullCommand = QString("cmd.exe /k \"%1 && pause\"").arg(command);

        STARTUPINFO si;
        PROCESS_INFORMATION pi;
        ZeroMemory(&si, sizeof(si));
        si.cb = sizeof(si);
        ZeroMemory(&pi, sizeof(pi));

        wchar_t commandW[1024];
        fullCommand.toWCharArray(commandW);
        commandW[fullCommand.length()] = '\0';

        // Set success based on whether CreateProcess succeeds
        success = CreateProcessW(NULL, commandW, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi);

        if (success) {
            CloseHandle(pi.hProcess);
            CloseHandle(pi.hThread);
            qDebug() << "cmd.exe started successfully!";
        } else {
            qDebug() << "Failed to start cmd.exe. Error code:" << GetLastError();
        }
    }












    else if (type == "exe_admin") {
        QString fullCommand = command;
        if (hasInput) {
            fullCommand += " " + inputValue;
        }
        QStringList args;
        args << "-Command" << "Start-Process cmd -Verb RunAs -ArgumentList '/k " + fullCommand + "'";
        success = QProcess::startDetached("powershell.exe", args);

    } else {
        // Unknown type - show error and do nothing
        qWarning() << "Unknown execution type:" << type << "- command not executed";
        return false;
    }

    if (!success) {
        qWarning() << "Failed to execute command:" << command;
    }

    return success;
}
