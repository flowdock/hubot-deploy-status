##
# Default adapter that sends results to the chat hubot is connected to.
#
formatter = require '../formatter'

module.exports = (response, robot, application, room, env) ->
  robot.messageRoom room,
    """
    Automatic status check:

    #{formatter.formatResponse(res)}

    cc: #{formatter.mentionCommitters(robot, res)}
    """
