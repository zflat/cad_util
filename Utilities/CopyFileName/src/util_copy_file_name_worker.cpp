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
#include <QLabel>
#include <QClipboard>
#include <QApplication>

#include "util_copy_file_name_worker.h"

#include "sldcontext.h"
#include "sld_model.h"

UtilCopyFileNameWorker::UtilCopyFileNameWorker(int argc, char *argv[], QObject* parent) : UtilWorker(argc, argv, parent){
    widget = new QLabel("Path: ");
    meta_hash.insert("widget_type", "simple");
}

void UtilCopyFileNameWorker::init(){
    UtilWorker::init();
    qDebug() << "Utility initialized";
}

void UtilCopyFileNameWorker::start(){

  SldContext * context = new SldContext();
  ISldWorksPtr swAppPtr = context->get_swApp();

  if(swAppPtr){
      IModelDoc2Ptr swModel;

      HRESULT hres = swAppPtr->get_IActiveDoc2(&swModel);
      if (FAILED(hres)){
          qWarning() << " Could not get the active doc";
      }else if(swModel){      
          BSTR fileName;
          hres = swModel->GetPathName(&fileName);
          
          if(FAILED(hres)){
              qWarning() << "Could not get the path name of the active document.";
          }else{
              QString qstr((QChar*)fileName, ::SysStringLen(fileName));
              qDebug() << qstr.toStdString().c_str();
              ((QLabel*)widget)->setText(qstr);
              QClipboard *clipboard = QApplication::clipboard();
              clipboard->setText(qstr);
          }
      }else{
          qWarning() << "No active document";
      }
  }

  delete context;
  emit complete();
}

void UtilCopyFileNameWorker::cleanup(){
    UtilWorker::cleanup();
}
