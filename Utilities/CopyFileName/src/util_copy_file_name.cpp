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
#include "util_copy_file_name.h"
#include "util_copy_file_name_worker.h"

QString UtilCopyFileName::name() const{
  return QObject::tr("Copy file name");
}

QString UtilCopyFileName::description() const{
 return QObject::tr("Read the full path name and copy to clipboard.");
}

QString UtilCopyFileName::command() const{
  return QObject::tr("CopyFileName");
}
UtilWorker *UtilCopyFileName::newWorker(){
    return new UtilCopyFileNameWorker();
}

QString UtilCopyFileName::version() const{ return QString("0.1.0"); }
