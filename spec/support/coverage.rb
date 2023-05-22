if ENV["CI"]
  require "simplecov"

  SimpleCov.command_name ENV.fetch("SIMPLECOV_COMMAND_NAME", "spec:unit")
  SimpleCov.start do
    add_filter(/spec/)
  end
end
