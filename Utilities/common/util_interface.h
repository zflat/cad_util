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

/*
  Plugin interface
  See example at:
  http://qt-project.org/doc/qt-5.1/qtwidgets/tools-plugandpaint.html
http://michael-stengel.com/blog/?p=4
https://qt-project.org/doc/qt-5.0/qtwidgets/tools-plugandpaintplugins-basictools.html
 */

#ifndef UTIL_INTERFACE_H
#define UTIL_INTERFACE_H

#include <QtPlugin>
#include <QString>
#include "util_worker.h"

class UtilInterface
{
 public:
    virtual ~UtilInterface(){}
    virtual QString name() const = 0;
    virtual QString description() const = 0;
    virtual QString command() const = 0;
    virtual QString version() const = 0;
    virtual UtilWorker* newWorker() = 0;
};

#define UtilInterface_iid "Receptacle.plugins.UtilInterface/0.1.0"

Q_DECLARE_INTERFACE(UtilInterface, UtilInterface_iid)

#endif // UTIL_INTERFACE_H
