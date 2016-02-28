require 'rubygems'
require 'tweetstream'
require 'firebase'
require 'date'
require 'twitter'

TweetStream.configure do |config|
  config.consumer_key       = 'XXXXXXXXXXXXXXX'
  config.consumer_secret    = 'XXXXXXXXXXXXXXX'
  config.oauth_token        = 'XXXXXXXXXXXXXXX'
  config.oauth_token_secret = 'XXXXXXXXXXXXXXX'
  config.auth_method        = :oauth
end

base_uri = 'https://dicebot.firebaseio.com'
firebase = Firebase::Client.new(base_uri, "XXXXXXXXXXXXXXX")

TweetStream::Daemon.new('twitter_listener', :log_output => true).userstream do |status|
  # begin
    client = Twitter::REST::Client.new do |config|
      config.consumer_key       = 'XXXXXXXXXXXXXXX'
      config.consumer_secret    = 'XXXXXXXXXXXXXXX'
      config.oauth_token        = 'XXXXXXXXXXXXXXX'
      config.oauth_token_secret = 'XXXXXXXXXXXXXXX'
    end
  
    # look for the #RollTheDice hashtag to trigger creation of a job
    unless status.retweet?
      puts "tweet received: #{status.text}"
      if /\B#RollTheDice/ =~ status.text   
        puts "tweet has hashtag: #{status.text}"       
        firebase.push('spin_requests', { :user => status.user.screen_name, 
          :message => status.text, :created_at => Time.new.strftime("%m/%d/%Y %I:%M %p"),
          :".priority" => (Time.gm(2020) - Time.new).to_f })

        # send a tweet back to the user to tell them it's queued and with a link to the site
        client.update("You're roll is coming up, @#{status.user.screen_name}. Check the status at http://dicebot.intridea.com #DiceBot #INTRIDEA")
      end
    end
  # rescue
  #   # TODO    
  # end
end
