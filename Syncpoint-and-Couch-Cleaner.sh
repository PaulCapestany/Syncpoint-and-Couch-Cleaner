#!/bin/sh

# Syncpoint-and-Couch-Cleaner is a CLI tool to cleanup Syncpoint databases such as:
# - sp_admin
# - channel-*
# - control-*
# it also cleans up _users DB by removing documents of type `org.couchdb.user*` (TODO: and maybe _design/syncpoint ?)
# it also cleans up _replicator DB by removing documents of type `global-control-*`
# 
# Even if you don't use Syncpoint, it still makes cleaning up a bunch of Couch databases a breeze.

echo -e "\nWelcome to Syncpoint-and-Couch-Cleaner"
echo -e "--------------------------------------\n"

# ask for CouchDB instance and credentials
printf "Enter host url (e.g. 127.0.0.1:5984 or mycouch.iriscouch.com): "
read HOST

printf "Enter your server admin name: "
read NAME

printf "Enter your server admin password: "
read PASSWORD

CREDS_AND_HOST="$NAME:$PASSWORD@$HOST"

echo -e "\n" > _all_dbs.txt

# markers for actions 
  KEEP="~~~~~~~~~~~~~~~~~~~~~~~~ KEEP ~~~~~~~~~~~~~~~~~~~~~~~~"
DELETE="~~~~~~~~~~~~~~~~~~~~~~~ DELETE ~~~~~~~~~~~~~~~~~~~~~~~"

echo -e "$KEEP\n" > _all_dbs.txt

# get list of all databases          # get rid of [" and "]            # insert newline at each "," between results
curl --silent -X GET $CREDS_AND_HOST/_all_dbs | sed "s/\[\"//" | sed "s/\"\]//" | sed 's/\",\"/\
/g' >> _all_dbs.txt
# ABOVE FORMATTING IS IMPORTANT!

# # design doc stuff
# cat _all_dbs.txt | awk 'NF' > design_docs.txt
# DESIGN_QUERY='_all_docs?startkey="_design/"&endkey="_design0"'

# # !!! 
# echo -e "$KEEP\n" > _all_dbs.txt

# cat design_docs.txt | while read DB
# 	do	
# 		# !!! testing / debugging
# 		echo -e $DB >> _all_dbs.txt
# 															   # !!! would need to fix this, design docs (and views) can have ANYTHING in their name
# 		curl --silent -X GET $CREDS_AND_HOST/$DB/$DESIGN_QUERY | echo -n `egrep -o '_design/[^"]*'` | sed "s|_design|"$DB"/_design|g" | sed 's/ /\
# /g' | uniq >> _all_dbs.txt
# 		# FORMAT ABOVE IS IMPORTANT!		
# 		printf "\n" >> _all_dbs.txt
# 	done

echo -e "\n$DELETE\n\n" >> _all_dbs.txt

###################
# SYNCPOINT STUFF #
###################

# Syncpoint database deletes:
# - sp_admin
# - channel-*
# - control-*
# 
# also cleans up _users DB, remove documents of org.couchdb.user* (and maybe _design/syncpoint ?)
# also cleans up _replicator DB, remove documents of global-control-*

printf "\nClean up all Syncpoint stuff? (YES/NO) "
read SHOULD_CLEAN_SYNCPOINT
printf "\n"
SHOULD_CLEAN_SYNCPOINT=`echo $SHOULD_CLEAN_SYNCPOINT | awk '{ print tolower($0) }'`

if [[ $SHOULD_CLEAN_SYNCPOINT =~ ^y[e]?[s]? ]]
	then 
	# YES - get all databases                                    # delete section markers								 # get rid of excess newlines
	cat _all_dbs.txt | awk "/$KEEP/,/$DELETE/" | sed "s/$KEEP//" | sed "s/$DELETE//" | awk 'NF'> awk_results.txt
	touch awk_results.txt
	# open awk_results.txt
	
	echo `egrep "(^(channel|control|single)-[0-9a-z]+|^sp_admin)" awk_results.txt` | sed 's/ /\
/g'
# FORMAT ABOVE IS IMPORTANT!

