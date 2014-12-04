// worker_zoomlifesize.h

#ifndef WORKER_ZOOMLIFESIZE_H
#define WORKER_ZOOMLIFESIZE_H

#include <QRunnable>
#include <QObject>
#include <QSettings>
#include <QScreen>
#include "util_worker.h"


#include "sldcontext.h"
#include "sld_model.h"
#include "m3d_helper.h"

#define UTIL_NEW_WORKER new WorkerZoomLifeSize()
class WorkerZoomLifeSize : public UtilWorker
{
    Q_OBJECT
public:
    WorkerZoomLifeSize(int argc=0, char *argv[]=NULL, QObject* parent=0);
    ~WorkerZoomLifeSize();
    void start();

    QObject* get_widget(){return (QObject*)widget;}
protected:

    // Flag that indicates if calibration is needed
    bool requires_calibration;


    bool verify_settings_are_current();

    /*
     * Will override any existing settings
     */
    bool create_zoom_settings();

    QScreen* find_screen_by_name(const QString & name);

    QWidget* widget;    
    QSettings* settings;

    SldContext * context;
    ISldWorksPtr swAppPtr;

    M3dHelper * math;

    /**
     * @brief px2m converts pixles to meters
     * @param px pixels
     * @param dpi physical dots per inch
     * @return meters
     */
    double px2m(int px, double dpi, double correction_factor=1.0);
};


#endif // WORKER_ZOOMLIFESIZE_H

