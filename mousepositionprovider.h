#ifndef MOUSEPOSITIONPROVIDER_H
#define MOUSEPOSITIONPROVIDER_H

#include <QObject>
#include <QPoint>
#include <QTimer>
#include <Windows.h>

class MousePositionProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QPoint cursorPosition READ cursorPosition NOTIFY cursorPositionChanged)

public:
    explicit MousePositionProvider(QObject *parent = nullptr) : QObject(parent)
    {
        // Set up timer to poll mouse position
        m_timer = new QTimer(this);
        connect(m_timer, &QTimer::timeout, this, &MousePositionProvider::updateCursorPosition);
        m_timer->start(16); // ~60 FPS
    }

    QPoint cursorPosition() const { return m_cursorPosition; }

signals:
    void cursorPositionChanged(QPoint cursorPosition);

private slots:
    void updateCursorPosition()
    {
        POINT point;
        if (GetCursorPos(&point))
        {
            QPoint newPosition(point.x, point.y);
            if (newPosition != m_cursorPosition)
            {
                m_cursorPosition = newPosition;
                emit cursorPositionChanged(m_cursorPosition);
            }
        }
    }

private:
    QTimer *m_timer;
    QPoint m_cursorPosition;
};

#endif // MOUSEPOSITIONPROVIDER_H
