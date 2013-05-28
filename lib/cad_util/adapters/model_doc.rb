module CadUtil

  class ModelDoc < BasicDecorator::Decorator

    def self.path_open(fpath, config="")
      c = Connection::App.connection
      app = c.app
      setdir_worked = c.set_current_working(File.dirname(fpath))
      type = c.doc_type(fpath)

      e = AsRefArg::new_obj
      w = AsRefArg::new_obj

      doc = app.OpenDoc6(fpath,
                   type,
                   ModelDoc.open_options,
                   config,
                   e, w)
      return ModelDoc.new doc
    end

    def save
      e = AsRefArg::new_obj
      w = AsRefArg::new_obj
      model.save3(ModelDoc.save_optns, e, w)
      parse_errors_warnings(*WIN32OLE::ARGV[1..2])
    end

    def close
      Connection::App.connection.app.CloseDoc(self.GetPathName)
    end

    private

    def model
      @component
    end

    def self.save_optns
      SldConst::SwSaveAsOptions_Silent |
        SldConst::SwSaveAsOptions_AvoidRebuildOnSave
    end

    def self.open_options
      SldConst::SwOpenDocOptions_Silent
    end

    def parse_open_err_warns(e, w)
      if w != 0
        puts "Warning opening document"
      end

      if e != 0
        puts "Error opening document"
      end
    end

    def parse_errors_warnings(e, w)
      if w !=0
        puts "Warning saving document"

        warn w,
        SldConst::SwFileSaveWarning_RebuildError,
        "Rebuild errors"

        warn w,
        SldConst::SwFileSaveWarning_NeedsRebuild,
        "Needs Rebuild"

        warn w,
        SldConst::SwFileSaveWarning_ViewsNeedUpdate,
        "View need update"

        warn w,
        SldConst::SwFileSaveWarning_AnimatorNeedToSolve,
        "Animator needs to solve"

        warn w,
        SldConst::SwFileSaveWarning_AnimatorFeatureEdits,
        "Animator feature edits"

        warn w,
        SldConst::SwFileSaveWarning_EdrwingsBadSelection,
        "Edrawings bad selection"

        warn w,
        SldConst::SwFileSaveWarning_AnimatorLightEdits,
        "Animator light edits"

        warn w,
        SldConst::SwFileSaveWarning_AnimatorCameraViews,
        "Animator Camera Views"

        warn w,
        SldConst::SwFileSaveWarning_AnimatorSectionViews,
        "Animatory section views"

        warn w,
        SldConst::SwFileSaveWarning_MissingOLEObjects,
        "Missing OLEObjects"

        warn w,
        SldConst::SwFileSaveWarning_OpenedViewOnly,
        "Opened view only"

      end # if w !=0
      if e != 0
        puts "Error saving document"

        err e,
        SldConst::SwReadOnlySaveError,
        "Read only save error"

        err e,
        SldConst::SwFileNameEmpty,
        "File name cannot be empty"

        err e,
        SldConst::SwFileNameContainsAtSign,
        "File name cannot contain the @ symbol"

        err e,
        SldConst::SwFileLockError,
        "File lock error"

        err e,
        SldConst::SwFileSaveFormatNotAvailable,
        "Save As file type is not valid"

        err e,
        SldConst::SwFileSaveAsDoNotOverwrite,
        "Do not overwrite an existing file"

        err e,
        SldConst::SwFileSaveAsInvalidFileExtension,
        "Filename extension does not match the SolidWorks document type"

        err e,
        SldConst::SwFileSaveAsNoSelection,
        "Save the selected bodies in a part document. Valid option for IPartDoc::SaveToFile2; however, not a valid option for IModelDocExtension::SaveAs"

        err e,
        SldConst::SwFileSaveAsBadEDrawingsVersion,
        "Bad EDrawings Version"

        err e,
        SldConst::SwFileSaveAsNameExceedsMaxPathLength,
        "Filename cannot exceed 255 characters"

        err e,
        SldConst::SwFileSaveAsNotSupported,
        "Save may not be supported or may have been was executed is such a way that the resulting file might not be complete, possibly because SolidWorks is hidden; if the error persists after setting SolidWorks to visible and re-attempting the Save As operation, contact SolidWorks API support."

      end # if e != 0
    end # def parse_errors_warnings

    def warn(val, const, msg)
      if (val & const) != 0
        puts msg
      end
    end

    def err(val, const, msg)
      if (val & const) != 0
        puts msg
      end
    end

  end # class ModelDoc

end # module CadUtil
