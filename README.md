# Sync PostgreSQL with Elasticsearch via Debezium

### Schema

```
                   +-------------+
                   |             |
                   |  PostgreSQL |
                   |             |
                   +------+------+
                          |
                          |
                          |
          +---------------v------------------+
          |                                  |
          |           Kafka Connect          |
          |    (Debezium, ES connectors)     |
          |                                  |
          +---------------+------------------+
                          |
                          |
                          |
                          |
                  +-------v--------+
                  |                |
                  | Elasticsearch  |
                  |                |
                  +----------------+


```
We are using Docker Compose to deploy the following components:

* PostgreSQL
* Kafka
  * ZooKeeper
  * Kafka Broker
  * Kafka Connect with [Debezium](http://debezium.io/) and [Elasticsearch](https://github.com/confluentinc/kafka-connect-elasticsearch) Connectors
* Elasticsearch

### Usage

```shell
docker-compose up --build

# wait until it's setup
./start.sh
```

### Testing

Check database's content

```shell
# Check contents of the PostgreSQL database:
docker-compose exec postgres bash -c 'psql -U $POSTGRES_USER $POSTGRES_DATABASE -c "SELECT * FROM customers"'

# Check contents of the Elasticsearch database:
curl http://localhost:9200/customers/_search?pretty
```

Create customer

```shell
docker-compose exec postgres bash -c 'psql -U $POSTGRES_USER $POSTGRES_DATABASE'
test_db=# insert into customers values(default, 'John', 'Doe', 'john.doe@example.com');

# Check contents of the Elasticsearch database:
curl http://localhost:9200/customers/_search?q=id:4
```

```json
{
  ...
  "hits": {
    "total": 1,
    "max_score": 1.0,
    "hits": [
      {
        "_index": "customers",
        "_type": "customers",
        "_id": "4",
        "_score": 1,
        "_source": {
          "id": 4,
          "first_name": "John",
          "last_name": "Doe",
          "email": "john.doe@example.com"
        }
      }
    ]
  }
}
```

Update customer

```shell
test_db=# UPDATE customers SET email = 'tesla@gmail.com' WHERE id = 4;

# Check contents of the Elasticsearch database:
curl http://localhost:9200/users/_search?q=id:4
```

```json
{
  ...
  "hits": {
    "total": 1,
    "max_score": 1.0,
    "hits": [
      {
        "_index": "customers",
        "_type": "customers",
        "_id": "4",
        "_score": 1,
        "_source": {
          "id": 4,
          "first_name": "John",
          "last_name": "Doe",
          "email": "tesla@gmail.com"
        }
      }
    ]
  }
}
```

Delete user

```shell
test_db=# DELETE FROM customers WHERE id = 4;

# Check contents of the Elasticsearch database:
curl http://localhost:9200/users/_search?q=id:4
```

```json
{
  ...
  "hits": {
    "total": 1,
    "max_score": 1.0,
    "hits": []
  }
}
```
