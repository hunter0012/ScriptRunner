#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>
#include <QColor>

class SettingsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString screenEdge READ screenEdge WRITE setScreenEdge NOTIFY screenEdgeChanged)
    Q_PROPERTY(QColor dockedColor READ dockedColor WRITE setDockedColor NOTIFY dockedColorChanged)
    Q_PROPERTY(QColor expandedColor READ expandedColor WRITE setExpandedColor NOTIFY expandedColorChanged)
    Q_PROPERTY(int cornerRadius READ cornerRadius WRITE setCornerRadius NOTIFY cornerRadiusChanged)
    Q_PROPERTY(bool followMouse READ followMouse WRITE setFollowMouse NOTIFY followMouseChanged)
    Q_PROPERTY(qreal savedX READ savedX WRITE setSavedX NOTIFY savedXChanged)
    Q_PROPERTY(qreal savedY READ savedY WRITE setSavedY NOTIFY savedYChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);

    Q_INVOKABLE void loadSettings();
    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE int getEdgeOffset(const QString &edge);
    Q_INVOKABLE void setEdgeOffset(const QString &edge, int offset);

    // Saved position
    Q_INVOKABLE void setSavedX(qreal x);
    Q_INVOKABLE void setSavedY(qreal y);
    Q_INVOKABLE qreal savedX() const;
    Q_INVOKABLE qreal savedY() const;

    // Getters
    QString screenEdge() const;
    QColor dockedColor() const;
    QColor expandedColor() const;
    int cornerRadius() const;
    bool followMouse() const;

    // Setters
    Q_INVOKABLE void setScreenEdge(const QString &edge);
    void setDockedColor(const QColor &color);
    void setExpandedColor(const QColor &color);
    void setCornerRadius(int radius);
    void setFollowMouse(bool follow);

signals:
    void screenEdgeChanged();
    void dockedColorChanged();
    void expandedColorChanged();
    void cornerRadiusChanged();
    void followMouseChanged();
    void savedXChanged();
    void savedYChanged();
    void settingsLoaded();
    void settingsSaved();

private:
    QSettings m_settings;
    QString m_screenEdge;
    QColor m_dockedColor;
    QColor m_expandedColor;
    int m_cornerRadius;
    bool m_followMouse;
};

#endif // SETTINGSMANAGER_H
