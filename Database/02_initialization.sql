﻿CREATE EXTENSION "uuid-ossp"
    SCHEMA public
    VERSION "1.1";

GRANT USAGE ON SCHEMA public TO app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLES TO app_user;
