/*
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Templates 2.15 as T
import QtQml 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.kicker 0.1 as Kicker

BasePage {
    id: root
    sideBarComponent: KickoffListView {
        id: sideBar
        focus: true // needed for Loaders
        model: plasmoid.rootItem.rootModel
        delegate: KickoffItemDelegate {
            width: view.availableWidth
            isCategory: model.hasChildren
        }
        implicitWidth: 250 * PlasmaCore.Units.devicePixelRatio
    }
    contentAreaComponent: VerticalStackView {
        id: stackView
        readonly property string preferredFavoritesViewObjectName: "favoritesGridView"
        readonly property Component preferredFavoritesViewComponent: favoritesGridViewComponent
        readonly property string preferredAppsViewObjectName: "applicationsGridView"
        readonly property Component preferredAppsViewComponent: applicationsGridViewComponent
        // NOTE: The 0 index modelForRow isn't supposed to be used. That's just how it works.
        property int appsModelRow: 1
        readonly property Kicker.AppsModel appsModel: plasmoid.rootItem.rootModel.modelForRow(appsModelRow)
        focus: true
        initialItem: preferredFavoritesViewComponent

        Component {
            id: favoritesGridViewComponent
            DropAreaGridView {
                id: favoritesGridView
                objectName: "favoritesGridView"
                focus: true
                model: plasmoid.rootItem.rootModel.favoritesModel
            }
        }

        Component {
            id: applicationsGridViewComponent
            KickoffGridView {
                id: applicationsGridView
                objectName: "applicationsGridView"
                model: stackView.appsModel
            }
        }

        onPreferredFavoritesViewComponentChanged: {
            if (root.sideBarItem != null && root.sideBarItem.currentIndex === 0) {
                stackView.replace(stackView.preferredFavoritesViewComponent)
            }
        }
        onPreferredAppsViewComponentChanged: {
            if (root.sideBarItem != null && root.sideBarItem.currentIndex > 1) {
                stackView.replace(stackView.preferredAppsViewComponent)
            }
        }

        Connections {
            target: root.sideBarItem
            function onCurrentIndexChanged() {
                // Only update row index if the condition is met.
                // The 0 index modelForRow isn't supposed to be used. That's just how it works.
                if (root.sideBarItem.currentIndex > 0) {
                    appsModelRow = root.sideBarItem.currentIndex
                }
                if (root.sideBarItem.currentIndex === 0
                    && stackView.currentItem.objectName !== stackView.preferredFavoritesViewObjectName) {
                    stackView.replace(stackView.preferredFavoritesViewComponent)
                } else if (root.sideBarItem.currentIndex > 0
                    && stackView.currentItem.objectName !== stackView.preferredAppsViewObjectName) {
                    stackView.replace(stackView.preferredAppsViewComponent)
                }
            }
        }
        Connections {
            target: plasmoid
            function onExpandedChanged() {
                if(!plasmoid.expanded) {
                    plasmoid.rootItem.contentArea.currentItem.forceActiveFocus()
                }
            }
        }
    }
    // NormalPage doesn't get destroyed when deactivated, so the binding uses
    // StackView.status and visible. This way the bindings are reset when
    // NormalPage is Activated again.
    Binding {
        target: plasmoid.rootItem
        property: "sideBar"
        value: root.sideBarItem
        when: root.T.StackView.status === T.StackView.Active && root.visible
        restoreMode: Binding.RestoreBinding
    }
    Binding {
        target: plasmoid.rootItem
        property: "contentArea"
        value: root.contentAreaItem.currentItem // NOT just root.contentAreaItem
        when: root.T.StackView.status === T.StackView.Active && root.visible
        restoreMode: Binding.RestoreBinding
    }
}
