
module CadUtil

  class SavePreview
    include Connection

    attr_reader :model

    def initialize(model = nil)
      @model ||= active_model
    end

    def valid?
      !model.nil?
    end

    def run
      set_preview
      model.save
    end

    private

    def set_preview
      show_isometric
      zoom_fit
    end

    def show_isometric
      model.ShowNamedView2 "*Isometric", -1
    end

    def zoom_fit
      model.ViewZoomtofit2
    end
  end # class SaveCopy

end # module CadUtil
