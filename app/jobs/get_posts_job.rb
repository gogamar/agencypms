class GetPostsJob < ApplicationJob
  queue_as :default

  def perform
    FeedImporter.import_feeds

    [{ "es" => "es" }, { "fr" => "fr" }, { "gb" => "en" }].each do |hash|
      from = 1.day.ago.strftime('%Y-%m-%dT00:00:00Z')
      lang = hash.values.first
      country = hash.keys.first

      search_params = { from: from, lang: lang, country: country, max: 10, param1: params[:param1], param2: params[:param2], param3: params[:param3], param4: params[:param4]}
      max = 5
      NewsApiService.get_news_from_gnews(from, lang, country, max)
    end
  end
end
