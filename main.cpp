#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "MousePositionProvider.h"
#include "SRunner.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Regi
    // Create an instance
    SRunner srunner;

    //ster our C++ class
    qmlRegisterType<MousePositionProvider>("com.SRunner", 1, 0, "MousePositionProvider");
    // qmlRegisterType<SRunner>("com.SRunner", 1, 0, "SRunner");

    // Expose it to QML
    engine.rootContext()->setContextProperty("srunner", &srunner);

    const QUrl url(u"qrc:/qt/qml/ScriptRunner/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
