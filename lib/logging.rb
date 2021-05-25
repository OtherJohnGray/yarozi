require 'logger'

class Logging

  def level
    @level ||= Logger.const_get( ENV["YAROZI_LOG_LEVEL"] || "ERROR" )
  end

  def logger
    @logger ||= (
      l = Logger.new("log/#{Process.pid}-#{Thread.current.inspect.delete_suffix(' run>').tr('#<Thread:','')}.log")
      l.level = level
      l
    )
  end

  %w(debug info warn error critical).each do |methodname|
    define_method(methodname.to_sym) do |message|
      logger.send methodname.to_sym, message unless Logger.const_get(methodname.upcase) < level
    end
  end

  def self.setup
    Object.class_eval { 
      def log
        Thread.current.thread_variable_set("log", Logging.new) unless Thread.current.thread_variable?("log")
        Thread.current.thread_variable_get("log")
      end
    }
  end


end