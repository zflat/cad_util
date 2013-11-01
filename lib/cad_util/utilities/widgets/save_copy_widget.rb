require "Qt"

module CadUtil
  module Utility
    class SaveCopyWidget < Qt::Widget
      attr_reader :fpath, :btn_box

      def initialize(parent=nil)
        super(parent)

        @fpath_label = Qt::Label.new("File Name:")

        @fpath = Qt::LineEdit.new(self)
        @fpath_btn = Qt::PushButton.new("Browse...")
        @fpath_btn.connect(SIGNAL(:clicked)){
          fpath_prompt(self, "File Name", @fpath.text, "SldWorks File")
        }

        @fpath_layout = Qt::HBoxLayout.new
        @fpath_layout.addWidget(@fpath)
        @fpath_layout.addWidget(@fpath_btn)

        @btn_box = Qt::DialogButtonBox.new(Qt::DialogButtonBox::Save)

        @fpath_label = Qt::Label.new("File Name:")
        @fpath_label.setBuddy(@fpath)

        @layout = Qt::VBoxLayout.new
        @layout.addWidget(@fpath_label)
        @layout.addLayout(@fpath_layout)
        @layout.addWidget(@btn_box)
        self.setLayout(@layout)

      end

      def fpath_prompt(*dialog_args)
        fpath_txt = Qt::FileDialog.getSaveFileName(*dialog_args)
        unless fpath_txt.nil?
          # set the text path
          @fpath.setText fpath_txt
          # emit accepted signal
          @btn_box.accepted
        end
      end

    end # class SaveCopyWidget
  end # module Utility
end # module CadUtil
