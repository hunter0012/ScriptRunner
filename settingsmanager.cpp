#include "SettingsManager.h"
#include <QDebug>
#include <QGuiApplication>

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent)
    , m_settings(QSettings::IniFormat, QSettings::UserScope,
                 QGuiApplication::organizationName(),
                 QGuiApplication::applicationName())
{
    // Default values
    m_screenEdge = "right";
    m_dockedColor = QColor("#3498DB");
    m_expandedColor = QColor("#2C3E50");
    m_cornerRadius = 4;
    m_followMouse = false;
}

void SettingsManager::loadSettings()
{
    m_settings.beginGroup("Window");
    m_screenEdge = m_settings.value("screenEdge", "right").toString();
    m_dockedColor = m_settings.value("dockedColor", QColor("#3498DB")).value<QColor>();
    m_expandedColor = m_settings.value("expandedColor", QColor("#2C3E50")).value<QColor>();
    m_cornerRadius = m_settings.value("cornerRadius", 4).toInt();
    m_followMouse = m_settings.value("followMouse", false).toBool();
    m_settings.endGroup();

    emit settingsLoaded();
    qDebug() << "Settings loaded from" << m_settings.fileName();
}

void SettingsManager::saveSettings()
{
    m_settings.beginGroup("Window");
    m_settings.setValue("screenEdge", m_screenEdge);
    m_settings.setValue("dockedColor", m_dockedColor);
    m_settings.setValue("expandedColor", m_expandedColor);
    m_settings.setValue("cornerRadius", m_cornerRadius);
    m_settings.setValue("followMouse", m_followMouse);
    m_settings.endGroup();
    m_settings.sync();

    emit settingsSaved();
    qDebug() << "Settings saved to" << m_settings.fileName();
}

int SettingsManager::getEdgeOffset(const QString &edge)
{
    m_settings.beginGroup("EdgePositions");
    int offset = m_settings.value(edge, 100).toInt(); // Default 100 pixels from top/left
    m_settings.endGroup();
    return offset;
}

void SettingsManager::setEdgeOffset(const QString &edge, int offset)
{
    m_settings.beginGroup("EdgePositions");
    m_settings.setValue(edge, offset);
    m_settings.endGroup();
}

// Saved position
void SettingsManager::setSavedX(qreal x)
{
    if (m_settings.value("Window/savedX", 0).toReal() != x) {
        m_settings.setValue("Window/savedX", x);
        emit savedXChanged();
    }
}

void SettingsManager::setSavedY(qreal y)
{
    if (m_settings.value("Window/savedY", 0).toReal() != y) {
        m_settings.setValue("Window/savedY", y);
        emit savedYChanged();
    }
}

qreal SettingsManager::savedX() const
{
    return m_settings.value("Window/savedX", 0).toReal();
}

qreal SettingsManager::savedY() const
{
    return m_settings.value("Window/savedY", 0).toReal();
}

// Getters
QString SettingsManager::screenEdge() const { return m_screenEdge; }
QColor SettingsManager::dockedColor() const { return m_dockedColor; }
QColor SettingsManager::expandedColor() const { return m_expandedColor; }
int SettingsManager::cornerRadius() const { return m_cornerRadius; }
bool SettingsManager::followMouse() const { return m_followMouse; }

// Setters
void SettingsManager::setScreenEdge(const QString &edge)
{
    if (m_screenEdge != edge) {
        m_screenEdge = edge;
        emit screenEdgeChanged();
    }
}

void SettingsManager::setDockedColor(const QColor &color)
{
    if (m_dockedColor != color) {
        m_dockedColor = color;
        emit dockedColorChanged();
    }
}

void SettingsManager::setExpandedColor(const QColor &color)
{
    if (m_expandedColor != color) {
        m_expandedColor = color;
        emit expandedColorChanged();
    }
}

void SettingsManager::setCornerRadius(int radius)
{
    if (m_cornerRadius != radius) {
        m_cornerRadius = radius;
        emit cornerRadiusChanged();
    }
}

void SettingsManager::setFollowMouse(bool follow)
{
    if (m_followMouse != follow) {
        m_followMouse = follow;
        emit followMouseChanged();
    }
}
