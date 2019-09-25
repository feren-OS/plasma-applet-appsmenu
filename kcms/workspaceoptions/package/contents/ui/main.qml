/*
 * Copyright 2018 Furkan Tokac <furkantokac34@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */
import QtQuick 2.7
import QtQuick.Controls 2.4 as Controls
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kcm 1.2 as KCM

import org.kde.plasma.core 2.0 as PlasmaCore

KCM.SimpleKCM {
    id: root

    KCM.ConfigModule.buttons: KCM.ConfigModule.Help | KCM.ConfigModule.Defaults | KCM.ConfigModule.Apply

    Kirigami.FormLayout {
        id: formLayout

        // Visaul behavior settings
        Controls.CheckBox {
            id: showToolTips
            Kirigami.FormData.label: i18n("Visual behavior:")
            text: i18n("Display informational tooltips on mouse hover")
            checked: kcm.toolTip
            onCheckedChanged: kcm.toolTip = checked
        }

        Controls.CheckBox {
            id: showVisualFeedback
            text: i18n("Display visual feedback for status changes")
            checked: kcm.visualFeedback
            onCheckedChanged: kcm.visualFeedback = checked
        }

        // We want to show the slider in a logarithmic way. ie
        // move from 4x, 3x, 2x, 1x, 0.5x, 0.25x, 0.125x
        // 0 is a special case
        RowLayout {
            Kirigami.FormData.label: i18n("Animation speed:")

            Controls.Label {
                text: i18nc("Animation speed", "Slow")
            }
            Controls.Slider {
                id: slider
                Layout.fillWidth: true
                from: -4
                to: 4
                stepSize: 1
                snapMode: Controls.Slider.SnapAlways
                onMoved: {
                    if(value === to) {
                        kcm.animationDurationFactor = 0;
                    } else {
                        kcm.animationDurationFactor = 1.0 / Math.pow(2, value);
                    }
                }
                value: if (kcm.animationDurationFactor === 0) {
                    return slider.to;
                } else {
                    return -(Math.log(kcm.animationDurationFactor) / Math.log(2));
                }
            }
            Controls.Label {
                text: i18nc("Animation speed", "Instant")
            }
        }

        Connections {
            target: kcm
            onToolTipChanged: showToolTips.checked = kcm.toolTip
            onVisualFeedbackChanged: showVisualFeedback.checked = kcm.visualFeedback
        }

        Item {
            Kirigami.FormData.isSection: false
        }

        // Click behavior settings

        Controls.RadioButton {
            id: singleClick
            Kirigami.FormData.label: i18n("Click behavior:")
            text: i18n("Single-click to open files and folders")
            checked: kcm.singleClick
            onCheckedChanged: kcm.singleClick = checked
        }

        Controls.RadioButton {
            id: doubleClick
            text: i18n("Double-click to open files and folders (single click to select)")
        }

        Connections {
            target: kcm
            onSingleClickChanged: {
                singleClick.checked = kcm.singleClick
                doubleClick.checked = !singleClick.checked
            }
        }
    }
}
