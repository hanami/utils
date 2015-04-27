module Lotus
  module Utils
    # String inflector
    #
    # @since x.x.x
    module Inflector
      # Rule for irregular plural
      #
      # @since x.x.x
      # @api private
      class IrregularRule
        # @since x.x.x
        # @api private
        def initialize(rules)
          @rules = rules
          @rules.freeze
        end

        # @since x.x.x
        # @api private
        def ===(other)
          key = other.downcase
          @rules.key?(key) || @rules.value?(key)
        end

        # @since x.x.x
        # @api private
        def apply(string)
          key    = string.downcase
          result = @rules[key] || @rules.rassoc(key).last

          string[0] + result[1..-1]
        end
      end

      # Rule for irregular plural, that uses a suffix.
      #
      # @since x.x.x
      # @api private
      class SuffixRule < IrregularRule
        def initialize(matcher, replacement, rules)
          super(rules)
          @matcher     = matcher
          @replacement = replacement
        end

        # @since x.x.x
        # @api private
        def ===(other)
          @rules.key?(other.downcase)
        end

        # @since x.x.x
        # @api private
        def apply(string)
          string.sub(@matcher, @replacement)
        end
      end

      # Matcher for blank strings
      #
      # @since x.x.x
      # @api private
      BLANK_STRING_MATCHER = /\A[[:space:]]*\z/.freeze

      # @since x.x.x
      # @api private
      CHES = 'ches'.freeze

      # @since x.x.x
      # @api private
      IES  = 'ies'.freeze

      # @since x.x.x
      # @api private
      ICE  = 'ice'.freeze

      # @since x.x.x
      # @api private
      ICES = 'ices'.freeze

      # @since x.x.x
      # @api private
      XES  = 'xes'.freeze

      # @since x.x.x
      # @api private
      A    = 'a'.freeze

      # @since x.x.x
      # @api private
      EAUX = 'eaux'.freeze

      # @since x.x.x
      # @api private
      INA  = 'ina'.freeze

      # @since x.x.x
      # @api private
      VES  = 'ves'.freeze

      # @since x.x.x
      # @api private
      SSES = 'sses'.freeze

      # @since x.x.x
      # @api private
      USES = 'uses'.freeze

      # @since x.x.x
      # @api private
      S    = 's'.freeze

      # Plural rule "is" => "es"
      #
      # @since x.x.x
      # @api private
      PLURAL_IS_ES = SuffixRule.new( /is\z/, 'es', {
        'analysis'    => true,
        'axis'        => true,
        'basis'       => true,
        'crisis'      => true,
        'diagnosis'   => true,
        'ellipsis'    => true,
        'hypothesis'  => true,
        'oasis'       => true,
        'paralysis'   => true,
        'parenthesis' => true,
        'synopsis'    => true,
        'synthesis'   => true,
        'thesis'      => true,
      })

      # Plural rule "is" => "ides"
      #
      # @since x.x.x
      # @api private
      PLURAL_IS_IDES = SuffixRule.new( /is\z/, 'ides', {
        'clitoris' => true,
        'iris'     => true,
      })

      # Plural rule "f" => "s"
      #
      # @since x.x.x
      # @api private
      PLURAL_F_S = SuffixRule.new( /\z/, 's', {
        'chief' => true,
        'spoof' => true,
      })

      # Plural rule "o" => "oes"
      #
      # @since x.x.x
      # @api private
      PLURAL_O_OES = SuffixRule.new( /\z/, 'es', {
        'buffalo'  => true,
        'domino'   => true,
        'echo'     => true,
        'embargo'  => true,
        'hero'     => true,
        'mosquito' => true,
        'potato'   => true,
        'tomato'   => true,
        'torpedo'  => true,
        'veto'     => true,
      })

      # Irregular rules
      #
      # @since x.x.x
      # @api private
      PLURAL_IRREGULAR = IrregularRule.new({
        # irregular
        'cactus'       => 'cacti',
        'child'        => 'children',
        'corpus'       => 'corpora',
        'foot'         => 'feet',
        'genus'        => 'genera',
        'goose'        => 'geese',
        'man'          => 'men',
        'ox'           => 'oxen',
        'person'       => 'people',
        'quiz'         => 'quizzes',
        'sex'          => 'sexes',
        'testis'       => 'testes',
        'tooth'        => 'teeth',
        'woman'        => 'women',
        # uncountable
        'deer'         => 'deer',
        'equipment'    => 'equipment',
        'fish'         => 'fish',
        'information'  => 'information',
        'means'        => 'means',
        'money'        => 'money',
        'news'         => 'news',
        'offspring'    => 'offspring',
        'rice'         => 'rice',
        'series'       => 'series',
        'sheep'        => 'sheep',
        'species'      => 'species',
        # a            => ae
        'alumna'       => 'alumnae',
        'alga'         => 'algae',
        'vertebra'     => 'vertebrae',
        'persona'      => 'personae',
        'antenna'      => 'antennae',
        'formula'      => 'formulae',
        'nebula'       => 'nebulae',
        'vita'         => 'vitae',
        # on           => a
        'criterion'    => 'criteria',
        'perihelion'   => 'perihelia',
        'aphelion'     => 'aphelia',
        'phenomenon'   => 'phenomena',
        'prolegomenon' => 'prolegomena',
        'noumenon'     => 'noumena',
        'organon'      => 'organa',
        'asyndeton'    => 'asyndeta',
        'hyperbaton'   => 'hyperbata',
        # us           => i
        'alumnus'      => 'alumni',
        'alveolus'     => 'alveoli',
        'bacillus'     => 'bacilli',
        'bronchus'     => 'bronchi',
        'locus'        => 'loci',
        'nucleus'      => 'nuclei',
        'stimulus'     => 'stimuli',
        'meniscus'     => 'menisci',
        'thesaurus'    => 'thesauri',
        # a            => ata
        'anathema'     => 'anathemata',
        'enema'        => 'enemata',
        'oedema'       => 'oedemata',
        'bema'         => 'bemata',
        'enigma'       => 'enigmata',
        'sarcoma'      => 'sarcomata',
        'carcinoma'    => 'carcinomata',
        'gumma'        => 'gummata',
        'schema'       => 'schemata',
        'charisma'     => 'charismata',
        'lemma'        => 'lemmata',
        'soma'         => 'somata',
        'diploma'      => 'diplomata',
        'lymphoma'     => 'lymphomata',
        'stigma'       => 'stigmata',
        'dogma'        => 'dogmata',
        'magma'        => 'magmata',
        'stoma'        => 'stomata',
        'drama'        => 'dramata',
        'melisma'      => 'melismata',
        'trauma'       => 'traumata',
        'edema'        => 'edemata',
        'miasma'       => 'miasmata',
        # s => es
        'acropolis'    => 'acropolises',
        'chaos'        => 'chaoses',
        'lens'         => 'lenses',
        'aegis'        => 'aegises',
        'cosmos'       => 'cosmoses',
        'mantis'       => 'mantises',
        'alias'        => 'aliases',
        'dais'         => 'daises',
        'marquis'      => 'marquises',
        'asbestos'     => 'asbestoses',
        'digitalis'    => 'digitalises',
        'metropolis'   => 'metropolises',
        'atlas'        => 'atlases',
        'epidermis'    => 'epidermises',
        'pathos'       => 'pathoses',
        'bathos'       => 'bathoses',
        'ethos'        => 'ethoses',
        'pelvis'       => 'pelvises',
        'bias'         => 'biases',
        'gas'          => 'gases',
        'polis'        => 'polises',
        'caddis'       => 'caddises',
        'rhinoceros'   => 'rhinoceroses',
        'cannabis'     => 'cannabises',
        'glottis'      => 'glottises',
        'sassafras'    => 'sassafrases',
        'canvas'       => 'canvases',
        'ibis'         => 'ibises',
        'trellis'      => 'trellises',
      })


      # Irregular rules
      #
      # @since x.x.x
      # @api private
      SINGULAR_IRREGULAR = IrregularRule.new({
        # irregular
        'cacti'   => 'cactus',
        'children'=> 'child',
        'corpora' => 'corpus',
        'feet'    => 'foot',
        'genera'  => 'genus',
        'geese'   => 'goose',
        'men'     => 'man',
        'oxen'    => 'ox',
        'people'  => 'person',
        'quizzes' => 'quiz',
        'sexes'   => 'sex',
        'testes'  => 'testis',
        'teeth'   => 'tooth',
        'women'   => 'woman',
        # uncountable
        'deer'        => 'deer',
        'equipment'   => 'equipment',
        'fish'        => 'fish',
        'information' => 'information',
        'means'       => 'means',
        'money'       => 'money',
        'news'        => 'news',
        'offspring'   => 'offspring',
        'rice'        => 'rice',
        'series'      => 'series',
        'sheep'       => 'sheep',
        'species'     => 'species',
        'police'      => 'police',
        # ae => a
        'alumnae'   => 'alumna',
        'algae'     => 'alga',
        'vertebrae' => 'vertebra',
        'personae'  => 'persona',
        'antennae'  => 'antenna',
        'formulae'  => 'formula',
        'nebulae'   => 'nebula',
        'vitae'     => 'vita',
        # a = on
        'criteria'    => 'criterion',
        'perihelia'   => 'perihelion',
        'aphelia'     => 'aphelion',
        'phenomena'   => 'phenomenon',
        'prolegomena' => 'prolegomenon',
        'noumena'     => 'noumenon',
        'organa'      => 'organon',
        'asyndeta'    => 'asyndeton',
        'hyperbata'   => 'hyperbaton',
        # ses => s
        'acropolises'  => 'acropolis',
        'chaoses'      => 'chaos',
        'lenses'       => 'lens',
        'aegises'      => 'aegis',
        'cosmoses'     => 'cosmos',
        'mantises'     => 'mantis',
        'aliases'      => 'alias',
        'daises'       => 'dais',
        'marquises'    => 'marquis',
        'asbestoses'   => 'asbestos',
        'digitalises'  => 'digitalis',
        'metropolises' => 'metropolis',
        'atlases'      => 'atlas',
        'epidermises'  => 'epidermis',
        'pathoses'     => 'pathos',
        'bathoses'     => 'bathos',
        'ethoses'      => 'ethos',
        'pelvises'     => 'pelvis',
        'biases'       => 'bias',
        'gases'        => 'gas',
        'polises'      => 'polis',
        'caddises'     => 'caddis',
        'rhinoceroses' => 'rhinoceros',
        'cannabises'   => 'cannabis',
        'glottises'    => 'glottis',
        'sassafrases'  => 'sassafras',
        'canvases'     => 'canvas',
        'ibises'       => 'ibis',
        'trellises'    => 'trellis',
        # fallback
        'hives' => 'hive',
        # ices => ex
        "codices"    => "codex",
        "murices"    => "murex",
        "silices"    => "silex",
        "apices"     => "apex",
        "latices"    => "latex",
        "vertices"   => "vertex",
        "cortices"   => "cortex",
        "pontifices" => "pontifex",
        "vortices"   => "vortex",
        "indices"    => "index",
        "simplices"  => "simplex",
        # ices => ix
        "radices"    => "radix",
        "helices"    => "helix",
        "appendices" => "appendix",
        # es => is
        "axes"        => "axis",
        "analyses"    => "analysis",
        "bases"       => "basis",
        "crises"      => "crisis",
        "diagnoses"   => "diagnosis",
        "ellipses"    => "ellipsis",
        "hypotheses"  => "hypothesis",
        "oases"       => "oasis",
        "paralyses"   => "paralysis",
        "parentheses" => "parenthesis",
        "syntheses"   => "synthesis",
        "synopses"    => "synopsis",
        "theses"      => "thesis",
      })

      # Pluralize the given string
      #
      # @param [String] the singular string
      #
      # @return [String,NilClass] the pluralized string, if present
      #
      # @since x.x.x
      def self.pluralize(string)
        return string if string.nil? || string.match(BLANK_STRING_MATCHER)

        case string
        when PLURAL_IRREGULAR
          PLURAL_IRREGULAR.apply(string)
        when /\A((.*)[^aeiou])ch\z/
          $1 + CHES
        when /\A((.*)[^aeiou])y\z/
          $1 + IES
        when /\A(.*)(ex|ix)\z/
          $1 + ICES
        when /\A(.*)(eau|#{ EAUX })\z/
          $1 + EAUX
        when /\A(.*)x\z/
          $1 + XES
        when /\A(.*)(um|#{ A })\z/
          $1 + A
        when /\A(.*)(ouse|#{ ICE })\z/
          $1 + ICE
        when PLURAL_O_OES
          PLURAL_O_OES.apply(string)
        when /\A(.*)(en|#{ INA })\z/
          $1 + INA
        when PLURAL_F_S
          PLURAL_F_S.apply(string)
        when /\A(.*)(?:([^f]))f[e]*\z/
          $1 + $2 + VES
        when /\A(.*)us\z/
          $1 + USES
        when PLURAL_IS_ES
          PLURAL_IS_ES.apply(string)
        when PLURAL_IS_IDES
          PLURAL_IS_IDES.apply(string)
        when /\A(.*)ss\z/
          $1 + SSES
        when /s\z/
          string
        else
          string + S
        end
      end

      # Singularize the given string
      #
      # @param [String] the pliral string
      #
      # @return [String,NilClass] the singularized string, if present
      #
      # @since x.x.x
      def self.singularize(string)
        return string if string.nil? || string.match(BLANK_STRING_MATCHER)

        case string
        when SINGULAR_IRREGULAR
          SINGULAR_IRREGULAR.apply(string)
        when /\A.*[^aeiou]#{CHES}\z/
          string.sub(CHES, 'ch')
        when /\A.*[^aeiou]#{IES}\z/
          string.sub(IES, 'y')
        when /\A(.*)#{ICE}\z/
          $1 + 'ouse'
        when /\A.*#{EAUX}\z/
          string.chop
        when /\A(.*)ides\z/
          $1 + 'is'
        when /\A(.*)us\z/
          $1 + 'i'
        when /\A(.*)ses\z/
          $1 + 's'
        when /\A(.*)ouse\z/
          $1 + 'ice'
        when /\A(.*)mata\z/
          $1 + 'ma'
        when /\A(.*)oes\z/
          $1 + 'o'
        when /\A(.*)mina\z/
          $1 + 'men'
        when /\A(.*)xes\z/
          $1 + 'x'
        when /\A(.*)ives\z/
          $1 + 'ife'
        when /\A(.*)ves\z/
          $1 + 'f'
        when /\A(.*)i\z/
          $1 + 'us'
        when /\A(.*)a\z/
          $1 + 'um'
        else
          string.chop
        end
      end
    end
  end
end
