#include "Utils.h"
#include <QTextStream>
#include <QFile>
#include <QDebug>
#include <QUrl>
#include <QLocale>

Utils::Utils(QObject *parent)
    : QObject{parent}
{}

Utils *Utils::instance()
{
    static Utils instance;
    return &instance;
}

QString Utils::pixelFormatToString(QVideoFrameFormat::PixelFormat pixelFormat)
{
    return QVideoFrameFormat::pixelFormatToString(pixelFormat);

}

QString Utils::toFormattedString(const QCameraFormat &cameraFormat)
{
    QString string;
    QTextStream str(&string);
    str << QVideoFrameFormat::pixelFormatToString(cameraFormat.pixelFormat())
        << ' ' << cameraFormat.resolution().width()
        << 'x' << cameraFormat.resolution().height()
        << ' ' << cameraFormat.minFrameRate()
        << '-' << cameraFormat.maxFrameRate() << "FPS";
    return string;
}

QString Utils::getSizeOfFile(const QUrl &urlPath)
{

    QString filePath = urlPath.toLocalFile();
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly)) {
        qint64 size = file.size()/1024;
        file.close();
        QLocale::setDefault(QLocale(QLocale::English, QLocale::UnitedStates));
        QLocale aString;
        qDebug() << "The size of the file is" << aString.toString(size) << "kilo bytes";
        return aString.toString(size);
    } else {
        qDebug() << "Failed to open the file";
        return "";
    }
}

QString Utils::getFileName(const QUrl &urlPath)
{
    return urlPath.fileName();
}
