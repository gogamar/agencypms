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

          # parsed_uri = URI.parse(post.url)
          # domain = parsed_uri.host

          new_post = Post.create(
            title_ca: entry.title,
            content_ca: decoded_summary,
            published_at: entry.published,
            url: entry.url,
            category_id: Category.first.id,
            user_id: User.where(role: "admin").first.id,
            image_url: entry.image
          )
        end
      end
    end
  end
end
