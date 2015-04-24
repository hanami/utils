module Lotus
  module Utils
    module Inflector
      class IrregularRule
        def initialize(rules)
          @rules = rules
          @rules.freeze
        end

        def ===(other)
          @rules.key?(other)
        end

        def apply(string)
          @rules[string]
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

      CHES = 'ches'.freeze
      IES  = 'ies'.freeze
      ICE  = 'ice'.freeze
      ICES = 'ices'.freeze
      XES  = 'xes'.freeze
      A    = 'a'.freeze
      EAUX = 'eaux'.freeze
      INA  = 'ina'.freeze
      VES  = 'ves'.freeze
      SES  = 'ses'.freeze
      USES = 'uses'.freeze
      ATA  = 'ata'.freeze
      S    = 's'.freeze

      PLURAL_A_AE = SuffixRule.new( /\z/, 'e', {
        'alga'     => true,
        'alumna'   => true,
        'antenna'  => true,
        'formula'  => true,
        'nebula'   => true,
        'persona'  => true,
        'vertebra' => true,
        'vita'     => true,
      })

      PLURAL_US_I = SuffixRule.new( /us\z/, 'i', {
        'alumnus'   => true,
        'alveolus'  => true,
        'bacillus'  => true,
        'bronchus'  => true,
        'locus'     => true,
        'meniscus'  => true,
        'nucleus'   => true,
        'stimulus'  => true,
        'thesaurus' => true,
      })

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

      PLURAL_ON_A = SuffixRule.new( /on\z/, 'a', {
        'aphelion'     => true,
        'asyndeton'    => true,
        'criterion'    => true,
        'hyperbaton'   => true,
        'noumenon'     => true,
        'organon'      => true,
        'perihelion'   => true,
        'phenomenon'   => true,
        'prolegomenon' => true,
      })

      PLURAL_IRREGULAR = IrregularRule.new({
        # irregular
        'cactus'      => 'cacti',
        'child'       => 'children',
        'corpus'      => 'corpora',
        'foot'        => 'feet',
        'genus'       => 'genera',
        'goose'       => 'geese',
        'man'         => 'men',
        'ox'          => 'oxen',
        'person'      => 'people',
        'quiz'        => 'quizzes',
        'sex'         => 'sexes',
        'testis'      => 'testes',
        'tooth'       => 'teeth',
        'woman'       => 'women',
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
      })

      def self.pluralize(string)
        case string
        when PLURAL_IRREGULAR
          PLURAL_IRREGULAR.apply(string)
        when /\A((.*)[^aeiou])ch\z/
          $1 + CHES
        when /\A((.*)[^aeiou])y\z/
          $1 + IES
        when /\A(.*)(ex|ix)\z/
          $1 + ICES
        when /\A(.*)x\z/
          $1 + XES
        when PLURAL_ON_A
          PLURAL_ON_A.apply(string)
        when /\A(.*)um\z/
          $1 + A
        when /\A(.*)eau\z/
          $1 + EAUX
        when /\A(.*)ouse\z/
          $1 + ICE
        when PLURAL_O_OES
          PLURAL_O_OES.apply(string)
        when /\A(.*)en\z/
          $1 + INA
        when PLURAL_F_S
          PLURAL_F_S.apply(string)
        when /\A(.*)(?:([^f]))f[e]*\z/
          $1 + $2 + VES
        when PLURAL_US_I
          PLURAL_US_I.apply(string)
        when /\A(.*)us\z/
          $1 + USES
        when PLURAL_IS_ES
          PLURAL_IS_ES.apply(string)
        when PLURAL_IS_IDES
          PLURAL_IS_IDES.apply(string)
        when /\A(.*)s\z/
          $1 + SES
        when PLURAL_A_AE
          PLURAL_A_AE.apply(string)
        when /\A(.*)a\z/
          $1 + ATA
        else
          string + S
        end
      end
    end
  end
end
