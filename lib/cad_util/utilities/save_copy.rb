
module CadUtil

  class SaveCopy
    include Connection

    def get_current_working
      app.GetCurrentWorkingDirectory
    end
  end # class SaveCopy

end # module CadUtil
