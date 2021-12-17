START TRANSACTION;

insert into customers
  values (default, 'Sally', 'Thomas', 'sally.thomas@acme.com');


insert into customers
  values (default, 'George', 'Bailey', 'gbailey@foobar.com');

insert into customers
  values (default, 'Edward', 'Walker', 'ed@walker.com');


COMMIT;
