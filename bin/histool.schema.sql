-- CREATE TABLE IF NOT EXISTS "history" (timestamp INTEGER, duration INTEGER, pwd TEXT, hispos INTEGER, typed TEXT, expanded TEXT, sha1 TEXT, UNIQUE (typed, expanded) ON CONFLICT REPLACE);
CREATE TABLE IF NOT EXISTS "commands" (
	commandid INTEGER PRIMARY KEY AUTOINCREMENT,
	command TEXT UNIQUE ON CONFLICT IGNORE
);
CREATE TABLE IF NOT EXISTS "directories" (
	directoryid INTEGER PRIMARY KEY,
	directory TEXT UNIQUE ON CONFLICT IGNORE
);
CREATE TABLE IF NOT EXISTS "runtimes" (
	runid INTEGER PRIMARY KEY,
	at INTEGER, duration INTEGER,
	cmd INTEGER, wd INTEGER,
	FOREIGN KEY(cmd) REFERENCES commands(commandid),
	FOREIGN KEY(wd) REFERENCES directories(directoryid)
);
