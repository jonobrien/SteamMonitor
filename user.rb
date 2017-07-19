require 'json'
require 'steam_web_api'


# user class that handles all the data manipulation
# for steam web api calls and sanitation

class User

    ### TODO -- make initializer with @vars and refactor

    ## take in the users community id and return their info
    # def initialize(id)
    #   puts ('user initialized: ' + id)
    #   @user = SteamWebApi::Player.new(id)
    #   puts('queried data for: ' + @user.summary.profile['personaname'])
    #   return @user
    # end
    def initialize()
        puts('[I] new player initialized')
    end


    # get the users steam information
    # returns: steamwebapi player object
    def getUser(pid)
        puts('[I] accessing user info for: ' + pid.to_s)
        # this seems computationaly heavy
        @player = SteamWebApi::Player.new(pid)
        puts('[I] retrieved user info for: ' + @player.summary.profile['personaname'])
        return @player
    end


    # take the string of all steamids from friends list
    # make csv string for conversion with getFriendVanities()
    # returns: csv string of friend IDs
    def getFriendIDstr(user)
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
        @owned = Hash.new
        puts('[I] getting games for: ' + user.summary.profile['personaname'])
        user.owned_games(include_played_free_games: true, include_appinfo: true).games.each { |game|
            @owned[game['appid']] = game['name']
        }
        return @owned
    end


    # get the same games a user has
    # with the original user
    # returns: array of games both users have
    def getSharedGames(firID, secID)###varArr)
        @same = []
        firP = getUser(firID)
        puts('[I] getting shared games for: ' + firID.to_s + ' and friends')
        # # TODO ?? -- take array of user IDs and make hash of ID => user info
        # @users = {}
        # varArr.each{ |userID|
        #   @usr = getUser(userID)
        #   @users[userID.to_s] = @usr
        # }
        secP = getUser(secID)
        mainGames = getAllOwned(firP)
        newPgames = getAllOwned(secP)
        puts('[I] new size: ' + newPgames.size.to_s)
        puts('[I] old size: ' + mainGames.size.to_s)
        @same = compareGames(mainGames, newPgames)
        return @same
    end


    # need to find the ruby-esque way of doing this
    # emun.detect or enum.find_all/find_index?
    # grep/grep_v?
    def compareGames(oneHash, twoHash)
        firstArr = oneHash.keys
        secArr = twoHash.keys
        @same = Hash.new
        puts('[I] comparing games...')
        if (firstArr.size < secArr.size)
            puts('[I] first < second')
            firstArr.each { |first|
                secArr.each { |second|
                    if (second == first)
                        @same[second] = twoHash[second]
                        break # break - found the game
                    end
            }}
        else # only search the smaller of the two
            puts('[I] second < first')
            secArr.each { |first|
                firstArr.each { |second|
                    if (second == first)
                        @same[second] = twoHash[second]
                        break # break - found the game
                    end
            }}
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


    # The steam API method for player summaries is dynamic
    # take in array of friend IDs, return hash of all friend data
    def getAllFriendData(usr)
        puts('[I] retrieving friend data for: ' + usr.summary.profile['personaname'])
        friendArr = getFriendIDstr(usr).split(',')
        @data = SteamWebApi::Player.summary(friendArr)
        if (@data.success == true)
            puts('[I] success')
            return @data.players
        end
        puts('[!!] Failed getting all friend data')
        puts()
        puts(@data)
        puts()
        return Hash.new
    end


    # take in game Hash and determine if game supports mp
    def getGameMultiplayerInfo(conn, gameHash)
        # http://store.steampowered.com/api/appdetails?appids=GAMEHASH.keys[index]
        # json[appid][data][categories][0][id] # 2, singleplayer
        # json[appid][data][categories][1][id] # 1, multiplayer
        # json[appid][data][categories][4][id] # 4, cross-platform mp
    end


end

=begin
        SAMPLE JSON RESPONSE
        {
            "113020":{
                "success":true,
                "data":{
                        ...
                    "categories":[
                        {
                           "id":2,
                           "description":"Single-player"
                        },{
                           "id":1,
                           "description":"Multi-player"
                        },{
                           "id":9,
                           "description":"Co-op"
                        },{
                           "id":24,
                           "description":"Shared\/Split Screen"
                        },{
                           "id":27,
                           "description":"Cross-Platform Multiplayer"
                        },{
                           "id":22,
                           "description":"Steam Achievements"
                        },{
                           "id":28,
                           "description":"Full controller support"
                        },{
                           "id":29,
                           "description":"Steam Trading Cards"
                        },{
                           "id":30,
                           "description":"Steam Workshop"
                        },{
                           "id":23,
                           "description":"Steam Cloud"
                        },{
                           "id":25,
                           "description":"Steam Leaderboards"
                        },{
                           "id":17,
                           "description":"Includes level editor"
                        }
                    ],
                    "platforms":{  
                        "windows":true,
                        "mac":true,
                        "linux":true
                    },
                    ...
                }
         }

=end