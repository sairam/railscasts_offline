begin
  require_relative 'subscription_code' #code = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
rescue
  puts "Please add your subscription code from subscription_code.rb.example"
  exit(0)
end

def filelists(dir)
   Dir.entries("./railscasts/#{dir}").sort{|x,y| y.split("-")[0] <=> x.split("-")[0] }
 end
EpisodeTypes = %w{pro revised free}
MainUrl = SubscriptionCode::TARGET_URL

def head(style_attr=:default,title="", title_link="")

  stylesheets = {}
  stylesheets[:default] = %{
    <link href="/stylesheets/bootstrap.css" media="screen" rel="stylesheet" type="text/css" />
  }.to_s
  stylesheets[:ascii] =%{
    <link href="/stylesheets/coderay.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="/stylesheets/application.css" media="screen" rel="stylesheet" type="text/css" />
  }.to_s

  %{<!DOCTYPE HTML>
  <html lang="en-US">
  <head>
    <meta charset="UTF-8">
    <title>Rails Casts Episodes (cached) #{title}- DO NOT DISTRIBUTE</title>
    <link rel="alternate" type="application/rss+xml" title="RSS" href="index.xml" />

    #{stylesheets[style_attr]}
    <style>
      body {
        margin: 0px;
        padding-left: 40px;
      }
    </style>
  </head>
  <body>
  <img src="/railscasts/railscasts_logo.png" >
  <h1>#{title}<a href="index.xml"><img src='/railscasts/feed-icon.png'></a></h1>#{title_link}<br />
  }.to_s

end


foot= %{
</body>
</html>
}.to_s

def rss_item(title,rel_link)
%{
<item>
<title>#{title}</title>
<description>Video of #{title}</description>
<link>#{MainUrl}#{rel_link}</link>
<pubDate>Tue, 31 Jan 2012 09:00:00 -0400</pubDate>
<enclosure url="#{MainUrl}#{rel_link}" length="1010698" type="video/mpeg"/>
<guid isPermaLink="false">http://tuts.local.crypsis.net/railscasts/#{rel_link}</guid>
</item>
}
end
def make_rss_main(items)
%{<rss version="2.0">

<channel>
<title>Rails Casts (Crypsis)</title>
<description> Cached videos of Rails Casts </description>
<link>#{MainUrl}</link>
<lastBuildDate>Mon, 30 Jan 2012 11:12:55 -0400</lastBuildDate>
<pubDate>Tue, 31 Jan 2012 09:00:00 -0400</pubDate>
#{items}
</channel>
</rss>
}
end


def print_nav(types = EpisodeTypes)
  out = ""
  out << "<h2>"
  types.each do |type|
    out << %{<a href="##{type}">#{type.to_s.capitalize}</a> &nbsp;&nbsp;&nbsp;}
    out << %{<a href="#{type}/index.xml"><img src='/railscasts/feed-icon-small.png'></a>&nbsp;&nbsp;&nbsp;}
  end
  out << "</h2>"
  out
end

def print_episodes(types = EpisodeTypes,relative_path="")
  out = ""
  rss = ""
  types.each do |type|
    filelist = filelists(type)
    out << %{<h1><a name="#{type}">#{type.to_s.capitalize}</a> </h1>}
    filelist.each do |link|
      if link.reverse.split(".")[0] == "4pm"
        out << "<div class='row'>"
        episode_name = link.to_s.split(".")[0].gsub("-"," ").capitalize
        out << %{<a class="btn span4" href="#{relative_path}#{type}/#{link}">#{episode_name}</a>}
        htmlfile = link.to_s.split(".")[0]+".html"
        ascii = "asciicasts/"+ htmlfile
        out << %{<a class="btn offset1 span2" href="#{relative_path}#{type}/#{ascii}">Read Episode</a>} if File.exists?("./railscasts/#{type}/raw/#{htmlfile}")
        out << "</div>" + "<br>"*2
        rss << rss_item("#{type} - #{episode_name}","#{type}/#{link}")
      end

    end
    out << "<br>"*3
  end
  [out,rss]
end
eps = print_episodes
open("railscasts/index.html","w+").write(head+print_nav+eps[0]+foot)
open("railscasts/index.xml","w+").write(make_rss_main(eps[1]))

EpisodeTypes.each do |type|
  rel_path = "../"
  eps = print_episodes([type],rel_path)
  open("railscasts/#{type}/index.html","w+").write(head+eps[0]+foot)
  open("railscasts/#{type}/index.xml","w+").write(make_rss_main(eps[1]))
  filelists(type).each do |ep|
    next unless ep.reverse.split(".")[0] == "4pm"
    htmlfile = ep.to_s.split(".")[0]+".html"
    ascii = "asciicasts/"+ htmlfile
    raw = "raw/"+ htmlfile
    watch_ep = %{<a class="btn" href="#{rel_path}#{ep}">Watch Episode</a>}
    if File.exists?("railscasts/#{type}/#{raw}")
      open("railscasts/#{type}/#{ascii}","w+") do |asci|
        asci.write( head(:ascii, ep.split(".")[0].split(".")[0].gsub("-"," ").capitalize, watch_ep)+open("railscasts/#{type}/#{raw}").read+foot )
      end
    end
  end

end

