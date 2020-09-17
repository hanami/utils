# frozen_string_literal: true

TEST_REPLACEMENT_CHAR = "fffd"
TEST_INVALID_CHARS    = ((0x0..0x8).to_a + (0x11..0x12).to_a + (0x14..0x1f).to_a).flatten.each_with_object({}) do |char, result|
  char = char.chr(Encoding::UTF_8)
  result[char] = TEST_REPLACEMENT_CHAR
end

TEST_HTML_ENTITIES = {
  '"' => "quot",
  "&" => "amp",
  "<" => "lt",
  ">" => "gt",
  " " => "nbsp",
  "¡" => "iexcl",
  "¢" => "cent",
  "£" => "pound",
  "¤" => "curren",
  "¥" => "yen",
  "¦" => "brvbar",
  "§" => "sect",
  "¨" => "uml",
  "©" => "copy",
  "ª" => "ordf",
  "«" => "laquo",
  "¬" => "not",
  "­" => "shy",
  "®" => "reg",
  "¯" => "macr",
  "°" => "deg",
  "±" => "plusmn",
  "²" => "sup2",
  "³" => "sup3",
  "´" => "acute",
  "µ" => "micro",
  "¶" => "para",
  "·" => "middot",
  "¸" => "cedil",
  "¹" => "sup1",
  "º" => "ordm",
  "»" => "raquo",
  "¼" => "frac14",
  "½" => "frac12",
  "¾" => "frac34",
  "¿" => "iquest",
  "À" => "Agrave",
  "Á" => "Aacute",
  "Â" => "Acirc",
  "Ã" => "Atilde",
  "Ä" => "Auml",
  "Å" => "Aring",
  "Æ" => "AElig",
  "Ç" => "Ccedil",
  "È" => "Egrave",
  "É" => "Eacute",
  "Ê" => "Ecirc",
  "Ë" => "Euml",
  "Ì" => "Igrave",
  "Í" => "Iacute",
  "Î" => "Icirc",
  "Ï" => "Iuml",
  "Ð" => "ETH",
  "Ñ" => "Ntilde",
  "Ò" => "Ograve",
  "Ó" => "Oacute",
  "Ô" => "Ocirc",
  "Õ" => "Otilde",
  "Ö" => "Ouml",
  "×" => "times",
  "Ø" => "Oslash",
  "Ù" => "Ugrave",
  "Ú" => "Uacute",
  "Û" => "Ucirc",
  "Ü" => "Uuml",
  "Ý" => "Yacute",
  "Þ" => "THORN",
  "ß" => "szlig",
  "à" => "agrave",
  "á" => "aacute",
  "â" => "acirc",
  "ã" => "atilde",
  "ä" => "auml",
  "å" => "aring",
  "æ" => "aelig",
  "ç" => "ccedil",
  "è" => "egrave",
  "é" => "eacute",
  "ê" => "ecirc",
  "ë" => "euml",
  "ì" => "igrave",
  "í" => "iacute",
  "î" => "icirc",
  "ï" => "iuml",
  "ð" => "eth",
  "ñ" => "ntilde",
  "ò" => "ograve",
  "ó" => "oacute",
  "ô" => "ocirc",
  "õ" => "otilde",
  "ö" => "ouml",
  "÷" => "divide",
  "ø" => "oslash",
  "ù" => "ugrave",
  "ú" => "uacute",
  "û" => "ucirc",
  "ü" => "uuml",
  "ý" => "yacute",
  "þ" => "thorn",
  "ÿ" => "yuml",
  "Œ" => "OElig",
  "œ" => "oelig",
  "Š" => "Scaron",
  "š" => "scaron",
  "Ÿ" => "Yuml",
  "ƒ" => "fnof",
  "ˆ" => "circ",
  "˜" => "tilde",
  "Α" => "Alpha",
  "Β" => "Beta",
  "Γ" => "Gamma",
  "Δ" => "Delta",
  "Ε" => "Epsilon",
  "Ζ" => "Zeta",
  "Η" => "Eta",
  "Θ" => "Theta",
  "Ι" => "Iota",
  "Κ" => "Kappa",
  "Λ" => "Lambda",
  "Μ" => "Mu",
  "Ν" => "Nu",
  "Ξ" => "Xi",
  "Ο" => "Omicron",
  "Π" => "Pi",
  "Ρ" => "Rho",
  "Σ" => "Sigma",
  "Τ" => "Tau",
  "Υ" => "Upsilon",
  "Φ" => "Phi",
  "Χ" => "Chi",
  "Ψ" => "Psi",
  "Ω" => "Omega",
  "α" => "alpha",
  "β" => "beta",
  "γ" => "gamma",
  "δ" => "delta",
  "ε" => "epsilon",
  "ζ" => "zeta",
  "η" => "eta",
  "θ" => "theta",
  "ι" => "iota",
  "κ" => "kappa",
  "λ" => "lambda",
  "μ" => "mu",
  "ν" => "nu",
  "ξ" => "xi",
  "ο" => "omicron",
  "π" => "pi",
  "ρ" => "rho",
  "ς" => "sigmaf",
  "σ" => "sigma",
  "τ" => "tau",
  "υ" => "upsilon",
  "φ" => "phi",
  "χ" => "chi",
  "ψ" => "psi",
  "ω" => "omega",
  "ϑ" => "thetasym",
  "ϒ" => "upsih",
  "ϖ" => "piv",
  "\u2002" => "ensp",
  "\u2003" => "emsp",
  "\u2009" => "thinsp",
  "\u200C" => "zwnj",
  "\u200D" => "zwj",
  "\u200E" => "lrm",
  "\u200F" => "rlm",
  "–" => "ndash",
  "—" => "mdash",
  "‘" => "lsquo",
  "’" => "rsquo",
  "‚" => "sbquo",
  "“" => "ldquo",
  "”" => "rdquo",
  "„" => "bdquo",
  "†" => "dagger",
  "‡" => "Dagger",
  "•" => "bull",
  "…" => "hellip",
  "‰" => "permil",
  "′" => "prime",
  "″" => "Prime",
  "‹" => "lsaquo",
  "›" => "rsaquo",
  "‾" => "oline",
  "⁄" => "frasl",
  "€" => "euro",
  "ℑ" => "image",
  "℘" => "weierp",
  "ℜ" => "real",
  "™" => "trade",
  "ℵ" => "alefsym",
  "←" => "larr",
  "↑" => "uarr",
  "→" => "rarr",
  "↓" => "darr",
  "↔" => "harr",
  "↵" => "crarr",
  "⇐" => "lArr",
  "⇑" => "uArr",
  "⇒" => "rArr",
  "⇓" => "dArr",
  "⇔" => "hArr",
  "∀" => "forall",
  "∂" => "part",
  "∃" => "exist",
  "∅" => "empty",
  "∇" => "nabla",
  "∈" => "isin",
  "∉" => "notin",
  "∋" => "ni",
  "∏" => "prod",
  "∑" => "sum",
  "−" => "minus",
  "∗" => "lowast",
  "√" => "radic",
  "∝" => "prop",
  "∞" => "infin",
  "∠" => "ang",
  "∧" => "and",
  "∨" => "or",
  "∩" => "cap",
  "∪" => "cup",
  "∫" => "int",
  "∴" => "there4",
  "∼" => "sim",
  "≅" => "cong",
  "≈" => "asymp",
  "≠" => "ne",
  "≡" => "equiv",
  "≤" => "le",
  "≥" => "ge",
  "⊂" => "sub",
  "⊃" => "sup",
  "⊄" => "nsub",
  "⊆" => "sube",
  "⊇" => "supe",
  "⊕" => "oplus",
  "⊗" => "otimes",
  "⊥" => "perp",
  "⋅" => "sdot",
  "⌈" => "lceil",
  "⌉" => "rceil",
  "⌊" => "lfloor",
  "⌋" => "rfloor",
  "\u2329" => "lang", # rubocop:disable Style/AsciiComments "〈"
  "\u232A" => "rang", # rubocop:disable Style/AsciiComments "〉"
  "◊" => "loz",
  "♠" => "spades",
  "♣" => "clubs",
  "♥" => "hearts",
  "♦" => "diams"
}.freeze

