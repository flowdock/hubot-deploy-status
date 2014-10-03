repository = "([-_\.0-9a-z]+)"

module.exports =
  deployStatus: ///
    (deploy-status(?!:auto))     # Command prefix
    (?:\s+for\s+#{repository})?  # possible repository
    (?:\s+in\s+#{repository})?   # possible env
  ///i
  autoDeployStatus: ///
    (deploy-status:auto)        # Command prefix
    (?:\s+(toggle|on|off))?         # subcommand
    (?:(?:\s+for)?\s+#{repository})? # app name
  ///i
