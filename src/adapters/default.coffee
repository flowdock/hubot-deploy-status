##
# Default adapter that sends results to the chat hubot is connected to.
#
formatter = require '../formatter'

module.exports = (response, robot, application, room) ->
  robot.messageRoom room,
    """
    Automatic status check:

    #{formatter.formatResponse(response)}

    cc: #{formatter.mentionCommitters(robot, response)}
    """
