# this worker listens for jobs and when it receives one it spins the dicebot, 
# takes a picutre, counts the pips, and tweets the results
require 'rubygems'
require 'firebase'
require 'aws/s3'
require 'date'
require 'twitter'

base_uri = 'https://dicebot.firebaseio.com'
firebase = Firebase::Client.new(base_uri, "XXXXXXXXXXXXXXX")

AWS::S3::Base.establish_connection!(
  :access_key_id     => 'XXXXXXXXXXXXXXX',
  :secret_access_key => 'XXXXXXXXXXXXXXX'
)

while true
  begin
    request = firebase.get('spin_requests', { :limit => 1 })    
    unless request.body.empty?
      user = request.body.first.last["user"]
      message = request.body.first.last["message"]
      request_id = request.body.first.first
    
      if user
        `sudo python spin.py`
        `raspistill -o dice.jpg -n -t 0 -w 640 -h 480`
        pips = `./count dice.jpg`
        #pips = "5"
      
        # Upload the image to s3    
        filename = "#{user}-dicebot-roll-#{ DateTime.now.strftime('%Q') }.jpg"
        AWS::S3::S3Object.store(filename, open("dice.jpg"), 'dicebot-images.intridea.com', :access => :public_read)
        file_url = "http://dicebot-images.intridea.com/#{filename}"
      
        # Put the result on the list to dispay on the website. 
        firebase.push('spin_results', { :count => pips, :user => user,
          :file_url => file_url, :message => message, :created_at => Time.new.strftime("%m/%d/%Y %I:%M %p"),
          :".priority" => (Time.gm(2020) - Time.new).to_f })
      
        # Send a tweet with the response back to the user
        client = Twitter::REST::Client.new do |config|
          config.consumer_key       = 'XXXXXXXXXXXXXXX'
          config.consumer_secret    = 'XXXXXXXXXXXXXXX'
          config.oauth_token        = 'XXXXXXXXXXXXXXX'
          config.oauth_token_secret = 'XXXXXXXXXXXXXXX'
        end
        client.update("Dicebot rolled you a #{pips}, @#{user}. See your role at #{file_url} #DiceBot #INTRIDEA")
            
        # Delete the request from firebase
        firebase.delete("https://dicebot.firebaseio.com/spin_requests/#{request_id}")
      end  
    else
      sleep(30)
    end
  rescue
    # TODO
    firebase = Firebase::Client.new(base_uri)

    AWS::S3::Base.establish_connection!(
      :access_key_id     => 'XXXXXXXXXXXXXXX',
      :secret_access_key => 'XXXXXXXXXXXXXXX'
    )    
  end
end

# for i in 1..100 do
#   twitter_user = "@user#{i}"
#   twitter_message = "roll the dice #{i}"
#   response = firebase.push('spin_requests', { :twitter_user => twitter_user,  :twitter_message => twitter_message, :".priority" => (Time.gm(2020) - Time.new).to_f })
# end