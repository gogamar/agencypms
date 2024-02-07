class GetPostsJob < ApplicationJob
  include NewsHelper
  queue_as :default

  def perform
    FeedImporter.import_feeds

    [{ "es" => "es" }, { "fr" => "fr" }, { "gb" => "en" }].each do |hash|
      from = 1.day.ago.strftime('%Y-%m-%dT00:00:00Z')
      lang = hash.values.first
      country = hash.keys.first
      max = 10

      params = { param1: "barcelona", param2: "costa", param3: "airbnb", param4: "booking" }
      search_query = build_search_query(params)

      search_params = { from: from, lang: lang, country: country, max: max }

      NewsApiService.get_news_from_gnews(search_query, search_params)
    end
  end
end
