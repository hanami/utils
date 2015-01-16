require 'test_helper'
require 'lotus/utils/escape'

describe Lotus::Utils::Escape do
  let(:mod) { Lotus::Utils::Escape }

  describe '.html' do
    TEST_ENCODINGS.each do |encoding|
      describe "#{ encoding }" do
        it "escapes nil" do
          result = mod.html(nil)
          result.must_equal ''
        end

        it "escapes 'test'" do
          result = mod.html('test'.encode(encoding))
          result.must_equal 'test'
        end

        it "escapes '&'" do
          result = mod.html('&'.encode(encoding))
          result.must_equal '&amp;'
        end

        it "escapes '<'" do
          result = mod.html('<'.encode(encoding))
          result.must_equal '&lt;'
        end

        it "escapes '>'" do
          result = mod.html('>'.encode(encoding))
          result.must_equal '&gt;'
        end

        it %(escapes '"') do
          result = mod.html('"'.encode(encoding))
          result.must_equal '&quot;'
        end

        it %(escapes "'") do
          result = mod.html("'".encode(encoding))
          result.must_equal '&apos;'
        end

        it "escapes '/'" do
          result = mod.html('/'.encode(encoding))
          result.must_equal '&#x2F;'
        end

        it "escapes '<script>'" do
          result = mod.html('<script>'.encode(encoding))
          result.must_equal '&lt;script&gt;'
        end

        it "escapes '<scr<script>ipt>'" do
          result = mod.html('<scr<script>ipt>'.encode(encoding))
          result.must_equal '&lt;scr&lt;script&gt;ipt&gt;'
        end

        it "escapes '&lt;script&gt;'" do
          result = mod.html('&lt;script&gt;'.encode(encoding))
          result.must_equal '&amp;lt;script&amp;gt;'
        end
      end
    end
  end

  describe '.html_attribute' do
    TEST_ENCODINGS.each do |encoding|
      describe "#{ encoding }" do
        it "escapes nil" do
          result = mod.html_attribute(nil)
          result.must_equal ''
        end

        it "escapes 'test'" do
          result = mod.html_attribute('test'.encode(encoding))
          result.must_equal 'test'
        end

        it "escapes '&'" do
          result = mod.html_attribute('&'.encode(encoding))
          result.must_equal '&amp;'
        end

        it "escapes '<'" do
          result = mod.html_attribute('<'.encode(encoding))
          result.must_equal '&lt;'
        end

        it "escapes '>'" do
          result = mod.html_attribute('>'.encode(encoding))
          result.must_equal '&gt;'
        end

        it %(escapes '"') do
          result = mod.html_attribute('"'.encode(encoding))
          result.must_equal '&quot;'
        end

        it %(escapes "'") do
          result = mod.html_attribute("'".encode(encoding))
          result.must_equal '&#x27;'
        end

        it "escapes '/'" do
          result = mod.html_attribute('/'.encode(encoding))
          result.must_equal '&#x2f;'
        end

        it "escapes '<script>'" do
          result = mod.html_attribute('<script>'.encode(encoding))
          result.must_equal '&lt;script&gt;'
        end

        it "escapes '<scr<script>ipt>'" do
          result = mod.html_attribute('<scr<script>ipt>'.encode(encoding))
          result.must_equal '&lt;scr&lt;script&gt;ipt&gt;'
        end

        it "escapes '&lt;script&gt;'" do
          result = mod.html_attribute('&lt;script&gt;'.encode(encoding))
          result.must_equal '&amp;lt&#x3b;script&amp;gt&#x3b;'
        end
      end
    end # tests with encodings

    TEST_INVALID_CHARS.each do |char, entity|
      it "escapes '#{ char }'" do
        result = mod.html_attribute(char)
        result.must_equal "&#x#{ TEST_REPLACEMENT_CHAR };"
      end
    end

    it "escapes tab" do
      result = mod.html_attribute("\t")
      result.must_equal "&#x9;"
    end

    it "escapes return carriage" do
      result = mod.html_attribute("\r")
      result.must_equal "&#xd;"
    end

    it "escapes new line" do
      result = mod.html_attribute("\n")
      result.must_equal "&#xa;"
    end

    it "escapes unicode char" do
      result = mod.html_attribute("Ā")
      result.must_equal '&#x100;'
    end

    TEST_HTML_ENTITIES.each do |char, entity|
      test_name = Lotus::Utils.jruby? ? char.ord : char

      it "escapes #{ test_name }" do
        result = mod.html_attribute(char)
        result.must_equal "&#{ entity };"
      end
    end
  end # .html_attribute
end
