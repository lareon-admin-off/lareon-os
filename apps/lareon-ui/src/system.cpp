#include "system.h"

#include <QClipboard>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QProcess>
#include <QStandardPaths>
#include <QTextStream>

System::System(QObject *parent)
    : QObject(parent)
{
}

int System::run(const QString &program, const QStringList &arguments, const QString &input)
{
    const int id = m_nextId++;
    auto *p = new QProcess(this);
    p->setProgram(program);
    p->setArguments(arguments);
    connect(p, &QProcess::finished, this, [this, p, id](int code, QProcess::ExitStatus status) {
        const QString out = QString::fromUtf8(p->readAllStandardOutput());
        const QString err = QString::fromUtf8(p->readAllStandardError());
        Q_EMIT finished(id, status == QProcess::NormalExit ? code : 255, out, err);
        p->deleteLater();
    });
    connect(p, &QProcess::errorOccurred, this, [this, p, id](QProcess::ProcessError e) {
        if (e == QProcess::FailedToStart) {
            Q_EMIT finished(id, 127, QString(), p->errorString());
            p->deleteLater();
        }
    });
    p->start();
    if (!input.isNull()) {
        p->write(input.toUtf8());
    }
    p->closeWriteChannel();
    return id;
}

bool System::startDetached(const QString &program, const QStringList &arguments)
{
    return QProcess::startDetached(program, arguments);
}

QString System::readFile(const QString &path) const
{
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return QString();
    }
    return QString::fromUtf8(f.readAll());
}

bool System::writeFile(const QString &path, const QString &text) const
{
    QFile f(path);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
        return false;
    }
    return f.write(text.toUtf8()) >= 0;
}

bool System::exists(const QString &path) const
{
    return QFile::exists(path);
}

QStringList System::listFiles(const QString &dir, const QStringList &nameFilters) const
{
    QStringList out;
    const QDir d(dir);
    const auto names = d.entryList(nameFilters, QDir::Files | QDir::Readable, QDir::Name);
    for (const QString &n : names) {
        out << d.absoluteFilePath(n);
    }
    return out;
}

QString System::homePath() const
{
    return QDir::homePath();
}

QString System::env(const QString &name) const
{
    return qEnvironmentVariable(name.toUtf8().constData());
}

QStringList System::timeZones() const
{
    QStringList zones;
    for (const char *tab : {"/usr/share/zoneinfo/zone1970.tab", "/usr/share/zoneinfo/zone.tab"}) {
        QFile f(QString::fromLatin1(tab));
        if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
            continue;
        }
        QTextStream in(&f);
        while (!in.atEnd()) {
            const QString line = in.readLine();
            if (line.startsWith(QLatin1Char('#'))) {
                continue;
            }
            const QStringList parts = line.split(QLatin1Char('\t'));
            if (parts.size() >= 3 && !zones.contains(parts.at(2))) {
                zones << parts.at(2);
            }
        }
        if (!zones.isEmpty()) {
            break;
        }
    }
    if (!zones.contains(QStringLiteral("UTC"))) {
        zones << QStringLiteral("UTC");
    }
    zones.sort();
    return zones;
}

void System::copyText(const QString &text) const
{
    if (auto *cb = QGuiApplication::clipboard()) {
        cb->setText(text);
    }
}

void System::quit(int code) const
{
    QCoreApplication::exit(code);
}
