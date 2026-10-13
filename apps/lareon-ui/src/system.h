// Small bridge between the Lareon screens (QML) and the system.
#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantMap>

class System : public QObject
{
    Q_OBJECT
    // which screen to show: "setup", "install-failed" or "crash"
    Q_PROPERTY(QString mode READ mode CONSTANT)
    // demo mode: sample data, nothing on the system is changed (used for screenshots)
    Q_PROPERTY(bool demo READ demo CONSTANT)
    // run in a normal window instead of full screen
    Q_PROPERTY(bool windowed READ windowed CONSTANT)
    // page to open first (setup screenshots: "wifi", "you", "lareon", "look", "privacy", "done")
    Q_PROPERTY(QString startPage READ startPage CONSTANT)
    // --set key=value pairs from the command line
    Q_PROPERTY(QVariantMap args READ args CONSTANT)

public:
    explicit System(QObject *parent = nullptr);

    QString mode() const { return m_mode; }
    bool demo() const { return m_demo; }
    bool windowed() const { return m_windowed; }
    QString startPage() const { return m_startPage; }
    QVariantMap args() const { return m_args; }

    void setMode(const QString &m) { m_mode = m; }
    void setDemo(bool d) { m_demo = d; }
    void setWindowed(bool w) { m_windowed = w; }
    void setStartPage(const QString &p) { m_startPage = p; }
    void setArgs(const QVariantMap &a) { m_args = a; }

    // Start a program without waiting. Result arrives in finished(id, ...).
    // `input` is written to the program's stdin (used for passwords, so they
    // never appear in a process list).
    Q_INVOKABLE int run(const QString &program, const QStringList &arguments, const QString &input = QString());
    // Start a program and forget about it (e.g. reopen a crashed app).
    Q_INVOKABLE bool startDetached(const QString &program, const QStringList &arguments = {});

    Q_INVOKABLE QString readFile(const QString &path) const;
    Q_INVOKABLE bool writeFile(const QString &path, const QString &text) const;
    Q_INVOKABLE bool exists(const QString &path) const;
    Q_INVOKABLE QStringList listFiles(const QString &dir, const QStringList &nameFilters) const;
    Q_INVOKABLE QString homePath() const;
    Q_INVOKABLE QString env(const QString &name) const;

    // Time zones from the system's zone1970.tab, sorted by name.
    Q_INVOKABLE QStringList timeZones() const;

    Q_INVOKABLE void copyText(const QString &text) const;
    Q_INVOKABLE void quit(int code = 0) const;

Q_SIGNALS:
    void finished(int id, int exitCode, const QString &out, const QString &err);

private:
    QString m_mode;
    bool m_demo = false;
    bool m_windowed = false;
    QString m_startPage;
    QVariantMap m_args;
    int m_nextId = 1;
};
