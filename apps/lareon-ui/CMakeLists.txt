cmake_minimum_required(VERSION 3.21)
project(lareon-ui VERSION 0.1.0 LANGUAGES CXX)

# Lareon OS screens: first-start setup, "couldn't be installed", crash dialog.
# Built against Debian 13's Qt 6 (qt6-base-dev, qt6-declarative-dev).

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Qml Quick)
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(lareon-ui
    src/main.cpp
    src/system.cpp
    src/system.h
)

set_source_files_properties(Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(lareon-ui
    URI Lareon
    VERSION 1.0
    QML_FILES
        Main.qml
        Theme.qml
        LButton.qml
        LField.qml
        LToggle.qml
        LRadio.qml
        LCard.qml
        LIcon.qml
        StepBar.qml
        TopBar.qml
        Scene.qml
        SetupFlow.qml
        PageWifi.qml
        PageYou.qml
        PageLareon.qml
        PageLook.qml
        PagePrivacy.qml
        PageDone.qml
        InstallFailed.qml
        CrashDialog.qml
)

target_link_libraries(lareon-ui PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick)

install(TARGETS lareon-ui RUNTIME DESTINATION bin)
