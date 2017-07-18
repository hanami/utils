require "pathname"
require "fileutils"

module Hanami
  module Utils
    # Files utilities
    #
    # @since x.x.x
    module Files # rubocop:disable Metrics/ModuleLength
      def self.touch(path)
        write(path, "")
      end

      def self.write(path, *content)
        mkdir_p(path)
        open(path, ::File::CREAT | ::File::WRONLY, *content)
      end

      def self.rewrite(path, *content)
        open(path, ::File::TRUNC | ::File::WRONLY, *content)
      end

      def self.cp(source, destination)
        mkdir_p(destination)
        FileUtils.cp(source, destination)
      end

      def self.mkdir(path)
        FileUtils.mkdir_p(path)
      end

      def self.mkdir_p(path)
        Pathname.new(path).dirname.mkpath
      end

      def self.delete(path)
        FileUtils.rm(path)
      end

      def self.delete_directory(path)
        FileUtils.remove_entry_secure(path)
      end

      def self.replace(path, target, replacement)
        content = ::File.readlines(path)
        content[index(content, path, target)] = "#{replacement}\n"

        rewrite(path, content)
      end

      def self.replace_last(path, target, replacement)
        content = ::File.readlines(path)
        content[-index(content.reverse, path, target) - 1] = "#{replacement}\n"

        rewrite(path, content)
      end

      def self.unshift(path, line)
        content = ::File.readlines(path)
        content.unshift("#{line}\n")

        rewrite(path, content)
      end

      def self.append(path, contents)
        mkdir_p(path)

        content = ::File.readlines(path)
        content << "#{contents}\n"

        rewrite(path, content)
      end

      def self.inject_after(path, contents, after)
        content = ::File.readlines(path)
        i       = index(content, path, after)

        content.insert(i + 1, "#{contents}\n")
        rewrite(path, content)
      end

      def self.remove_line(path, contents)
        content = ::File.readlines(path)
        i       = index(content, path, contents)

        content.delete_at(i)
        rewrite(path, content)
      end

      def self.remove_block(path, target) # rubocop:disable Metrics/AbcSize
        content  = ::File.readlines(path)
        starting = index(content, path, target)
        line     = content[starting]
        size     = line[/\A[[:space:]]*/].bytesize
        closing  = (" " * size) + (target =~ /{/ ? '}' : 'end')
        ending   = starting + index(content[starting..-1], path, closing)

        content.slice!(starting..ending)
        rewrite(path, content)

        remove_block(path, target) if containts?(content, target)
      end

      def self.open(path, mode, *content)
        ::File.open(path, mode) do |file|
          file.write(Array(content).flatten.join)
        end
      end

      def self.contents(path)
        ::IO.read(Hanami.root.join(path))
      end

      def self.read_matching_line(path, target)
        content = ::File.readlines(path)
        line    = content.find do |l|
          case target
          when ::String
            l.include?(target)
          when Regexp
            l =~ target
          end
        end

        line or raise ArgumentError.new("Cannot find `#{target}' inside `#{path}'.")
      end

      def self.index(content, path, target)
        line_number(content, target) or
          raise ArgumentError.new("Cannot find `#{target}' inside `#{path}'.")
      end

      def self.exist?(path)
        File.exist?(path)
      end

      def self.directory?(path)
        File.directory?(path)
      end

      def self.containts?(content, target)
        !line_number(content, target).nil?
      end

      def self.line_number(content, target)
        content.index do |l|
          case target
          when ::String
            l.include?(target)
          when Regexp
            l =~ target
          end
        end
      end
    end
  end
end
