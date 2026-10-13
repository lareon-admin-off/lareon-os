/*
    Lareon OS shut-down screen.

    Based on Plasma 6.3's Breeze Logout.qml (plasma-workspace,
    lookandfeel/org.kde.breeze/contents/logout/Logout.qml):
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
    SPDX-License-Identifier: GPL-2.0-or-later

    Same signals, properties and behaviour as Plasma's; only the look changed:
    round buttons, Lareon colours and type, a countdown with "Cancel" and a
    "… now" button.
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.sessions
import "timer.js" as AutoTriggerTimer

Item {
    id: root
    height: screenGeometry.height
    width: screenGeometry.width

    signal logoutRequested()
    signal haltRequested()
    signal haltUpdateRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal rebootUpdateRequested()
    signal cancelRequested()
    signal lockScreenRequested()
    signal cancelSoftwareUpdateRequested()

    property alias backgroundColor: backgroundRect.color

    function sleepRequested() {
        root.suspendRequested(2);
    }

    function hibernateRequested() {
        root.suspendRequested(4);
    }

    property real timeout: 30
    property real remainingTime: root.timeout

    property var currentAction: {
        switch (sdtype) {
        case ShutdownType.ShutdownTypeReboot:
            return () => softwareUpdatePending ? rebootUpdateRequested() : rebootRequested();
        case ShutdownType.ShutdownTypeHalt:
            return () => softwareUpdatePending ? haltUpdateRequested() : haltRequested();
        default:
            return () => logoutRequested();
        }
    }

    readonly property bool showAllOptions: sdtype === ShutdownType.ShutdownTypeDefault

    // which round button is highlighted (Lareon: the action that will happen)
    property string chosen: sdtype === ShutdownType.ShutdownTypeReboot ? "restart"
                          : sdtype === ShutdownType.ShutdownTypeNone ? "signout" : "shutdown"

    SessionsModel {
        id: sessionsModel
        includeUnusedSessions: false
    }

    QQC2.Action {
        onTriggered: root.cancelRequested()
        shortcut: "Escape"
    }

    onRemainingTimeChanged: {
        if (remainingTime <= 0) {
            (currentAction)();
        }
    }

    Timer {
        id: countDownTimer
        running: !showAllOptions
        repeat: true
        interval: 1000
        onTriggered: remainingTime--
        Component.onCompleted: {
            AutoTriggerTimer.addCancelAutoTriggerCallback(function() {
                countDownTimer.running = false;
            });
        }
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: "#13111b"
        opacity: 0.82
    }
    MouseArea {
        anchors.fill: parent
        onClicked: cancelRequested()
    }

    // one round Lareon button
    component RoundButton: Item {
        id: rb
        property string label
        property string iconName
        property bool highlighted: false
        signal activated()
        implicitWidth: 130
        implicitHeight: 92 + 14 + labelText.implicitHeight
        activeFocusOnTab: true
        Keys.onPressed: AutoTriggerTimer.cancelAutoTrigger()
        Keys.onReturnPressed: rb.activated()
        Keys.onEnterPressed: rb.activated()
        Keys.onSpacePressed: rb.activated()

        Rectangle {
            id: circle
            width: 92
            height: 92
            radius: 46
            anchors.horizontalCenter: parent.horizontalCenter
            color: rb.highlighted ? Qt.rgba(1, 0.486, 0.122, 0.22) : Qt.rgba(0.129, 0.118, 0.176, 0.7)
            border.width: rb.highlighted || rb.activeFocus ? 2 : 1
            border.color: rb.highlighted || rb.activeFocus ? "#ff7c1f" : Qt.rgba(1, 1, 1, 0.12)
            Rectangle {
                visible: rb.highlighted
                anchors.centerIn: parent
                width: parent.width + 12
                height: parent.height + 12
                radius: width / 2
                color: "transparent"
                border.width: 6
                border.color: Qt.rgba(1, 0.486, 0.122, 0.12)
            }
            Kirigami.Icon {
                anchors.centerIn: parent
                width: 36
                height: 36
                source: rb.iconName
                color: "#ece9f5"
                isMask: true
            }
        }
        Text {
            id: labelText
            anchors.top: circle.bottom
            anchors.topMargin: 14
            anchors.horizontalCenter: parent.horizontalCenter
            text: rb.label
            color: rb.highlighted ? "#ffffff" : Qt.rgba(0.925, 0.914, 0.961, 0.9)
            font.family: "Geist"
            font.pixelSize: 15
            font.weight: rb.highlighted ? Font.DemiBold : Font.Normal
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: AutoTriggerTimer.cancelAutoTrigger()
            onClicked: rb.activated()
        }
    }

    component PillButton: QQC2.Button {
        id: pb
        property bool primary: false
        implicitHeight: 40
        leftPadding: 20
        rightPadding: 20
        hoverEnabled: true
        contentItem: Text {
            text: pb.text
            color: pb.primary ? "#13111b" : "#ece9f5"
            font.family: "Geist"
            font.pixelSize: 14.5
            font.weight: pb.primary ? Font.DemiBold : Font.Medium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 9
            color: pb.primary ? (pb.hovered ? "#ff8f3d" : "#ff7c1f") : (pb.hovered ? "#2b2838" : "#211e2d")
            border.width: pb.primary ? 0 : 1
            border.color: "#2b2838"
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 36

            RoundButton {
                label: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Sleep")
                iconName: "system-suspend"
                visible: spdMethods.SuspendState && root.showAllOptions
                onActivated: sleepRequested()
            }
            RoundButton {
                label: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Hibernate")
                iconName: "system-suspend-hibernate"
                visible: spdMethods.HibernateState && root.showAllOptions
                onActivated: hibernateRequested()
            }
            RoundButton {
                label: softwareUpdatePending ? i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "@action:button Keep short", "Install Updates and Restart")
                                             : i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                iconName: softwareUpdatePending ? "system-reboot-update" : "system-reboot"
                highlighted: root.chosen === "restart"
                visible: maysd && (sdtype === ShutdownType.ShutdownTypeReboot || root.showAllOptions)
                onActivated: softwareUpdatePending ? rebootUpdateRequested() : rebootRequested()
            }
            RoundButton {
                label: softwareUpdatePending ? i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "@action:button Keep short", "Install Updates and Shut Down")
                                             : i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                iconName: softwareUpdatePending ? "system-shutdown-update" : "system-shutdown"
                highlighted: root.chosen === "shutdown"
                focus: sdtype === ShutdownType.ShutdownTypeHalt || root.showAllOptions
                visible: maysd && (sdtype === ShutdownType.ShutdownTypeHalt || root.showAllOptions)
                onActivated: softwareUpdatePending ? haltUpdateRequested() : haltRequested()
            }
            RoundButton {
                label: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log Out")
                iconName: "system-log-out"
                highlighted: root.chosen === "signout"
                visible: canLogout && (sdtype === ShutdownType.ShutdownTypeNone || root.showAllOptions)
                onActivated: logoutRequested()
            }
        }

        Text {
            Layout.topMargin: 44
            Layout.alignment: Qt.AlignHCenter
            visible: countDownTimer.running
            text: {
                switch (sdtype) {
                case ShutdownType.ShutdownTypeReboot:
                    return softwareUpdatePending ? i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Installing software updates and restarting in 1 second", "Installing software updates and restarting in %1 seconds", root.remainingTime)
                    : i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Restarting in 1 second", "Restarting in %1 seconds", root.remainingTime);
                case ShutdownType.ShutdownTypeNone:
                    return i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Logging out in 1 second", "Logging out in %1 seconds", root.remainingTime);
                case ShutdownType.ShutdownTypeHalt:
                default:
                    return softwareUpdatePending ? i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Installing software updates and shutting down in 1 second", "Installing software updates and shutting down in %1 seconds", root.remainingTime)
                    : i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Shutting down in 1 second", "Shutting down in %1 seconds", root.remainingTime);
                }
            }
            color: Qt.rgba(0.925, 0.914, 0.961, 0.85)
            font.family: "Geist"
            font.pixelSize: 17
        }

        Text {
            Layout.topMargin: 14
            Layout.maximumWidth: 560
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            visible: sessionsModel.count > 1 && (sdtype !== ShutdownType.ShutdownTypeNone || root.showAllOptions)
            text: i18ndp("plasma_lookandfeel_org.kde.lookandfeel",
                         "One other user is currently logged in. If the computer is shut down or restarted, that user may lose work.",
                         "%1 other users are currently logged in. If the computer is shut down or restarted, those users may lose work.",
                         sessionsModel.count - 1)
            color: "#a7a4ba"
            font.family: "Geist"
            font.pixelSize: 14
        }
        Text {
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignHCenter
            visible: rebootToFirmwareSetup
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "When restarted, the computer will enter the firmware setup screen.")
            color: "#a7a4ba"
            font.family: "Geist"
            font.pixelSize: 14
        }
        Text {
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignHCenter
            visible: rebootToBootLoaderMenu
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "When restarted, the computer will enter the boot loader menu.")
            color: "#a7a4ba"
            font.family: "Geist"
            font.pixelSize: 14
        }

        RowLayout {
            Layout.topMargin: 22
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            PillButton {
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Cancel")
                onClicked: cancelRequested()
            }
            PillButton {
                primary: true
                visible: !root.showAllOptions
                text: {
                    switch (sdtype) {
                    case ShutdownType.ShutdownTypeReboot:
                        return i18nd("plasma_lookandfeel_org.kde.lookandfeel", "&Restart Now").replace("&", "");
                    case ShutdownType.ShutdownTypeNone:
                        return i18nd("plasma_lookandfeel_org.kde.lookandfeel", "&Log Out Now").replace("&", "");
                    default:
                        return i18nd("plasma_lookandfeel_org.kde.lookandfeel", "&Shut Down Now").replace("&", "");
                    }
                }
                onClicked: (currentAction)()
            }
        }
    }
}
