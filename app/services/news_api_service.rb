class NewsApiService
  include HTTParty

  BASE_URL = 'https://gnews.io/api/v4'
  API_KEY = ENV['GNEWS_API_KEY']

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

  def self.get_news_from_gnews(search_query, search_params)
    begin
      lang = search_params[:lang]

      response = search(search_query, search_params)

      if response
        articles = response['articles']

        articles.each do |article|
          cleaned_content = article["content"].sub(/\s*\[.*\]\z/, '')
          existing_post = Post.find_by(url: article["url"])
          if existing_post
            existing_post.update("content_#{lang}": cleaned_content) if existing_post.present?
          else
            Post.create(
              "title_#{lang}": article["title"],
              "content_#{lang}": article["description"] + "<br>" + cleaned_content,
              url: article["url"],
              published_at: article["publishedAt"],
              image_url: article["image"],
              source: article["source"]["name"],
              user_id: User.where(role: "admin").first.id,
              category_id: Category.first.id
            )
          end
        end
      end
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end
end
