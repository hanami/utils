module Lotus
  module Utils
    # String inflector
    #
    # @since 0.4.1
    # @api private
    module Inflector
      # Rule for irregular plural
      #
      # @since 0.4.1
      # @api private
      class IrregularRule
        # @since 0.4.1
        # @api private
        def initialize(rules)
          @rules = rules
          @rules.freeze
        end

        # @since 0.4.1
        # @api private
        def ===(other)
          key = other.downcase
          @rules.key?(key) || @rules.value?(key)
        end

        # @since 0.4.1
        # @api private
        def apply(string)
          key    = string.downcase
          result = @rules[key] || @rules.rassoc(key).last

          string[0] + result[1..-1]
        end
      end

      # Rule for irregular plural, that uses a suffix.
      #
      # @since 0.4.1
      # @api private
      class SuffixRule < IrregularRule
        def initialize(matcher, replacement, rules)
          super(rules)
          @matcher     = matcher
          @replacement = replacement
        end

        # @since 0.4.1
        # @api private
        def ===(other)
          @rules.key?(other.downcase)
        end

        # @since 0.4.1
        # @api private
        def apply(string)
          string.sub(@matcher, @replacement)
        end
      end

      # Matcher for blank strings
      #
      # @since 0.4.1
      # @api private
      BLANK_STRING_MATCHER = /\A[[:space:]]*\z/.freeze

      # @since 0.4.1
      # @api private
      A    = 'a'.freeze

      # @since 0.4.1
      # @api private
      CH   = 'ch'.freeze

      # @since 0.4.1
      # @api private
      CHES = 'ches'.freeze

      # @since 0.4.1
      # @api private
      EAUX = 'eaux'.freeze

      # @since 0.4.1
      # @api private
      F    = 'f'.freeze

      # @since 0.4.1
      # @api private
      I    = 'i'.freeze

      # @since 0.4.1
      # @api private
      ICE  = 'ice'.freeze

      # @since 0.4.1
      # @api private
      ICES = 'ices'.freeze

      # @since 0.4.1
      # @api private
      IDES = 'ides'.freeze

      # @since 0.4.1
      # @api private
      IES  = 'ies'.freeze

      # @since 0.4.1
      # @api private
      IFE  = 'ife'.freeze

      # @since 0.4.1
      # @api private
      INA  = 'ina'.freeze

      # @since 0.4.1
      # @api private
      IS   = 'is'.freeze

      # @since 0.4.1
      # @api private
      IVES = 'ives'.freeze

      # @since 0.4.1
      # @api private
      MA   = 'ma'.freeze

      # @since 0.4.1
      # @api private
      MATA = 'mata'.freeze

      # @since 0.4.1
      # @api private
      MEN  = 'men'.freeze

      # @since 0.4.1
      # @api private
      MINA = 'mina'.freeze

      # @since 0.4.1
      # @api private
      O    = 'o'.freeze

      # @since 0.4.1
      # @api private
      OES  = 'oes'.freeze

      # @since 0.4.1
      # @api private
      OUSE = 'ouse'.freeze

      # @since 0.4.1
      # @api private
      S    = 's'.freeze

      # @since 0.4.1
      # @api private
      SES  = 'ses'.freeze

      # @since 0.4.1
      # @api private
      SSES = 'sses'.freeze

      # @since 0.4.1
      # @api private
      UM   = 'um'.freeze

      # @since 0.4.1
      # @api private
      US   = 'us'.freeze

      # @since 0.4.1
      # @api private
      USES = 'uses'.freeze

      # @since 0.4.1
      # @api private
      VES  = 'ves'.freeze

      # @since 0.4.1
      # @api private
      X    = 'x'.freeze

      # @since 0.4.1
      # @api private
      XES  = 'xes'.freeze

      # @since 0.4.1
      # @api private
      Y    = 'y'.freeze

      # Plural rule "is" => "es"
      #
      # @since 0.4.1
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
      # @since 0.4.1
      # @api private
      PLURAL_IS_IDES = SuffixRule.new( /is\z/, 'ides', {
        'clitoris' => true,
        'iris'     => true,
      })

      # Plural rule "f" => "s"
      #
      # @since 0.4.1
      # @api private
      PLURAL_F_S = SuffixRule.new( /\z/, 's', {
        'chief' => true,
        'spoof' => true,
      })

      # Plural rule "o" => "oes"
      #
      # @since 0.4.1
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
      # @since 0.4.1
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
      # @since 0.4.1
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
        'horses'       => 'horse',
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
      # @param string [String] a string to pluralize
      #
      # @return [String,NilClass] the pluralized string, if present
      #
      # @api private
      # @since 0.4.1
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
      # @param string [String] a string to singularize
      #
      # @return [String,NilClass] the singularized string, if present
      #
      # @api private
      # @since 0.4.1
      def self.singularize(string)
        return string if string.nil? || string.match(BLANK_STRING_MATCHER)

        case string
        when SINGULAR_IRREGULAR
          SINGULAR_IRREGULAR.apply(string)
        when /\A.*[^aeiou]#{CHES}\z/
          string.sub(CHES, CH)
        when /\A.*[^aeiou]#{IES}\z/
          string.sub(IES, Y)
        when /\A(.*)#{ICE}\z/
          $1 + OUSE
        when /\A.*#{EAUX}\z/
          string.chop
        when /\A(.*)#{IDES}\z/
          $1 + IS
        when /\A(.*)#{US}\z/
          $1 + I
        when /\A(.*)#{SES}\z/
          $1 + S
        when /\A(.*)#{OUSE}\z/
          $1 + ICE
        when /\A(.*)#{MATA}\z/
          $1 + MA
        when /\A(.*)#{OES}\z/
          $1 + O
        when /\A(.*)#{MINA}\z/
          $1 + MEN
        when /\A(.*)#{XES}\z/
          $1 + X
        when /\A(.*)#{IVES}\z/
          $1 + IFE
        when /\A(.*)#{VES}\z/
          $1 + F
        when /\A(.*)#{I}\z/
          $1 + US
        when /\A(.*)#{A}\z/
          $1 + UM
        when /[^s]\z/
          string
        else
          string.chop
        end
      end
    end
  end
end
