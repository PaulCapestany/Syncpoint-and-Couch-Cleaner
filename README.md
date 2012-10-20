# Syncpoint-and-Couch-Cleaner

Syncpoint-and-Couch-Cleaner is a CLI tool to cleanup Syncpoint databases such as `sp_admin`, `channel-*`, and `control-*`.

It also cleans up the `_users` DB by removing documents of type `org.couchdb.user*`. Similarly, it cleans up the `_replicator` DB by removing documents of type `global-control-*`

## How to use Syncpoint-and-Couch-Cleaner

In terminal, make sure you `cd` into the folder containing Syncpoint-and-Couch-Cleaner.sh, and type `bash Syncpoint-and-Couch-Cleaner.sh` to run it. 

You'll be asked for the url, admin name, and password of your CouchDB. You'll be asked if you want to automagically clean up all Syncpoint stuff, and you'll then also be asked if you want to manually manage your other databases. Pretty straightforward. 

## Drag-n-drop to delete databases

So, even if you don't use Syncpoint, Syncpoint-and-Couch-Cleaner still makes cleaning up a bunch of CouchDB databases a breeze with the power of drag-n-drop (well, more like copy/pasting stuff in a text file).

![Screenshot](https://s3.amazonaws.com/files.droplr.com/files_production/acc_60414/ZAiD?AWSAccessKeyId=AKIAJSVQN3Z4K7MT5U2A&Expires=1350771487&Signature=HDk%2BfVyvhQIZoI%2FHkMAS7VJcpZg%3D&response-content-disposition=inline%3B%20filename%2A%3DUTF-8%27%27Screenshot%2B2012-10-20%2Bat%2B14.17.44.png)

![Screenshot](https://s3.amazonaws.com/files.droplr.com/files_production/acc_60414/mqsA?AWSAccessKeyId=AKIAJSVQN3Z4K7MT5U2A&Expires=1350770545&Signature=LpjPuXc2Rkx9nlcYS0FWcXPulkE%3D&response-content-disposition=inline%3B%20filename%2A%3DUTF-8%27%27Screenshot%2B2012-10-20%2Bat%2B14.01.37.png)

It would be nice to also be able to similarly handle design docs, but I got tired so I didn't fully implement it (the code is commented out in the script).

This is my first CLI tool and I mostly just wanted to play with oldschool Unix tools and such, so I basically had no idea what I was doing. That said, suggestions/questions/feedback are welcome! 