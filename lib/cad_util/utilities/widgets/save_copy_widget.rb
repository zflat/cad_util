require "Qt"

module CadUtil
  module Utility
    class SaveCopyWidget < Qt::Widget
      attr_reader :fpath

      def initialize(parent=nil)
        super(parent)

        @fpath_label = Qt::Label.new("File Name:")

        @fpath = Qt::LineEdit.new(self)
        @fpath_btn = Qt::PushButton.new("Browse...")
        @fpath_layout = Qt::HBoxLayout.new
        @fpath_layout.addWidget(@fpath)
        @fpath_layout.addWidget(@fpath_btn)

        @btn_next =  Qt::PushButton.new("Next")
        @btn_box = Qt::DialogButtonBox.new
        @btn_box.addButton(@btn_next, Qt::DialogButtonBox::ActionRole)

        @fpath_label = Qt::Label.new("File Name:")
        @fpath_label.setBuddy(@fpath)

        @layout = Qt::VBoxLayout.new
        @layout.addWidget(@fpath_label)
        @layout.addLayout(@fpath_layout)
        @layout.addWidget(@btn_box)
        self.setLayout(@layout)

      end


    end # class SaveCopyWidget
  end # module Utility
end # module CadUtil
