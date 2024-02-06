class NewsApiService
  include HTTParty

  BASE_URL = 'https://gnews.io/api/v4'
  API_KEY = '451212eb9ae0f3d49560cb329c237799'


  def self.get(endpoint, params = {})
    url = "#{BASE_URL}/#{endpoint}?apikey=#{API_KEY}"

    params.each { |key, value| url += "&#{key}=#{value}" }

    response = HTTParty.get(url)

    if response.success?
      return JSON.parse(response.body)
    else
      puts "Error: #{response.code}, #{response.message}"
      return nil
    end
  end

  def self.search(query, params = {})
    endpoint = 'search'
    params['q'] = query

    return get(endpoint, params)
  end
end
