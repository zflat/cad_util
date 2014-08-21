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
#include <QFileInfo>

#include "util_interface_safe_save_as_copy.h"
#include "worker_safe_save_as_copy.h"

#include "sldcontext.h"
#include "sld_model.h"

WorkerSafeSaveAsCopy::WorkerSafeSaveAsCopy(int argc, char *argv[], QObject* parent) : UtilWorker(argc, argv, parent), model(NULL){
    widget = new SaveCopyWidget();
    QObject::connect(widget, SIGNAL(save_accepted()), this, SLOT(process_save()));
    meta_hash.insert("widget_type", "simple");
    meta_hash.remove("silent");
}


QString WorkerSafeSaveAsCopy::fpath_0(){
    if(NULL == model){
        return NULL;
    }
    return model->path_name();
}

void WorkerSafeSaveAsCopy::process_save(){
    waiting_for_input=false;
}

void WorkerSafeSaveAsCopy::start(){

      SldContext * context = new SldContext();
      try{
          ISldWorksPtr swAppPtr = context->get_swApp();

          if(swAppPtr){
              IModelDoc2Ptr swModel;

              HRESULT hres = swAppPtr->get_IActiveDoc2(&swModel);
              if (FAILED(hres)){
                  qWarning() << " Could not get the active doc";
                  delete context;
                  Q_EMIT complete();
                  return;
              }else if(!swModel){
                  qWarning() << "No active document";
                  delete context;
                  Q_EMIT complete();
                  return;
              }

              // Assign the active document to the current model
              IModelDoc2* swModelPtr = static_cast<IModelDoc2*>(swModel);
              model = new SldModel(context,static_cast<IModelDoc2**>(&swModelPtr));

              // Set the file name to the existing file for starters
              widget->set_fpath_str(fpath_0());

              // Spin wait for (valid) GUI inputs
              waiting_for_input=true;
              while(waiting_for_input){
                  QThread::msleep(10);
                if(is_terminate_requested){
                    return;
                }
                // Verify that the selected path is not an open name
                QStringList* doc_paths = context->app()->open_docs_list();
                QStringList* names = new QStringList();
                for(QStringList::iterator it = doc_paths->begin();it !=names->end(); ++it){
                    names->append(QFileInfo(*it).fileName());
                }
                if(names->contains(QFileInfo(widget->fpath()).fileName())){
                    qDebug() << "Selected file name conflict with the name of an open document";
                    waiting_for_input = true;
                }
                delete doc_paths;
                delete names;
              }

              // Disable widget GUI during processing
              widget->ui_enable(false);

              // perform a save-as with the new name
              if(!model->save_as(widget->fpath())){
                  qWarning() << "Save as failed for the current document.";
                  delete context;
                  Q_EMIT complete();
                  return;
              }

              // open the newly saved file
              IModelDoc2Ptr new_model_ptr;
              SldModel* new_model = new SldModel(context);
              if(!new_model->open(widget->fpath(), static_cast<IModelDoc2**>(&new_model_ptr))){
                  qWarning() << "Could not open the new document to change color";
              }else{

                  if( qApp->property("optn.verbose").toBool()){
                         qDebug() << tr("New document opened");
                         qDebug() << new_model->path_name().toStdString().c_str();
                         IModelDoc2* swModelPtr = new_model_ptr;
                         SldModel temp_model(context, static_cast<IModelDoc2**>(&swModelPtr));
                  }

                  // change the color of the new file
                  if(!new_model->change_color()){
                      qWarning() << "Could not change the color of the new document";
                  }

                  // Save the new file with SaveAsSilent to force color change
                  // See https://forum.solidworks.com/thread/52728
                  new_model->save_as_silent(widget->fpath(), false);
                  new_model->save();
              }

              delete new_model;
              new_model=NULL;
              delete model;
              model=NULL;
          }
      }catch(...){
        qCritical() << "An unhandled exception has occured.";
      }

  delete context;
  Q_EMIT complete();
  return;

}

