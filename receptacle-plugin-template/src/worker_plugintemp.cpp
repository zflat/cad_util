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

// worker_%ProjectName:l%.cpp

#include <QDebug>
#include <QApplication>

#include "worker_%ProjectName:l%.h"

#include "sldcontext.h"
#include "sld_model.h"

Worker%ProjectName%::Worker%ProjectName%(int argc, char *argv[], QObject* parent) : UtilWorker(argc, argv, parent){
    /*
    widget = new QLabel("Path: ");
    meta_hash.insert("widget_type", "simple");
    meta_hash.insert("silent", "true");
    */
}

void Worker%ProjectName%::start(){

  /*
  SldContext * context = new SldContext();
  ISldWorksPtr swAppPtr = context->get_swApp();
  delete context;
  */
  
  emit complete();
}

