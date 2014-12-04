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

// worker_zoomlifesize.cpp

#include <QDebug>
#include <QApplication>

#include "smartvars.h"

#include "worker_zoomlifesize.h"

// http://www.viewsonic.com/us/product-archive/monitors/va2431wm.html
#define SCREEN_VISIBLE_DIAG 24.456

WorkerZoomLifeSize::WorkerZoomLifeSize(int argc, char *argv[], QObject* parent) : UtilWorker(argc, argv, parent){
    /*
    widget = new QLabel("Path: ");
    meta_hash.insert("widget_type", "simple");
    */

    meta_hash.insert("silent", "true");
    settings = new QSettings ("Receptacle", "Zoom Life Size");
    requires_calibration = ! verify_settings_are_current();
    if(!requires_calibration){
        meta_hash.insert("silent", "true");
    }

    context = NULL;
    swAppPtr = NULL;
}

WorkerZoomLifeSize::~WorkerZoomLifeSize(){
    delete settings;
    if(NULL != context){
        delete context;
        context = NULL;
    }
    if(NULL != swAppPtr){
        swAppPtr->Release();
        swAppPtr = NULL;
    }
}

void WorkerZoomLifeSize::start(){

    context = new SldContext();
    swAppPtr = context->get_swApp();
    math = new M3dHelper(context);

    /// Store information for the screen(s)
    int count=0;
    double dpi_x=0;
    double dpi_y=0;
    double ldpi=0;
    double ppi = 0; // pixels per mmm
    settings->beginWriteArray("screens");
    foreach (QScreen *screen, qApp->screens()){
        settings->setArrayIndex(count++);
        settings->setValue("name", screen->name());
        if(0 == dpi_x)
            dpi_x = screen->physicalDotsPerInchX();
        else if(dpi_x != screen->physicalDotsPerInchX())
            qWarning() << "Not all screens are the the same x-resolution";
        settings->setValue("dpi_x", screen->physicalDotsPerInchX());
        if(0==dpi_y)
            dpi_y = screen->physicalDotsPerInchY();
        else if(dpi_y != screen->physicalDotsPerInchY())
            qWarning() << "Not all screens are the the same y-resolution";
        settings->setValue("dpi_y", screen->physicalDotsPerInchY());

        ldpi = screen->logicalDotsPerInch();
        qDebug() << "Logical dpi_x: " << screen->logicalDotsPerInchX();
        qDebug() << "Logical dpi_y: " << screen->logicalDotsPerInchY();

        qDebug() << "Physical size w: " << screen->physicalSize().width();
        qDebug() << "Physical size h: " << screen->physicalSize().height();
        qDebug() << "Physical size diag: " << \
                    sqrt(pow(screen->physicalSize().width(),2)+pow(screen->physicalSize().height(),2.0));

        qDebug() << "Pixel size w: " << screen->size().width();
        qDebug() << "Pixel size h: " << screen->size().height();
        qDebug() << "Pixel size diag: " << sqrt(pow(screen->size().width(),2)+pow(screen->size().height(),2.0));

        ppi = sqrt(pow(screen->size().width(),2)+pow(screen->size().height(),2.0)) / SCREEN_VISIBLE_DIAG;
    }
    qDebug() << "Computed ppi: " << ppi;
    settings->endArray();
    settings->sync();

    /// Determine the zoom factor
    /// * Read the current view orientation & view translation
    /// * Read the current window size W x H
    /// * Project a W x H rectangle on current view orientation
    /// * Select the rectangle and zoom to selection
    /// * Translate the view by corrected view translation
    ///

    if(NULL == swAppPtr){
     qWarning() << "swApp not initialized.";
     emit complete();
     return;
    }

    IModelViewPtr p_ModelView = NULL;
    IMathVectorPtr swViewTrans = NULL;
    IMathTransformPtr swViewOrien = NULL;
    IMathTransformPtr swViewOriXlate = NULL;
    IModelDoc2Ptr swModel= NULL;
    IModelDocExtensionPtr swModDocExt = NULL;

    double initial_scale;
    double zoomed_scale;


    HRESULT hres = swAppPtr->get_IActiveDoc2(&swModel);
    if (FAILED(hres)){
        qWarning() << " Could not get the active doc";
        emit complete();
        return;
    }else if(NULL == swModel){
        qWarning() << " No active document";
        emit complete();
        return;
    }


    LPDISPATCH pDisp;
    hres = swModel->get_ActiveView(static_cast<IDispatch **>(&pDisp));
    if(hres != S_OK){
        qWarning() << "Could not get the active view";
        emit complete();
        return;
    }else if(pDisp != NULL){
        hres = pDisp->QueryInterface(IID_IModelView,  (LPVOID *)(&p_ModelView));
        if(! SUCCEEDED(hres)){
            qWarning () << "Could not create IModelView";
            emit complete();
            return;
        }
    }

    /// Read the current orientation, translation & zoom factor
    hres = p_ModelView->get_Orientation3(&swViewOrien);
    hres = p_ModelView->get_Translation3(&swViewTrans);
    hres = p_ModelView->get_Scale2(&initial_scale);


    std::vector<double> xform_vals(12);
    VARIANT data_var;
    swViewOrien->get_ArrayData(static_cast<VARIANT*>(&data_var));
    SafeDoubleArray ori_vals(data_var);
    qDebug() << "Orientation data";
    for(uint i=0; i<ori_vals.getSize(); i++){
        if(abs(ori_vals[i]) < 1.0e-6){
            // qDebug()<< "Very small number: " << abs(ori_vals[i]);
            ori_vals[i] = 0.0;
        }
        if(i<xform_vals.size())
            xform_vals[i] = ori_vals[i];

        if(i%3==0){
            qDebug() << "";
        }
        qDebug()<< ori_vals[i];
    }
    //xform_vals[9]  = 0.0;
    //xform_vals[10] = 0.0;
    //xform_vals[11] = 0.0;

    swViewTrans->get_ArrayData(static_cast<VARIANT*>(&data_var));
    SafeDoubleArray xlate_vals = SafeDoubleArray(data_var);
    /*
    xform_vals[9]  -= xlate_vals[0];
    xform_vals[10] -= xlate_vals[1];
    xform_vals[11] -= xlate_vals[2];
    */
    qDebug() << "Translation data";
    for(uint i=0; i<16 && i<xlate_vals.getSize(); i++){
        qDebug()<< xlate_vals[i];
    }

    if(true){
        swViewOriXlate = math->xformT(xform_vals, 1.0);
        hres = swViewOriXlate->Inverse(static_cast<IDispatch **>(&pDisp));
        hres = pDisp->QueryInterface(IID_IMathTransform,  (LPVOID *)(&swViewOriXlate));
        if(NULL == swViewOriXlate){
            qCritical() << "Could not construct the view frame transformation.";
            emit complete();
            return;
        }
    }else{
        hres = swViewOrien->Inverse(static_cast<IDispatch **>(&pDisp));
        hres = pDisp->QueryInterface(IID_IMathTransform,  (LPVOID *)(&swViewOriXlate));
        // swViewOriXlate = swViewOrien;
    }


    /// Hide the feature manager tree

    /*
    VARIANT_BOOL retVal = VARIANT_FALSE;
    BSTR bstr_title = SysAllocString(L"");
    context->get_swApp()->RunCommand(swCommand_e::swNextTipOfDayString, bstr_title, &retVal);
    swApp.RunCommand((int)swCommands_e.swCommands_Hideshow_Brwser_Tree, ""); C# syntax
    */

    /*
    hres = swModel->get_Extension(&swModDocExt);
    VARIANT_BOOL hideResults = VARIANT_FALSE;
    hres = swModDocExt->HideFeatureManager(VARIANT_TRUE, &hideResults);
    if(VARIANT_FALSE == hideResults){
        qDebug() << "Hiding feature manager tree unsucessful.";
    }
    */

    /// Get the view frame W and H in pixles
    int height_px=0;
    hres = p_ModelView->get_FrameHeight(&height_px);
    int width_px=0;
    hres = p_ModelView->get_FrameWidth(&width_px);
    double diag_px = sqrt(pow(height_px,2)+pow(width_px,2.0));

    /// Convert pixles to meters
    double width_m = px2m(width_px, ppi);
    double height_m = px2m(height_px, ppi);
    double diag_m = px2m(diag_px, ppi);

    qDebug() << "Frame width: " << width_px << "px (" << width_m << "m)";
    qDebug() << "Frame height: " << height_px << "px (" << height_m << "m)";
    qDebug() << "Frame diag: " << diag_px << "px (" << diag_m << "m)";

    /// Create the projected W x H points
    //double dbl_corner_a0[] = {-width_m/2, height_m/2, -0.050};
    //double dbl_corner_b0[] = {width_m/2, -height_m/2, 0.050};

    double dbl_corner_a0[] = {0.0, height_m/2, 0.0};
    double dbl_corner_b0[] = {0.0, -height_m/2, 0.0};
    std::vector<double> corner_a = math->transform(M3dHelper::makeVector(dbl_corner_a0, 3), swViewOriXlate);
    std::vector<double> corner_b = math->transform(M3dHelper::makeVector(dbl_corner_b0, 3), swViewOriXlate);

    qDebug() << "Top back left corner at: \n\t" << \
                "p(" << dbl_corner_a0[0] << "," << \
                dbl_corner_a0[1] << "," << \
                dbl_corner_a0[2] << ")\n\t" \
                "p'(" << corner_a[0] << "," << \
                corner_a[1] << "," << \
                corner_a[2] << ")";

    qDebug() << "Bottom front right corner at: \n\t" << \
                "p(" << dbl_corner_b0[0] << "," << \
                dbl_corner_b0[1] << "," << \
                dbl_corner_b0[2] << ")\n\t" \
                "p'(" << corner_b[0] << "," << \
                corner_b[1] << "," << \
                corner_b[2] << ")";


    /// Zoom to projected W x H points
    //hres = swModel->ViewZoomTo2(corner_a[0], corner_a[1], corner_a[2], corner_b[0], corner_b[1], corner_b[2] );
    //xxxxxxxxxxxxx
    // It looks like the ViewZoomTo2 applies the current view transformation
    // to the given points.
    // This means that we don't need to transform the orientation.
    // Also, it appears that the points are relative to viewing the model at the X-Y plane (Z out of the page)
    //xxxxxxxxxxxxx
    hres = swModel->ViewZoomTo2(dbl_corner_a0[0], dbl_corner_a0[1], dbl_corner_a0[2], dbl_corner_b0[0], dbl_corner_b0[1], dbl_corner_b0[2] );
    if(FAILED(hres)){
        qWarning() << "Could not zoom to calibration region";
    }


    /// Translate the view by corrected view translation

    // Get the updated scale factor
    hres = p_ModelView->get_Scale2(&zoomed_scale);

    // hres = p_ModelView->put_Translation3(swViewTrans);
    hres = p_ModelView->get_Translation3(&swViewTrans);
    swViewTrans->get_ArrayData(static_cast<VARIANT*>(&data_var));
    xlate_vals = SafeDoubleArray(data_var);
    qDebug() << "Translation data";
    for(uint i=0; i<16 && i<xlate_vals.getSize(); i++){
        qDebug()<< xlate_vals[i];
    }

    swViewTrans->Release();
    swViewOrien->Release();
    p_ModelView->Release();
    swModel->Release();

    qDebug() << "Ready to zoom";

    emit complete();
}

