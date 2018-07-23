/*
 *   Copyright (C) 2012 - 2016 by Ivan Cukic <ivan.cukic@kde.org>
 *
 *   This program is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU General Public License as
 *   published by the Free Software Foundation; either version 2 of
 *   the License or (at your option) version 3 or any later version
 *   accepted by the membership of KDE e.V. (or its successor approved
 *   by the membership of KDE e.V.), which shall act as a proxy
 *   defined in Section 14 of version 3 of the license.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "ActivitiesTab.h"

#include <QQmlContext>
#include <QQmlEngine>
#include <QQmlComponent>

#include <QQuickView>
#include <QGuiApplication>
#include <QVBoxLayout>

#include "ExtraActivitiesInterface.h"
#include "definitions.h"

#include <utils/d_ptr_implementation.h>

#include "kactivities-kcm-features.h"

#include "utils.h"

class ActivitiesTab::Private {
public:
    std::unique_ptr<QQuickView> viewActivities;
    ExtraActivitiesInterface *extraActivitiesInterface;
};

ActivitiesTab::ActivitiesTab(QWidget *parent)
    : QWidget(parent)
    , d()
{
    new QVBoxLayout(this);

    d->extraActivitiesInterface = new ExtraActivitiesInterface(this);

    d->viewActivities = createView(this);
    d->viewActivities->rootContext()->setContextProperty(
        QStringLiteral("kactivitiesExtras"), d->extraActivitiesInterface);
    setViewSource(d->viewActivities, QStringLiteral("/qml/activitiesTab/main.qml"));
}

ActivitiesTab::~ActivitiesTab()
{
}

void ActivitiesTab::defaults()
{
}

void ActivitiesTab::load()
{
}

void ActivitiesTab::save()
{
}
