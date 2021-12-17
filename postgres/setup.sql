START TRANSACTION;

CREATE TABLE customers(
  id    SERIAL PRIMARY KEY,
  first_name varchar(100),
  last_name varchar(100),
  email VARCHAR(40) NOT NULL UNIQUE
);

COMMIT;
