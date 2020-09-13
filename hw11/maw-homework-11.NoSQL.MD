NoSQL базы
Задание 1.	В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.
```
Microsoft Windows [Version 6.1.7601]

Alex@HPDV6 d:\openserver
$ redis-cli
127.0.0.1:6379> HVALS ip-count
(empty list or set)
127.0.0.1:6379> HINCRBY ip-count '192.168.2.2' 1
(integer) 1
127.0.0.1:6379> HINCRBY ip-count '192.168.2.2' 1
(integer) 2
127.0.0.1:6379> HINCRBY ip-count '192.168.2.33' 1
(integer) 1
127.0.0.1:6379> HVALS ip-count
1) "2"
2) "1"
127.0.0.1:6379> HGETALL ip-count
1) "192.168.2.2"
2) "2"
3) "192.168.2.33"
4) "1"
127.0.0.1:6379> HGET ip-count '192.168.2.1'
(nil)
127.0.0.1:6379> HGET ip-count '192.168.2.33'
"1"
127.0.0.1:6379>
```

Задание 2.	При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот, 
поиск электронного адреса пользователя по его имени.
Создадим хэш, в который будем одной командой записывать два поле-значение: имя-емэил и емэил-имя
В этом случае в одном хэше user-email можно искать и по имени и по адресу
(можно конечно и разделить по разным хэшам, но что это меняет?)
```
127.0.0.1:6379> HVALS user-email
(empty list or set)
127.0.0.1:6379> HMSET user-email 'Alex Mokin' 'mr.aleksay@gmail.com' 'mr.aleksay@gmail.com' 'Alex Mokin'
OK
127.0.0.1:6379> HMSET user-email 'Anna M' 'anna@gmail.com' 'anna@gmail.com' 'Anna M'
OK
127.0.0.1:6379> HMSET user-email 'Tim M' 'tim@gmail.com' 'tim@gmail.com' 'Tim M'
OK
127.0.0.1:6379> HKEYS user-email
1) "Alex Mokin"
2) "mr.aleksay@gmail.com"
3) "Anna M"
4) "anna@gmail.com"
5) "Tim M"
6) "tim@gmail.com"
127.0.0.1:6379> HGET user-email 'Alex Mokin'
"mr.aleksay@gmail.com"
127.0.0.1:6379> HGET user-email 'mr.aleksay@gmail.com'
"Alex Mokin"
127.0.0.1:6379> HGET user-email 'anna@gmail.com'
"Anna M"
127.0.0.1:6379> HGET user-email 'Tim M'
"tim@gmail.com"
127.0.0.1:6379> HGET user-email 'tim@gmail.com'
"Tim M"
127.0.0.1:6379> HGET user-email '123@gmail.com'
(nil)
127.0.0.1:6379>
```

Задание 3.	Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.

```
Microsoft Windows [Version 6.1.7601]

Alex@HPDV6 C:\Users\Alex
# mongo
MongoDB shell version v4.2.5
connecting to: mongodb://127.0.0.1:27017/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("5f70f704-10fc-46ad-a8ab-6e90367419f0") }
MongoDB server version: 4.2.5
Welcome to the MongoDB shell.
> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
> use shop
switched to db shop
> db.createColletcion('catalog')
2020-09-13T16:10:22.252+0500 E  QUERY    [js] uncaught exception: TypeError: db.createColletcion is not a function :
@(shell):1:1
> db.createCollection('catalog')
{ "ok" : 1 }
> db.createCollection('products')
{ "ok" : 1 }
> show tables
catalog
products
> db.catalog.insert({name:'HDD'})
WriteResult({ "nInserted" : 1 })
> db.catalog.insert({name:'SSD'})
WriteResult({ "nInserted" : 1 })
> db.catalog.find()
{ "_id" : ObjectId("5f5dfeb1e189b03cedc0c615"), "name" : "HDD" }
{ "_id" : ObjectId("5f5dfebae189b03cedc0c616"), "name" : "SSD" }

> db.products.insert({name:'Maxtor HDD 1Tb model 321wer1tb', })
WriteResult({ "nInserted" : 1 })
> db.products.find();
{ "_id" : ObjectId("5f5dff46e189b03cedc0c617"), "name" : "Maxtor HDD 1Tb model 321wer1tb" }
> db.products.remove({_id : ObjectId("5f5dff46e189b03cedc0c617")});
WriteResult({ "nRemoved" : 1 })

> db.products.find();
> db.products.insert({name:'Maxtor HDD 1Tb model 321wer1tb',
... description: 'The faster HDD from Maxtor',
... price: 3999.00,
... catalog_id: new ObjectId("5f5dfeb1e189b03cedc0c615")});
WriteResult({ "nInserted" : 1 })

> db.products.insert({name:'WD HDD 3Tb model wd3tbblack', 
... description: 'Faster HDD from WD', 
... price: 2888.00, 
... catalog_id: new ObjectId("5f5dfeb1e189b03cedc0c615")});
WriteResult({ "nInserted" : 1 })

> db.products.insert({name:'QUONO SSD 120', 
... description: 'QUONO SSD 120Gb, 560/540',
... price: 3339.00,
... catalog_id: new ObjectId("5f5dfeb1e189b03cedc0c616")});
WriteResult({ "nInserted" : 1 })
> db.products.find();
{ "_id" : ObjectId("5f5e0107e189b03cedc0c618"), "name" : "Maxtor HDD 1Tb model 321wer1tb", "description" : "The faster HDD from Maxtor", "price" : 3999, "catalog_id" : ObjectId("5f5dfeb1e189b03cedc0c615") }
{ "_id" : ObjectId("5f5e01c2e189b03cedc0c619"), "name" : "WD HDD 3Tb model wd3tbblack", "description" : "Faster HDD from WD", "price" : 2888, "catalog_id" : ObjectId("5f5dfeb1e189b03cedc0c615") }
{ "_id" : ObjectId("5f5e0229e189b03cedc0c61a"), "name" : "QUONO SSD 120", "description" : "QUONO SSD 120Gb, 560/540", "price" : 3339, "catalog_id" : ObjectId("5f5dfeb1e189b03cedc0c616") }

> db.products.find({catalog_id: ObjectId("5f5dfeb1e189b03cedc0c616")});
{ "_id" : ObjectId("5f5e0229e189b03cedc0c61a"), "name" : "QUONO SSD 120", "description" : "QUONO SSD 120Gb, 560/540", "price" : 3339, "catalog_id" : ObjectId("5f5dfeb1e189b03cedc0c616") }
>
```
