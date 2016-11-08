use oss;

CREATE TABLE `roomAccess` (
	`school`	VARCHAR(32) NOT NULL,
	`room`		VARCHAR(32) NOT NULL,
	`time`		VARCHAR(8)  NOT NULL,
	`all`		BOOLEAN  NOT NULL,
	`proxy`		BOOLEAN  NOT NULL,
	`printing`	BOOLEAN  NOT NULL,
	`mailing`	BOOLEAN  NOT NULL,
	`samba`		BOOLEAN  NOT NULL,
	PRIMARY KEY  (`school`,`room`,`time`)
);

CREATE TABLE `softwareStatus` (
	`school`	VARCHAR(32) NOT NULL,
	`software`	VARCHAR(32) NOT NULL,
	`workstation`   VARCHAR(32) NOT NULL,
	`status`	VARCHAR(2)  NOT NULL,
	PRIMARY KEY  (`school`,`software`,`workstation`)
);


CREATE TABLE `configurationValue` (
	`school`	VARCHAR(32) NOT NULL,
	`id`            VARCHAR(32) NOT NULL,
	`name`		VARCHAR(32) NOT NULL,
	`value`		mediumblob   default NULL,
);