TEST_PLURALS = {
  # um => a
  "bacterium"   => "bacteria",
  "agendum"     => "agenda",
  "desideratum" => "desiderata",
  "erratum"     => "errata",
  "stratum"     => "strata",
  "datum"       => "data",
  "ovum"        => "ova",
  "extremum"    => "extrema",
  "candelabrum" => "candelabra",
  "curriculum"  => "curricula",
  "millennium"  => "millennia",
  "referendum"  => "referenda",
  "stadium"     => "stadia",
  "medium"      => "media",
  "memorandum"  => "memoranda",
  "criterium"   => "criteria",
  "perihelium"  => "perihelia",
  "aphelium"    => "aphelia",
  # on => a
  "phenomenon"   => "phenomena",
  "prolegomenon" => "prolegomena",
  "noumenon"     => "noumena",
  "organon"      => "organa",
  # o => os
  "albino"        => "albinos",
  "archipelago"   => "archipelagos",
  "armadillo"     => "armadillos",
  "commando"      => "commandos",
  "crescendo"     => "crescendos",
  "fiasco"        => "fiascos",
  "ditto"         => "dittos",
  "dynamo"        => "dynamos",
  "embryo"        => "embryos",
  "ghetto"        => "ghettos",
  "guano"         => "guanos",
  "inferno"       => "infernos",
  "jumbo"         => "jumbos",
  "lumbago"       => "lumbagos",
  "magneto"       => "magnetos",
  "manifesto"     => "manifestos",
  "medico"        => "medicos",
  "octavo"        => "octavos",
  "photo"         => "photos",
  "pro"           => "pros",
  "quarto"        => "quartos",
  "canto"         => "cantos",
  "lingo"         => "lingos",
  "generalissimo" => "generalissimos",
  "stylo"         => "stylos",
  "rhino"         => "rhinos",
  "casino"        => "casinos",
  "auto"          => "autos",
  "macro"         => "macros",
  "zero"          => "zeros",
  "todo"          => "todos",
  "studio"        => "studios",
  "avocado"       => "avocados",
  "zoo"           => "zoos",
  "banjo"         => "banjos",
  "cargo"         => "cargos",
  "flamingo"      => "flamingos",
  "fresco"        => "frescos",
  "halo"          => "halos",
  "mango"         => "mangos",
  "memento"       => "mementos",
  "motto"         => "mottos",
  "tornado"       => "tornados",
  "tuxedo"        => "tuxedos",
  "volcano"       => "volcanos",
  # The correct form from italian is: o => i. (Eg. contralto => contralti)
  # English dictionaries are reporting o => s as a valid rule
  #
  # We're sticking to the latter rule, in order to not introduce exceptions
  # for words that end with "o". See the previous category.
  "solo"      => "solos",
  "soprano"   => "sopranos",
  "basso"     => "bassos",
  "alto"      => "altos",
  "contralto" => "contraltos",
  "tempo"     => "tempos",
  "piano"     => "pianos",
  "virtuoso"  => "virtuosos",
  # o => oes
  "buffalo"  => "buffaloes",
  "domino"   => "dominoes",
  "echo"     => "echoes",
  "embargo"  => "embargoes",
  "hero"     => "heroes",
  "mosquito" => "mosquitoes",
  "potato"   => "potatoes",
  "tomato"   => "tomatoes",
  "torpedo"  => "torpedos",
  "veto"     => "vetos",
  # a => ata
  "anathema"  => "anathemata",
  "enema"     => "enemata",
  "oedema"    => "oedemata",
  "bema"      => "bemata",
  "enigma"    => "enigmata",
  "sarcoma"   => "sarcomata",
  "carcinoma" => "carcinomata",
  "gumma"     => "gummata",
  "schema"    => "schemata",
  "charisma"  => "charismata",
  "lemma"     => "lemmata",
  "soma"      => "somata",
  "diploma"   => "diplomata",
  "lymphoma"  => "lymphomata",
  "stigma"    => "stigmata",
  "dogma"     => "dogmata",
  "magma"     => "magmata",
  "stoma"     => "stomata",
  "drama"     => "dramata",
  "melisma"   => "melismata",
  "trauma"    => "traumata",
  "edema"     => "edemata",
  "miasma"    => "miasmata",
  # # is => es
  # "axis"        => "axes",
  # "analysis"    => "analyses",
  # "basis"       => "bases",
  # "crisis"      => "crises",
  # "diagnosis"   => "diagnoses",
  # "ellipsis"    => "ellipses",
  # "hypothesis"  => "hypotheses",
  # "oasis"       => "oases",
  # "paralysis"   => "paralyses",
  # "parenthesis" => "parentheses",
  # "synthesis"   => "syntheses",
  # "synopsis"    => "synopses",
  # "thesis"      => "theses",
  # us => uses
  "apparatus"  => "apparatuses",
  "impetus"    => "impetuses",
  "prospectus" => "prospectuses",
  "cantus"     => "cantuses",
  "nexus"      => "nexuses",
  "sinus"      => "sinuses",
  "coitus"     => "coituses",
  "plexus"     => "plexuses",
  "status"     => "statuses",
  "hiatus"     => "hiatuses",
  "bus"        => "buses",
  "octopus"    => "octopuses",
  #
  # none => i
  # "afreet" => true,
  # "afrit"  => true,
  # "efreet" => true,
  #
  # none => im
  # "cherub" => true,
  # "goy"    => true,
  # "seraph" => true,
  #
  # man => mans
  "human"      => "humans",
  "Alabaman"   => "Alabamans",
  "Bahaman"    => "Bahamans",
  "Burman"     => "Burmans",
  "German"     => "Germans",
  "Hiroshiman" => "Hiroshimans",
  "Liman"      => "Limans",
  "Nakayaman"  => "Nakayamans",
  "Oklahoman"  => "Oklahomans",
  "Panaman"    => "Panamans",
  "Selman"     => "Selmans",
  "Sonaman"    => "Sonamans",
  "Tacoman"    => "Tacomans",
  "Yakiman"    => "Yakimans",
  "Yokohaman"  => "Yokohamans",
  "Yuman"      => "Yumans",
  # ch => es
  "witch"  => "witches",
  "church" => "churches",
  # ch => chs
  "stomach" => "stomachs",
  "epoch"   => "epochs",
  # e => es,
  "mustache" => "mustaches",
  "horse"    => "horses",
  "verse"    => "verses",
  "universe" => "universes",
  "inverse"  => "inverses",
  "price"    => "prices",
  "advice"   => "advices",
  "device"   => "devices",
  # x => es
  "box" => "boxes",
  "fox" => "foxes",
  # vowel + y => s
  "boy" => "boys",
  "way" => "ways",
  "buy" => "buys",
  # consonant + y => ies
  "baby"       => "babies",
  "lorry"      => "lorries",
  "entity"     => "entities",
  "repository" => "repositories",
  "fly"        => "flies",
  # f => ves
  "leaf"  => "leaves",
  "hoof"  => "hooves",
  "self"  => "selves",
  "elf"   => "elves",
  "half"  => "halves",
  "scarf" => "scarves",
  "dwarf" => "dwarves",
  # https://github.com/hanami/utils/issues/289
  "original fee" => "original fees",
  # vocal + fe => ves
  "knife" => "knives",
  "life"  => "lives",
  "wife"  => "wives",
  # eau => eaux
  "beau"    => "beaux",
  "bureau"  => "bureaux",
  "tableau" => "tableaux",
  # ouse => ice
  "louse" => "lice",
  "mouse" => "mice",
  # irregular
  "cactus" => "cacti",
  "foot"   => "feet",
  "tooth"  => "teeth",
  "goose"  => "geese",
  "child"  => "children",
  "man"    => "men",
  "woman"  => "women",
  "person" => "people",
  "ox"     => "oxen",
  "corpus" => "corpora",
  "genus"  => "genera",
  "sex"    => "sexes",
  "quiz"   => "quizzes",
  "testis" => "testes",
  # uncountable
  "deer"        => "deer",
  "fish"        => "fish",
  "money"       => "money",
  "means"       => "means",
  "offspring"   => "offspring",
  "series"      => "series",
  "sheep"       => "sheep",
  "species"     => "species",
  "equipment"   => "equipment",
  "information" => "information",
  "rice"        => "rice",
  "news"        => "news",
  "police"      => "police",
  # fallback (add s)
  "giraffe"      => "giraffes",
  "test"         => "tests",
  "feature"      => "features",
  "fixture"      => "fixtures",
  "controller"   => "controllers",
  "action"       => "actions",
  "router"       => "routers",
  "route"        => "routes",
  "endpoint"     => "endpoints",
  "string"       => "strings",
  "view"         => "views",
  "template"     => "templates",
  "layout"       => "layouts",
  "application"  => "applications",
  "api"          => "apis",
  "model"        => "models",
  "mapper"       => "mappers",
  "mapping"      => "mappings",
  "table"        => "tables",
  "attribute"    => "attributes",
  "column"       => "columns",
  "migration"    => "migrations",
  "presenter"    => "presenters",
  "wizard"       => "wizards",
  "architecture" => "architectures",
  "cat"          => "cats",
  "car"          => "cars",
  "area"         => "areas",
  "hive"         => "hives",
  # https://github.com/hanami/utils/issues/106
  "album"        => "albums",
  # https://github.com/hanami/utils/issues/173
  "kitten"       => "kittens",
  # https://github.com/hanami/utils/issues/289
  "fee"          => "fees"
}.freeze

