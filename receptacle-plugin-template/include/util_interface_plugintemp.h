/*

Copyright 2014 William Wedler

This file is part of Receptacle

Receptacle is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Receptacle is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Receptacle.  If not, see <http://www.gnu.org/licenses/>.

*/

#ifndef UTIL_INTERFACE_%ProjectName:u%_H
#define UTIL_INTERFACE_%ProjectName:u%_H

#include <QtPlugin>
#include <QObject>
#include <QString>

#include "util_interface.h"
#include "util_worker.h"

#include "worker_%ProjectName:l%.h"

class UtilInterface%ProjectName% : public QObject, public UtilInterface
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "Receptacle.plugins.UtilInterface/0.1.0")
    Q_INTERFACES(UtilInterface)

public:
    UtilWorker* newWorker(){
        return UTIL_NEW_WORKER;
    }

    virtual QString name() const{
        return QObject::tr("%NAME%");
    }
    virtual QString description() const{
        return QObject::tr("%DESCRIPTION%");
    }
    virtual QString command() const{
        return QObject::tr("%COMMAND%");
    }

    virtual QString version() const{ return QString("0.1.0"); }
};

#endif // UTIL_INTERFACE_%ProjectName:u%_H
