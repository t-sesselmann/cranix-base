CREATE DATABASE oss;
use oss;

CREATE TABLE `accounts` (
	`school`	VARCHAR(32) NOT NULL,
	`id`		VARCHAR(32) NOT NULL,
	`type`		VARCHAR(16) NOT NULL,
	PRIMARY KEY  (`school`,`id`)
);

CREATE TABLE `users` (
	`school`	VARCHAR(32) NOT NULL,
	`id`		VARCHAR(32) NOT NULL,
	`role`		VARCHAR(16) NOT NULL,
	PRIMARY KEY  (`school`,`id`)
)

CREATE TABLE `groups` (
	`school`	VARCHAR(32) NOT NULL,
	`id`		VARCHAR(32) NOT NULL,
	`type`		VARCHAR(16) NOT NULL,
	PRIMARY KEY  (`school`,`id`)
);

CREATE TABLE `rooms` (
	`school`	VARCHAR(32) NOT NULL,
	`id`		VARCHAR(32) NOT NULL,
	`startIP`	VARCHAR(16) NOT NULL,
	`netMask`	integer  NOT NULL,
	PRIMARY KEY  (`school`,`id`)
);

CREATE TABLE `workstations` (
	`school`	VARCHAR(32) NOT NULL,
	`id`		VARCHAR(32) NOT NULL,
	`room`		VARCHAR(16) NOT NULL,
	`IP`		VARCHAR(16) NOT NULL,
	`MAC`		VARCHAR(17) NOT NULL,
	PRIMARY KEY  (`school`,`id`)
);

CREATE TABLE `software` (
	`id`		VARCHAR(32) NOT NULL,
	
);
