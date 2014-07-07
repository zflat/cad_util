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


#include <QDebug>
#include <QThread>
#include "util_save_preview.h"
#include "util_save_preview_worker.h"

QString UtilSavePreview::name() const{
  return QObject::tr("Save Preview");
}

QString UtilSavePreview::description() const{
 return QObject::tr("Save the file after rotating to iso view and zooming to fit the screen.");
}

QString UtilSavePreview::command() const{
  return QObject::tr("SavePreview");
}
UtilWorker *UtilSavePreview::newWorker(){
    return new UtilSavePreviewWorker();
}

QString UtilSavePreview::version() const{ return QString("0.1.0"); }
