#include "globalfunc.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QCoreApplication>
#include <QScreen>
#include <QGuiApplication>
#include <QDate>
#include <QMap>
#include <QVector>
#include <QFontDatabase>
GlobalFunc::GlobalFunc(QObject *parent)
    : QObject(parent)
    , m_teamFilePath(QCoreApplication::applicationDirPath() + "/resources/team.json")
    , m_scoreFilePath(QCoreApplication::applicationDirPath() + "/resources/score.json")
    , m_configFilePath(QCoreApplication::applicationDirPath() + "/resources/config.json")
{
}

// ... readJsonFile 和 writeJsonFile 函数保持不变 ...
QJsonObject GlobalFunc::readJsonFile(const QString& filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Cannot open file for reading:" << filePath;
        return QJsonObject();
    }
    QByteArray data = file.readAll();
    file.close();
    QJsonParseError parseError;
    QJsonDocument document = QJsonDocument::fromJson(data, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "Parse error:" << parseError.errorString();
        return QJsonObject();
    }
    return document.object();
}

bool GlobalFunc::writeJsonFile(const QString& filePath, const QJsonObject& jsonObj)
{
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Cannot open file for writing:" << filePath;
        return false;
    }
    QJsonDocument document(jsonObj);
    file.write(document.toJson());
    file.close();
    return true;
}


// --- [MODIFIED] ---
// 适配说明：
// 此函数现在读取 "teams" 数组，并遍历它来构建一个 QVariantMap。
// 这样做可以保持此函数的返回类型不变，从而让 getTeamMembers 函数无需任何修改即可继续工作。
QVariantMap GlobalFunc::getTeams()
{
    QJsonObject jsonObj = readJsonFile(m_teamFilePath);
    if (jsonObj.isEmpty() || !jsonObj.contains("teams") || !jsonObj["teams"].isArray()) {
        qWarning() << "team.json is invalid or 'teams' key is not an array.";
        return QVariantMap();
    }

    QVariantMap teamsMap;
    const QJsonArray teamsArray = jsonObj["teams"].toArray();

    for (const QJsonValue &teamValue : teamsArray) {
        const QJsonObject teamObject = teamValue.toObject();
        const QString teamName = teamObject["name"].toString();
        const QJsonArray membersArray = teamObject["members"].toArray();

        QVariantList membersList;
        for (const QJsonValue &memberValue : membersArray) {
            membersList.append(memberValue.toString());
        }

        if (!teamName.isEmpty()) {
            teamsMap[teamName] = membersList;
        }
    }

    return teamsMap;
}

// --- [MODIFIED] ---
QVariantList GlobalFunc::getTeamNames()
{
    QJsonObject jsonObj = readJsonFile(m_teamFilePath);
    if (jsonObj.isEmpty() || !jsonObj.contains("teams") || !jsonObj["teams"].isArray()) {
        qWarning() << "team.json is invalid or 'teams' key is not an array.";
        return QVariantList();
    }

    QVariantList teamNames;
    const QJsonArray teamsArray = jsonObj["teams"].toArray();

    for (const QJsonValue &teamValue : teamsArray) {
        const QJsonObject teamObject = teamValue.toObject();
        if (teamObject.contains("name")) {
            teamNames.append(teamObject["name"].toString());
        }
    }

    return teamNames;
}

// --- [UNCHANGED] ---
// 适配说明：此函数无需修改，因为它依赖于 getTeams() 的返回结果，而我们保持了 getTeams() 的返回类型。
QVariantList GlobalFunc::getTeamMembers(const QString& teamName)
{
    QVariantMap teams = getTeams();
    return teams.value(teamName).toList();
}


// --- [NEW IMPLEMENTATION] ---
// 适配说明：这是方案一中提供的 calculateScore 函数的最终实现。
QJsonArray GlobalFunc::calculateScore(int days)
{
    // 1. 数据读取
    QJsonObject teamData = readJsonFile(m_teamFilePath);
    QJsonObject scoreData = readJsonFile(m_scoreFilePath);

    if (!teamData.contains("teams") || !teamData["teams"].isArray() || scoreData.isEmpty()) {
        qWarning() << "Failed to read JSON files or 'teams' key is not an array in team.json.";
        return QJsonArray();
    }

    // 2. 日期范围确定
    QStringList datesToProcess;
    if (days == 0) {
        datesToProcess = scoreData.keys();
    } else {
        const QDate currentDate = QDate::currentDate();
        for (int i = 0; i < days; ++i) {
            datesToProcess.append(currentDate.addDays(-i).toString("yyyy-MM-dd"));
        }
    }

    // 3. 得分统计 (使用 Map 实现高效查找)
    QMap<QString, QJsonObject> memberStats;

    // 3.1 初始化所有成员信息，此时顺序是正确的
    const QJsonArray teamsArray = teamData["teams"].toArray();
    QList<QString> orderedMembers; // 用于保持最终输出的顺序
    for (const QJsonValue &teamValue : teamsArray) {
        const QJsonObject teamObject = teamValue.toObject();
        const QString teamName = teamObject["name"].toString();
        const QJsonArray membersArray = teamObject["members"].toArray();

        for (const QJsonValue &memberValue : membersArray) {
            QString memberName = memberValue.toString();
            if (!memberName.isEmpty()) {
                orderedMembers.append(memberName);
                memberStats[memberName] = QJsonObject{
                    {"name", memberName},
                    {"team", teamName},
                    {"count", 0}
                };
            }
        }
    }

    // 3.2 遍历日期，累加得分
    for (const QString &dateStr : datesToProcess) {
        if (scoreData.contains(dateStr)) {
            const QJsonArray dailyScorers = scoreData[dateStr].toArray();
            for (const QJsonValue &scorerValue : dailyScorers) {
                QString scorerName = scorerValue.toString();
                auto it = memberStats.find(scorerName);
                if (it != memberStats.end()) {
                    it.value()["count"] = it.value()["count"].toInt() + 1;
                }
            }
        }
    }

    // 4. 结果输出 (按照原始文件顺序)
    QJsonArray finalResult;
    for (const QString &memberName : orderedMembers) {
        const auto& stat = memberStats.value(memberName);
        if (stat["count"].toInt() > 0) {
            finalResult.append(stat);
        }
    }

    return finalResult;
}


