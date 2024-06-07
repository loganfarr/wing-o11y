# Winglang O11y
This is a small pet project to get more familiar with [Winglang](https://www.winglang.io). 

It's a data-streaming API that intakes various observability-related data and stores them with corresponding account info. 

Some functional requirement notes:
- The account ID should be derived from the authentication method, which at this time is just an APi key. 
- The log message is parsed by using a few different regex patterns to determine what sort of log message it is. They are neither exhaustive nor guaranteed to be 100% accurate in this project.
- Metrics should be able to be streamed with a name, value, host, and timestamp
  - For this project, the "streaming" part may just be a continuous succession of API calls 
- An account is synonymous with a billing account, and should have org-related inforamtion to it. 
- Users should auth through AWS Cognito and belong to an account

More updates coming soon!