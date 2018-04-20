module Hanami
  # Abstract mutable result
  class Result
    def initialize(data = {})
      @data   = data
      @result = nil
    end

    def []=(key, value)
      @data[key.to_sym] = value
    end

    def [](key)
      @data.fetch(key, nil)
    end

    def fail(*messages)
      @result = Failure.new(*messages, @data)
    end

    def error(exception, code: nil, message: nil)
      @result = Error.new(exception, code: code, message: message)
    end

    def result
      @result || Success.new(@data)
    end
  end

  # Successful result
  class Success
    def initialize(data = {})
      @data = data.freeze
      freeze
    end

    def [](key)
      @data.fetch(key, nil)
    end
  end

  # Failing result
  class Failure < Success
    attr_reader :messages

    def initialize(*messages, **data)
      @messages = Array(messages).flatten.freeze
      super(data)
    end

    def message
      messages.first
    end
  end

  # Error result
  class Error < Success
    attr_reader :exception, :code, :message

    def initialize(exception, code: :error, message: nil)
      @exception = exception
      @message = message.nil? ? exception.message : message
      @code = code
      freeze
    end

    def backtrace
      exception.backtrace
    end
  end
end
