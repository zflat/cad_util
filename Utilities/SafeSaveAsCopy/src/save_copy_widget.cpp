#include "save_copy_widget.h"
#include "ui_save_copy_widget.h"

SaveCopyWidget::SaveCopyWidget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::SaveCopyWidget)
{
    ui->setupUi(this);
}

SaveCopyWidget::~SaveCopyWidget()
{
    delete ui;
}
