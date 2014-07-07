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
#include "util_save_preview_worker.h"

#include "sld_app_context.h"

void UtilSavePreviewWorker::start(){
  qDebug() << "Run in plugin UtilSleepyWorker <---" ;

  SldAppContext * app = new SldAppContext;
  ISldWorksPtr swAppPtr = app->getApp();

  if(swAppPtr){
      IModelDoc2Ptr swModel;

      HRESULT hres = swAppPtr->get_IActiveDoc2(&swModel);
      if (FAILED(hres)){
          qWarning() << " Could not get the active doc";
      }else if(swModel){
          IModelViewPtr swView;
          hres = swModel->get_IActiveView(&swView);

          BSTR viewName = SysAllocString(L"*Isometric");
          hres = swModel->ShowNamedView2(viewName, -1);
          hres = swModel->ViewZoomtofit2();

          long save_err=0;
          long save_warn=0;
          long save_optns = swSaveAsOptions_e::swSaveAsOptions_Silent\
                  | swSaveAsOptions_e::swSaveAsOptions_AvoidRebuildOnSave;
          VARIANT_BOOL bres = false;
          swModel->Save3(save_optns, &save_err, &save_warn, &bres);


          BSTR pathName;
          (hres) = swModel->GetPathName(&pathName);
          if (FAILED(hres)){
              qWarning() << " Could not get the document path name";
          }else{
              QString qstr((QChar*)pathName, ::SysStringLen(pathName));
              qDebug() << qstr.toStdString().c_str();
          }
      }
  }

  delete app;

    for(int i=0; i<25; i++){
        QThread::msleep(500);
        qDebug()<<i<<endl;
        if(is_terminate_requested){
            return;
        }
    }
    qDebug() << "Done Sleepy";
    emit complete();
}
