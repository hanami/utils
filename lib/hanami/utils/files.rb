module Hanami
  module Utils
    # Files utilities
    #
    # @since x.x.x
    module Files
      def self.touch(path)
        write(path, "")
      end

      def self.write(path, *content)
        Pathname.new(path).dirname.mkpath
        open(path, ::File::CREAT | ::File::WRONLY, *content)
      end

      def self.rewrite(path, *content)
        open(path, ::File::TRUNC | ::File::WRONLY, *content)
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
        content = ::File.readlines(path)
        content << "#{contents}\n"

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

      def self.index(content, path, target)
        line_number(content, target) or
          raise ArgumentError.new("Cannot find `#{target}' inside `#{path}'.")
      end

      def self.containts?(content, target)
        !line_number(content, target).nil?
      end

      def self.line_number(content, target)
        content.index { |l| l.include?(target) }
      end
    end
  end
end
