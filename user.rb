require 'json'
require 'steam_web_api'


# user class that handles all the data manipulation
# for steam web api calls and sanitation
class User

	## take in the users community id and return their info
	# def initialize(id)
	# 	puts ('user initialized: ' + id)
	# 	@user = SteamWebApi::Player.new(id)
	# 	puts('queried data for: ' + @user.summary.profile['personaname'])
	# 	return @user
	# end
	def initialize()
	end


	# take the string of all steamids from friends list
	# make csv string for conversion with getFriendVanities()
	def getFriendIDs(user)
		@friendStr = ''
		user.friends.friends.each { |friend| 
			@friendStr += friend['steamid'] + ','
		}
		return @friendStr
	end


	# take in the users community id and convert the friend list
	# from IDs to usernames as seen by the user normally
	def getFriendVanities(apikey, id, steamIdKeys)
		@personas = []
		response = $conn.get 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' + apikey + '&steamids=' + steamIdKeys
		JSON.parse(response.body)['response']['players'].each { |friend|
			@personas.push(friend['personaname'])
		}
		return @personas
	end


	# hash of owned game data with array of games
	# separate out the app IDs of games owned for usage
	def getAllOwned(user)
		@owned = []
		user.owned_games(include_played_free_games: true, include_appinfo: true).games.each { |game|
			@owned.push(game['appid'])
		}
		return @owned
	end


	# get the same games a user has
	# with the original user
	# compare lists...
	# need to get the list of the second user...
	def getSharedGames(user, uid)
		puts()
		puts('games for: ' + uid)
		newP = SteamWebApi::Player.new(uid)
		newPgames = getAllOwned(newP)
		mainGames = getAllOwned(user)
		@same = []
		if (newPgames.count.to_s < mainGames.count.to_s)
			# compare every new user game against old
		else
			# compare every old with new
		end # if block
		return @same
	end


	



end # end class