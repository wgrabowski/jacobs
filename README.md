# jacobs - just another commit build status checker
jacobs check if your commits was processed by your Jenkins jobs
# Requirements
* git 
* curl
* jq
# Before use / installation
* clone repo or download zip to your machine
* copy credentials.properties.sample as credentials.properties
* in ```credentials.properties``` provide jenkins url, your username & password want to track
* in each repository you want to track add ```.jacobsrc``` file with names of Jenkins jobs you want to track
# Usage
## Alias
It is recommended to add alias (i.e. in your .bashrc file) pointing to jacobs.sh location.
