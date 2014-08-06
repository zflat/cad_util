# Copyright 2014 William Wedler
#
# This file is part of Receptacle
#
# Receptacle is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Receptacle is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Receptacle.  If not, see <http://www.gnu.org/licenses/>.


filepathname=$$_PRO_FILE_
filename=$$basename(filepathname)
proj_name=$$replace(filename, .pro,)

util_interface_name=util_interface_$${proj_name}
util_worker_name=worker_$${proj_name}

TEMPLATE    = lib
CONFIG      += plugin
QT          += core gui testlib

TARGET      = $$qtLibraryTarget(util_$${proj_name})
DESTDIR     = $$PWD/../../build\host\plugins

SOURCES += \
    $$PWD/src/$${util_worker_name}.cpp \
     $$PWD/src/save_copy_widget.cpp

HEADERS += \
    $$PWD/include/$${util_interface_name}.h \
    $$PWD/include/$${util_worker_name}.h \
     $$PWD/include/save_copy_widget.h

INCLUDEPATH += $$PWD/src \
    $$PWD/"include" \

include($$PWD/../common/common.pri)

FORMS += \
     $$PWD/src/save_copy_widget.ui
