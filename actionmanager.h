#ifndef ACTIONMANAGER_H
#define ACTIONMANAGER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QMap>
#include <QVariantMap>

class ActionManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap categorizedActions READ categorizedActions NOTIFY actionsChanged)
    Q_PROPERTY(QStringList categoriesKeys READ categoriesKeys NOTIFY actionsChanged)

public:
    explicit ActionManager(QObject *parent = nullptr);

    Q_INVOKABLE bool loadActions(const QString &filePath = "actions.json");
    Q_INVOKABLE void executeAction(const QString &actionId);
    Q_INVOKABLE void executeActionWithInputs(const QString &actionId, const QVariantMap &inputs);
    Q_INVOKABLE void executeActionWithFile(const QString &actionId, const QString &filePath);

    Q_INVOKABLE QJsonObject getAction(const QString &actionId) const;

    QVariantMap categorizedActions() const;
    QStringList  categoriesKeys() const;

signals:
    void actionsChanged();
    void actionExecuted(const QString &actionId, bool success);
    void actionsLoaded(bool success);
    void actionWithInputsRequired(const QString &actionId, const QJsonArray &inputs);

private:
    QJsonArray m_allActions;
    QMap<QString, QJsonArray> m_categories;

    void parseActions(const QJsonArray &actions);
    QString buildCommand(const QString &templateStr, const QVariantMap &inputs) const;
    QString escapeArgument(const QString &arg) const;
    bool executeCommand(const QString &command, const QString &type, const QString &inputValue);
};

#endif // ACTIONMANAGER_H
