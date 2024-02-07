class FeedImporter
  require 'cgi'
  require 'feedjira'

  def self.import_feeds
    begin
    Feed.all.each do |feed|
      xml = HTTParty.get(feed.url).body
      parsed_xml = Feedjira.parse(xml)

      if parsed_xml.entries.any?
        parsed_xml.entries.each do |entry|

          desc = entry["description"].presence || entry["summary"].presence
          decoded_summary = CGI.unescapeHTML(desc)
          content = entry["content"].presence

          doc = Nokogiri::HTML(content) if content
          first_img = doc.at('img') if doc

          image = entry["image"].presence || (first_img["src"].presence if first_img)

          url = entry["url"].presence || entry["link"].presence

          parsed_uri = URI.parse(url)
          domain = parsed_uri.host

          publish_date = entry["published"].presence || entry["pubDate"].presence

          existing_post = Post.find_by(url: url)
          next if existing_post

          Post.create(
            "title_#{feed.language}": entry.title,
            "content_#{feed.language}": decoded_summary,
            published_at: publish_date,
            url: url,
            category_id: feed.category_id,
            user_id: User.where(role: "admin").first.id,
            image_url: image,
            feed_id: feed.id,
            source: domain
          )
        end
      end
    end
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end
end
