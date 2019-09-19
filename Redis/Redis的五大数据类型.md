# Redis的五大数据类型
## key
* 查询当前库的所有键：` keys + *`
* 判断某个键是否存在：`exists <key>`
* 查看键对应的数据类型：`type <key>`
* 删除某个键：`del <key>`
* 为键设置对应的过期时间，单位秒：`expire <key> <seconds>`
* 查看还有多少秒过期，-1表示永不过期，-2表示已经过期：`ttl <key>`
* 查看当前数据库key的数量：`dbsize`
* 清空当前库：`flushdb`
* 通杀全部库：`flushall`

## string
* 查询对应键值：`get <key>`
* 添加键值对：`set <key> <value>`
* 将给定的value追加到原值的末尾：`append <key> <value>`
* 获取值的长度：`strlen <key>`
* 只有在key不存在时设置key的值：`setnx <key> <value>`
* 将key中存储的数字值增加1（只能对数字值操作）：`incr <key>`
* 将key中存储的数字值减1（只能对数字值操作）：`decr <key>`
* 将key中存储的数字值增减，自定义步长：`incrby / decrby <key> <increment>`
* 同时设置一个或多个key-value对：`mset <key1><value1> <key2><value2>...`
* 同时获取一个或多个value：`mget <key1><key2>...`
* 同时设置一个或多个key-value对，当且仅当所有给定的key都不存在时：`msetnx <key1><value1> <key2><value2>...`
* 获得值的范围，类似java中的substring：`getrange <key> <start> <end>`
* 用<value>覆写<key>所存储的字符串值，从<起始位置>开始：`setrange <key> <start> <value>`
* 设置键值的同时，设置过期时间，单位秒：`setex <key> <seconds> <value>`
* 以新换旧，设置新值的同时获得旧值：`getset <key> <value>`

## list(单键多值)
* 从左边/右边插入一个或多个值：`lpush / rpush <key> <value1><value1>...`
* 从左边/右边吐出一个或多个值（值在键在，值亡键亡）：`lpop / rpop <key>`
* 从<key1>键表右边吐出一个值，插入到<key2>键表左边：`rpoplpush <key1> <key2>`
* 按照索引下标获得元素（从左到右）：`lrange <key> <start> <stop>`
* 按照索引下标获得元素（从左到右）：`lindex <key> <index>`
* 获得列表长度：`llen <key>`
* 在<value>前面插入<newvalue>：`linsert <key> before <value> <newvalue>`
* 从左边删除n个value（从左到右）：`lrem <key> <n> <value>`

## set(无序集合，自动排重)
* 将一个或多个member元素加入到集合key中，已经存在于key集合member元素将被忽略：`sadd <key> <value1><value2>...`
* 取出该集合的所有值：`smembers <key>`
* 判断<key>集合是否存在该<value>值，存在返回1，不存在返回0：`sismember <key> <value>`
* 返回该集合的元素个数：`scard <key>`
* 删除集合中的某个元素：`srem <key> <value1><value2>`
* 随机从该集合中吐出一个或多个值：`spop <key> <n>`
* 随机从集合中取出n个值，不会从集合中删除：`srandmember <key> <n>`
* 返回两个集合的交集元素：`sinter <key1> <key2>`
* 返回两个集合的并集元素：`sunion <key1> <key2>`
* 返回两个集合的差集元素：`sdiff <key1> <key2>`

## hash(键值对集合，string类型的field和value的映射表)
* 给<key>集合中的<field>键赋值<value>: `hset <key> <field> <value>`
* 从<key>集合的<field>取出value：`hget <key> <field>`
* 批量设置hash的值：`hmset <key> <field1><value1> <field2><value2>`
* 查看哈希表key中，给定域field是否存在：`hexists <key> <field>`
* 列出该hash集合的所有field：`hkeys <key>`
* 列出该hash集合的所有value：`hvals <key>`
* 为哈希表key中的域field的值加上增量increment：`hincrby <key> <field> <increment>`
* 将hash表key中的域field的值设置为value，当且仅当域field不存在：`hsetnx <key> <field> <value>`

## zset(sorted set，按照score升序排列)
* 将一个或多个member元素及其score值加入到有序集合key当中：`zadd <key> <score1><value1> <score2><value2>`
* 按照索引下标获得元素（从左到右），带WITHSCORES，可以让分数一起和值返回到结果集：`zrange <key> <start> <stop>[withscores]`
* 返回有序集key中，所有的score值介于min和max之间（包括min和max），有序集按score递增排列：`zrangebyscore <key> <min> <max>[withscores]`
* 同上，改为递减排列：`zrevrangebyscore <key> <max> <min> [withscore]`
* 为元素的score加上增量：`zincrby <key> <increment> <value>`
* 删除该集合下，指定值的元素：`zrem <key> <value>`
* 统计该集合中，分数区间内的元素个数：`zcount <key> <min> <max>`
* 返回该值在集合中的排名，从0开始：`zrank <key> <value>`