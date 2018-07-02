# Description
#   Perform a Blade Runner 2049-style Baseline Test on someone
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

    robot.hear /baseline test @(.+)/i, (msg) ->
        
        challenger = msg.message.user.name
        testee = msg.match[1]
        
        msg.send "`" + testee + ", " + challenger + " has requested a baseline test. Your participation is mandatory. Failure to comply would result in a violation of GDP-R-69-N. Let's begin. Are you ready?`" 

        db = robot.brain.get 'baseline_test_db'

        if not db?
            db = {}

        # <Test code>
        #testee = challenger
        #console.log "Saving " + testee
        # </Test code>       

        db[testee] = {}
        db[testee]["content"] = []

        db[testee]["step"] = -1
        db[testee]["questions_answered"] = 0;
        db[testee]["correct_answers"] = 0;
        db[testee]["time"] = new Date()
        db[testee]["content"] = all_content[Math.floor(Math.random() * all_content.length)]

    robot.hear /#(.+)/i, (msg) ->
        user = msg.message.user.name

        if not db? or not (user of db)
            console.log "No test recorded."
            return

        if db[user]["time"]?
            recordedTime = new Date(db[user]["time"])
        else
            recordedTime = new Date()

        currentTime = new Date()
        currentTime = new Date( currentTime.getFullYear(), currentTime.getMonth(), currentTime.getDate())
        recordedTime = new Date( recordedTime.getFullYear(), recordedTime.getMonth(), recordedTime.getDate())

        milisecsPerHour = 1000 * 60 * 60
        milisecsBetween = currentTime.getTime() - recordedTime.getTime()
        hours = milisecsBetween / milisecsPerHour
        
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

        no_period_expected_answer = expected_answer.substr 0, expected_answer.length - 1
        upper_case_answer = answer.toUpperCase()

        if upper_case_answer is expected_answer.toUpperCase() or upper_case_answer is no_period_expected_answer.toUpperCase()
            if step >= 0 
                db[user]["correct_answers"] += 1
        else if step < 0        
            msg.send "`You have failed to comply to a baseline test. HR and the authorities have been notified. Remain where you are and do not resist when the authorities arrive.`"
            delete db[user]
            return

        db[user]["step"] += 1
        step += 1
        total_questions = db[user]["content"].length
        
        if step < total_questions
            q = db[user]["content"][step].question    
            msg.send "`" + q + "`"
        else
            complete_test(msg, user, total_questions, db[user]["correct_answers"])   
            delete db[user]     

complete_test = (msg, username, total_questions, correct_answers) ->
    percentage = correct_answers/total_questions
    msg.send "`Your score was " + Math.round(percentage * 100).toFixed(2) + "%.`"

    message = ""
    if (percentage < 0.25)
        message = username + ", you're nowhere near your baseline. Stay where you are, a decommissioning team has been dispatched to your location."
    else if percentage < 0.5
        message = "Officer " + username + ", report to the decommissioning station in your precinct immediately. Once there follow their instructions or face immediate termination."
    else if percentage < 1
        message = "Officer " + username + ", your result is worrisome. HR has been notified and will contact you shortly. Rest assured there will be repercussions."
    else
        message = username + ", constant as always. Report to HR to collect your bonus."

    msg.send "`" + message + "`"
