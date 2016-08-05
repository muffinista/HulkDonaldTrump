#!/usr/bin/env ruby

require 'rubygems'
require 'chatterbot/dsl'

#
# this is the script for the twitter bot HulkDonaldTrump
# generated on 2016-08-03 16:38:53 -0400
#

ADMIN_USERS = ["muffinista"]

# remove this to get less output when running your bot
#verbose

# Exclude a list of offensive, vulgar, 'bad' words. This list is
# populated from Darius Kazemi's wordfilter module
# @see https://github.com/dariusk/wordfilter
exclude bad_words

def hulkify_tweet(tweet)
  return false if tweet.retweet? ||
                  tweet.text =~ /http/ ||
                  tweet.text =~ /@/ ||
                  tweet.user.screen_name !~ /realdonaldtrump/i
  
  output = tweet.text.upcase.gsub(/["']/, "")
  ["IS", "THE", "WAS", "HAD", "AN", "TO"].each { |w|
    output = output.gsub(/\b#{w}\b/, " ")
  }

  output = output.
           gsub(/WE\b/, "HULK ").
           gsub(/MY\b/, "HULK'S ").
           gsub(/OUR\b/, "HULK'S ").
           gsub(/I\b/, "HULK ").
           gsub(/IM\b/, "HULK ").
           gsub(/AM\b/, "IS ")
  
  output = output.gsub(/BEAT\b/, "SMASH ")
  
  output = output.gsub(/ED\b/, "")
  

  output = output.gsub(/ +/, " ").gsub(/\./, "!").lstrip.rstrip

  output = output.gsub(/&amp;/i, "&")

  #puts tweet.text
  #puts output

  if output.length < 130
    output = output.gsub(/!/) { "!" * rand(1..4) }
  end
  
  tweet output
  true

end

#
# the bot follows realDonaldTrump and will get tweets from its home_timeline
#
@tweeted = false
home_timeline do |tweet|
  next if @tweeted == true
  @tweeted = hulkify_tweet(tweet)
end

#
# neat trick, you can DM links to realDonaldTrump tweets and the bot
# will hulkify them. but only if you're an admin user!
#
direct_messages do |tweet|
  next if ! ADMIN_USERS.include? tweet.sender.screen_name

  #STDERR.puts "well, here i am #{tweet.sender.screen_name}: #{tweet.text}"
  puts tweet.uris.inspect
  url = tweet.urls[0].expanded_url

  puts url

  uri = URI(url)
  path = uri.path

  #https://twitter.com/realDonaldTrump/status/759479059046883328

  tweet_id = path.split(/\//).last

  original = client.status(tweet_id)
  puts original.inspect

  hulkify_tweet(original)
  
end
  
