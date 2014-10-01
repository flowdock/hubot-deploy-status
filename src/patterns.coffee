repository = "([-_\.0-9a-z]+)"

module.exports =
  deployStatus: ///
    (deploy-status)     # Command prefix
    (?:                 # possible...
      \s+for            # for <app>
      \s+#{repository}
    )?
    (?:                 # possible
      \s+in             # in <environment>
      \s+#{repository}
    )?
  ///i
