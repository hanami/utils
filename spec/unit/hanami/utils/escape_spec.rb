require 'hanami/utils'
require 'hanami/utils/escape'

RSpec.describe Hanami::Utils::Escape do
  let(:mod) { Hanami::Utils::Escape }

  TEST_ENCODINGS = Encoding.name_list.each_with_object(['UTF-8']) do |encoding, result|
    test_string = '<script>'.encode(Encoding::UTF_8)

    string = begin
              test_string.encode(encoding)
            rescue
              nil
            end

    result << encoding if !string.nil? && string != test_string
  end

  describe '.html' do
    TEST_ENCODINGS.each do |encoding|
      describe encoding.to_s do
        it "doesn't escape safe string" do
          input  = Hanami::Utils::Escape::SafeString.new('&')
          result = mod.html(input.encode(encoding))
          expect(result).to eq '&'
        end

        it 'escapes nil' do
          result = mod.html(nil)
          expect(result).to eq ''
        end

        it "escapes 'test'" do
          result = mod.html('test'.encode(encoding))
          expect(result).to eq 'test'
        end

        it "escapes '&'" do
          result = mod.html('&'.encode(encoding))
          expect(result).to eq '&amp;'
        end

        it "escapes '<'" do
          result = mod.html('<'.encode(encoding))
          expect(result).to eq '&lt;'
        end

        it "escapes '>'" do
          result = mod.html('>'.encode(encoding))
          expect(result).to eq '&gt;'
        end

        it %(escapes '"') do
          result = mod.html('"'.encode(encoding))
          expect(result).to eq '&quot;'
        end

        it %(escapes "'") do
          result = mod.html("'".encode(encoding))
          expect(result).to eq '&apos;'
        end

        it "escapes '/'" do
          result = mod.html('/'.encode(encoding))
          expect(result).to eq '&#x2F;'
        end

        it "escapes '<script>'" do
          result = mod.html('<script>'.encode(encoding))
          expect(result).to eq '&lt;script&gt;'
        end

        it "escapes '<scr<script>ipt>'" do
          result = mod.html('<scr<script>ipt>'.encode(encoding))
          expect(result).to eq '&lt;scr&lt;script&gt;ipt&gt;'
        end

        it "escapes '&lt;script&gt;'" do
          result = mod.html('&lt;script&gt;'.encode(encoding))
          expect(result).to eq '&amp;lt;script&amp;gt;'
        end

        it %(escapes '""><script>xss(5)</script>') do
          result = mod.html('""><script>xss(5)</script>'.encode(encoding))
          expect(result).to eq '&quot;&quot;&gt;&lt;script&gt;xss(5)&lt;&#x2F;script&gt;'
        end

        it %(escapes '><script>xss(6)</script>') do
          result = mod.html('><script>xss(6)</script>'.encode(encoding))
          expect(result).to eq '&gt;&lt;script&gt;xss(6)&lt;&#x2F;script&gt;'
        end

        it %(escapes '# onmouseover="xss(7)" ') do
          result = mod.html('# onmouseover="xss(7)" '.encode(encoding))
          expect(result).to eq '# onmouseover=&quot;xss(7)&quot; '
        end

        it %(escapes '/" onerror="xss(9)">') do
          result = mod.html('/" onerror="xss(9)">'.encode(encoding))
          expect(result).to eq '&#x2F;&quot; onerror=&quot;xss(9)&quot;&gt;'
        end

        it %(escapes '/ onerror="xss(10)"') do
          result = mod.html('/ onerror="xss(10)"'.encode(encoding))
          expect(result).to eq '&#x2F; onerror=&quot;xss(10)&quot;'
        end

        it %(escapes '<<script>xss(14);//<</script>') do
          result = mod.html('<<script>xss(14);//<</script>'.encode(encoding))
          expect(result).to eq '&lt;&lt;script&gt;xss(14);&#x2F;&#x2F;&lt;&lt;&#x2F;script&gt;'
        end
      end
    end

    it 'escapes word with different encoding' do
      skip 'There is no ASCII-8BIT encoding' unless Encoding.name_list.include?('ASCII-8BIT')

      # rubocop:disable Style/AsciiComments
      # 'тест' means test in russian
      string   = 'тест'.force_encoding('ASCII-8BIT')
      encoding = string.encoding

      result = mod.html(string)
      expect(result).to eq 'тест'
      expect(result.encoding).to eq Encoding::UTF_8

      expect(string.encoding).to eq encoding
    end
  end

  describe '.html_attribute' do
    TEST_ENCODINGS.each do |encoding|
      describe encoding.to_s do
        it "doesn't escape safe string" do
          input  = Hanami::Utils::Escape::SafeString.new('&')
          result = mod.html_attribute(input.encode(encoding))
          expect(result).to eq '&'
        end

        it 'escapes nil' do
          result = mod.html_attribute(nil)
          expect(result).to eq ''
        end

        it "escapes 'test'" do
          result = mod.html_attribute('test'.encode(encoding))
          expect(result).to eq 'test'
        end

        it "escapes '&'" do
          result = mod.html_attribute('&'.encode(encoding))
          expect(result).to eq '&amp;'
        end

        it "escapes '<'" do
          result = mod.html_attribute('<'.encode(encoding))
          expect(result).to eq '&lt;'
        end

        it "escapes '>'" do
          result = mod.html_attribute('>'.encode(encoding))
          expect(result).to eq '&gt;'
        end

        it %(escapes '"') do
          result = mod.html_attribute('"'.encode(encoding))
          expect(result).to eq '&quot;'
        end

        it %(escapes "'") do
          result = mod.html_attribute("'".encode(encoding))
          expect(result).to eq '&#x27;'
        end

        it "escapes '/'" do
          result = mod.html_attribute('/'.encode(encoding))
          expect(result).to eq '&#x2f;'
        end

        it "escapes '<script>'" do
          result = mod.html_attribute('<script>'.encode(encoding))
          expect(result).to eq '&lt;script&gt;'
        end

        it "escapes '<scr<script>ipt>'" do
          result = mod.html_attribute('<scr<script>ipt>'.encode(encoding))
          expect(result).to eq '&lt;scr&lt;script&gt;ipt&gt;'
        end

        it "escapes '&lt;script&gt;'" do
          result = mod.html_attribute('&lt;script&gt;'.encode(encoding))
          expect(result).to eq '&amp;lt&#x3b;script&amp;gt&#x3b;'
        end

        it %(escapes '""><script>xss(5)</script>') do
          result = mod.html_attribute('""><script>xss(5)</script>'.encode(encoding))
          expect(result).to eq '&quot;&quot;&gt;&lt;script&gt;xss&#x28;5&#x29;&lt;&#x2f;script&gt;'
        end

        it %(escapes '><script>xss(6)</script>') do
          result = mod.html_attribute('><script>xss(6)</script>'.encode(encoding))
          expect(result).to eq '&gt;&lt;script&gt;xss&#x28;6&#x29;&lt;&#x2f;script&gt;'
        end

        it %(escapes '# onmouseover="xss(7)" ') do
          result = mod.html_attribute('# onmouseover="xss(7)" '.encode(encoding))
          expect(result).to eq '&#x23;&#x20;onmouseover&#x3d;&quot;xss&#x28;7&#x29;&quot;&#x20;'
        end

        it %(escapes '/" onerror="xss(9)">') do
          result = mod.html_attribute('/" onerror="xss(9)">'.encode(encoding))
          expect(result).to eq '&#x2f;&quot;&#x20;onerror&#x3d;&quot;xss&#x28;9&#x29;&quot;&gt;'
        end

        it %(escapes '/ onerror="xss(10)"') do
          result = mod.html_attribute('/ onerror="xss(10)"'.encode(encoding))
          expect(result).to eq '&#x2f;&#x20;onerror&#x3d;&quot;xss&#x28;10&#x29;&quot;'
        end

        it %(escapes '<<script>xss(14);//<</script>') do
          result = mod.html_attribute('<<script>xss(14);//<</script>'.encode(encoding))
          expect(result).to eq '&lt;&lt;script&gt;xss&#x28;14&#x29;&#x3b;&#x2f;&#x2f;&lt;&lt;&#x2f;script&gt;'
        end
      end
    end # tests with encodings

    TEST_INVALID_CHARS.each_key do |char|
      it "escapes '#{char}'" do
        result = mod.html_attribute(char)
        expect(result).to eq "&#x#{TEST_REPLACEMENT_CHAR};"
      end
    end

    it 'escapes tab' do
      result = mod.html_attribute("\t")
      expect(result).to eq '&#x9;'
    end

    it 'escapes return carriage' do
      result = mod.html_attribute("\r")
      expect(result).to eq '&#xd;'
    end

    it 'escapes new line' do
      result = mod.html_attribute("\n")
      expect(result).to eq '&#xa;'
    end

    it 'escapes unicode char' do
      result = mod.html_attribute('Ā')
      expect(result).to eq '&#x100;'
    end

    it "doesn't escape ','" do
      result = mod.html_attribute(',')
      expect(result).to eq ','
    end

    it "doesn't escape '.'" do
      result = mod.html_attribute('.')
      expect(result).to eq '.'
    end

    it "doesn't escape '-'" do
      result = mod.html_attribute('-')
      expect(result).to eq '-'
    end

    it "doesn't escape '_'" do
      result = mod.html_attribute('_')
      expect(result).to eq '_'
    end

    TEST_HTML_ENTITIES.each do |char, entity|
      test_name = Hanami::Utils.jruby? ? char.ord : char

      it "escapes #{test_name}" do
        result = mod.html_attribute(char)
        expect(result).to eq "&#{entity};"
      end
    end
  end # .html_attribute

  describe '.url' do
    TEST_ENCODINGS.each do |encoding|
      describe encoding.to_s do
        it "doesn't escape safe string" do
          input  = Hanami::Utils::Escape::SafeString.new('javascript:alert(0);')
          result = mod.url(input.encode(encoding))
          expect(result).to eq 'javascript:alert(0);'
        end

        it 'escapes nil' do
          result = mod.url(nil)
          expect(result).to eq ''
        end

        it "escapes 'test'" do
          result = mod.url('test'.encode(encoding))
          expect(result).to eq ''
        end

        it "escapes 'http://hanamirb.org'" do
          result = mod.url('http://hanamirb.org'.encode(encoding))
          expect(result).to eq 'http://hanamirb.org'
        end

        it "escapes 'https://hanamirb.org'" do
          result = mod.url('https://hanamirb.org'.encode(encoding))
          expect(result).to eq 'https://hanamirb.org'
        end

        it "escapes 'https://hanamirb.org#introduction'" do
          result = mod.url('https://hanamirb.org#introduction'.encode(encoding))
          expect(result).to eq 'https://hanamirb.org#introduction'
        end

        it "escapes 'https://hanamirb.org/guides/index.html'" do
          result = mod.url('https://hanamirb.org/guides/index.html'.encode(encoding))
          expect(result).to eq 'https://hanamirb.org/guides/index.html'
        end

        it "escapes 'mailto:user@example.com'" do
          result = mod.url('mailto:user@example.com'.encode(encoding))
          expect(result).to eq 'mailto:user@example.com'
        end

        it "escapes 'mailto:user@example.com?Subject=Hello'" do
          result = mod.url('mailto:user@example.com?Subject=Hello'.encode(encoding))
          expect(result).to eq 'mailto:user@example.com?Subject=Hello'
        end

        it "escapes 'javascript:alert(1);'" do
          result = mod.url('javascript:alert(1);'.encode(encoding))
          expect(result).to eq ''
        end

        # See https://github.com/mzsanford/twitter-text-rb/commit/cffce8e60b7557e9945fc0e8b4383e5a66b1558f
        it %(escapes 'http://x.xx/@"style="color:pink"onmouseover=alert(1)//') do
          result = mod.url('http://x.xx/@"style="color:pink"onmouseover=alert(1)//'.encode(encoding))
          expect(result).to eq 'http://x.xx/@'
        end

        it %{escapes 'http://x.xx/("style="color:red"onmouseover="alert(1)'} do
          result = mod.url('http://x.xx/("style="color:red"onmouseover="alert(1)'.encode(encoding))
          expect(result).to eq 'http://x.xx/('
        end

        it %(escapes 'http://x.xx/@%22style=%22color:pink%22onmouseover=alert(1)//') do
          result = mod.url('http://x.xx/@%22style=%22color:pink%22onmouseover=alert(1)//'.encode(encoding))
          expect(result).to eq 'http://x.xx/@'
        end
      end

      describe 'encodes non-String objects that respond to `.to_s`' do
        TEST_ENCODINGS.each do |enc|
          describe enc.to_s do
            it 'escapes a Date' do
              result = mod.html(Date.new(2016, 0o1, 27))
              expect(result).to eq '2016-01-27'
            end

            it 'escapes a Time' do
              time_string = Hanami::Utils.jruby? ? '2016-01-27 12:00:00 UTC' : '2016-01-27 12:00:00 +0000'
              result = mod.html(Time.new(2016, 0o1, 27, 12, 0, 0, 0))
              expect(result).to eq time_string
            end

            it 'escapes a DateTime' do
              result = mod.html(DateTime.new(2016, 0o1, 27, 12, 0, 0, 0))
              expect(result).to eq '2016-01-27T12:00:00+00:00'
            end
          end
        end
      end
    end
  end
end
