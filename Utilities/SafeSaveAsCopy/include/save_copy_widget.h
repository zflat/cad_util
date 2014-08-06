#ifndef SAVE_COPY_WIDGET_H
#define SAVE_COPY_WIDGET_H

#include <QWidget>
#include <QDialogButtonBox>

namespace Ui {
class SaveCopyWidget;
}

class SaveCopyWidget : public QWidget
{
    Q_OBJECT

public:
    explicit SaveCopyWidget(QWidget *parent = 0);
    ~SaveCopyWidget();

    QString fpath();


private:
    Ui::SaveCopyWidget *ui;
};

#endif // SAVE_COPY_WIDGET_H
