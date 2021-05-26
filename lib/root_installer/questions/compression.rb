class RootInstaller::Questions::Compression < Question

  def text
    <<~TEXT

      This installer can configure compression for your root dataset. 
      
      Please select encryption type you want from the list below. For configurable compression types such as gzip, zstd, and zstd-fast, you can configure the compression level in a subsequent screen.

    TEXT
  end

  def ask
    wizard.title = "Root Dataset Compression"
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
      
    @choice = wizard.ask(text, items, height, width, menu_height)
  end

  def respond
    task.set :root_compression_type, @choice
    case @choice
    when "gzip"
      subquestions.append RootInstaller::Questions::Compression::GzipLevel.new( task )
    when "zstd"
      subquestions.append RootInstaller::Questions::Compression::ZstdLevel.new( task )
    when "zstd-fast"
      subquestions.append RootInstaller::Questions::Compression::ZstdFastLevel.new( task )
    end
  end


  class GzipLevel < Question
  end


  class ZstdLevel < Question
  end


  class ZstdFastLevel < Question
  end


end