require 'test_helper'
require 'lotus/utils/escape'

describe Lotus::Utils::Escape do
  let(:mod) { Lotus::Utils::Escape }

  describe '.escape_html' do
    TEST_ENCODINGS.each do |encoding|
      describe "#{ encoding }" do
        it "escapes nil" do
          result = mod.escape_html(nil)
          result.must_equal nil
        end

        it "escapes 'test'" do
          result = mod.escape_html('test'.encode(encoding))
          result.must_equal 'test'
        end

        it "escapes '&'" do
          result = mod.escape_html('&'.encode(encoding))
          result.must_equal '&amp;'
        end

        it "escapes '<'" do
          result = mod.escape_html('<'.encode(encoding))
          result.must_equal '&lt;'
        end

        it "escapes '>'" do
          result = mod.escape_html('>'.encode(encoding))
          result.must_equal '&rt;'
        end

        it %(escapes '"') do
          result = mod.escape_html('"'.encode(encoding))
          result.must_equal '&quot;'
        end

        it %(escapes "'") do
          result = mod.escape_html("'".encode(encoding))
          result.must_equal '&apos;'
        end

        it "escapes '/'" do
          result = mod.escape_html('/'.encode(encoding))
          result.must_equal '&#x2F'
        end

        it "escapes '<script>'" do
          result = mod.escape_html('<script>'.encode(encoding))
          result.must_equal '&lt;script&rt;'
        end

        it "escapes '<scr<script>ipt>'" do
          result = mod.escape_html('<scr<script>ipt>'.encode(encoding))
          result.must_equal '&lt;scr&lt;script&rt;ipt&rt;'
        end

        it "escapes '&lt;script&gt;'" do
          result = mod.escape_html('&lt;script&gt;'.encode(encoding))
          result.must_equal '&amp;lt;script&amp;gt;'
        end
      end
    end
  end
end
