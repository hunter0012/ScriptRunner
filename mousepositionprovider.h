#ifndef MOUSEPOSITIONPROVIDER_H
#define MOUSEPOSITIONPROVIDER_H

#include <QObject>
#include <QPoint>

class MousePositionProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QPoint cursorPosition READ cursorPosition NOTIFY cursorPositionChanged)

public:
    explicit MousePositionProvider(QObject *parent = nullptr);

    QPoint cursorPosition() const;

signals:
    void cursorPositionChanged(const QPoint &cursorPosition);

public slots:
    void updateCursorPosition();

private:
    QPoint m_cursorPosition;
};

#endif // MOUSEPOSITIONPROVIDER_H
