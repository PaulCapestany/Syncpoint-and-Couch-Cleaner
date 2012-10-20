Syncpoint-and-Couch-Cleaner is a CLI tool to cleanup Syncpoint databases such as `sp_admin`, `channel-*`, and `control-*`.

It also cleans up the `_users` DB by removing documents of type `org.couchdb.user*`. Similarly, it cleans up the `_replicator` DB by removing documents of type `global-control-*`

Even if you don't use Syncpoint, it still makes cleaning up a bunch of CouchDB databases a breeze!
