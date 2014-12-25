---
layout: false
---
xml.instruct!
xml.rss(
  'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
  'xmlns:sy' => "http://purl.org/rss/1.0/modules/syndication/",
  'xmlns:admin' => "http://webns.net/mvcb/",
  'xmlns:rdf' => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
  'xmlns:content' => "http://purl.org/rss/1.0/modules/content/",
  'xmlns:itunes' => "http://www.itunes.com/dtds/podcast-1.0.dtd",
  'xmlns:atom' => "http://www.w3.org/2005/Atom",
  'version' => "2.0"
  ) do

  xml.channel do
    xml.title podcast.title
    xml.link podcast.website
    xml.language podcast.language
    xml.pubDate episodes.last.published_date.to_datetime.to_s(:rfc822)
    xml.lastBuildDate episodes.last.published_date.to_datetime.to_s(:rfc822)
    xml.copyright "&#xA9; #{Date.today.year} #{sentence(podcast.podcasters.map(&:name))}"
    xml.itunes :subtitle, podcast.subtitle
    xml.itunes :author, sentence(podcast.podcasters.map(&:name))
    xml.itunes :keywords, podcast.keywords.join(', ')
    xml.itunes :explicit, podcast.explicit
    xml.itunes :summary, podcast
    xml.description { xml.cdata!(podcast.summary_html) }
    xml.itunes :owner do
      xml.itunes :name, sentence(podcast.podcasters.map(&:name))
      xml.itunes :email, podcast.email
    end
    xml.itunes :image, href: podcast.cover_art

    podcast.categories.each do |c|
      parts = c.split('.')
      mapper = lambda do
        if parts.size > 1
          xml.itunes :category, text: parts.shift do
            mapper.call
          end
        else
          xml.itunes :category, text: parts.shift
        end
      end
      mapper.call
    end

    xml.atom :link, href: podcast.feed_url, rel: 'self', type: 'application/rss+xml'

    episodes.each do |episode|
      xml.item do
        xml.title episode.title
        xml.link podcast.website + episode.url
        xml.itunes :author, sentence(episode.podcasters.map(&:name))
        xml.itunes :subtitle, "#{podcast.title}: #{episode.title}"
        xml.itunes :summary, episode.description
        xml.itunes :image, href: podcast.cover_art
        xml.enclosure url: episode.source[:url], length: episode.source[:length], type: episode.source[:type]
        xml.guid podcast.website + episode.url, isPermalink: 'true'
        xml.pubDate episode.published_date.to_datetime.to_s(:rfc822)
        xml.itunes :duration, episode.source[:duration]
        xml.itunes :keywords, podcast.keywords.join(', ')
        xml.itunes :explicit, podcast.explicit
        xml.description { xml.cdata!(episode.html_description) }
        xml.content :encoded do
           xml.cdata!(episode.html_description + '<br />' + episode.html_show_notes)
         end
      end
    end

  end

end
