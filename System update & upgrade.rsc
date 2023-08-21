:log/warning message="Script is running!";

# Change channel to (long term/stable/testing/development), if you need another version
:system/package/update set channel=stable;
:delay 3;
:global Ver value=[system/package/update/get status];
:delay 3;
:global Ch value=[system/package/update/get channel];
:delay 3;
:global Nver value=[system/package/update/get latest-version];
:log/warning message="Checking for new versions"
:delay 10;

:if ($Ver = "New version is available") do={
:log/warning message="New version is available, channel: $Ch, new version: $Nver is installing...";
:delay 5;
:system/scheduler/add start-time=startup name=Upgrade on-event={
:delay delay-time=10;
:global CrtVer value=[system/routerboard/get current-firmware];
:global UpgVer value=[system/routerboard/get upgrade-firmware];
:if ($CrtVer != $UpgVer) do={system/routerboard/upgrade};
:delay delay-time=10;
:log/warning message="Removing schedule...";
:system/scheduler/remove Upgrade;
:system/scheduler/add start-time=startup name=OK on-event={
:log/warning message="System updating & upgrading is complete!";
:system/scheduler/remove OK
		};
:log/warning message="Script complete, rebooting system in 10 seconds...";
:delay 10;
:log/warning message="Rebooting...";
:system/reboot
	}; 
:system/package/update/install;
} else {log/warning message="$Ver"};
