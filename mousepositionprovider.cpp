#include "MousePositionProvider.h"
#include <QCursor>
#include <QGuiApplication>
#include <QScreen>
#include <QTimer>

MousePositionProvider::MousePositionProvider(QObject *parent)
    : QObject(parent)
    , m_cursorPosition(QCursor::pos())
{
    // Set up timer to update cursor position periodically
    QTimer *timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &MousePositionProvider::updateCursorPosition);
    timer->start(16); // ~60 FPS
}

QPoint MousePositionProvider::cursorPosition() const
{
    return m_cursorPosition;
}

void MousePositionProvider::updateCursorPosition()
{
    QPoint newPos = QCursor::pos();
    if (m_cursorPosition != newPos) {
        m_cursorPosition = newPos;
        emit cursorPositionChanged(m_cursorPosition);
    }
}
