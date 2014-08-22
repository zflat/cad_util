#include "save_copy_widget.h"
#include "ui_save_copy_widget.h"

#include <QFileDialog>

SaveCopyWidget::SaveCopyWidget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::SaveCopyWidget)
{
    ui->setupUi(this);    
    QObject::connect(ui->btn_box, SIGNAL(accepted()), this, SIGNAL(save_accepted()));
    connect(ui->txt_fpath, SIGNAL(returnPressed()), this, SIGNAL(save_accepted()));

    this->setFocusProxy(ui->txt_fpath);
}

SaveCopyWidget::~SaveCopyWidget()
{
    delete ui;
}

void SaveCopyWidget::on_fpath_btn_clicked()
{
    QString fpath_str = QFileDialog::getSaveFileName(this, "File Name", ui->txt_fpath->text(), "Solidworks File");

    if(!fpath_str.isNull() && !fpath_str.isEmpty()){
        // Set the text path
        set_fpath_str(fpath_str);
        // emit accepted signal
        ui->btn_box->accepted();
    }
}

void SaveCopyWidget::set_fpath_str(const QString &fpath){
    ui->txt_fpath->setText(fpath);
}

void SaveCopyWidget::select_fpath_base_name(){
    QString fbasename = QFileInfo(fpath()).completeBaseName();
    ui->txt_fpath->setSelection(fpath().indexOf(fbasename), fbasename.length());
}

void SaveCopyWidget::ui_enable(bool is_enabled){
    ui->txt_fpath->setEnabled(is_enabled);
    ui->btn_box->setEnabled(is_enabled);
    ui->fpath_btn->setEnabled(is_enabled);
}

QString SaveCopyWidget::fpath(){
    return ui->txt_fpath->text();
}