bool WorkerZoomLifeSize::create_zoom_settings(){
    return false;
}

/*
double WorkerZoomLifeSize::px2m(int logical_px, double logical_dpi, double physical_dpi){
    double physical_px = logical_px * (physical_dpi/logical_dpi);
    return physical_px/physical_dpi*0.0254;
}*/


double WorkerZoomLifeSize::px2m(int px, double dpi, double correction_factor){
    return px/(dpi*correction_factor)*0.0254;
}


bool WorkerZoomLifeSize::verify_settings_are_current(){

    int n_screens = settings->beginReadArray("screens");
    bool is_valid = true;

    /// Verify the screen count is correct
    int screen_count = settings->value("size").toInt();

    if(qApp->screens().count() != screen_count){
        is_valid = false;
    }else{
        /// Iterate over each screen

        for(int i=0; i < n_screens; ++i){
            settings->setArrayIndex(i);

           /// lookup screen based on screen name
            QScreen* screen = find_screen_by_name(settings->value("name").toString());

           /// Check the physical dimensions
           if(NULL != screen){
               // X dots per inch
               if(!qFuzzyCompare(settings->value("dpi_x").toFloat(),
                                 (float)screen->physicalDotsPerInchX())){
                   qDebug() <<  settings->value("dpi_x").toFloat();
                   qDebug() << screen->physicalDotsPerInchX();
                    is_valid = false;
                    break;
               }

               // Y dots per inch
               if(!qFuzzyCompare(settings->value("dpi_y").toFloat(),
                                 (float)screen->physicalDotsPerInchY())){
                    is_valid = false;
                    break;
               }
           }
        }
    }

    settings->endArray();
    return false;
}

QScreen* WorkerZoomLifeSize::find_screen_by_name(const QString &name){
    foreach (QScreen *screen, qApp->screens()){
        if(screen->name().compare(name) == 0){
            return screen;
        }
    }
    return NULL;
}


