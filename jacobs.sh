#!/usr/bin/env bash
JACOBS_HOME=$(dirname $0);
source "$JACOBS_HOME"/credentials.properties;

get_last_built_revision(){
curl -s -X GET $JENKINS_URL/job/$JENKINS_JOB_NAME/lastSuccessfulBuild/api/json \
--user $JENKINS_USER:$JENKINS_PASSWORD | jq -r '.actions[] | select(._class == "hudson.plugins.git.util.BuildData") | .lastBuiltRevision.SHA1'
}

# $1 - number of last commits to check
check_last_n_commits(){
    local last_build_rev=$(get_last_built_revision);

    printf "%30s \t %.40s" "Commit" "$JENKINS_JOB_NAME"
    printf "\n---------------------------------------------------------------------"
    while read commit; do
        rev=$(echo "$commit" | cut -d" " -f 1);
        name=$(echo "$commit" | cut -d" " -f 2-);
        git merge-base --is-ancestor $rev $last_build_rev
        if [ "$?" -eq "0" ]; then
            built="built";
        else
            built="not built";
        fi
        printf "\n%s %.22s \t  %s" $rev "$name" "$built"
    done <<< "$(git log --oneline -$1)";
    printf "\n"
}
usage(){
    echo 'jacobs - check if your commits were built by Jenkins

usage:
jacobs last <number> - check if last <number> of commits is build successfully by your Jenkins job
jacobs config        - print current config'
echo
config
}
config(){
    printf "Current config:\n" "$JACOBS_HOME"/credentials.properties
    printf "%s: %s\n" "Jenkins host" $JENKINS_URL
    printf "%s: %s\n" "Jenkins user" $JENKINS_USER
    printf "%s: %s\n" "Jenkins job " $JENKINS_JOB_NAME
    printf "\n To change config edit %s file\n" "$JACOBS_HOME"/credentials.properties
}


if [ "$#" == "0" ]; then
    usage    
fi

while (( "$#" )); do
    case $1 in
		last)
			check_last_n_commits $2
			shift
		;;
		config)
			config
			exit
		;;
		* | -h | --help | --usage )
			usage   
			exit
    esac
    shift
done


