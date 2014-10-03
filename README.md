hubot-deploy-status
===================

Check deployment statuses from GitHub. Tries to use same data and configs that's available for [hubot-deploy](https://github.com/hubot-deploy). Reads app config from `apps.json` and uses `HUBOT_GITHUB_TOKEN` or a user's personal deploy token (see `hubot-deploy`) if that's available to make api requests.

The script will fetch the latest deployment for an app (in specified environment) and display its status compared to the master (repo default) branch.

Tokens
------

Please not that to work, the GitHub tokens used must have `user,repo` oauth scopes. hubot-deploy requires only `repo_deployment` scope but that's not enough for this script.

Usage
-----

For app that's configured with name `example` and has environments `staging` and `production`, you can say

```
hubot deploy-status for example in staging
```

and the response will be something like

```
Hubot:

App example is 4 commits ahead master in staging.
The deployed ref is deploy-with-heaven (e429769).

Commits not in master:
e88769b Mumakil  Bump version
6f23b1a Mumakil  Create a separate group for deploy gems
7e2aaae Mumakil  Use capistrano-flowdock for deploy notifications
e429769 Mumakil  Use double quotes in gemfile

```
