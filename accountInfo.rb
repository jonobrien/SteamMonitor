#require 'openssl'
#require 'steam-api'
#gem 'steam-api'
#Steam.apikey = key
#puts Steam::Player.steam_level(pkey)

# get friends list of a user and their info and compare owned games between friends
# TODO -- add achievement comparison functions similar to games

load 'user.rb'



def main

	apikey = 'steamdev-api-key-here'  # steam app api key
	pID    = '76561198017058828'        # steamid of a user


	# Faraday undefined -> check api keys
	#### https://github.com/lostisland/faraday
	$conn = Faraday.new(:url => 'http://api.steampowered.com/') do |faraday|
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




	# query for the chosen user's info (based on community id)
	usr = User.new()
	mainP = usr.getUser(pID)
	mainPfriendstr = usr.getFriendIDs(mainP)
	mainFriendIDs = mainPfriendstr.split(",")
	mainPFriends = usr.getFriendPersonas(apikey, pID, mainPfriendstr)
	puts('username: ' + mainP.summary.profile['personaname'])
	# visually confirm the two counts are the same, id and persona
	puts('      nSteamid len: ' + mainP.friends.friends.size.to_s)
	puts('nDisplay names len: ' + mainPFriends.size.to_s)
	puts()
	puts('done')
	## get the games that three chosen users have in common
	shared = usr.getSharedGames(pID, mainFriendIDs[5])##mainFriendIDs)
	thirdP = usr.getAllOwned(usr.getUser(mainFriendIDs[1]))
	sharedThird = usr.compareGames(shared, thirdP)
end # end main

main



=begin       -- initial irb test --


2.2.3 :005 > require 'steam_web_api'
 => true 
2.2.3 :006 > SteamWebApi.configure do |config|
2.2.3 :007 >     config.api_key = 'steam-dev-apikey'
2.2.3 :008?>   end
2.2.3 :009 > player = SteamWebApi::Player.new('player-apikey')
2.2.3 :010 > player.methods


-- the methods available to a player object  --

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