This repo is defunct as Syncpoint has been replaced by [sync_gateway](https://github.com/couchbase/sync_gateway/).

# ~~Syncpoint-and-Couch-Cleaner~~

~~Presented to you by — [Paul Capestany][1]~~

~~*Syncpoint-and-Couch-Cleaner* is a CLI tool that quickly cleans up/deletes all [Syncpoint][2]-generated databases, such as `sp_admin`, `channel-*`, and `control-*`.~~

~~It also cleans up the `_users` DB by removing documents of type `org.couchdb.user*`. Similarly, it cleans up the `_replicator` DB by removing documents of type `global-control-*`.~~

~~You can also use *Syncpoint-and-Couch-Cleaner* to delete a bunch of CouchDB databases all at once instead of doing it individually via the web admin interface.~~

## ~~How to use~~

~~In terminal, make sure you `cd` into the folder containing `Syncpoint-and-Couch-Cleaner.sh`, and enter `bash Syncpoint-and-Couch-Cleaner.sh` to run it.~~

~~You'll be asked for the url, admin name, and password of your CouchDB. You'll be asked if you want to automagically clean up all Syncpoint stuff, and you'll then also be asked if you want to manually manage your other databases. Pretty straightforward.~~

## ~~Drag-n-drop to delete databases~~

~~So, even if you don't use Syncpoint, *Syncpoint-and-Couch-Cleaner* still makes cleaning up a bunch of CouchDB databases a breeze with the power of drag-n-drop (well, more like copy/pasting stuff in a text file).~~

~~![Screenshot](http://i45.tinypic.com/fef68g.png)~~

~~![Screenshot](http://i49.tinypic.com/f8nth.png)~~

~~It would be nice to also be able to similarly handle design docs, but I got tired so I didn't fully implement it (the code is commented out in the script).~~

~~This is my first CLI tool and I mostly just wanted to play with Bash/scripting, so I basically had no idea what I was doing.~~

~~That said, all suggestions/questions/feedback are welcome!~~

[1]: http://paulcapestany.com
[2]: https://github.com/couchbaselabs/Syncpoint-API
