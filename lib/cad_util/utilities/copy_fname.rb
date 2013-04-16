require 'clipboard'

module CadUtil

  class CopyFname
    include Connection

    attr_reader :model

    def initialize(model = nil)
      @model ||= active_model
    end

    def valid?
      !model.nil?
    end

    def run
      if valid?
        Clipboard.copy model.GetPathName
      end
    end

  end # class SaveCopy

end # module CadUtil
