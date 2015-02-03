require 'test_helper'
require 'lotus/utils'
require 'lotus/utils/escape'

describe Lotus::Utils::Escape do
  let(:mod) { Lotus::Utils::Escape }

  describe '.html' do
    TEST_ENCODINGS.each do |encoding|
      describe "#{ encoding }" do
        it "doesn't escape safe string" do
          input  = Lotus::Utils::Escape::SafeString.new('&')
          result = mod.html(input.encode(encoding))
          result.must_equal '&'
        end

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

        it %(escapes '""><script>xss(5)</script>') do
          result = mod.html('""><script>xss(5)</script>'.encode(encoding))
          result.must_equal '&quot;&quot;&gt;&lt;script&gt;xss(5)&lt;&#x2F;script&gt;'
        end

        it %(escapes '><script>xss(6)</script>') do
          result = mod.html('><script>xss(6)</script>'.encode(encoding))
          result.must_equal '&gt;&lt;script&gt;xss(6)&lt;&#x2F;script&gt;'
        end

        it %(escapes '# onmouseover="xss(7)" ') do
          result = mod.html('# onmouseover="xss(7)" '.encode(encoding))
          result.must_equal '# onmouseover=&quot;xss(7)&quot; '
        end

        it %(escapes '/" onerror="xss(9)">') do
          result = mod.html('/" onerror="xss(9)">'.encode(encoding))
          result.must_equal '&#x2F;&quot; onerror=&quot;xss(9)&quot;&gt;'
        end

        it %(escapes '/ onerror="xss(10)"') do
          result = mod.html('/ onerror="xss(10)"'.encode(encoding))
          result.must_equal '&#x2F; onerror=&quot;xss(10)&quot;'
        end

        it %(escapes '<<script>xss(14);//<</script>') do
          result = mod.html('<<script>xss(14);//<</script>'.encode(encoding))
          result.must_equal '&lt;&lt;script&gt;xss(14);&#x2F;&#x2F;&lt;&lt;&#x2F;script&gt;'
        end
      end
    end
  end

  describe '.html_attribute' do
    TEST_ENCODINGS.each do |encoding|
      describe "#{ encoding }" do
        it "doesn't escape safe string" do
          input  = Lotus::Utils::Escape::SafeString.new('&')
          result = mod.html_attribute(input.encode(encoding))
          result.must_equal '&'
        end

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

        it %(escapes '""><script>xss(5)</script>') do
          result = mod.html_attribute('""><script>xss(5)</script>'.encode(encoding))
          result.must_equal '&quot;&quot;&gt;&lt;script&gt;xss&#x28;5&#x29;&lt;&#x2f;script&gt;'
        end

        it %(escapes '><script>xss(6)</script>') do
          result = mod.html_attribute('><script>xss(6)</script>'.encode(encoding))
          result.must_equal '&gt;&lt;script&gt;xss&#x28;6&#x29;&lt;&#x2f;script&gt;'
        end

        it %(escapes '# onmouseover="xss(7)" ') do
          result = mod.html_attribute('# onmouseover="xss(7)" '.encode(encoding))
          result.must_equal '&#x23;&#x20;onmouseover&#x3d;&quot;xss&#x28;7&#x29;&quot;&#x20;'
        end

        it %(escapes '/" onerror="xss(9)">') do
          result = mod.html_attribute('/" onerror="xss(9)">'.encode(encoding))
          result.must_equal '&#x2f;&quot;&#x20;onerror&#x3d;&quot;xss&#x28;9&#x29;&quot;&gt;'
        end

        it %(escapes '/ onerror="xss(10)"') do
          result = mod.html_attribute('/ onerror="xss(10)"'.encode(encoding))
          result.must_equal '&#x2f;&#x20;onerror&#x3d;&quot;xss&#x28;10&#x29;&quot;'
        end

        it %(escapes '<<script>xss(14);//<</script>') do
          result = mod.html_attribute('<<script>xss(14);//<</script>'.encode(encoding))
          result.must_equal '&lt;&lt;script&gt;xss&#x28;14&#x29;&#x3b;&#x2f;&#x2f;&lt;&lt;&#x2f;script&gt;'
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

    it "doesn't escape ','" do
      result = mod.html_attribute(",")
      result.must_equal ','
    end

    it "doesn't escape '.'" do
      result = mod.html_attribute(".")
      result.must_equal '.'
    end

    it "doesn't escape '-'" do
      result = mod.html_attribute("-")
      result.must_equal '-'
    end

    it "doesn't escape '_'" do
      result = mod.html_attribute("_")
      result.must_equal '_'
    end

    TEST_HTML_ENTITIES.each do |char, entity|
      test_name = Lotus::Utils.jruby? ? char.ord : char

      it "escapes #{ test_name }" do
        result = mod.html_attribute(char)
        result.must_equal "&#{ entity };"
      end
    end
  end # .html_attribute

  describe '.url' do
    TEST_ENCODINGS.each do |encoding|
      describe "#{ encoding }" do
        it "doesn't escape safe string" do
          input  = Lotus::Utils::Escape::SafeString.new('javascript:alert(0);')
          result = mod.url(input.encode(encoding))
          result.must_equal 'javascript:alert(0);'
        end

        it "escapes nil" do
          result = mod.url(nil)
          result.must_equal ''
        end

        it "escapes 'test'" do
          result = mod.url('test'.encode(encoding))
          result.must_equal ''
        end

        it "escapes 'http://lotusrb.org'" do
          result = mod.url('http://lotusrb.org'.encode(encoding))
          result.must_equal 'http://lotusrb.org'
        end

        it "escapes 'https://lotusrb.org'" do
          result = mod.url('https://lotusrb.org'.encode(encoding))
          result.must_equal 'https://lotusrb.org'
        end

        it "escapes 'https://lotusrb.org#introduction'" do
          result = mod.url('https://lotusrb.org#introduction'.encode(encoding))
          result.must_equal 'https://lotusrb.org#introduction'
        end

        it "escapes 'https://lotusrb.org/guides/index.html'" do
          result = mod.url('https://lotusrb.org/guides/index.html'.encode(encoding))
          result.must_equal 'https://lotusrb.org/guides/index.html'
        end

        it "escapes 'mailto:user@example.com'" do
          result = mod.url('mailto:user@example.com'.encode(encoding))
          result.must_equal 'mailto:user@example.com'
        end

        it "escapes 'mailto:user@example.com?Subject=Hello'" do
          result = mod.url('mailto:user@example.com?Subject=Hello'.encode(encoding))
          result.must_equal 'mailto:user@example.com?Subject=Hello'
        end

        it "escapes 'javascript:alert(1);'" do
          result = mod.url('javascript:alert(1);'.encode(encoding))
          result.must_equal ''
        end

        # See https://github.com/mzsanford/twitter-text-rb/commit/cffce8e60b7557e9945fc0e8b4383e5a66b1558f
        it %(escapes 'http://x.xx/@"style="color:pink"onmouseover=alert(1)//') do
          result = mod.url('http://x.xx/@"style="color:pink"onmouseover=alert(1)//'.encode(encoding))
          result.must_equal 'http://x.xx/@'
        end

        it %{escapes 'http://x.xx/("style="color:red"onmouseover="alert(1)'} do
          result = mod.url('http://x.xx/("style="color:red"onmouseover="alert(1)'.encode(encoding))
          result.must_equal 'http://x.xx/('
        end

        it %(escapes 'http://x.xx/@%22style=%22color:pink%22onmouseover=alert(1)//') do
          result = mod.url('http://x.xx/@%22style=%22color:pink%22onmouseover=alert(1)//'.encode(encoding))
          result.must_equal 'http://x.xx/@'
        end
      end
    end
  end
end
