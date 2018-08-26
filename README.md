# Migration

Script to help migrate code from SVN to GIT without losing commits history, tags and branchs.

## Requirements

```
apt-get install git git-svn subversion
```

## Configuration
Change the variables:
* PROJECT_NAME : Name of your project 
* BASE_SVN : The url to SVN repository to be migrated
* BRANCHES : The branches folder inside BASE_SVN
* TAGS : The tags folder inside BASE_SVN
* TRUNK : The trunk folder inside BASE_SVN
* GIT_URL : The url to Git repository to migrate

## Execution

```
./migrate-svn-to-git
```

Enjoy it.
