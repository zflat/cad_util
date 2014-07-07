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


/*
  Plugin interface
  See example at:
  http://qt-project.org/doc/qt-5.1/qtwidgets/tools-plugandpaint.html
http://michael-stengel.com/blog/?p=4
https://qt-project.org/doc/qt-5.0/qtwidgets/tools-plugandpaintplugins-basictools.html

Object Factory with plugins:
http://stackoverflow.com/questions/9070817/qobject-factory-in-qt-pluginnon-creator
 */

#ifndef UTIL_WORKER_H
#define UTIL_WORKER_H

#include <QObject>
#include <QHash>
#include <QString>

class UtilWorker : public QObject
{
    Q_OBJECT
 public:
    UtilWorker(int argc=0, char *argv[]=NULL, QObject* parent=0) : QObject( parent ), meta_hash(), \
        is_terminate_requested(false){}
    virtual ~UtilWorker(){}
    virtual void init(){}
    virtual bool is_valid(){return true;}
    virtual void start(){emit complete(0);}
    virtual QString meta_lookup(const QString &key){
        return (meta_hash.contains(key)) ? meta_hash.value(key, QString()) : QString();
    }
    virtual QObject* get_widget(){return NULL;}
public slots:
    /**
     * @brief exit_early indicates that a cancel request has been made.
     */
    virtual void exit_early(){is_terminate_requested = true;}
 signals:
    // notify when we're done
    void complete(int result=0);
  protected:
    QHash<QString, QString> meta_hash;

    /**
     * @brief is_terminate_requested flags the worker that early exit has been requested when set to True
     */
    bool is_terminate_requested;
};

#endif //UTIL_WORKER_H

