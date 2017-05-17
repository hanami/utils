if ENV['COVERALL']
  require 'coveralls'
  Coveralls.wear!
end

$LOAD_PATH.unshift 'lib'
require 'hanami/utils'

Hanami::Utils.require!("spec/support")
