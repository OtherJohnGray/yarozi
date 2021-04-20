class Logging


  def level
    @level ||= ( ENV["YAROZI_LOG_LEVEL"] || "ERROR" )
  end

  def logger
    @logger ||= (
      l = Logger.new("log/PID-#{Process.pid}-#{Thread.current.inspect}.log")
      l.level = Logger.const_get level
      l
    )
  end

  %w(debug info warn error critical).each do |methodname|
    define_method(methodname.to_sym) do |message|
      if level > 
      logger.send level.to_sym, message
    end
  end


end


def self.start

  Object.class_eval { 
    def log
      Thread.current.thread_variable_set("log", Logging.new) unless Thread.current.thread_variable?("log")
      Thread.current.thread_variable_get("log")
    end
  }
end


end