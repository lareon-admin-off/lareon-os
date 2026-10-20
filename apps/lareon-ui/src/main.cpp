// lareon-ui: the Lareon OS screens that aren't part of Plasma or the installer.
//
//   lareon-ui setup                              first-start setup (full screen)
//   lareon-ui install                            the Lareon OS installer (full screen)
//   lareon-ui install-failed --set log=FILE      "Lareon OS couldn't be installed"
//   lareon-ui home                               the Lareon launcher (search and all apps)
//   lareon-ui updates                            Software updates
//   lareon-ui settings [--set page=sound]        Lareon Settings
//   lareon-ui crash --set name=Files --set exe=/usr/bin/dolphin ...
//
// Options for testing:
//   --demo                 sample data; nothing on the computer is changed
//   --windowed             normal window instead of full screen
//   --page NAME            open the setup on a page (wifi, you, lareon, look, privacy, done)
//   --screenshot FILE.png  draw the screen once, save it, and quit (implies --demo)

#include <cstdio>

#include <QCommandLineParser>
#include <QGuiApplication>
#include <QImage>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QTimer>

#include "system.h"

int main(int argc, char *argv[])
{
    // Our own look everywhere: the plain Qt Quick Controls style, coloured by Theme.qml.
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");

    // Screenshot mode must decide its rendering before the app exists.
    for (int i = 1; i < argc; ++i) {
        if (qstrcmp(argv[i], "--screenshot") == 0) {
            qputenv("QT_QUICK_BACKEND", "software");
        }
    }

    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("lareon-ui"));
    QGuiApplication::setOrganizationName(QStringLiteral("Lareon"));
    QGuiApplication::setDesktopFileName(QStringLiteral("lareon-ui"));

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("Lareon OS screens"));
    parser.addHelpOption();
    parser.addPositionalArgument(QStringLiteral("mode"), QStringLiteral("setup, install-failed or crash"));
    const QCommandLineOption setOpt(QStringLiteral("set"), QStringLiteral("Pass key=value to the screen."), QStringLiteral("key=value"));
    const QCommandLineOption demoOpt(QStringLiteral("demo"), QStringLiteral("Use sample data and change nothing."));
    const QCommandLineOption windowedOpt(QStringLiteral("windowed"), QStringLiteral("Use a normal window."));
    const QCommandLineOption pageOpt(QStringLiteral("page"), QStringLiteral("Open on this page."), QStringLiteral("name"));
    const QCommandLineOption shotOpt(QStringLiteral("screenshot"), QStringLiteral("Save one frame to a PNG and quit."), QStringLiteral("file"));
    parser.addOptions({setOpt, demoOpt, windowedOpt, pageOpt, shotOpt});
    parser.process(app);

    const QStringList positional = parser.positionalArguments();
    const QString mode = positional.isEmpty() ? QStringLiteral("setup") : positional.first();
    if (mode != QLatin1String("setup") && mode != QLatin1String("install") && mode != QLatin1String("install-failed") && mode != QLatin1String("crash") && mode != QLatin1String("home") && mode != QLatin1String("updates") && mode != QLatin1String("settings")) {
        fprintf(stderr, "lareon-ui: unknown screen '%s'\n", qPrintable(mode));
        return 2;
    }

    QVariantMap args;
    for (const QString &kv : parser.values(setOpt)) {
        const int eq = kv.indexOf(QLatin1Char('='));
        if (eq > 0) {
            args.insert(kv.left(eq), kv.mid(eq + 1));
        }
    }

    const bool screenshot = parser.isSet(shotOpt);

    System sys;
    sys.setMode(mode);
    sys.setDemo(parser.isSet(demoOpt) || screenshot);
    sys.setWindowed(parser.isSet(windowedOpt) || screenshot || mode == QLatin1String("crash"));
    sys.setStartPage(parser.value(pageOpt));
    sys.setArgs(args);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("Sys"), &sys);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app, [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.loadFromModule("Lareon", "Main");
    if (engine.rootObjects().isEmpty()) {
        return 1;
    }

    if (screenshot) {
        auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst());
        if (!window) {
            return 1;
        }
        const QString file = parser.value(shotOpt);
        // Give images and fonts a moment to load, then save one frame.
        QTimer::singleShot(2000, &app, [window, file] {
            const QImage img = window->grabWindow();
            const bool ok = !img.isNull() && img.save(file);
            fprintf(stderr, ok ? "lareon-ui: saved %s\n" : "lareon-ui: could not save %s\n", qPrintable(file));
            QCoreApplication::exit(ok ? 0 : 1);
        });
    }

    return app.exec();
}
