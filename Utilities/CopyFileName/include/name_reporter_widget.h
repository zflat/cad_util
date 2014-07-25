#ifndef NAME_REPORTER_WIDGET_H
#define NAME_REPORTER_WIDGET_H

#include <QWidget>

namespace Ui {
class NameReporterWidget;
}

class NameReporterWidget : public QWidget
{
    Q_OBJECT

public:
    explicit NameReporterWidget(QWidget *parent = 0);
    ~NameReporterWidget();

public slots:
    void report_action(const QString & name);

private slots:
    void on_pushButton_pressed();

private:
    Ui::NameReporterWidget *ui;
};

#endif // NAME_REPORTER_WIDGET_H
