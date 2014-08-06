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

#include "util_interface_safe_save_as_copy.h"
#include "worker_safe_save_as_copy.h"

#include "sldcontext.h"
#include "sld_model.h"

WorkerSafeSaveAsCopy::WorkerSafeSaveAsCopy(int argc, char *argv[], QObject* parent) : UtilWorker(argc, argv, parent){
    widget = new SaveCopyWidget();
    meta_hash.insert("widget_type", "simple");
    meta_hash.remove("silent");
}


void WorkerSafeSaveAsCopy::start(){

  SldContext * context = new SldContext();
  ISldWorksPtr swAppPtr = context->get_swApp();

  if(swAppPtr){
      IModelDoc2Ptr swModel;

      HRESULT hres = swAppPtr->get_IActiveDoc2(&swModel);
      if (FAILED(hres)){
          qWarning() << " Could not get the active doc";
      }else if(swModel){
          IModelDoc2* swModelPtr = static_cast<IModelDoc2*>(swModel);
          SldModel* model = new SldModel(context,static_cast<IModelDoc2**>(&swModelPtr));

          // Save as new name

          if(false && !model->change_color()){
              qWarning() << "Could not change the color of the current document";
          }
          delete model;
      }else{
          qWarning() << "No active document";
      }
  }

  delete context;
  Q_EMIT complete();
}

