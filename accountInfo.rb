#require 'openssl'
#require 'steam-api'
#gem 'steam-api'
#Steam.apikey = key
#puts Steam::Player.steam_level(pkey)

# get friends list of a user and their info
# found a way to get from steamid to display names (the gem's methods were oddly slow)


require 'json'
require 'steam_web_api'

apikey = 'steamdev-api-key-here'  # steam app api key
apikey = 'A9F3DD5EBFB794FC3C87FF96FAD2F423'
pkey = '76561198017058828'        # steamid of a user
ownedAppIDs = []
steamVanityNames = []
steamIdKeys = ''


# Faraday undefined -> check api keys
#### https://github.com/lostisland/faraday
conn = Faraday.new(:url => 'http://api.steampowered.com/') do |faraday|
  faraday.request  :url_encoded                          # form-encode POST params
  #faraday.response :logger                              # log requests to STDOUT
  faraday.headers['Content-Type'] = 'application/json'   # set the content type to JSON
  faraday.adapter  Faraday.default_adapter               # make requests with Net::HTTP
end


# for Rails, you can put this code in initializer: 
# config/initializers/steam_web_api.rb
SteamWebApi.configure do |config|
    config.api_key = apikey
end

# get the same games a user has
# with the original user
def getSharedGames(plyr, uname)
	puts('global games: ')
	puts(plyr.owned_games)
	puts()
	puts('games for: ' + uname)
end

# query for the chose user's info (based on community id)

player = SteamWebApi::Player.new(pkey)
data = player.owned_games
# owned_games has additional options
data = player.owned_games(include_played_free_games: true, include_appinfo: true)
puts('username: ' + player.summary.profile['personaname'])

# take the string of all steamids from friends list
# query the steam api for their display names
player.friends.friends.each { |friend| 
	steamIdKeys += friend['steamid'] + ','
}


# hash of owned game data with array of games
# separate out the app IDs of games owned for usage
player.owned_games.games.each { |game|
	ownedAppIDs.push(game['appid'])
}
puts()
puts('sorted owned')
puts(ownedAppIDs)
puts('done owned')

response = conn.get 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' + apikey + '&steamids=' + steamIdKeys
JSON.parse(response.body)['response']['players'].each { |friend|
	steamVanityNames.push(friend['personaname'])
}








# visually confirm the two counts are the same
puts('      nSteamid len: ' + player.friends.friends.count.to_s)
puts('nDisplay names len: ' + steamVanityNames.count.to_s)
puts
puts 'done'



getSharedGames(player, "chris")




=begin       -- initial irb test --


2.2.3 :005 > require 'steam_web_api'
 => true 
2.2.3 :006 > SteamWebApi.configure do |config|
2.2.3 :007 >     config.api_key = 'steam-dev-apikey'
2.2.3 :008?>   end
2.2.3 :009 > player = SteamWebApi::Player.new('player-apikey')
2.2.3 :010 > player.methods


the methods available to a player object:

[:steam_id, :steam_id=, :owned_games, :stats_for_game, :achievements, :summary, 
	:friends, :recently_played_games, :playing_shared_game, :bans, :response, 
	:response=, :get, :parse_response, :build_response, :to_json, :nil?, :===, 
	:=~, :!~, :eql?, :hash, :<=>, :class, :singleton_class, :clone, :dup, :itself, 
	:taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :freeze, :frozen?, 
	:to_s, :inspect, :methods, :singleton_methods, :protected_methods, 
	:private_methods, :public_methods, :instance_variables, :instance_variable_get, 
	:instance_variable_set, :instance_variable_defined?, :remove_instance_variable, 
	:instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, 
	:extend, :display, :method, :public_method, :singleton_method, 
	:define_singleton_method, :object_id, :to_enum, :enum_for, :==, :equal?, :!, 
	:!=, :instance_eval, :instance_exec, :__send__, :__id__]


=end