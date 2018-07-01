# Description
#   Keeps track of lunch orders
#
# Commands:
#   baseline test @<USERNAME> - runs a baseline test on a user
#   #<ANSWER> - submits an answer to the baseline test
#
# Author:
#   Vladimir Kovac

all_content = require('./baseline_test_content.coffee')

module.exports = (robot) ->

    db = {}

    robot.hear /baseline test (@.+)/i, (msg) ->
        
        challenger = msg.message.user.name
        testee = msg.match[1]
        
        msg.send testee + ", " + challenger + " has requested a baseline test. Your participation is mandatory. Failure to comply would result in a violation of GDP-R-69-N. Let's begin. Are you ready?"

        db = robot.brain.get 'baseline_test_db'

        if not db?
            db = {}

        # TODO: REMOVE
        testee = challenger

        msg.send "Saving " + testee

        db[testee] = {}
        db[testee]["content"] = []

        db[testee]["step"] = -1
        db[testee]["questions_answered"] = 0;
        db[testee]["correct_answers"] = 0;

        db[testee]["content"] = all_content[Math.floor(Math.random() * all_content.length)]

    robot.hear /#(.+)/i, (msg) ->
        user = msg.message.user.name

        if not db? or not user of db
            console.log "No test recorded."
            return

        if db[user]["time"]?
            recordedTime = new Date(db["time"])
        else
            recordedTime = new Date()
        msg.send "recordedTime " + recordedTime

        currentTime = new Date()
        currentTime = new Date( currentTime.getFullYear(), currentTime.getMonth(), currentTime.getDate())
        recordedTime = new Date( recordedTime.getFullYear(), recordedTime.getMonth(), recordedTime.getDate())

        milisecsPerHour = 1000 * 60 * 60
        milisecsBetween = currentTime.getTime() - recordedTime.getTime()
        hours = milisecsBetween / milisecsPerHour

        console.log "Hours: " + hours + " (diff: " + milisecsBetween + ")"
        if Math.floor(hours) != 0
            delete db[user]
            return

        # Respond
        answer = msg.match[1]

        step = db[user]["step"]


        if step is -1
            expected_answer = "yes."
        else
            expected_answer = db[user]["content"][step].answer

        console.log answer + " - # # # - " + expected_answer


        no_period_expected_answer = expected_answer.substr 0, expected_answer.length - 1
        upper_case_answer = answer.toUpperCase

        if upper_case_answer is expected_answer.toUpperCase or upper_case_answer is no_period_expected_answer.toUpperCase
            db[user]["correct_answers"] += 1
            console.log "correct"
        else
            console.log "incorrect"
        
        db[user]["step"] += 1

        console.log db[user]["content"].length

        q = db[user]["content"][step + 1].question
        #questions_answered = db[user]["questions_answered"]
        #db[user]["questions_answered"] = questions_answered + 1
        msg.send q