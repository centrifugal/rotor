# Start developer backend

``` bash
tarantoolctl rocks install cartridge 2.5.0
tarantoolctl rocks install https://raw.githubusercontent.com/moonlibs/indexpiration/master/rockspecs/indexpiration-scm-1.rockspec
```

## Pure Tarantool

### Single node

``` bash
tarantool init.lua 1
```

### Sentinel

- First replica
``` bash
tarantool init.lua 1
```

- Second replica
``` bash
tarantool init.lua 2
```

- Warning without replication now!!!

### Sharded

- First shard

``` bash
tarantool init.lua 1
```

- Second shard
``` bash
tarantool init.lua 2
```

## Cartridge

### Single node ready to work on 127.0.0.1

``` bash
tarantool init_cartridge.lua --bootstrap true
```

### Multinode

```bash
tarantool init_cartridge.lua --advertise-uri 127.0.0.1:3301 --workdir one
```

```bash
tarantool init_cartridge.lua --advertise-uri 127.0.0.1:3302 --http-enabled false --workdir two
```

#### Sentinel

- Configure topology on web ui http://127.0.0.1:8081
  - Configure on first node
    - Enable centrifuge
    - Create replicaset
  - Configure on second node
    - Join replicaset
  - Enable failover (eventual or stateful)

#### Sharded

- Configure topology on web ui http://127.0.0.1:8081
  - Configure on first node
    - Enable centrifuge
    - Create replicaset
  - Configure on second node
    - Enable centrifuge
    - Create replicaset

#### Combined

- Sharded + Sentinel

# Start centrifuge

``` bash
git clone  https://github.com/centrifugal/centrifuge.git
cd centrifuge/_examples/custom_engine_tarantool
```

## Pure Tarantool

### Single node

``` bash
go run main.go
```

### Multinode

#### Sentinel

``` bash
go run main.go -ha
```

#### Sharded

``` bash
go run main.go -sharded
```

## Cartridge

### Single

``` bash
go run main.go -user admin -password secret-cluster-cookie
```

### Multinode

#### Sentinel

``` bash
go run main.go -ha -user admin -password secret-cluster-cookie
```

#### Sharded

``` bash
go run main.go -sharded -user admin -password secret-cluster-cookie
```

# Tests

``` bash
tarantoolctl rocks install luatest
```

- Run

``` bash
.rocks/bin/luatest
```
