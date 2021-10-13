class RootInstaller::Questions::Compression < Question

  def text
    <<~TEXT

      This installer can configure compression for your root dataset. 
      
      Please select encryption type you want from the list below. For configurable compression types such as gzip, zstd, and zstd-fast, you can configure the compression level in a subsequent screen.

    TEXT
  end

  def ask
    wizard.title = "Root Dataset Compression"
    wizard.notags = false
    wizard.default_item = task.root_compression_type if task.respond_to? :root_compression_type
    items = [
      ["off", "Do not compress the root dataset"],
      ["gzip", "low speed and high compression"],
      ["lz4", "high speed and good compression"],
      ["lzjb", "good performance and compression"],
      ["zle", "Just compress runs of zeros"],
      ["zstd", "good speed and high compression"],
      ["zstd-fast", "high speed and good compression"]
    ]

    height = 19
    width = 76
    menu_height = 7
      
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
    def text
      <<~TEXT
  
        Use the up and down arrow keys to select the GZip compression level you want, or press enter to accept the default compression level of 6. 
        
        GZip compression level is between 1 (fastest) and 9 (best compression).
  
      TEXT
    end
  
    def ask
      wizard.title = "GZip Compression Level"
      wizard.default_item = task.respond_to?(:gzip_compression_level) ? task.gzip_compression_level.to_s : "6"
      items = [
        ["1", "Use GZip compression level 1"],
        ["2", "Use GZip compression level 2"],
        ["3", "Use GZip compression level 3"],
        ["4", "Use GZip compression level 4"],
        ["5", "Use GZip compression level 5"],
        ["6", "Use GZip compression level 6"],
        ["7", "Use GZip compression level 7"],
        ["8", "Use GZip compression level 8"],
        ["9", "Use GZip compression level 9"]
      ]
  
      height = 12
      width = 76
      menu_height = 1
        
      @choice = wizard.ask(text, items, height, width, menu_height)
    end
  
    def respond
      task.set :gzip_compression_level, @choice.to_i
    end

  end


  class ZstdLevel < Question
    def text
      <<~TEXT
  
        Use the up and down arrow keys to select the zstd compression level you want, or press enter to accept the default compression level of 3. 
        
        zstd compression level is between 1 (fastest) and 19 (best compression).
  
      TEXT
    end
  
    def ask
      wizard.title = "zstd Compression Level"
      wizard.default_item = task.respond_to?(:zstd_compression_level) ? task.zstd_compression_level.to_s : "3"
      items = [
        ["1",  "Use zstd compression level 1"],
        ["2",  "Use zstd compression level 2"],
        ["3",  "Use zstd compression level 3"],
        ["4",  "Use zstd compression level 4"],
        ["5",  "Use zstd compression level 5"],
        ["6",  "Use zstd compression level 6"],
        ["7",  "Use zstd compression level 7"],
        ["8",  "Use zstd compression level 8"],
        ["9",  "Use zstd compression level 9"],
        ["10", "Use zstd compression level 10"],
        ["11", "Use zstd compression level 11"],
        ["12", "Use zstd compression level 12"],
        ["13", "Use zstd compression level 13"],
        ["14", "Use zstd compression level 14"],
        ["15", "Use zstd compression level 15"],
        ["16", "Use zstd compression level 16"],
        ["17", "Use zstd compression level 17"],
        ["18", "Use zstd compression level 18"],
        ["19", "Use zstd compression level 19"]
      ]
  
      height = 12
      width = 76
      menu_height = 1
        
      @choice = wizard.ask(text, items, height, width, menu_height)
    end
  
    def respond
      task.set :zstd_compression_level, @choice.to_i
    end
  end


  class ZstdFastLevel < Question
    def text
      <<~TEXT
  
        Use the up and down arrow keys to select the zstd-fast compression level you want, or press enter to accept the default compression level of 1. 
        
        zstd-fast compression level is between 1 (best compression) and 1000 (fastest).
  
      TEXT
    end
  
    def ask
      wizard.title = "zstd-fast Compression Level"
      wizard.default_item = task.respond_to?(:zstd_fast_compression_level) ? task.zstd_fast_compression_level.to_s : "1"
      items = [
        ["1",    "Use zstd-fast compression level 1"],
        ["2",    "Use zstd-fast compression level 2"],
        ["3",    "Use zstd-fast compression level 3"],
        ["4",    "Use zstd-fast compression level 4"],
        ["5",    "Use zstd-fast compression level 5"],
        ["6",    "Use zstd-fast compression level 6"],
        ["7",    "Use zstd-fast compression level 7"],
        ["8",    "Use zstd-fast compression level 8"],
        ["9",    "Use zstd-fast compression level 9"],
        ["10",   "Use zstd-fast compression level 10"],
        ["20",   "Use zstd-fast compression level 20"],
        ["30",   "Use zstd-fast compression level 30"],
        ["40",   "Use zstd-fast compression level 40"],
        ["50",   "Use zstd-fast compression level 50"],
        ["60",   "Use zstd-fast compression level 60"],
        ["70",   "Use zstd-fast compression level 70"],
        ["80",   "Use zstd-fast compression level 80"],
        ["90",   "Use zstd-fast compression level 90"],
        ["100",  "Use zstd-fast compression level 100"],
        ["500",  "Use zstd-fast compression level 500"],
        ["1000", "Use zstd-fast compression level 1000"]
      ]
  
      height = 12
      width = 76
      menu_height = 1
        
      @choice = wizard.ask(text, items, height, width, menu_height)
    end
  
    def respond
      task.set :zstd_fast_compression_level, @choice.to_i
    end
  end


end
