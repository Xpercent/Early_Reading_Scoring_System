#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QUrl>
#include "GlobalFunc.h"
int main(int argc, char *argv[])
{
    // // 设置应用程序属性
    // QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    // QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // 注册C++类到QML
    GlobalFunc globalFunc;
    engine.rootContext()->setContextProperty("globalFunc", &globalFunc);
    globalFunc.registerFont("resources/remixicon.ttf");
    QJsonObject varobj = globalFunc.readJsonFile("resources/config.json");
    globalFunc.setVardata(varobj);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
        engine.load("page/Main.qml");

    return app.exec();
}
