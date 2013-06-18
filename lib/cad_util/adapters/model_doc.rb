require "cad_util/context_decorator"

module CadUtil

  class ModelDoc < ContextDecorator

    def self.path_open(fpath, config="", context)
      app = context.app
      setdir_worked = app.set_current_working(File.dirname(fpath))
      type = SldConst.doc_type(fpath)

      e = AsRefArg::new_obj
      w = AsRefArg::new_obj

      doc = app.OpenDoc6(fpath,
                   type,
                   ModelDoc.open_options,
                   config,
                   e, w)
      return ModelDoc.new doc, context
    end

    def save
      e = AsRefArg::new_obj
      w = AsRefArg::new_obj
      model.save3(ModelDoc.save_optns, e, w)
      parse_errors_warnings(*WIN32OLE::ARGV[1..2])
    end

    def save_as(fpath)
      options =
        SldConst::SwSaveAsOptions_Silent|SldConst::SwSaveAsOptions_Copy
      e = AsRefArg::new_obj
      w = AsRefArg::new_obj
      saved = model.SaveAs4(fpath,
                             SldConst::SwSaveAsCurrentVersion,
                            options,
                             e, w)
      parse_errors_warnings(*WIN32OLE::ARGV[1..2])
      return saved
    end

    def close
      context.app.CloseDoc(self.GetPathName)
    end

    def show_isometric
      model.ShowNamedView2 "*Isometric", -1
    end

    def zoom_fit
      model.ViewZoomtofit2
    end

    def change_color(color=nil)
      color ||= random_color
      mat_vals = model.MaterialPropertyValues
      (0..2).to_a.each do |i|
        mat_vals[i] = color[i]
      end

      # Wrap the array as a variant to be compliant
      vals_arr = WIN32OLE_VARIANT.array([mat_vals.count],
                                        WIN32OLE::VARIANT::VT_R8)
      (0..mat_vals.count-1).to_a.each do |i|
        vals_arr[i] = mat_vals[i]
      end

      model.extension.RemoveMaterialProperty(SldConst::SwThisConfiguration,nil)
      model.MaterialPropertyValues = vals_arr
    end

    def doc_type
      SldConst.doc_type(model.GetPathName)
    end

    private

    def random_color
      srand
      prng = Random.new
      3.times.map{prng.rand(0.85)+0.1}
    end

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
        warn w, "Warning opening document"
      end

      if e != 0
        err e, "Error opening document"
      end
    end

    def parse_errors_warnings(e, w)
      if w !=0
        warn w, w, "Warning saving document"

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
        err e, e, "Error saving document"

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
        context.log.warn msg
      end
    end

    def err(val, const, msg)
      if (val & const) != 0
        context.log.error msg
      end
    end

  end # class ModelDoc

end # module CadUtil
