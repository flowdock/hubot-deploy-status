##
# Default adapter that sends results to the chat hubot is connected to.
#
formatter = require '../formatter'

module.exports =
  message: (response, robot, application, room, done = ->) ->
    message = """
      Automatic status check:

      #{formatter.formatResponse(response)}

      cc: #{formatter.mentionCommitters(robot, response)}
      """
    robot.messageRoom room, message
    done()
  collectResults: ->
    # noop
