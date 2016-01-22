require 'hanami/utils/class_attribute'

module Hanami
  module Utils
    # String inflector
    #
    # @since 0.4.1
    module Inflector
      # Rules for irregular plurals
      #
      # @since 0.6.0
      # @api private
      class IrregularRules
        # @since 0.6.0
        # @api private
        def initialize(rules)
          @rules = rules
        end

        # @since 0.6.0
        # @api private
        def add(key, value)
          @rules[key.downcase] = value.downcase
        end

        # @since 0.6.0
        # @api private
        def ===(other)
          key = other.downcase
          @rules.key?(key) || @rules.value?(key)
        end

        # @since 0.6.0
        # @api private
        def apply(string)
          key    = string.downcase
          result = @rules[key] || @rules.rassoc(key).last

          string[0] + result[1..-1]
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

      # @since 0.6.0
      # @api private
      ES   = 'es'.freeze

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

      # @since 0.6.0
      # @api private
      NA   = 'na'.freeze

      # @since 0.6.0
      # @api private
      NON  = 'non'.freeze

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

      # @since 0.6.0
      # @api private
      TA   = 'ta'.freeze

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

      include Utils::ClassAttribute

      # Irregular rules for plurals
      #
      # @since 0.6.0
      # @api private
      class_attribute :plurals
      self.plurals = IrregularRules.new({
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
      })

      # Irregular rules for singulars
      #
      # @since 0.6.0
      # @api private
      class_attribute :singulars
      self.singulars = IrregularRules.new({
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
        # fallback
        'hives'       => 'hive',
        'horses'      => 'horse',
      })

      # Block for custom inflection rules.
      #
      # @param [Proc] blk custom inflections
      #
      # @since 0.6.0
      #
      # @see Hanami::Utils::Inflector.exception
      # @see Hanami::Utils::Inflector.uncountable
      #
      # @example
      #   require 'hanami/utils/inflector'
      #
      #   Hanami::Utils::Inflector.inflections do
      #     exception   'analysis', 'analyses'
      #     exception   'alga',     'algae'
      #     uncountable 'music', 'butter'
      #   end
      def self.inflections(&blk)
        class_eval(&blk)
      end

      # Add a custom inflection exception
      #
      # @param [String] singular form
      # @param [String] plural form
      #
      # @since 0.6.0
      #
      # @see Hanami::Utils::Inflector.inflections
      # @see Hanami::Utils::Inflector.uncountable
      #
      # @example
      #   require 'hanami/utils/inflector'
      #
      #   Hanami::Utils::Inflector.inflections do
      #     exception 'alga', 'algae'
      #   end
      def self.exception(singular, plural)
        singulars.add(plural, singular)
        plurals.add(singular, plural)
      end

      # Add an uncountable word
      #
      # @param [Array<String>] words
      #
      # @since 0.6.0
      #
      # @see Hanami::Utils::Inflector.inflections
      # @see Hanami::Utils::Inflector.exception
      #
      # @example
      #   require 'hanami/utils/inflector'
      #
      #   Hanami::Utils::Inflector.inflections do
      #     uncountable 'music', 'art'
      #   end
      def self.uncountable(*words)
        Array(words).each do |word|
          exception(word, word)
        end
      end

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
        when plurals
          plurals.apply(string)
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
        when /\A(.*)ma\z/
          string + TA
        when /\A(.*)(um|#{ A })\z/
          $1 + A
        when /\A(.*)(ouse|#{ ICE })\z/
          $1 + ICE
        when /\A(buffal|domin|ech|embarg|her|mosquit|potat|tomat)#{ O }\z/i
          $1 + OES
        when /\A(.*)(en|#{ INA })\z/
          $1 + INA
        when /\A(.*)(?:([^f]))f[e]*\z/
          $1 + $2 + VES
        when /\A(.*)us\z/
          $1 + USES
        when /\A(.*)non\z/
          $1 + NA
        when /\A((.*)[^aeiou])is\z/
          $1 + ES
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
        when singulars
          singulars.apply(string)
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
        when /\A(.*)ae\z/
          $1 + A
        when /\A(.*)na\z/
          $1 + NON
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
