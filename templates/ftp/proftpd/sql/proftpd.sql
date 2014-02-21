CREATE TABLE ftpgroups (
	groupname varchar(16) NOT NULL default '',
	gid smallint(6) NOT NULL default '2001',
	members varchar(16) NOT NULL default '',
	KEY groupname (groupname)
) ENGINE=MyISAM COMMENT='ProFTP group table';

CREATE TABLE ftpusers (
	id int(10) unsigned NOT NULL auto_increment,
	userid varchar(32) NOT NULL default '',
	passwd varchar(255) NOT NULL default '',
	uid smallint(6) NOT NULL default '2001',
	gid smallint(6) NOT NULL default '2001',
	homedir varchar(255) NOT NULL default '',
	shell varchar(16) NOT NULL default '/sbin/nologin',
	count int(11) NOT NULL default '0',
	accessed datetime NOT NULL default '0000-00-00 00:00:00',
	modified datetime NOT NULL default '0000-00-00 00:00:00',
	PRIMARY KEY (id),
	UNIQUE KEY userid (userid)
) ENGINE=MyISAM COMMENT='ProFTP user table';