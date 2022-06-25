# setup connections
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @reqs/connections/es-sink.json
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @reqs/connections/source.json



curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @reqs/connections/es-q.json
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @reqs/connections/es-q.json

curl -i -X DELETE -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/test_db-connector

curl -i -X DELETE -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/elastic-sink

curl -X GET http://localhost:8081/subjects

curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @reqs/connections/es-qa.json
curl -i -X GET http://localhost:9200/_mapping

curl -i -X DELETE http://localhost:8081/subjects/dbserver1.public.answer-value/versions/1
# psql command
create database test_db;
\c test_db
# insert into question (question_content, question_detail, user_id) values ('ᠶᠠᠮᠠᠷ ᠰᠣᠨᠢᠨ ᠪᠣᠢ?', 'ᠰᠣᠨᠢᠨ ᠰᠠᠶ᠋ᠢᠬᠠᠨ ᠶᠠᠭᠤ ᠪᠠᠶ᠋ᠢᠨ᠎ᠠ?', 1);
insert into answer (id, content, user_id) values(default, 'hell', 1);
# kafka command
kafka-topics.sh --delete --bootstrap-server kafka:9092 --topic dbserver1.public.question

kafka-topics.sh --bootstrap-server kafka:9092 --list

kafka-get-offsets.sh --topic dbserver1.public.question --bootstrap-server kafka:9092

# other command
docker compose up -d
docker compose exec postgres psql -Upostgres
docker compose exec kafka bash
docker run -it --rm --name ksqldb-cli  \
    --network sync-postgresql-with-elasticsearch-example_default \
   confluentinc/cp-ksqldb-cli:7.0.4 http://ksqldb-server:8088

docker ps
docker exec -it xxxxxxxxx bash
# ksqldb cli command

SET 'auto.offset.reset' = 'earliest';

show topics;

show streams;

show tables;

PRINT 'dbserver1.public.question' FROM BEGINNING;

# CREATE STREAM question_src (id bigint key, question_title varchar, question_content varchar, created_at bigint, updated_at bigint, version int)
CREATE STREAM question_src
  WITH (KAFKA_TOPIC='dbserver1.public.question', VALUE_FORMAT='AVRO');

# CREATE STREAM answer_src (id bigint key, question_id bigint, content varchar, created_at bigint, updated_at bigint, version int)
CREATE STREAM answer_src
  WITH (KAFKA_TOPIC='dbserver1.public.answer', VALUE_FORMAT='AVRO');

CREATE TABLE question_src_table
  WITH (partitions=1)
  as select id , LATEST_BY_OFFSET(question_content) as question_content,
      LATEST_BY_OFFSET(question_detail) as question_detail,
      LATEST_BY_OFFSET(created_at) as created_at,
      LATEST_BY_OFFSET(updated_at) as updated_at,
      LATEST_BY_OFFSET(version) as version
    from question_src
    group by id;

select * from question_src_table where id = 1;

DESCRIBE question_table;

CREATE STREAM question_answer with (partitions=1) as
  select a.id as id,
        a.question_content as question_content,
        a.question_detail as question_detail,
        a.created_at as question_created_at,
        a.updated_at as question_updated_at,
        a.version as question_version,
        b.id as answer_id,
        b.content as answer_content,
        b.created_at as answer_created_at,
        b.updated_at answer_updated_at,
        b.version as answer_version
  from answer_src b
    left join question_src_table a ON a.id = b.question_id;

drop stream question_answer;

select * from question_answer emit changes;
# elasticsearch curl
# delete index
curl --location --request DELETE 'localhost:9200/dbserver1.public.question'
