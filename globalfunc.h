#ifndef GLOBALFUNC_H
#define GLOBALFUNC_H

#include <QObject>
#include <QString>
#include <QJsonObject>
#include <QJsonArray>
#include <QDate>
#include <QVariantMap>
#include <QVariantList>
#include <QQmlEngine>
#include <QScreen>
#include <QGuiApplication>

class GlobalFunc : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QJsonObject vardata READ vardata WRITE setVardata NOTIFY vardataChanged FINAL)

public:
    explicit GlobalFunc(QObject *parent = nullptr);

    // JSON文件读取通用函数
    Q_INVOKABLE QJsonObject readJsonFile(const QString& filePath);

    // 写入JSON文件通用函数
    Q_INVOKABLE bool writeJsonFile(const QString& filePath, const QJsonObject& jsonObj);

    // 团队相关函数
    Q_INVOKABLE QVariantMap getTeams();
    Q_INVOKABLE QVariantList getTeamNames();  // 返回按JSON原始顺序的团队名称列表
    Q_INVOKABLE QVariantList getTeamMembers(const QString& teamName);

    // 分数相关函数
    Q_INVOKABLE bool addScore(const QString& memberName, const QDate& date = QDate::currentDate());
    Q_INVOKABLE bool removeScore(const QString& memberName, const QDate& date = QDate::currentDate());
    Q_INVOKABLE QVariantList getTodayScores();
    Q_INVOKABLE bool isMemberScored(const QString& memberName, const QDate& date = QDate::currentDate());

    // 配置相关函数
    // Q_INVOKABLE QVariantMap getConfig();
    // Q_INVOKABLE int getResolution();
    // Q_INVOKABLE double getScaleFactor();
    // Q_INVOKABLE bool shouldRunFullScreen();

    // 当前日期
    Q_INVOKABLE QString getCurrentDate();
    Q_INVOKABLE QString registerFont(QString fontPath);


    // 在GlobalFunc类中添加以下函数声明
    Q_INVOKABLE QJsonArray calculateScore(int days);

    QJsonObject vardata() const;
    void setVardata(const QJsonObject &newVardata);

signals:
    void scoreChanged();
    void vardataChanged();

private:
    QJsonObject m_vardata;
    QString m_teamFilePath;
    QString m_scoreFilePath;
    QString m_configFilePath;
};

#endif // GLOBALFUNC_H
