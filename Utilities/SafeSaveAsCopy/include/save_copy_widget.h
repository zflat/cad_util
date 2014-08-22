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
    void set_fpath_str(const QString & fpath);
    void select_fpath_base_name();
    void ui_enable(bool is_enabled);

signals:
    void save_accepted();

private slots:
    void on_fpath_btn_clicked();

private:
    Ui::SaveCopyWidget *ui;
};

#endif // SAVE_COPY_WIDGET_H
