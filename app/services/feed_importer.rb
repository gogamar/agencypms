class FeedImporter
  require 'cgi'
  require 'feedjira'

  def self.import_feeds
    begin
    Feed.all.each do |feed|
      xml = HTTParty.get(feed.url).body
      parsed_xml = Feedjira.parse(xml)

      puts "this is the parsed xml: #{parsed_xml}"

      if parsed_xml.entries.any?
        parsed_xml.entries.each do |entry|
          decoded_summary = CGI.unescapeHTML(entry.summary)

          parsed_uri = URI.parse(entry.url)
          domain = parsed_uri.host

          existing_post = Post.find_by(url: entry.url)
          next if existing_post

          Post.create(
            "title_#{feed.language}": entry.title,
            "content_#{feed.language}": decoded_summary,
            published_at: entry.published,
            url: entry.url,
            category_id: feed.category_id,
            user_id: User.where(role: "admin").first.id,
            image_url: entry.image,
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
