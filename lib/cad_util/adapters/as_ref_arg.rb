module CadUtil
  module AsRefArg
    attr_accessor :value

    def AsRefArg.new_obj
      WIN32OLE_VARIANT.new(0,
                           WIN32OLE::VARIANT::VT_BYREF|
                           WIN32OLE::VARIANT::VT_I4).extend AsRefArg
    end
  end

end
