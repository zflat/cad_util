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

#ifndef UTIL_COPY_FILE_NAME_H
#define UTIL_COPY_FILE_NAME_H

#include <QtPlugin>
#include <QObject>
#include <QString>

#include "util_interface.h"
#include "util_worker.h"

class UtilCopyFileName : public QObject, public UtilInterface
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "Receptacle.plugins.UtilInterface/0.1.0")
    Q_INTERFACES(UtilInterface)

public:
    virtual QString name() const;
    virtual QString description() const;
    virtual QString command() const;    
    virtual QString version() const;

    UtilWorker* newWorker();
};

#endif // UTIL_COPY_FILE_NAME_H
