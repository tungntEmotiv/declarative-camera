// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#if QT_CONFIG(permissions)
  #include <QPermission>
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QCoreApplication::setApplicationName("Camera Example");
    QCoreApplication::setOrganizationName("QtProject");
    QCoreApplication::setApplicationVersion("1.1.0");

    QQmlApplicationEngine engine;

#if defined (Q_OS_ANDROID)
    engine.rootContext()->setContextProperty("isAndroid", QVariant(true));
#else
    engine.rootContext()->setContextProperty("isAndroid", QVariant(false));
#endif
#if defined (Q_OS_IOS)
    engine.rootContext()->setContextProperty("isIOS", QVariant(true));
#else
    engine.rootContext()->setContextProperty("isIOS", QVariant(false));
#endif

#if defined (Q_OS_ANDROID) || defined (Q_OS_IOS)
    engine.rootContext()->setContextProperty("mobileUI", QVariant(true));
#else
    engine.rootContext()->setContextProperty("mobileUI", QVariant(false));
#endif

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));


#if QT_CONFIG(permissions)
    QCameraPermission cameraPermission;
    qApp->requestPermission(cameraPermission, [](const QPermission &permission) {
        // Show UI in any case. If there is no permission, the UI will just
        // be disabled.
        if (permission.status() != Qt::PermissionStatus::Granted)
            qWarning("Camera permission is not granted!");
    });
#endif

    return app.exec();
}
