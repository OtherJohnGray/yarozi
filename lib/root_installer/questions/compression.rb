class RootInstaller::Questions::Compression < Question

    attr_reader :root_compression_type

    def ask
      dialog.title = "Root Dataset Compression"
      dialog.nocancel = true
      text = <<~TEXT

        This installer can configure compression for your root dataset. 
        
        Please select encryption type you want from the list below. For configurable compression types such as gzip, zstd, and zstd-fast, you can configure the compression level in a subsequent screen.

      TEXT

      items = [
        ["off", "Do not encrypt the root dataset"],
        ["gzip", "low speed and high compression"],
        ["lz4", "high speed and good compression"],
        ["lzjb", "good performance and compression"],
        ["zle", "Just compress runs of zeros"],
        ["zstd", "good speed and high compression"],
        ["zstd-fast", "high speed and good compression"]
      ]

      height = 19
      width = 76
      menu_height = 6
      
      @root_compression_type = dialog.menu(text, items, height, width, menu_height)
      case @root_compression_type
      when "gzip"
        follow_on_questions << RootInstaller::Questions::GzipLevel.new( task )
      when "zstd"
        follow_on_questions << RootInstaller::Questions::ZstdLevel.new( task )
      when "zstd-fast"
        follow_on_questions << RootInstaller::Questions::ZstdFastLevel.new( task )
      end
    end

end