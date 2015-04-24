module Lotus
  module Utils
    module Inflector
      class IrregularRule
        def initialize(rules)
          @rules = rules
          @rules.freeze
        end

        def ===(other)
          key = other.downcase
          @rules.key?(key) || @rules.value?(key)
        end

        def apply(string)
          key    = string.downcase
          result = @rules[key] || @rules.rassoc(key).last

          string[0] + result[1..-1]
        end
      end

      class SuffixRule < IrregularRule
        def initialize(matcher, replacement, rules)
          super(rules)
          @matcher     = matcher
          @replacement = replacement
        end

        def apply(string)
          string.sub(@matcher, @replacement)
        end
      end

      BLANK_STRING_MATCHER = /\A[[:space:]]*\z/.freeze

      CHES = 'ches'.freeze
      IES  = 'ies'.freeze
      ICE  = 'ice'.freeze
      ICES = 'ices'.freeze
      XES  = 'xes'.freeze
      A    = 'a'.freeze
      EAUX = 'eaux'.freeze
      INA  = 'ina'.freeze
      VES  = 'ves'.freeze
      SSES = 'sses'.freeze
      USES = 'uses'.freeze
      S    = 's'.freeze

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

      PLURAL_IS_IDES = SuffixRule.new( /is\z/, 'ides', {
        'clitoris' => true,
        'iris'     => true,
      })

      PLURAL_F_S = SuffixRule.new( /\z/, 's', {
        'chief' => true,
        'spoof' => true,
      })

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
    end
  end
end
