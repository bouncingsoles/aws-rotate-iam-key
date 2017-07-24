#!/bin/bash
echo "Verifying that AWS CLI is installed ..."
command -v aws >/dev/null 2>&1 || { echo >&2 "AWS CLI tools are required, but couldn't be found. Please install from https://aws.amazon.com/cli/. Aborting."; exit 1; }

if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` --info <name>"
  echo "                        ## prints old and new key ids ##"
  echo "                                                   "
  echo "                     --list <name>"
  echo "                        ## List all the keys on the account ##"
  echo "                                                   "
  echo "                     --create <name>"
  echo "                        ## Will delete inactive key and create a new one under account ##"
  echo "                                                   "
  echo "                     --expire <name> <key>"
  echo "                        ## Set key to inactive ##"
  echo "                                                   "
  echo "                     --rotate <name>"
  echo "                        ## WARNING: Deletes the oldest ACTIVE key if there are 2 on the account, sets current to inactive, then creates new key.#"
  echo "                        # If there is 1 key creates a new one and sets oldest to inactive. ## "
  echo "                        # If there is only 1 key on the account it creates a new one and sets current key to inactive. ##"
  echo "                                                   "
  echo "                     --delete <name> <key>"
  echo "                        ## Deletes key entered. ##"
exit 0
fi

if [ "$1" == "--list" ]; then
    NAME=$2
aws iam list-access-keys --user-name $NAME --output text
exit 0
fi

if [ "$1" == "--info" ]; then
    NAME=$2

EXISTING_KEYS_CREATEDATES=0
EXISTING_KEYS_CREATEDATES=($(aws iam list-access-keys --user-name $NAME --query 'AccessKeyMetadata[].CreateDate' --output text))
NUM_EXISTING_KEYS=${#EXISTING_KEYS_CREATEDATES[@]}
  IFS=$'\n' sorted_createdates=($(sort <<<"${EXISTING_KEYS_CREATEDATES[*]}"))
  unset IFS
  OLDER_KEY_CREATEDATE="${sorted_createdates[0]}"
  OLDER_KEY_ID=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${OLDER_KEY_CREATEDATE}'].AccessKeyId" --output text)
  OLDER_KEY_STATUS=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${OLDER_KEY_CREATEDATE}'].Status" --output text)
  NEWER_KEY_CREATEDATE="${sorted_createdates[1]}"
  NEWER_KEY_ID=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${NEWER_KEY_CREATEDATE}'].AccessKeyId" --output text)
  NEWER_KEY_STATUS=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${NEWER_KEY_CREATEDATE}'].Status" --output text)

echo "OLDER_KEY_ID=$OLDER_KEY_ID"
echo "OLDER_KEY_CREATEDATE=$OLDER_KEY_CREATEDATE"
echo "NEWER_KEY_ID=$NEWER_KEY_ID"
echo "NEWER_KEY_CREATEDATE=$NEWER_KEY_CREATEDATE"

exit 0
fi

if [ "$1" == "--create" ]; then
    NAME=$2
#Check to see if there is an inactive key we can delete.
INACTIVEKEYFOUND=`aws iam list-access-keys --user-name $NAME --output text | grep Inactive | awk '{print $2}' | tail -n1`

if [ -n "$INACTIVEKEYFOUND" ]; then
aws iam delete-access-key --access-key-id $INACTIVEKEYFOUND --user-name $NAME
fi

EXISTING_KEYS_CREATEDATES=0
EXISTING_KEYS_CREATEDATES=($(aws iam list-access-keys --user-name $NAME --query 'AccessKeyMetadata[].CreateDate' --output text))
NUM_EXISTING_KEYS=${#EXISTING_KEYS_CREATEDATES[@]}

if [ ${NUM_EXISTING_KEYS} -lt 2 ]; then

OUTPUT=`aws iam create-access-key --user-name $NAME --output text`
echo $OUTPUT | awk '{print "ACCESSKEY\n"$2"\n""SECRET\n"$4}'

exit 0
else
  echo "Sorry, there is no room to create another key.  Delete one first, or set one as inactive."
  exit 1
fi

fi

if [ "$1" == "--rotate" ]; then
NAME=$2
##Block to get list of current keys in order.
EXISTING_KEYS_CREATEDATES=0
EXISTING_KEYS_CREATEDATES=($(aws iam list-access-keys --user-name $NAME --query 'AccessKeyMetadata[].CreateDate' --output text))
NUM_EXISTING_KEYS=${#EXISTING_KEYS_CREATEDATES[@]}

##If there is only 1 key for user then just set that key as inactive and create a new one
if [ ${NUM_EXISTING_KEYS} -lt 2 ]; then
#  echo "You have only one existing key."
OLDER_KEY_ID=`aws iam list-access-keys --user-name $NAME --output text | awk '{print $2}'`
KEYSECRET=`aws iam create-access-key --user-name $NAME --output text | awk '{print $4}'`
sleep 2
aws iam update-access-key --access-key-id $OLDER_KEY_ID --status Inactive --user-name $NAME
sleep 2
NEWER_KEY_ID=`aws iam list-access-keys --user-name $NAME --output text | grep Active | awk '{print $2}'`

echo "NAME"
echo "$NAME"
echo "Access Key ID"
echo "$NEWER_KEY_ID"
echo "Access Key Secret"
echo "$KEYSECRET"
exit;
fi

  IFS=$'\n' sorted_createdates=($(sort <<<"${EXISTING_KEYS_CREATEDATES[*]}"))
  unset IFS
  OLDER_KEY_CREATEDATE="${sorted_createdates[0]}"
  OLDER_KEY_ID=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${OLDER_KEY_CREATEDATE}'].AccessKeyId" --output text)
  OLDER_KEY_STATUS=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${OLDER_KEY_CREATEDATE}'].Status" --output text)
  NEWER_KEY_CREATEDATE="${sorted_createdates[1]}"
  NEWER_KEY_ID=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${NEWER_KEY_CREATEDATE}'].AccessKeyId" --output text)
  NEWER_KEY_STATUS=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${NEWER_KEY_CREATEDATE}'].Status" --output text)

##Block to create the keys
aws iam delete-access-key --access-key-id $OLDER_KEY_ID --user-name $NAME
aws iam update-access-key --access-key-id $NEWER_KEY_ID --status Inactive --user-name $NAME
KEYSECRET=`aws iam create-access-key --user-name $NAME --output text | awk '{print $4}'`
##---

EXISTING_KEYS_CREATEDATES=0
EXISTING_KEYS_CREATEDATES=($(aws iam list-access-keys --user-name $NAME --query 'AccessKeyMetadata[].CreateDate' --output text))
NUM_EXISTING_KEYS=${#EXISTING_KEYS_CREATEDATES[@]}
  IFS=$'\n' sorted_createdates=($(sort <<<"${EXISTING_KEYS_CREATEDATES[*]}"))
  unset IFS
  OLDER_KEY_CREATEDATE="${sorted_createdates[0]}"
  OLDER_KEY_ID=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${OLDER_KEY_CREATEDATE}'].AccessKeyId" --output text)
  OLDER_KEY_STATUS=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${OLDER_KEY_CREATEDATE}'].Status" --output text)
  NEWER_KEY_CREATEDATE="${sorted_createdates[1]}"
  NEWER_KEY_ID=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${NEWER_KEY_CREATEDATE}'].AccessKeyId" --output text)
  NEWER_KEY_STATUS=$(aws iam list-access-keys --user-name $NAME --query "AccessKeyMetadata[?CreateDate=='${NEWER_KEY_CREATEDATE}'].Status" --output text)

echo "NAME"
echo "$NAME"
echo "Access Key ID"
echo "$NEWER_KEY_ID"
echo "Access Key Secret"
echo "$KEYSECRET"

exit 0
fi

if [ "$1" == "--delete" ]; then
    NAME=$2
    KEY=$3
aws iam delete-access-key --access-key-id $KEY --user-name $NAME
exit 0
fi

if [ "$1" == "--expire" ]; then
    NAME=$2
    KEY=$3
aws iam update-access-key --access-key-id $KEY --status Inactive --user-name $NAME
returncode=$?
if [ "$returncode" == "0" ]; then
  echo "Key $KEY expired successfully for user $NAME."
  exit 0
else
  echo "ALERT: I wasn't able to expire the key! Either it didn't exist or it was already expired."
  exit 1
fi


fi
  echo "Usage: `basename $0` --info <name>"
  echo "                        ## prints old and new key ids ##"
  echo "                                                   "
  echo "                     --list <name>"
  echo "                        ## List all the keys on the account ##"
  echo "                                                   "
  echo "                     --create <name>"
  echo "                        ## Will delete inactive key and create a new one under account ##"
  echo "                                                   "
  echo "                     --expire <name> <key>"
  echo "                        ## Set key to inactive ##"
  echo "                                                   "
  echo "                     --rotate <name>"
  echo "                        ## WARNING: Deletes the oldest ACTIVE key if there are 2 on the account, sets current to inactive, then creates new key.#"
  echo "                        # If there is 1 key creates a new one and sets oldest to inactive. ## "
  echo "                        # If there is only 1 key on the account it creates a new one and sets current key to inactive. ##"
  echo "                                                   "
  echo "                     --delete <name> <key>"
  echo "                        ## Deletes key entered. ##"
exit 0
