// worker_random_color_change.h

#ifndef WORKER_RANDOM_COLOR_CHANGE_H
#define WORKER_RANDOM_COLOR_CHANGE_H


#include <QRunnable>
#include <QObject>
#include "util_worker.h"

#define UTIL_NEW_WORKER new WorkerRandomColorChange()
class WorkerRandomColorChange : public UtilWorker
{
    Q_OBJECT
public:
    WorkerRandomColorChange(int argc=0, char *argv[]=NULL, QObject* parent=0);
    void start();
    void init();
    void cleanup();

    QObject* get_widget(){return (QObject*)widget;}
protected:
    QWidget* widget;
};


#endif // WORKER_RANDOM_COLOR_CHANGE_H
