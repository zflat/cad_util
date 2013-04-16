module CadUtil

  module SldConst
    if SldConst.constants.empty?
      arr = WIN32OLE_TYPE.typelibs.select{|t| t =~ /(solidworks).*(const)/i }
      WIN32OLE.const_load(arr[0], SldConst)
    end
  end

end
