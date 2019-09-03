# Jets Project

This README would normally document whatever steps are necessary to get the application up and running.

Things you might want to cover:

* Dependencies
* Configuration
* Database setup
* How to run the test suite
* Deployment instructions


docker run -d -p 6379:6379 redis

* Create environment files
** Create a .env.development file with the following keys:
SLACK_API_TOKEN=<<A Slack bot's OAuth key>>
REDIS_URL=redis://localhost:6379/15

** Create a .env.production file with the following keys:
SLACK_API_TOKEN=<<Your Slack bot's OAuth key>>
REDIS_URL=<<Your production Redis>>
VPC_SECURITY_GROUPS=<<One or more AWS VPC ids>> eg: ["vpc1", "vpc1"]
VPC_SUBNETS=<<VPC subnets>> eg: ["sg1", "sg2"]