# rhel7_islandora_server
A series of scripts to install a islandora ready server on RHEL 7. These are bash scripts to be used by the system administrator.


### Basics ###

* Starting with a fresh install
* User names, passwords, and paths have to be set in the files in the configs directory
* Each script has a order that it should be run.  ss-2-apache-php  should be run before ss-5-drupal.
* Not all have to be executed, for example, if you did not want to install sleuthkit, just do not run that script.
* Run a script, check and see what happened, did it install?  Can you see that part functioning?
* To update a component, like FITS, modify the script or version in the variables file and run the script again.

### About ###

* This is based on https://github.com/pc37utn/centos7_base_box
which is based on https://github.com/Islandora-Labs/islandora_vagrant_base_box

