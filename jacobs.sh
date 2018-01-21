#!/usr/bin/env bash
JACOBS_HOME=$(dirname $0);
REPO_HOME=$(git rev-parse --show-toplevel);
declare -A last_revisions;
source "$JACOBS_HOME"/credentials.properties;

# $1 - job name
get_last_built_revision(){
curl -s -X GET $JENKINS_URL/job/$1/lastSuccessfulBuild/api/json \
--user $JENKINS_USER:$JENKINS_PASSWORD | jq -r '.actions[] | select(._class == "hudson.plugins.git.util.BuildData") | .lastBuiltRevision.SHA1'
}
get_last_revisions(){
    for job in $(cat "$REPO_HOME/.jacobsrc") ;do
    echo "Get last built revision for $job"
    last_revisions[$job]=$(get_last_built_revision $job) 
    done
    }
# $1 - commit hash
check_commit(){
    for job in ${!last_revisions[@]} ;do
        git merge-base --is-ancestor $1 ${last_revisions[$job]}
        if [ "$?" -eq "0" ]; then
            built="\033[32mWAS_BUILT\e[0m";
        else
            built="\033[31mNOT_BUILT\e[0m";
        fi
        printf "\n\t %b %s %b" $built "on"  $job
    done
        
    
}
# $1 - commit list 
check_commits(){
    # local last_build_rev=$(get_last_built_revision);
    git fetch
    get_last_revisions

    printf "Commits:" 
    while read commit; do
        rev=$(echo "$commit" | cut -d" " -f 1);
        name=$(echo "$commit" | cut -d" " -f 2-);
        printf "\n\n%s %.80s \t  %s" $rev "$name"
        check_commit $rev                 
    done <<< "$1";
    printf "\n"
}
# $1 - number of last commits to check
check_last_n_commits(){
    check_commits "$(git log --oneline -$1)";
}
# $1 - pattern to filer by
filter(){
    check_commits "$(git log --oneline --grep="$1" -$2)";
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
			exit

		;;
        filter)
			filter $2 $3
            shift
            shift
			exit
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


