#include <QClipboard>
#include <QDebug>
#include <QFileInfo>

#include "name_reporter_widget.h"
#include "ui_name_reporter_widget.h"

NameReporterWidget::NameReporterWidget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::NameReporterWidget)
{
    ui->setupUi(this);
}

NameReporterWidget::~NameReporterWidget()
{
    delete ui;
}

void NameReporterWidget::report_action(const QString & name){

    QClipboard *clipboard = QApplication::clipboard();
    clipboard->setText(name);
    ui->lineEdit->setText(name);

    // ((QLabel*)widget)->setText(qstr);
}

void NameReporterWidget::on_pushButton_pressed()
{

    QFileInfo info(ui->lineEdit->text());
    info.fileName();

    int name_start = ui->lineEdit->text().lastIndexOf(info.fileName());
    ui->lineEdit->setSelection(name_start, info.baseName().length());

    QClipboard *clipboard = QApplication::clipboard();
    clipboard->setText(ui->lineEdit->selectedText());
}
