#ifndef ACTIONMANAGER_H
#define ACTIONMANAGER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QMap>

class ActionManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap categorizedActions READ categorizedActions NOTIFY actionsChanged)
    Q_PROPERTY(QStringList categoriesKeys READ categoriesKeys NOTIFY actionsChanged)

public:
    explicit ActionManager(QObject *parent = nullptr);

    Q_INVOKABLE bool loadActions(const QString &filePath = "actions.json");
    Q_INVOKABLE void executeAction(const QString &actionId);

    Q_INVOKABLE QJsonObject getAction(const QString &actionId) const;

    QVariantMap categorizedActions() const;
    QStringList  categoriesKeys() const;

signals:
    void actionsChanged();
    void actionExecuted(const QString &actionId, bool success);
    void actionsLoaded(bool success);

private:
    QJsonArray m_allActions;
    QMap<QString, QJsonArray> m_categories; // e.g., "tools" -> array of actions

    void parseActions(const QJsonArray &actions);
};

#endif // ACTIONMANAGER_H
