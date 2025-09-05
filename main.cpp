#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QDebug>
#include <QQuickStyle>
#include <QLibraryInfo>

#include "MousePositionProvider.h"
#include "SRunner.h"
#include "SettingsManager.h"
#include "ActionManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Application info
    app.setOrganizationName("ScriptRunner");
    app.setApplicationName("ScriptRunner");

    // Optional: set QQuick style
    QQuickStyle::setStyle("Basic");

    // Initialize managers
    SettingsManager settingsManager;
    ActionManager actionManager;

    settingsManager.loadSettings();

    // Load actions.json from the qml folder
    QString qmlFolder = QDir(QCoreApplication::applicationDirPath()).filePath("qml");
    QString actionsPath = QDir(qmlFolder).filePath("actions.json");

    if (!QFile::exists(actionsPath) || !actionManager.loadActions(actionsPath)) {
        qWarning() << "Failed to load actions from:" << actionsPath;
    }

    QQmlApplicationEngine engine;

    // C++ objects
    SRunner srunner;
    MousePositionProvider mouseProvider;

    // Register type
    qmlRegisterType<MousePositionProvider>("com.SRunner", 1, 0, "MousePositionProvider");

    // Expose objects to QML
    engine.rootContext()->setContextProperty("srunner", &srunner);
    engine.rootContext()->setContextProperty("mouseProvider", &mouseProvider);
    engine.rootContext()->setContextProperty("settingsManager", &settingsManager);
    engine.rootContext()->setContextProperty("actionManager", &actionManager);

    // Set import path to only qml folder next to exe
    engine.addImportPath(qmlFolder);

    // Load Main.qml from the qml folder
    QString mainQmlPath = QDir(qmlFolder).filePath("Main.qml");
    if (!QFile::exists(mainQmlPath)) {
        qCritical() << "Main.qml not found in:" << mainQmlPath;
        return -1;
    }

    engine.load(QUrl::fromLocalFile(mainQmlPath));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
