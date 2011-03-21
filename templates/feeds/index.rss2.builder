xml.instruct!
xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    xml.title "Template RSS Feed"
    xml.link full_url "/index.rss2"
    xml.pubDate Time.now.rfc822
    xml.description ""
    entries.published.each do |entry|
      xml.item do
        xml.title entry.title
        xml.link full_url entry.link
        xml.description entry.render
        xml.pubDate entry.pubdate.rfc822
        xml.guid full_url entry.link
        xml.author entry.author
      end
    end
  end
end