####################################
		# For _replicator and _users DB, do:
		# 1) http://127.0.0.1:5984/_replicator/_all_docs
		# 2) parse for id: "global-control-73918sahdjasd*"
		# 3) parse for rev: "5-1291038akjhsd918hekjsad*"
		# 4) curl --silent -X DELETE $CREDS_AND_HOST/_replicator/global-control-98128114aed8801c0b442de12d003a6b?rev=5-813fb8cd8035177f482e033c9e81864f
	
		NO_DESIGN_DOCS_QUERY='_all_docs?include_docs=true&startkey="_design0"'
		curl --silent -X GET $CREDS_AND_HOST/_replicator/$NO_DESIGN_DOCS_QUERY | echo -n `egrep -o '(\"_id\":\"global-control-[^"]*|\"_rev\":\"[0-9][^"]*|\"target\":\"[^"]*)'` | sed "s|\"_rev\":\"|?rev=|g" | sed "s|\"_id\":\"||g" | sed 's/ /\
/g' > docs_to_delete.txt 
		curl --silent -X GET $CREDS_AND_HOST/_users/$NO_DESIGN_DOCS_QUERY | echo -n `egrep -o '(\"_id\":\"org.couchdb.user:[^"]*|\"_rev\":\"[0-9][^"]*|(\"channel_database\":\"|\"control_database\":\"))'` | sed "s|\"_rev\":\"|?rev=|g" | sed "s|\"_id\":\"||g" | sed 's/ /\
/g' >> docs_to_delete.txt 

		DOC_NAME=""
		DOC_REV=""
		DOC_SHOULD_BE_DELETED=""
		declare -a docDeletionArray

		while read LINE
			do		
				# build string to delete *only* Syncpoint-related replication docs AND user docs
				if [[ $LINE =~ ^(global-control-)[0-9a-z]+ ]]
					then
					DOC_NAME="_replicator/$LINE"
					DOC_SHOULD_BE_DELETED="NO"	
				elif [[ $LINE =~ ^(org.couchdb.user:)[0-9a-z]+ ]]
					then
					DOC_NAME="_users/$LINE"
					DOC_SHOULD_BE_DELETED="NO"						
				elif [[ $LINE =~ ^(\?rev=)[0-9a-z]+ ]]
					then
					DOC_REV="$LINE"
					DOC_SHOULD_BE_DELETED="NO"	
				elif [[ $LINE =~ ^(\"target\":\"sp_admin) ]] || [[ $LINE =~ ^(\"control_database\"|\"channel_database\") ]]
					then
					DOC_SHOULD_BE_DELETED="YES"	
				else
					DOC_SHOULD_BE_DELETED="NO"	
				fi
				 
				if [[ $DOC_SHOULD_BE_DELETED =~ YES ]]
					then
					docDeletionArray=("${docDeletionArray[@]}" "$DOC_NAME$DOC_REV")
					# echo "array item: ${docDeletionArray["${totalDocs}"]}"
				fi
			# echo "entire array... ${docDeletionArray[@]}"
			# this prevents subshell from spawning, rendering array useless outside of loop 
			done < docs_to_delete.txt

		echo "${docDeletionArray[@]}" | sed 's/ /\
/g' | sort -u > docs_to_delete.txt
# ABOVE FORMATTING IS IMPORTANT!

####################################

	printf "\nDelete all the above Syncpoint databases, along with `cat docs_to_delete.txt | wc -l | sed 's/ //g'` _users and/or _replicator docs? (YES/NO) "
	read FOR_REALS_DELETE_SYNCPOINT
	printf "\n"
	FOR_REALS_DELETE_SYNCPOINT=`echo $FOR_REALS_DELETE_SYNCPOINT | awk '{ print tolower($0) }'`

	if [[ $FOR_REALS_DELETE_SYNCPOINT =~ ^y[e]?[s]? ]]
		then
		cat awk_results.txt | while read DB
			do		
				# look for Syncpoint databases 	
				# clean up _users DB, remove documents of org.couchdb.user* (and maybe _design/syncpoint ?)
				# clean up _replicator DB, remove documents of global-control-*											   
				if [[ $DB =~ ^(channel|control|single)-[0-9a-z]+ ]] || [[ $DB =~ ^(sp_admin) ]]
					then
					# # for debugging, | od -c allows us to see exact whitespace/character usage
					# echo $DB | od -c

					# delete all sp_admin, channel-*, and control-* databases
					RESPONSE=`curl --silent -X DELETE $CREDS_AND_HOST/$DB`
					if [[ $RESPONSE =~ "{\"ok\":true" ]]
						then
						echo -e "[DELETED] $DB" 
					else
						echo -e "[ERROR] could not delete $DB"
					fi
				fi
			done

# 		# 4) curl --silent -X DELETE $CREDS_AND_HOST/_replicator/global-control-98128114aed8801c0b442de12d003a6b?rev=5-813fb8cd8035177f482e033c9e81864f
		cat docs_to_delete.txt | while read DOC
			do	
				RESPONSE=`curl --silent -X DELETE $CREDS_AND_HOST/$DOC`
				if [[ $RESPONSE =~ "{\"ok\":true" ]]
					then
					# purposefully left blank.. or not
					UGHhHh="imtired"
				else
					echo -e "[ERROR] could not delete $DOC"	
				fi		
			done

		echo -e "\nAlrighty — all Syncpoint stuff is cleaned up!\n"

		echo -e "$KEEP\n" > _all_dbs.txt
		# create list of all databases, again            # get rid of [" and "]            # insert newline at each "," between results
		curl --silent -X GET $CREDS_AND_HOST/_all_dbs | sed "s/\[\"//" | sed "s/\"\]//" | sed 's/\",\"/\
/g' >> _all_dbs.txt
# ABOVE FORMATTING IS IMPORTANT!
	echo -e "\n$DELETE\n\n" >> _all_dbs.txt
	
	else
		echo -e "ABORT! ABORT! Syncpoint stuff wasn't deleted.\n"
	fi

else
	echo -e "K, won't delete Syncpoint.\n"
fi

printf "\nManually manage your other databases? (YES/NO) "
read MANUALLY_MANAGE
printf "\n"
MANUALLY_MANAGE=`echo $MANUALLY_MANAGE | awk '{ print tolower($0) }'`

if [[ $MANUALLY_MANAGE =~ ^y[e]?[s]? ]]
	then 
	touch _all_dbs.txt
	open _all_dbs.txt

	printf "\n1) Move databases to appropriate section in the _all_dbs.txt document that just opened.\n2) Save your changes to _all_dbs.txt\n3) Type SAVED to continue, or anything else to cancel. "
	read DID_SAVE
	printf "\n"
	DID_SAVE=`echo $DID_SAVE | awk '{ print tolower($0) }'`

	if [[ $DID_SAVE =~ ^s[a]?[v]?[e]?[d]? ]]
		then 
		# read in all databases that we want to delete
		# awk '/regex/,0'
 		# awk '/regex/,EOF'
		cat _all_dbs.txt | awk "/$DELETE/,EOF" | sed "s/$DELETE//" | awk 'NF' > awk_results.txt
		# cat _all_dbs.txt | awk "/$DELETE/,/$DELETE_DESIGN_DOCS/" | sed "s/$DELETE//" | sed "s/$DELETE_DESIGN_DOCS//" | awk 'NF' > awk_results.txt
		touch awk_results.txt

		echo -e `cat awk_results.txt` | sed 's/ /\
/g'
# FORMAT ABOVE IS IMPORTANT!

		printf "\nDelete all the above databases? (YES/NO) "
		read FOR_REALS_DELETE_DATABASES
		printf "\n"
		FOR_REALS_DELETE_DATABASES=`echo $FOR_REALS_DELETE_DATABASES | awk '{ print tolower($0) }'`

		if [[ $FOR_REALS_DELETE_DATABASES =~ ^y[e]?[s]? ]]
			then
			# delete the databases
			cat awk_results.txt | while read DB
				do	
					# delete all specified databases
					RESPONSE=`curl --silent -X DELETE $CREDS_AND_HOST/$DB`
					
					if [[ $RESPONSE =~ "{\"ok\":true" ]]
						then
						echo -e "[DELETED] $DB" 
					else
						echo -e "[ERROR] could not delete $DB"
					fi
				done

			echo -e "$KEEP\n" > _all_dbs.txt
			# create list of all databases, again            # get rid of [" and "]            # insert newline at each "," between results
			curl --silent -X GET $CREDS_AND_HOST/_all_dbs | sed "s/\[\"//" | sed "s/\"\]//" | sed 's/\",\"/\
/g' >> _all_dbs.txt
# ABOVE FORMATTING IS IMPORTANT!
			echo -e "\n$DELETE\n\n" >> _all_dbs.txt
			touch _all_dbs.txt 
		
		else
			echo -e "\nABORT! ABORT! No databases were harmed."
		fi
	else
		echo -e "\nOK, there's nothing else to do then!"
	fi
fi

if [ -e _all_dbs.txt ]
	then
	rm _all_dbs.txt
fi
if [ -e awk_results.txt ]
	then
	rm awk_results.txt
fi
if [ -e docs_to_delete.txt ]
	then
	rm docs_to_delete.txt
fi

echo -e "\nAll done — ciao!\n"


