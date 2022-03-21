/*
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.private.kicker 0.1 as Kicker //for Leave
import QtQuick.Templates 2.15 as T
import QtGraphicalEffects 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.13 as Kirigami
import org.kde.kcoreaddons 1.0 as KCoreAddons
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

PlasmaExtras.PlasmoidHeading {
    id: root

    property alias searchText: searchField.text
    property Item configureButton: configureButton
    property Item avatar: avatar

    Kicker.SystemModel {
        id: systemModel
        favoritesModel: plasmoid.rootItem.rootModel.systemFavoritesModel
    }

    contentHeight: Math.max(searchField.implicitHeight, leaveButtons.implicitHeight)

    leftPadding: Math.round((background.margins.left - background.inset.left) / 2.0)
    rightPadding: Math.round((background.margins.right - background.inset.right) / 2.0)
    topPadding: Math.round((background.margins.top - background.inset.top) / 2.0)
    bottomPadding: background.margins.bottom + Math.round((background.margins.bottom - background.inset.bottom) / 2.0)

    leftInset: -plasmoid.rootItem.backgroundMetrics.leftPadding
    rightInset: -plasmoid.rootItem.backgroundMetrics.rightPadding
    topInset: -background.margins.top
    bottomInset: 0

    KCoreAddons.KUser {
        id: kuser
    }

    spacing: plasmoid.rootItem.backgroundMetrics.spacing

    RowLayout {
        id: headerItems
        spacing: root.spacing
        anchors.left: parent.left
        anchors.right: parent.right
        Keys.onDownPressed: plasmoid.rootItem.contentArea.forceActiveFocus(Qt.TabFocusReason)

        PC3.RoundButton {
            id: avatar
            visible: KQuickAddons.KCMShell.authorize("kcm_users.desktop").length > 0
            hoverEnabled: true
            Layout.preferredWidth: root.contentHeight
            Layout.preferredHeight: root.contentHeight
            Accessible.name: kuser.fullName
            leftPadding: PlasmaCore.Units.devicePixelRatio
            rightPadding: PlasmaCore.Units.devicePixelRatio
            topPadding: PlasmaCore.Units.devicePixelRatio
            bottomPadding: PlasmaCore.Units.devicePixelRatio
            contentItem: Kirigami.Avatar {
                source: kuser.faceIconUrl
                name: kuser.fullName
            }
            Rectangle {
                parent: avatar.background
                anchors.fill: avatar.background
                anchors.margins: -PlasmaCore.Units.devicePixelRatio
                z: 1
                radius: height/2
                color: "transparent"
                border.width: avatar.visualFocus ? PlasmaCore.Units.devicePixelRatio * 2 : 0
                border.color: PlasmaCore.Theme.buttonFocusColor
            }
            HoverHandler {
                id: hoverHandler
                cursorShape: Qt.PointingHandCursor
            }
            PC3.ToolTip.text: Accessible.name
            PC3.ToolTip.visible: hovered
            PC3.ToolTip.delay: Kirigami.Units.toolTipDelay

            Keys.onLeftPressed: if (LayoutMirroring.enabled) {
                searchField.forceActiveFocus(Qt.TabFocusReason)
            }
            Keys.onRightPressed: if (!LayoutMirroring.enabled) {
                searchField.forceActiveFocus(Qt.TabFocusReason)
            }
            Keys.onDownPressed: if (plasmoid.rootItem.sideBar) {
                plasmoid.rootItem.sideBar.forceActiveFocus(Qt.TabFocusReason)
            } else {
                plasmoid.rootItem.contentArea.forceActiveFocus(Qt.TabFocusReason)
            }

            onClicked: KQuickAddons.KCMShell.openSystemSettings("kcm_users")
        }
        PC3.TextField {
            id: searchField
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.leftMargin: plasmoid.rootItem.backgroundMetrics.leftPadding
            focus: true
            placeholderText: i18n("Search…")
            clearButtonShown: true
            Accessible.editable: true
            Accessible.searchEdit: true
            inputMethodHints: Qt.ImhNoPredictiveText
            Binding {
                target: plasmoid.rootItem
                property: "searchField"
                value: searchField
            }
            Connections {
                target: plasmoid
                function onExpandedChanged() {
                    if(!plasmoid.expanded) {
                        searchField.clear()
                    }
                }
            }
            Shortcut {
                sequence: StandardKey.Find
                onActivated: {
                    searchField.forceActiveFocus(Qt.ShortcutFocusReason)
                    searchField.selectAll()
                }
            }
            onTextEdited: {
                searchField.forceActiveFocus(Qt.ShortcutFocusReason)
            }
            onAccepted: {
                plasmoid.rootItem.contentArea.currentItem.action.triggered()
                plasmoid.rootItem.contentArea.currentItem.forceActiveFocus(Qt.ShortcutFocusReason)
            }
            Keys.priority: Keys.AfterItem
            Keys.forwardTo: plasmoid.rootItem.contentArea.view
            Keys.onLeftPressed: if (activeFocus) {
                if (LayoutMirroring.enabled) {
                    nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
                } else {
                    nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason)
                }
            }
            Keys.onRightPressed: if (activeFocus) {
                if (!LayoutMirroring.enabled) {
                    nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
                } else {
                    nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason)
                }
            }
        }

        RowLayout {
            id: leaveButtons
            Layout.alignment: Qt.AlignRight

            Repeater {
                model: systemModel

                PC3.ToolButton {
                    Layout.alignment: Qt.AlignVCenter
                    icon.name: model.decoration
                    display: PC3.ToolButton.IconOnly
                    visible: String(plasmoid.configuration.systemFavorites).includes(model.favoriteId)

                    PC3.ToolTip.text: model.display
                    PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PC3.ToolTip.visible: hovered
                    Keys.onLeftPressed: if (LayoutMirroring.enabled) {
                        nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
                    } else {
                        nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason)
                    }
                    Keys.onRightPressed: if (!LayoutMirroring.enabled) {
                        nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
                    } else {
                        nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason)
                    }
                    onClicked: systemModel.trigger(index, "", "")
                }
            }
        }
    }
}
