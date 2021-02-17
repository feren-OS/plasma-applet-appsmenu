/*
    Copyright (C) 2020  Mikel Johnson <mikel5764@gmail.com>
    Copyright (C) 2021  Kai Uwe Broulik <kde@broulik.de>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
import QtQuick 2.12
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.plasma.components 2.0 as PlasmaComponents // for Menu + MenuItem
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Layouts 1.12

Item {
    id: leaveButtonRoot

    RowLayout {
        id: leaveButtonsRow
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
        spacing: PlasmaCore.Units.smallSpacing * 2

        Repeater {
            model: systemFavorites

            PlasmaComponents3.ToolButton {
                // so that it lets the buttons elide...
                //Layout.fillWidth: true
                // ... but does not make the buttons grow
                //Layout.maximumWidth: implicitWidth
                icon.name: model.decoration
                onClicked: {
                    systemFavorites.trigger(index, "", "")
                }
                
                PlasmaComponents3.ToolTip {
                    text: model.display
                    visible: model.hovered
                }
            }
        }

        Item { // compact layout
            Layout.fillWidth: true
        }
    }

    Instantiator {
        model: Kicker.SystemModel {
            id: systemModel
            favoritesModel: globalFavorites
        }
        delegate: PlasmaComponents.MenuItem {
            text: model.display
            icon: model.decoration
            visible: !String(plasmoid.configuration.systemFavorites).includes(model.favoriteId)

            onClicked: systemModel.trigger(index, "", "")
        }
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Tab && mainTabGroup.state == "top") {
            keyboardNavigation.state = "LeftColumn"
            root.currentView.forceActiveFocus()
            event.accepted = true;
        }
    }

}
