// worker_%ProjectName:l%.h

#ifndef WORKER_%ProjectName:u%_H
#define WORKER_%ProjectName:u%_H

#include <QRunnable>
#include <QObject>
#include "util_worker.h"

#define UTIL_NEW_WORKER new Worker%ProjectName%()
class Worker%ProjectName% : public UtilWorker
{
    Q_OBJECT
public:
    Worker%ProjectName%(int argc=0, char *argv[]=NULL, QObject* parent=0);
    void start();

    QObject* get_widget(){return (QObject*)widget;}
protected:
    QWidget* widget;
};


#endif // WORKER_%ProjectName:u%_H
