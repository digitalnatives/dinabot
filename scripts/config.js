const config = {
  freebees: {
    loginUrl: 'https://freebees.io/login',
    email: process.env.HUBOT_FREEBESS_EMAIL || '',
    password: process.env.HUBOT_FREEBESS_PASSWORD || '',
    slackHookUrl: process.env.HUBOT_FREEBESS_SLACK_HOOK_URL || '',
    slackChannel: process.env.HUBOT_FREEBESS_SLACK_CHANNEL || 'dev-notifications',
  }
}

module.exports = config
