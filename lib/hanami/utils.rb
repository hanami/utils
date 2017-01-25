# Hanami - The web, with simplicity
#
# @since 0.1.0
module Hanami
  require 'hanami/utils/version'
  require 'hanami/utils/file_list'

  # Ruby core extentions and Hanami utilities
  #
  # @since 0.1.0
  module Utils
    # @since 0.3.1
    # @api private
    HANAMI_JRUBY = 'java'.freeze

    # @since 0.3.1
    # @api private
    HANAMI_RUBINIUS = 'rbx'.freeze

    # Checks if the current VM is JRuby
    #
    # @return [TrueClass,FalseClass] return if the VM is JRuby or not
    #
    # @since 0.3.1
    # @api private
    def self.jruby?
      RUBY_PLATFORM == HANAMI_JRUBY
    end

    # Checks if the current VM is Rubinius
    #
    # @return [TrueClass,FalseClass] return if the VM is Rubinius or not
    #
    # @since 0.3.1
    # @api private
    def self.rubinius?
      RUBY_ENGINE == HANAMI_RUBINIUS
    end

    # Recursively require Ruby files under the given directory.
    #
    # If the directory is relative, it implies it's the path from current directory.
    # If the directory is absolute, it uses as it is.
    #
    # It respects file separator of the current operating system.
    # A pattern like <tt>"path/to/files"</tt> will work both on *NIX and Windows machines.
    #
    # @param directory [String, Pathname] the directory
    #
    # @since 0.9.0
    def self.require!(directory)
      for_each_file_in(directory) { |file| require_relative(file) }
    end

    # Recursively reload Ruby files under the given directory.
    #
    # If the directory is relative, it implies it's the path from current directory.
    # If the directory is absolute, it uses as it is.
    #
    # It respects file separator of the current operating system.
    # A pattern like <tt>"path/to/files"</tt> will work both on *NIX and Windows machines.
    #
    # @param directory [String, Pathname] the directory
    #
    # @since x.x.x
    # @api private
    def self.reload!(directory)
      for_each_file_in(directory) { |file| load(file) }
    end

    # Recursively scans through the given directory and yields the given block
    # for each Ruby source file.
    #
    # If the directory is relative, it implies it's the path from current directory.
    # If the directory is absolute, it uses as it is.
    #
    # It respects file separator of the current operating system.
    # A pattern like <tt>"path/to/files"</tt> will work both on *NIX and Windows machines.
    #
    # @param directory [String, Pathname] the directory
    # @param blk [Proc] the block to yield
    #
    # @since x.x.x
    # @api private
    def self.for_each_file_in(directory, &blk)
      directory = directory.to_s.gsub(%r{(\/|\\)}, File::SEPARATOR)
      directory = Pathname.new(Dir.pwd).join(directory).to_s
      directory = File.join(directory, '**', '*.rb') unless directory =~ /(\*\*)/

      FileList[directory].each(&blk)
    end
  end
end
