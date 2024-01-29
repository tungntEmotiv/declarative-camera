#ifndef UTILS_H
#define UTILS_H

#include <QObject>
#include <QVideoFrameFormat>
#include <QCameraFormat>

class Utils : public QObject
{
    Q_OBJECT
public:
    explicit Utils(QObject *parent = nullptr);

    static Utils *instance();

public slots:
    static QString pixelFormatToString(QVideoFrameFormat::PixelFormat pixelFormat);
    static QString toFormattedString(const QCameraFormat &cameraFormat);
    static QString getSizeOfFile(const QUrl &urlPath);
    static QString getFileName(const QUrl &urlPath);
};

#endif // UTILS_H
