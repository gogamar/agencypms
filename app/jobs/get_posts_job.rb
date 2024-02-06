class GetPostsJob < ApplicationJob
  require 'cgi'
  queue_as :default

  def perform
    Feed.all.each do |feed|
      xml = HTTParty.get(feed.url).body
      parsed_xml = Feedjira.parse(xml)

      if parsed_xml.entries.any?
        parsed_xml.entries.each do |entry|
          decoded_summary = CGI.unescapeHTML(entry.summary)

          parsed_uri = URI.parse(post.url)
          domain = parsed_uri.host

          existing_post = Post.find_by(guid: entry.guid)
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
  end
end
