Encoding.default_external = 'UTF-8'

$LOAD_PATH.unshift(File.expand_path('./application'))

# Include critical gems
require 'config/variables'

if %w(development test).include?(RACK_ENV)
  require 'pry'
  require 'awesome_print'
  require 'dotenv'
  Dotenv.load(".env.#{RACK_ENV}")
end

require 'bundler'
Bundler.setup :default, RACK_ENV
require 'rack/indifferent'
require 'grape'
require 'grape/batch'
# Initialize the application so we can add all our components to it
class Api < Grape::API; end

# Include all config files
require 'config/sequel'
require 'config/hanami'
require 'config/grape'
require 'config/mail'

# require some global libs
require 'lib/core_ext'
require 'lib/time_formats'
require 'lib/io'

# load active support helpers
require 'active_support'
require 'active_support/core_ext'

# require all models
Dir['./application/models/*.rb'].each { |rb| require rb }
Dir['./application/validators/*.rb'].each { |rb| require rb }
Dir['./application/mailers/**/*.rb'].each { |rb| require rb }
Dir['./application/api_helpers/**/*.rb'].each { |rb| require rb }

class Api < Grape::API
  version 'v1.0', using: :path
  content_type :json, 'application/json'
  default_format :json
  prefix :api

  helpers do
    # Got to this because Hanami::Validations only accepts
    # symbol keys, unless for declared attributes.
    # See https://github.com/hanami/validations/issues/20
    def permit_attributes(keys)
      params
        .fetch(:attributes, {})
        .slice(*keys)
        .symbolize_keys
    end

    def handling_validation(v)
      result = v.validate

      if result.success?
        yield
      else
        raise Api::ValidationError.new(result.errors)
      end
    end
  end

  rescue_from Api::ValidationError do |e|
    data = { error_type: 'validations', errors: e.errors }
    error!(data, 422)
  end

  rescue_from Api::AuthenticationError do |e|
    data = { error_type: 'authentication', errors: e.message }
    error!(data, 401)
  end

  helpers SharedParams
  helpers ApiResponse
  include Auth

  Dir['./application/api_entities/**/*.rb'].each { |rb| require rb }
  Dir['./application/api/**/*.rb'].each { |rb| require rb }

  add_swagger_documentation \
    mount_path: '/docs'
end
