// worker_random_color_change.h

#ifndef WORKER_SAFE_SAVE_AS_COPY_H
#define WORKER_SAFE_SAVE_AS_COPY_H


#include <QRunnable>
#include <QObject>
#include "util_worker.h"
#include "save_copy_widget.h"
#include "sld_model.h"

#define UTIL_NEW_WORKER new WorkerSafeSaveAsCopy()
class WorkerSafeSaveAsCopy : public UtilWorker
{
    Q_OBJECT
public:
    WorkerSafeSaveAsCopy(int argc=0, char *argv[]=NULL, QObject* parent=0);
    void start();

    QObject* get_widget(){return (QObject*)widget;}
protected:
    SaveCopyWidget* widget;

private slots:
    void process_save();

private:
    QString fpath_0();
    SldModel* model;
    bool waiting_for_input;
};


#endif // WORKER_SAFE_SAVE_AS_COPY_H
