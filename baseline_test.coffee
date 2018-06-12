# Description
#   Keeps track of lunch orders
#
# Commands:
#   lunch order me <restaurant> -> <order> - adds order to specified restaurant
#   lunch summarize <restaurant> - displays a summary of all orders for specified restaurant
#   lunch cancel my orders - deletes all orders by user from all restaurants
#
# Author:
#   Dino Milacic, Vladimir Kovac

removeFromArray = (array, item, index) =>
    while((index = array.indexOf(item)) > -1) 
        array.splice(index, 1);
    



module.exports = (robot) ->

    db = {}

    robot.hear /baseline test (@.+)/i, (msg) ->
        
        challenger = msg.message.user.name
        testee = msg.match[1]
        
        msg.send testee + ", " + challenger + " has requested a baseline test. Your participation is mandatory. Failure to comply would result in a violation of GDP-R-69-N. Let's begin. Are you ready?"

        db = robot.brain.get 'baseline_test_db'

        if not db?
            db = {}

        db[testee] = {}

        db[testee]["step"] = 0
        db[testee]["questions_answered"] = 0;
        db[testee]["correct_answers"] = 0;

        db[testee]["questions"] = []
        db[testee]["answers"] = []

        questions = []
        answers = []
        questions[0] = ""
        answers[0] = "yes"

        questions[1] = "Recite your baseline."
        answers[1] = "And blood-black nothingness began to spin... A system of cells interlinked within cells interlinked within cells interlinked within one stem... And dreadfully distinct against the dark, a tall white fountain played."

        questions[2] = "Cells."
        answers[2] = "Cells."

        questions[3] = "Have you ever been in an institution? Cells."
        answers[3] = "Cells."

        questions[4] = "Do they keep you in a cell? Cells."
        answers[4] = "Cells."


        db[testee]["questions"] = questions
        db[testee]["answers"] = answers

        ###


        lunchString = (userMsg.split " ")[0]
        didUseLunch = lunchString.toUpperCase() == "LUNCH"
        
        restoran = msg.match[2].toUpperCase()
        jelo = msg.match[3].toUpperCase()
        

        # msg.send "R:"+restoran+"  J:"+jelo+"   U:"+user

        db = robot.brain.get 'lunch-db'
        currentTime = new Date()
        currentTime = new Date( currentTime.getFullYear(), currentTime.getMonth(), currentTime.getDate())
		
        # msg.send "currentTime: " + currentTime
		
        if not db?
            db = {}

        recordedTime = new Date()
        if db["time"]?
            recordedTime = new Date(db["time"])
        else
            recordedTime = new Date('01/01/2000')
        # msg.send "recordedTime " + recordedTime

        recordedTime = new Date( recordedTime.getFullYear(), recordedTime.getMonth(), recordedTime.getDate())

        milisecsPerDay = 1000 * 60 * 60 * 24
        milisecsBetween = currentTime.getTime() - recordedTime.getTime()
        days = milisecsBetween / milisecsPerDay
		
        # msg.send "currentTime.time: " +  currentTime.getTime()
        # msg.send "recordedTime.time: " +  recordedTime.getTime()
        
        # msg.send "days " + days
        # msg.send "days " + Math.floor(days)
        
        if Math.floor(days) != 0
            db["data"] = null
            db["time"] = currentTime
			
        # msg.send "time " + db["time"]
        # msg.send "data " + db["data"]
			
        if not db["data"]?
            db["data"] = {}

        if not db["data"][restoran]?
            db["data"][restoran] = {}

        if not db["data"][restoran][jelo]?
            db["data"][restoran][jelo] = 
                "amount": 0,
                "users": []

        db["data"][restoran][jelo]["amount"] += 1

        # if db["data"][restoran][jelo]["users"].indexOf(user) < 0
            # db["data"][restoran][jelo]["users"].push user
        db["data"][restoran][jelo]["users"].push user   

        # msg.send db["data"]
        robot.brain.set 'lunch-db', db

        if (didUseLunch)
            msg.send user + ": Lunch added! ✅"
        else
            msg.send user + ": Unch added! ✅ (I got your back :relaxed:)"
    ###

    robot.listen(
        # Matcher
        (message) ->
            console.log "User:" + user + " db:" + db
            user = message.user.name
            if user in db
                # Respond
                console.log "Y"
                step = db[user]["step"]
                answers = db[user]["answers"]                
                correct_answers = db[user]["correct_answers"]

                if message == answers[step]
                    db[user]["correct_answers"] = correct_answers + 1
                true
            else
                console.log "N"
                false
        # Callback
        (response) ->
            response.send "RESPONSE"
            if db? and db[user]?
                step = db[user][step]
                db[user][step] = step + 1
                q = db[user][questions][step + 1]
                questions_answered = db[user]["questions_answered"]
                db[user]["questions_answered"] = questions_answered + 1
                response.reply q
    )

    robot.hear /^lunch summarize (.+)$/i, (msg) ->
        targetRestoran = msg.match[1].toUpperCase()

        # msg.send "R:"+targetRestoran

        db = robot.brain.get 'lunch-db'

        currentTime = new Date()
        currentTime = new Date( currentTime.getFullYear(), currentTime.getMonth(), currentTime.getDate())

        if not db?
            db = {}

        recordedTime = new Date()
        if db["time"]?
            recordedTime = new Date(db["time"])
            # msg.send "recordedTime: " + db["time"]

        recordedTime = new Date( recordedTime.getFullYear(), recordedTime.getMonth(), recordedTime.getDate())

        milisecsPerDay = 1000 * 60 * 60 * 24
        milisecsBetween = currentTime.getTime() - recordedTime.getTime()
        days = milisecsBetween / milisecsPerDay

        if Math.floor(days) != 0
            db["data"] = null
            db["time"] = currentTime

        response = "*`-- SAZETAK -- " + targetRestoran + " --`*\n```\n"
        if db["data"]?
            if Object.keys(db["data"]).length > 0
                for r in Object.keys(db["data"])
                    if r isnt targetRestoran
                        continue
                    restoran = db["data"][r]
                    for jelo in Object.keys(restoran)
                        order = restoran[jelo]
                        response += '- ' + jelo + ' x ' + order["amount"] + "  {" + order["users"].join(', ') + "}" + '\n'
            else
                response += "404 lunch not found\n"
        else
            response += "404 lunch not found\n"
        response +=   "```"

        msg.send response

    robot.hear /^lunch cancel my orders$/i, (msg) ->
        # targetRestoran = msg.match[1].toUpperCase()
        # jelo = msg.match[2].toUpperCase()
        user = msg.message.user.name

        # msg.send "U:"+user
        
        db = robot.brain.get 'lunch-db'

        currentTime = new Date()
        currentTime = new Date( currentTime.getFullYear(), currentTime.getMonth(), currentTime.getDate())

        if not db?
            db = {}

        recordedTime = new Date()
        if db["time"]?
            recordedTime = new Date(db["time"])

        recordedTime = new Date( recordedTime.getFullYear(), recordedTime.getMonth(), recordedTime.getDate())

        milisecsPerDay = 1000 * 60 * 60 * 24
        milisecsBetween = currentTime.getTime() - recordedTime.getTime()
        days = milisecsBetween / milisecsPerDay

        if Math.floor(days) != 0
            db["data"] = null
            db["time"] = currentTime

        if db["data"]?
            i = 0
            while i < Object.keys(db["data"]).length
                r = Object.keys(db["data"])[i]
                restoran = db["data"][r]
                for jelo in Object.keys(restoran)
                    order = restoran[jelo]
                    # msg.send "ORDER #"+i+" -> "+jelo+" : "+order["amount"]+"{"+order["users"].join(", ")+"}"
                    index = order["users"].indexOf(user)
                    while index >= 0 # or order["users"].length > 0 or order["amount"] > 0
                        # continue
                        # removeFromArray(order["users"],user,0)
                        order["users"].splice(index,1)
                        order["amount"] = Math.max(0,order["amount"] - 1)
                        
                        # msg.send "=> index="+index+" -> "+jelo+" : "+order["amount"]+"{"+order["users"].join(", ")+"}"

                        if order["amount"] == 0
                            # msg.send "Order data deleted ✅"
                            delete restoran[jelo]
                            break

                        index = order["users"].indexOf(user)

                if Object.keys(restoran).length <= 0
                    delete db["data"][r]
                    # msg.send "Restaurant deleted! ✅"
                else
                    i++
                    # msg.send "Nope"
            msg.send "Orders canceled! ✅"
        else
            msg.send "No data"

        robot.brain.set 'lunch-db', db

    # robot.hear /lunch test my order (.+) -&gt; (.+)/i, (msg) ->
    #     input = msg.match[1].toUpperCase().split("->")
    #     targetRestoran = input[0]
    #     targetJelo = input[1]
    #     user = msg.message.user.name
    #     msg.send "R:"+targetRestoran+"  J:"+targetJelo+"   U:"+user

    # robot.hear /lunch cancel my order (.+) (?:-&gt;|->) (.+)/i, (msg) ->
    #     input = msg.match[1].toUpperCase().split("->")
    #     targetRestoran = msg.match[1].toUpperCase()
    #     targetJelo = msg.match[2].toUpperCase()
    #     user = msg.message.user.name

    #     msg.send "R:"+targetRestoran+"  J:"+targetJelo+"   U:"+user


    #     db = robot.brain.get 'lunch-db'

    #     currentTime = new Date()
    #     currentTime = new Date( currentTime.getFullYear(), currentTime.getMonth(), currentTime.getDate())

    #     if not db?
    #         db = {}

    #     recordedTime = new Date()
    #     if db["time"]?
    #         recordedTime = new Date(db["time"])

    #     recordedTime = new Date( recordedTime.getFullYear(), recordedTime.getMonth(), recordedTime.getDate())

    #     milisecsPerDay = 1000 * 60 * 60 * 24
    #     milisecsBetween = currentTime.getTime() - recordedTime.getTime()
    #     days = milisecsBetween / milisecsPerDay

    #     if Math.floor(days) != 0
    #         db["data"] = null
    #         db["time"] = currentTime

    #     if db["data"]?
    #         i = 0
    #         while i < Object.keys(db["data"]).length
    #             r = Object.keys(db["data"])[i]
    #             if r isnt targetRestoran
    #                 i++
    #             else    
    #                 restoran = db["data"][r]
    #                 for jelo in Object.keys(restoran)
    #                     order = restoran[jelo]
    #                     if jelo isnt targetJelo and order["users"].indexOf(user) < 0
    #                         continue
    #                     removeFromArray(order["users"],user,0)
    #                     order["amount"] = Math.max(0,order["amount"] - 1)
    #                     if order["amount"] == 0
    #                         delete restoran[jelo]
    #                 if Object.keys(restoran).length <= 0
    #                     delete db["data"][r]
    #                     msg.send "Lunch deleted! ✅"
    #                 else
    #                     i++
    #                     msg.send "Nope"
    #     else
    #         msg.send "nema podataka"

    robot.hear /^lunch reset! (.+)$/i, (msg) ->
        restaurant = msg.match[1].toUpperCase()

        db = robot.brain.get 'lunch-db'

        if not db?
            db = {}

        if db["data"]?
            if db["data"][restaurant]?
                delete db["data"][restaurant]
                msg.send "Restaurant data reset! ✅"
                db["data"][restaurant] = {}
            else
                msg.send "404 Restaurant " + restaurant + " not found."
        else
            msg.send "nema podataka"

    robot.hear /^lunch help$/i, (msg) ->
        response = "Ordering lunch is easy:\n"
        response += "*To order*: `lunch order me <Restaurant name> -> <Meal>`\n"
        response += "*To cancel your order*: `lunch cancel my orders`\n"
        response += "*To review orders for a restaurant*: `lunch summarize <Restaurant name>`\n"
        response += "Don't worry about upper case/lower case letters. :) \nBon appetit!\n"
        msg.send response