module CadUtil

  module SldConst
    def SldConst.doc_type(fname)
      return nil if fname.nil?
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
    
    private 
    
    def SldConst.load_constants(fname, module_name)  
      # Check for constants store  
      if File.exist?(fname)
        require fname
        include const_get(module_name)
      else
        # Load from WIN32OLE if no store found
        if SldConst.constants.empty?
          arr = WIN32OLE_TYPE.typelibs.select{|t| t =~ /^(solidworks).*(const)/i }
          WIN32OLE.const_load(arr[0], SldConst)
        end    
        
        # Save loaded constants to store for later use
        SldConst.store_constants(fname, module_name)
      end
    end
    
    def SldConst.store_constants(fname, module_name)
      File.open(fname, 'w') do |f|
        f.puts "module #{module_name}"
        SldConst.constants[0..SldConst.constants.length-2].each do |c|
          f.puts "#{c}=#{SldConst.const_get(c, false)}"
        end
        f.puts "end"
      end
    end
    
    # Load constants
    SldConst.load_constants File.join(ENV['SCRIPT_ENTRY'], 'sld_const_store.rb'), 'SldConstStore'

  end

end
