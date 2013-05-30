module CadUtil

  module SldConst
    if SldConst.constants.empty?
      arr = WIN32OLE_TYPE.typelibs.select{|t| t =~ /(solidworks).*(const)/i }
      WIN32OLE.const_load(arr[0], SldConst)
    end

    def SldConst.doc_type(fname)
      case File.extname(fname)[1..-1].downcase
      when 'sldasm'
        SldConst::SwDocASSEMBLY
      when 'sldprt'
        SldConst::SwDocPART
      when 'slddrw'
        SldConst::SwDocDRAWING
      else
        SldConst::SwDocNONE
      end
    end

  end

end
