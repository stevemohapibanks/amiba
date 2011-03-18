xml.instruct!
xml.feed "xml:lang" => "en-GB", "xmlns" => 'http://www.w3.org/2005/Atom' do
  xml.id "tag:#{site_name},2005:/index.atom"
  xml.link(:rel => 'alternate', :type => 'text/html', :href => full_url("/"))
  xml.link(:rel => 'self', :type => 'application/atom+xml', :href => full_url("/index.atom"))
  xml.title "Template atom feed"
  xml.updated entries.first.pubdate.xmlschema

  entries.each do |entry|
    xml.item do |item|
      item.title entry.title
      item.link(:rel => 'alternate', :type => 'text/html', :href => full_url(entry.link))
      item.id "tag:#{site_name},2005:#{entry.link}"
      item.published entry.pubdate.xmlschema
      item.author do |author|
        author.name entry.author
      end
      item.content(entry.render, :type => "html")
    end
  end
end
