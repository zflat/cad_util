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
#include <QTime>

#include "util_interface_random_color_change.h"
#include "worker_random_color_change.h"

#include "sldcontext.h"
#include "sld_model.h"

WorkerRandomColorChange::WorkerRandomColorChange(int argc, char *argv[], QObject* parent) : UtilWorker(argc, argv, parent){
    widget = new QLabel("Path: ");
    meta_hash.insert("widget_type", "simple");
    meta_hash.insert("silent", "true");
}

WorkerRandomColorChange::~WorkerRandomColorChange(){
    if(NULL != widget)
        delete widget;
    widget = NULL;
}

void WorkerRandomColorChange::init(){
    UtilWorker::init();    
    qDebug() << "Utility initialized";
}

void WorkerRandomColorChange::start(){

  SldContext * context = new SldContext();
  ISldWorksPtr swAppPtr = context->get_swApp();

  qsrand(QTime::currentTime().msec());

  if(swAppPtr){
      IModelDoc2Ptr swModel;

      HRESULT hres = swAppPtr->get_IActiveDoc2(&swModel);
      bool is_recording_history = false;
      if (FAILED(hres)){
          qWarning() << " Could not get the active doc";
      }else if(swModel){
          IModelDoc2* swModelPtr = static_cast<IModelDoc2*>(swModel);
          SldModel* model = new SldModel(context,static_cast<IModelDoc2**>(&swModelPtr));

          IModelDocExtensionPtr swModelExt;
          hres = swModelPtr->get_Extension(&swModelExt);

          if (FAILED(hres) && !swModelExt){
              qWarning() << "Could not get the document extension";
          }else{
              hres = swModelExt->StartRecordingUndoObject();
              if(FAILED(hres)){
                  qWarning() << "Could not push action to undo history";
              }else{
                  is_recording_history = true;
              }
          }

          if( !model->change_color()){
              qWarning() << "Could not change the color of the current document";
          }

          if(swModelExt && is_recording_history){
              VARIANT_BOOL invisible = false;
              VARIANT_BOOL outval = false;
              BSTR history_name = SysAllocString(L"Random color change");
              hres = swModelExt->FinishRecordingUndoObject2(history_name, invisible, &outval);
          }

          qDebug() << "Color changed";

          if(swModelExt)
            swModelExt->Release();

          delete model;
      }else{
          qWarning() << "No active document";
      }
  }

  delete context;
  emit complete();
}

void WorkerRandomColorChange::cleanup(){
    UtilWorker::cleanup();
}
