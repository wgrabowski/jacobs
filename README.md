# jacobs - just another commit build status checker
jacobs check if your commits was processed by your Jenkins jobs
# Before use / installation
* clone repo or download zip to your machine
* copy credentials.properties.sample as credentials.properties
* in ```credentials.properties``` provide jenkins url, your username & password and name of job you want to track
# Usage
## Alias
It is recommended to add alias (i.e. in your .bashrc file) pointing to jacobs.sh location.

## Check last N commits
To check if last N commits was successfully built by your Jenkins job:
```<your alias of path to jacobs.sh> N``` where N is number of your choice

