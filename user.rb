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


	#take in the app IDs and return a hash of {id => name}...
	def getGameNams(idArr)
		puts(idArr)

	end


	# get the same games a user has
	# with the original user
	def getSharedGames(first, second)
		@same = [] # the compared games that both users have
		puts()
		puts('[I] shared games for: ' + first.to_s + ' and ' + second.to_s)

		secP = SteamWebApi::Player.new(second)
		firP = SteamWebApi::Player.new(first)
		mainGames = getAllOwned(firP)
		newPgames = getAllOwned(secP)
		puts('[I] new size: ' + newPgames.size.to_s)
		puts('[I] old size: ' + mainGames.size.to_s)

		# need to find the ruby-esque way of doing this
		# emun.detect or enum.find_all/find_index?
		# grep/grep_v?
		if (newPgames.size < mainGames.size)
			puts('[I] new < old')
			newPgames.each { |first|
				mainGames.each { |second|
					if (second == first)
						@same.push(second)
						break
					end
				}
			}
		else
			puts('[I] old < new')
			mainGames.each { |first|
				newPgames.each { |second|
					if (second == first)
						@same.push(second)
						break
					end
				}
			}
		end
		puts('[I] nSame: ' + @same.size.to_s)
		puts()
		return @same
	end


	



end # end class