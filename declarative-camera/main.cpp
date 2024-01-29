// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include "Utils.h"

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

    engine.rootContext()->setContextProperty("utils", Utils::instance());

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

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

#if QT_CONFIG(permissions)
    // If the permissions are not granted, display another main window, which
    // simply contains the error message.
    const QUrl noPermissionsUrl(QStringLiteral("qrc:/main_no_permissions.qml"));
    QCameraPermission cameraPermission;
    qApp->requestPermission(cameraPermission, [&](const QPermission &permission) {
        if (permission.status() != Qt::PermissionStatus::Granted) {
            qWarning("Camera permission is not granted!");
            engine.load(noPermissionsUrl);
            return;
        }
        QMicrophonePermission micPermission;
        qApp->requestPermission(micPermission, [&](const QPermission &permission) {
            if (permission.status() != Qt::PermissionStatus::Granted) {
                qWarning("Microphone permission is not granted!");
                engine.load(noPermissionsUrl);
            } else {
                engine.load(url);
            }
        });
    });
#else
    engine.load(url);
#endif

    return app.exec();
}
