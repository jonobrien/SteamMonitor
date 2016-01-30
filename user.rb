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


	# get the users steam information
	# returns: steamwebapi player object
	def getUser(pid)
		puts('[I] getting user info for: ' + pid.to_s)
		return SteamWebApi::Player.new(pid)
	end


	# take the string of all steamids from friends list
	# make csv string for conversion with getFriendVanities()
	# returns: csv string of friend IDs
	def getFriendIDs(user)
		@friendStr = ''
		puts('[I] getting friend IDs for: ' + user.summary.profile['personaname'])
		user.friends.friends.each { |friend| 
			@friendStr += friend['steamid'] + ','
		}
		return @friendStr
	end


	# found a way to get from steamid to display names (the gem's methods were odd/slow)

	# take in the users community id and convert the friend list
	# from IDs to usernames as seen by the user normally
	# returns: array of user personas as displayed in friends list
	def getFriendPersonas(apikey, id, steamIdKeys)
		@personas = []
		response = $conn.get 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' + apikey + '&steamids=' + steamIdKeys
		JSON.parse(response.body)['response']['players'].each { |friend|
			@personas.push(friend['personaname'])
		}
		return @personas
	end


	# hash of owned game data with array of games
	# separate out the app IDs of games owned for usage
	# returns: array of games user owns/f2p played
	def getAllOwned(user)
		@owned = []
		puts('[I] getting games for: ' + user.summary.profile['personaname'])
		user.owned_games(include_played_free_games: true, include_appinfo: true).games.each { |game|
			@owned.push(game['appid'])
		}
		return @owned
	end


	#take in the app IDs and return a hash of {id => name}...
	def getGameNames(idArr)
		puts(idArr)
		# TODO -- getAllOwned should return appid and name to refactor this

	end


	# get the same games a user has
	# with the original user
	# returns: array of games both users have
	def getSharedGames(firID, secID)###varArr)
		@same = []
		puts()
		firP = getUser(firID)
		puts('[I] getting shared games for: ' + firID.to_s + ' and friends')
		# # take array of user IDs and make hash of ID => user info
		# @users = {}
		# varArr.each{ |userID|
		# 	@usr = getUser(userID)
		# 	@users[userID.to_s] = @usr
		# }
		secP = getUser(secID)###varArr[5])
		mainGames = getAllOwned(firP)
		newPgames = getAllOwned(secP)
		puts('[I] new size: ' + newPgames.size.to_s)
		puts('[I] old size: ' + mainGames.size.to_s)
		@same = compareGames(mainGames, newPgames)
		puts()
		return @same
	end


	# need to find the ruby-esque way of doing this
	# emun.detect or enum.find_all/find_index?
	# grep/grep_v?
	def compareGames(firstArr, secArr)
		@same = []
		puts('[I] comparing games...')
		if (firstArr.size < secArr.size)
			puts('[I] first < second')
			firstArr.each { |first|
				secArr.each { |second|
					if (second == first)
						@same.push(second)
						break # break - found the game
					end
				}
			}
		else
			puts('[I] second < first')
			secArr.each { |first|
				firstArr.each { |second|
					if (second == first)
						@same.push(second)
						break # break - found the game
					end
				}
			}
		end
		puts('[I] nSame: ' + @same.size.to_s)
		return @same
	end


	# take in a couple users and desired games
	# returns: hash of achievements have in common for games
	def getSharedAchievements(usrOne, usrTwo, gameArr)
		puts('[I] getting shared achievements for users:')
		puts('    and games:')
	end


end # end class