// ... 所有其他函数 (addScore, removeScore, getTodayScores, etc.) 保持不变 ...
// ... 因为它们只与 score.json 和 config.json 交互，不受 team.json 结构变化的影响。

bool GlobalFunc::addScore(const QString& memberName, const QDate& date)
{
    QJsonObject jsonObj = readJsonFile(m_scoreFilePath);
    QString dateStr = date.toString("yyyy-MM-dd");
    QJsonArray scoresArray = jsonObj.value(dateStr).toArray();

    for (const QJsonValue& value : scoresArray) {
        if (value.toString() == memberName) {
            return false; // 已存在
        }
    }

    scoresArray.append(memberName);
    jsonObj[dateStr] = scoresArray;

    bool success = writeJsonFile(m_scoreFilePath, jsonObj);
    if (success) {
        emit scoreChanged();
    }
    return success;
}

bool GlobalFunc::removeScore(const QString& memberName, const QDate& date)
{
    QJsonObject jsonObj = readJsonFile(m_scoreFilePath);
    QString dateStr = date.toString("yyyy-MM-dd");

    if (!jsonObj.contains(dateStr)) {
        return false;
    }

    QJsonArray scoresArray = jsonObj[dateStr].toArray();
    QJsonArray newArray;
    bool found = false;
    for (const QJsonValue& value : scoresArray) {
        if (value.toString() != memberName) {
            newArray.append(value);
        } else {
            found = true;
        }
    }

    if (!found) {
        return false;
    }

    if (newArray.isEmpty()) {
        jsonObj.remove(dateStr);
    } else {
        jsonObj[dateStr] = newArray;
    }

    bool success = writeJsonFile(m_scoreFilePath, jsonObj);
    if (success) {
        emit scoreChanged();
    }
    return success;
}

QVariantList GlobalFunc::getTodayScores()
{
    QJsonObject jsonObj = readJsonFile(m_scoreFilePath);
    QString today = QDate::currentDate().toString("yyyy-MM-dd");
    QVariantList scores;
    QJsonArray scoresArray = jsonObj.value(today).toArray();
    for (const QJsonValue& value : scoresArray) {
        scores.append(value.toString());
    }
    return scores;
}

bool GlobalFunc::isMemberScored(const QString& memberName, const QDate& date)
{
    QJsonObject jsonObj = readJsonFile(m_scoreFilePath);
    QString dateStr = date.toString("yyyy-MM-dd");
    QJsonArray scoresArray = jsonObj.value(dateStr).toArray();
    for (const QJsonValue& value : scoresArray) {
        if (value.toString() == memberName) {
            return true;
        }
    }
    return false;
}

// QVariantMap GlobalFunc::getConfig()
// {
//     QJsonObject jsonObj = readJsonFile(m_configFilePath);
//     return jsonObj.toVariantMap();
// }

// int GlobalFunc::getResolution()
// {
//     QVariantMap config = getConfig();
//     return config.value("resolution", 1920).toInt();
// }

// double GlobalFunc::getScaleFactor()
// {
//     int configResolution = getResolution();
//     return static_cast<double>(configResolution) / 1920.0;
// }

// bool GlobalFunc::shouldRunFullScreen()
// {
//     int configResolution = getResolution();
//     QScreen* screen = QGuiApplication::primaryScreen();
//     if (!screen) {
//         return false;
//     }
//     int screenWidth = screen->geometry().width();
//     return configResolution == screenWidth;
// }

QString GlobalFunc::getCurrentDate()
{
    return QDate::currentDate().toString("yyyy-MM-dd");
}

QString GlobalFunc::registerFont(QString fontPath) {
    int id = QFontDatabase::addApplicationFont(fontPath);
    if (id != -1) {
        QString family = QFontDatabase::applicationFontFamilies(id).at(0);
        qDebug() << "Loaded font family:" << family;
        return family;
    } else {
        qWarning() << "Failed to load font:" << fontPath;
        return QString();
    }
}

QJsonObject GlobalFunc::vardata() const
{
    return m_vardata;
}
void GlobalFunc::setVardata(const QJsonObject &newVardata)
{
    if (m_vardata == newVardata)
        return;
    m_vardata = newVardata;
    emit vardataChanged();
}
