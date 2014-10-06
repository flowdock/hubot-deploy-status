hubot-deploy-status
===================

Check deployment statuses from GitHub. Tries to use same data and configs that's available for [hubot-deploy](https://github.com/hubot-deploy). Reads app config from `apps.json` and uses `HUBOT_GITHUB_TOKEN` or a user's personal deploy token (see `hubot-deploy`) if that's available to make api requests.

The script will fetch the latest deployment for an app (in specified environment) and display its status compared to the master (repo default) branch.

The script will also allow automatic cron-like deployment status checks, so your hubot can be configured to notify you if some environment for an app is not up to date (for example one component hasn't been deployed to production).

Tokens
------

Please not that to work, the GitHub tokens used must have `user,repo` oauth scopes. hubot-deploy requires only `repo_deployment` scope but that's not enough for this script.

Usage
-----

For app that's configured with name `example-app` and has environments `staging` and `production`, you can say

```
hubot deploy-status for example-app in staging
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

To check which apps and envs can be queried:

```
hubot deploy-status
```

To toggle / turn on / turn on / check status of configured automatic checks

```
# what apps and envs are automatically checked
hubot deploy-status:auto

# Turn all checks off
hubot deploy-status:auto off

# Toggle specific environment
hubot deploy-status:auto toggle app1 in production

# Turn on all environments for an app
hubot deploy-status:auto on for app1
```


Configuration
-------------

In general, the script will need `HUBOT_GITHUB_TOKEN`, which you will probably already have if your hubot interacts with github. If you want to have full functionality, the token must have `user,repo` oauth scopes.

In `apps.json`, you can configure the automatic status using cron-like syntax:
```javascript
{
    # A simple case with just production environment.
    # Check the status once every work day at 8am and post
    # results to a chat room.
    "example1": {
        "provider": "heroku",
        "repository": "acme/example1",
        "check_deploy_status": {
            "environments": {
                "production": "0 0 8 * * 1-5"
            },
            "room": "14dc03c3-8c97-45a5-8432-59df312e7c1b"
        }
    },
    # A little more complex example with multiple environments
    # and timezone support. Checks production every workday at
    # 8am EET and staging environment every two hours.
    "example2": {
        "provider": "bundler_capistrano",
        "repository": "acme/example2",
        "environments": ["staging", "production"],
        "check_deploy_status": {
            "environments": {
                "production": "0 0 8 * * 1-5",
                "staging": "0 0 8-18/2 * * 1-5"
            },
            "room": "14dc03c3-8c97-45a5-8432-59df312e7c1b",
            "timezone": "Europe/Helsinki"
        }
    }
}

```

The script uses [cron package](https://www.npmjs.org/package/cron), so the cron pattern can be anything that package understands. Timezones are from [time package](https://www.npmjs.org/package/time).
