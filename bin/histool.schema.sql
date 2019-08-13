-- CREATE TABLE IF NOT EXISTS "history" (timestamp INTEGER, duration INTEGER, pwd TEXT, hispos INTEGER, typed TEXT, expanded TEXT, sha1 TEXT, UNIQUE (typed, expanded) ON CONFLICT REPLACE);
CREATE TABLE IF NOT EXISTS "commands" (command TEXT UNIQUE ON CONFLICT IGNORE);
