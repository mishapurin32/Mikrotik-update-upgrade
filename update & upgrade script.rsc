# Script "auto update & upgrade" version: 1.0 release

:log/warning message="Script is running!";
:log/warning message="DO NOT UNPLUG POWER WHILE ROUTER IS BEING UPGRADED!";

# Change channel to (long term/stable/testing/development), if you need another version
:system/package/update set channel=stable;
:delay 3;
:system/package/update/check-for-updates;
:delay 5;
:global Ver value=[system/package/update/get status];
:delay 3;
:global Ch value=[system/package/update/get channel];
:delay 3;
:global Nver value=[system/package/update/get latest-version];
:delay 3;
:global CrtDate value=[system/clock/get date];
:log/warning message="Checking for new versions";
:delay 20;
:if ($Ver = "New version is available") do={
	:log/warning message="New version is available, channel: $Ch, new version: $Nver is installing...";
	:log/warning message="During the update process, your router will reboot twice";
	:delay 5;
	
	:log/warning message="Creating backup and script file before update";
	:system/backup/ save name="Backup before update $CrtDate";
	:delay 5;
	:export file="Script before update $CrtDate"
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
			:system/scheduler/remove OK;
			:log/warning message="System updating & upgrading is complete!";
		};
		
		:log/warning message="Script complete, rebooting system in 10 seconds...";
		:delay 10;
		:log/warning message="Rebooting...";
		:system/reboot;
	};
	
:system/package/update/install;
} else {
		:log/warning message="$Ver";
		:log/warning message="Script complete";
		};

:if ($Ver = "finding out new versions") do={
	:log/warning message="Error, please do manual update";
};