TEST_SINGULARS = {
  # a => ae
  "alumna"   => "alumnae",
  "alga"     => "algae",
  "vertebra" => "vertebrae",
  "persona"  => "personae",
  "antenna"  => "antennae",
  "formula"  => "formulae",
  "nebula"   => "nebulae",
  "vita"     => "vitae",
  # is => ides
  "iris"     => "irides",
  "clitoris" => "clitorides",
  # us => i
  "alumnus"   => "alumni",
  "alveolus"  => "alveoli",
  "bacillus"  => "bacilli",
  "bronchus"  => "bronchi",
  "locus"     => "loci",
  "nucleus"   => "nuclei",
  "stimulus"  => "stimuli",
  "meniscus"  => "menisci",
  "thesaurus" => "thesauri",
  # f => s
  "chief" => "chiefs",
  "spoof" => "spoofs",
  # en => ina
  "stamen"  => "stamina",
  "foramen" => "foramina",
  "lumen"   => "lumina",
  # s => es
  "acropolis"  => "acropolises",
  "chaos"      => "chaoses",
  "lens"       => "lenses",
  "aegis"      => "aegises",
  "cosmos"     => "cosmoses",
  "mantis"     => "mantises",
  "alias"      => "aliases",
  "dais"       => "daises",
  "marquis"    => "marquises",
  "asbestos"   => "asbestoses",
  "digitalis"  => "digitalises",
  "metropolis" => "metropolises",
  "atlas"      => "atlases",
  "epidermis"  => "epidermises",
  "pathos"     => "pathoses",
  "bathos"     => "bathoses",
  "ethos"      => "ethoses",
  "pelvis"     => "pelvises",
  "bias"       => "biases",
  "gas"        => "gases",
  "polis"      => "polises",
  "caddis"     => "caddises",
  "rhinoceros" => "rhinoceroses",
  "cannabis"   => "cannabises",
  "glottis"    => "glottises",
  "sassafras"  => "sassafrases",
  "canvas"     => "canvases",
  "ibis"       => "ibises",
  "trellis"    => "trellises",
  "kiss"       => "kisses",
  # https://github.com/hanami/utils/issues/106
  "album"      => "albums",
  # https://github.com/hanami/utils/issues/217
  "phase"      => "phases",
  "exercise"   => "exercises",
  "release"    => "releases"
}.merge(TEST_PLURALS)

require "hanami/utils/inflector"
Hanami::Utils::Inflector.inflections do
  exception   "analysis", "analyses"
  exception   "alga",     "algae"
  uncountable "music", "butter"
end

class WrappingHash
  def initialize(hash)
    @hash = hash.to_h
  end

  def to_hash
    @hash
  end
  alias_method :to_h, :to_hash
end
