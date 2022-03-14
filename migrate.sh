#!/bin/bash


###########################
#### Don't need to change from here
###########################

#STYLE_COLOR
RED='\033[0;31m';
LIGHT_GREEN='\e[1;32m';
NC='\033[0m' # No Color


# PARAM VALIDATION
if [ -z "$PROJECT_NAME" ]
then
  echo -e "${RED} [ERROR] env variable PROJECT_NAME missing, it can't continue..."
  exit 2
fi

if [ -z "$EMAIL_DOMAIN" ]
then
  echo -e "${RED} [ERROR] env variable EMAIL_DOMAIN missing, it can't continue..."
  exit 2
fi

if [ -z "$BASE_SVN" ]
then
  echo -e "${RED} [ERROR] env variable BASE_SVN missing, it can't continue..."
  exit 2
fi

if [ -z "$BRANCHES" ] || [ -z "$TAGS" ] || [ -z "$TRUNK" ]
then
  echo -e "${RED} [ERROR] env variable BRANCHES, TAGS, TRUNK missing, it cant continue..."
  exit 2
fi


# Geral Configuration
ABSOLUTE_PATH=$(pwd)
TMP=$ABSOLUTE_PATH/"migration-"$PROJECT_NAME

# Branchs Configuration
SVN_BRANCHES=$BASE_SVN/$BRANCHES
SVN_TAGS=$BASE_SVN/$TAGS
SVN_TRUNK=$BASE_SVN/$TRUNK

AUTHORS=$PROJECT_NAME"-authors.txt"

echo -e "${LIGHT_GREEN} [LOG] Starting migration of ${NC}" $SVN_TRUNK
echo -e "${LIGHT_GREEN} [LOG] Using: ${NC}" $(git --version)
echo -e "${LIGHT_GREEN} [LOG] Using: ${NC}"  $(svn --version | grep svn,)
echo
echo
echo -e "${LIGHT_GREEN} [LOG] Step 01/08 Create Directories ${NC}" $TMP


mkdir -p $TMP
cd $TMP

echo
echo -e "${LIGHT_GREEN} [LOG] Step 02/08 Getting authors ${NC}"
AUTHORS_LOG=$(svn log -q $BASE_SVN)
if [ $? -ne 0 ]
then
  echo -e "${RED} [ERROR] Could not access $BASE_SVN"
  exit 2
fi
echo "$AUTHORS_LOG" | awk -F '|' '{print $2}' | awk 'NF' | awk '{$1=$1};1' | awk '{print $0 " = "$0 "<"$0"@"ENVIRON["EMAIL_DOMAIN"]">"}'| sort -u >> $AUTHORS

echo
echo -e "${LIGHT_GREEN} [RUN] Step 03/08"

if [ "$IGNORE_BRANCHES_TAG" = "false" ]
then
  echo 'git svn clone --authors-file='$AUTHORS' --trunk='$TRUNK' --branches='$BRANCHES' --tags='$TAGS $BASE_SVN $TMP
  git svn clone --authors-file=$AUTHORS --trunk=$TRUNK --branches=$BRANCHES --tags=$TAGS $BASE_SVN $TMP
else
  echo "clone with no branches"
  git svn clone --authors-file=$AUTHORS $BASE_SVN $TMP
fi
echo -e "${NC}"

git config --local user.name "$AUTHOR_NAME"
git config --local user.email "$AUTHOR_EMAIL"

echo
echo -e "${LIGHT_GREEN} [LOG] Step 04/08  Getting first revision ${NC}"
FIRST_REVISION=$( svn log -r 1:HEAD --limit 1 $BASE_SVN | awk -F '|' '/^r/ {sub("^ ", "", $1); sub(" $", "", $1); print $1}' )

echo
echo -e "${LIGHT_GREEN} [RUN] Step 05/08 ${NC}"
echo 'git svn fetch -'$FIRST_REVISION':HEAD'
git svn fetch -$FIRST_REVISION:HEAD

echo
echo -e "${LIGHT_GREEN} [RUN] Step 06/08 ${NC}"
echo 'git remote add origin '$GIT_URL
git remote add origin $GIT_URL


if [ "$IGNORE_BRANCHES_TAG" = "false" ]
then
  echo
  echo -e "${LIGHT_GREEN} [RUN] Step 07/08 ${NC}"
  echo 'svn ls '$SVN_BRANCHES

  for BRANCH in $(svn ls $SVN_BRANCHES); do
      echo git branch ${BRANCH%/} remotes/svn/${BRANCH%/}
      git branch ${BRANCH%/} remotes/svn/${BRANCH%/}
  done

  git for-each-ref --format="%(refname:short) %(objectname)" refs/remotes/origin/tags | grep -v "@" | cut -d / -f 3- |
  while read ref
  do
    echo git tag -a $ref -m 'import tag from svn'
    git tag -a $ref -m 'import tag from svn'
  done

  git for-each-ref --format="%(refname:short)" refs/remotes/origin/tags | cut -d / -f 1- |
  while read ref
  do
    git branch -rd $ref
  done
fi

echo
echo -e "${LIGHT_GREEN} [RUN] Step 08/08 [RUN] git push ${NC}"

if [ "$PUSH_REPOSITORY" = "true" ]
then
  git push origin --all --force
  git push origin --tags
fi

echo 'Successful.'
