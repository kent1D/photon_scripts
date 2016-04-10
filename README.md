# Photon scripts

Scripts for the [Photon geocoder](https://github.com/komoot/photon)

## Init script

The script ```photon``` in the ```start-stop/``` folder is a Debian init script (should be usable with other distributions).

It permits to ```start```, ```stop```, ```restart``` and view the ```status``` of the Java programm launched as daemon.

## Updater script

The script ```photon_update.sh``` in the ```update/``` folder is an updater for the Photon's Elasticsearch indexes.

It can be used manually launching the script directly via CLI but also in crontab.

We recommend to launch it once a week thrue a crontab job (the Photon's Elasticsearche indexes are updated on [the source repository once a week](https://github.com/komoot/photon#installation)).