TEMPLATE=app
TARGET=declarative-camera

QT += quick qml multimedia

SOURCES += main.cpp
RESOURCES += declarative-camera.qrc

target.path = $$[QT_INSTALL_EXAMPLES]/multimedia/declarative-camera
INSTALLS += target

ios{
    QMAKE_OBJECTIVE_CFLAGS += -fobjc-arc

    #change some config
    CONFIG -= bitcode
    QMAKE_RPATHDIR += @loader_path/Frameworks
    #only support iphone
    QMAKE_APPLE_TARGETED_DEVICE_FAMILY = 1
    QMAKE_INFO_PLIST = ios/Info.plist
}else:android{
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    DISTFILES += \
            android/AndroidManifest.xml \
            android/build.gradle \
            android/res/values/libs.xml
}

