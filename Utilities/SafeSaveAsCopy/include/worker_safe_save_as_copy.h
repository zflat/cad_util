// worker_random_color_change.h

#ifndef WORKER_SAFE_SAVE_AS_COPY_H
#define WORKER_SAFE_SAVE_AS_COPY_H


#include <QRunnable>
#include <QObject>
#include "util_worker.h"
#include "save_copy_widget.h"

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
};


#endif // WORKER_SAFE_SAVE_AS_COPY_H
