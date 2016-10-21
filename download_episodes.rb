require 'open-uri'
require 'net/https'
require 'rubygems'
require 'nokogiri'

class Episodes

  include RailsCastsCommon

  attr_reader :media_url, :format

  def initialize
    get_subscription_code
    @media_url = {
      :free => "http://media.railscasts.com/assets/episodes/videos/",
      :subscription => "http://media.railscasts.com/assets/subscriptions/#{subscription_code}/videos/"
    }
    @format    = ".mp4"
    @save_data = []
  end

  def subscription(type)
    if type == :revised || type == :pro
      :subscription
    elsif type == :free
      :free
    else
      type
    end
  end

  def pageopen(url,use_cookies=false)
    puts "Opening page #{url}"
    ck = ""
    if use_cookies
      ck = CookieString
    end

    begin
      page = open(url, :proxy => proxy, "Cookie" => ck)
    rescue OpenURI::HTTPError => e
      page                    = nil
      puts "The request for a page at #{url} returned an error. #{e.message}"
    end
    page
  end

  def process
    fetch
    save
    true
  end

  def download full_url, to_here
    writeOut = open(to_here, "wb")
    data     = pageopen(full_url)
    if data
      writeOut.write(data.read)
      writeOut.close
    end
    !data.nil?
  end

  def fetch
    episode_urls = { :free => [ "http://railscasts.com/?type=free"], :revised => %w{http://railscasts.com/?type=revised}, :pro => %w{http://railscasts.com/?type=pro } }
    base_url     = "http://railscasts.com"
    asciiview    = "?view=asciicast"
    asciiformat  = ".html"
    asciicasts   = "asciicasts"
    asciiimages  = "#{asciicasts}/images"

    episode_urls.each do |type,urls|
      urls.each do |url|
        limiter = ARGV[0].to_i || 1
        until url.nil? == true
          p     = pageopen(url)

          page  = Nokogiri::HTML(p.read)

          page.css("h2 > a").each do |link|

            ep  = link["href"].split("/")[2]

            epa = (ep.split("-")[0]).size
            ep  = ("0"*(3-epa))+ep if epa - 3 < 0

            unless File.exists?("railscasts/#{type}/#{ep}#{format}") && File.open("railscasts/#{type}/#{ep}#{format}", 'r').size > 1000000
              open("railscasts/#{type}/get.url",'a+').write( "wget -c "+media_url[subscription(type)]+ep+format + "\n")
            else
              save_data << link["href"]
            end

            # now process asciicasts
            ascii_file = "railscasts/#{type}/raw/#{ep}#{asciiformat}"
            unless File.exists?(ascii_file) && (File.open(ascii_file).size > 10) && (File.open(ascii_file).read =~ /Currently no transcriptions/).nil?
              puts "Processing Asciicast for #{type}/#{ep}"
              ascii                                             = pageopen(base_url+link["href"]+asciiview, subscription(type)==:subscription )
              Nokogiri::HTML(ascii.read).css(".asciicast").each do |epread|
                epread.css('img').each do |x|
                  next unless x['src'][0..3] == base_url[0..3]
                  ai       = "railscasts/#{type}/#{asciiimages}/#{x['src'].split('/')[-1].split('?')[0]}"
                  download x['src'],ai
                  x['src'] = "/"+ai
                end

                # we dont need this additional clippy
                epread.css('.clippy').each {|d| d.inner_html    = ""}
                epread.css('.languages').each {|d| d.inner_html = ""}

                File.open("railscasts/#{type}/raw/#{ep}#{asciiformat}","w+") do |f|
                  f.write(epread.inner_html)
                end
              end
            end

          end
          url   = nil
          LimitPages = 0 # 0 will ignore this config

          next if (LimitPages - limiter == 0)
          limiter +=1

          p     = page.css(".pagination > a[@rel='next']")
          p.each do |link|
            url = base_url+link["href"]
          end

        end
      end
      # now go to next page and perform the same
    end
  end

  def save
    eplist       = open('./railscasts.txt','w+')
    eplist.write(link["href"]+"\n")
    eplist.close
  end

end