# Photon scripts

Scripts for the [Photon geocoder](https://github.com/komoot/photon)

## Init script

The script ```photon``` in the ```start-stop/``` folder is a Debian init script (should be usable with other distributions).

It permits to ```start```, ```stop```, ```restart``` and view the ```status``` of the Java programm launched as daemon.

## Updater script

The script ```photon_update.sh``` in the ```update/``` folder is an updater for the Photon's Elasticsearch indexes.

It can be used manually launching the script directly via CLI but also in crontab.

We recommend to launch it once a week thrue a crontab job (the Photon's Elasticsearche indexes are updated on [the source repository once a week](https://github.com/komoot/photon#installation)).

### Changelog

### Versions 0.0.x

#### Version 0.0.2 (2016-07-25)

Since the files in the database are different from an export to an other, the new downloaded files didn't replace the former ones.

Now we make a backup of the former database (in `/var/www/photon/photon_data_save`) before upgrading it.

#### Version 0.0.1

The original version of the script
