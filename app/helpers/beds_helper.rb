module BedsHelper
  require 'httparty'
  require 'oj'

  class Beds
    include HTTParty
    base_uri 'https://beds24.com/api/json'

    attr_accessor :auth_token

    def initialize(auth_token)
      @auth_token = auth_token
    end


    def get_rates(prop_key, options={})
      self.class.post(
        '/getRates',
        body: payload(prop_key, options)
      )
    rescue Oj::ParseError
      raise Error, 'Got encoding different from JSON. Please check passed options'
    rescue APIError => e
      e.response
    end

    def get_properties
      response = self.class.post('/getProperties', body: authentication.to_json)
      json = parse!(response)
      json['getProperties']
    rescue Oj::ParseError
      raise Error, 'Got encoding different from JSON. Please check passed options'
    rescue APIError => e
      e.response
    end

    def get_property_content(prop_key, options={})
      response = self.class.post(
        '/getPropertyContent',
        body: payload(prop_key, options)
      )
      json = parse!(response)
      json["getPropertyContent"]
      rescue Oj::ParseError
      raise Error, 'Got encoding different from JSON. Please check passed options'
    rescue APIError => e
      e.response
    end

    def set_rates(prop_key, options={})
      self.class.post(
        '/setRates',
        body: payload(prop_key, options)
      )
    rescue Oj::ParseError
      raise Error, 'Got encoding different from JSON. Please check passed options'
    rescue APIError => e
      e.response
    end

    private

    def authentication(prop_key = nil)
      {
        authentication: {
          apiKey: auth_token,
          propKey: prop_key
        }
      }
    end

    def payload(prop_key = nil, options={})
      authentication(prop_key)
        .merge(options)
        .to_json
    end

    def parse!(response)
      json = Oj.load(response.body)
      if json.is_a?(Hash) && !json['error'].nil?
        raise APIError.new(
          "API Error: #{json['errorCode']} #{json['error']}",
          json
        )
      else
        json
      end
    end
  end
end
