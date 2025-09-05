#include "ActionManager.h"
#include <QFile>
#include <QJsonDocument>
#include <QDebug>
#include <QDir>
#include <QProcess>
#include <QCoreApplication>

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

    QString command = action.value("command").toString();
    QString type = action.value("type").toString();

    bool success = false;

    if (type == "exe") {
        success = QProcess::startDetached(command);
    } else if (type == "exe_in_cmd") {
        QStringList args;
#ifdef Q_OS_WIN
        args << "/C" << command;
        success = QProcess::startDetached("cmd.exe", args);
#else
        args << "-c" << command;
        success = QProcess::startDetached("sh", args);
#endif
    } else if (type == "exe_admin") {
#ifdef Q_OS_WIN
        QString params = QString("/c start \"\" \"%1\"").arg(command);
        success = QProcess::startDetached("powershell.exe", QStringList() << params);
#else
        success = QProcess::startDetached(command);
#endif
    }

    qDebug() << "Executed action:" << actionId << "success:" << success;
    emit actionExecuted(actionId, success);
}

