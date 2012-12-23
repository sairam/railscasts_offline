# Scraper for [Railscasts](http://railscasts.com/)
* Pro and Revised episodes require subscription at [railscasts.com/pro](http://railscasts.com/pro)

# Disclaimer
* This was a code written in mid 2011 when I got frustrated with my internet connection and was eager to go through Railscasts.
* No standards were followed during the making of these files.

# Written for ruby 1.9.3
```bash
# requires rubygems
gem install nokogiri
```

# Setup

```bash
mkdir -p railscasts/{free,pro,revised}/{raw,asciicasts} railscasts/{free,pro,revised}/asciicasts/images
cd railscasts
wget http://railscasts.com/assets/railscasts_logo.png
wget http://www.feedicons.com/download/feedicons-standard.zip
unzip feedicons-standard.zip && rm feedicons-standard.zip
mv feed-icon-14x14.png feed-icon-small.png
mv feed-icon-28x28.png feed-icon.png
cd ..
```
# Configuring
Fill up your subscription code, cookie token and target_url where you plan to host.
```bash
cp subscription_code.rb.example subscription_code.rb
# Open http://railscasts.com
# copy cookie and subscription code
vim subscription_code.rb
```

# Getting the latest episode versions
```bash
ruby download_episodes.rb # This will populate the wget urls in the free, pro and revised
# run ruby download_episodes.rb 0 for the first time to download all the versions . Otherwise only last 1 page in the railscasts list will be considered for download
sh wget   #  script to download all the files.
ruby generate_index.html.rb # to generate the index.html, index.rss for viewing on a web browser
```
# TODO 
1. add a script given the username and password fetches and populates subscription\_code.rb
1. Fix publication dates in RSS Feeds
1. Refactor code in classes. 

# LICENSE
See LICENSE file for distribution

# NOTE - [Content Distribution of RailsCasts](http://railscasts.com/about) 
All free RailsCasts episodes are under the Creative Commons license. You are free to distribute unedited versions of those episodes for non-commercial purposes. You are also free to translate them into any language. If you would like to edit the video please contact [Ryan Bates](http://github.com/ryanb). All pro and revised episodes are not licensed for redistribution.