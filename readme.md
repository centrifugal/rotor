# Rotor – Tarantool Cartridge-based engine for Centrifugo

This is a Lua part of [Centrifugo experimental integration](https://centrifugal.dev/docs/server/engines#tarantool-engine) with [Tarantool](https://www.tarantool.io/en/) as a possible Engine option. 

The integration provides an efficient PUB/SUB, ephemeral history streams and channel presence functionality.

This repo is an engine built with Tarantool Cartridge framework. For other possible Tarantool setups (without Cartridge) refer to the [tarantool-centrifuge](https://github.com/centrifugal/tarantool-centrifuge) repo.

## Status

At this stage we consider this **experimental**: API and repo structure can still evolve as we get more feedback from the Centrifugo community.

## Local setup

Prerequisites: Go language and Tarantool should be installed.

Also, install dependencies:

``` bash
tarantoolctl rocks install cartridge 2.7.1
tarantoolctl rocks install https://raw.githubusercontent.com/centrifugal/tarantool-centrifuge/main/centrifuge-scm-1.rockspec
```

Then run:

```
cartridge start
```

This will run Cartridge with 2 nodes from `instances.yml`, you can then go to http://localhost:8081 and configure topology.

Alternatively, you can run single node Tarantool with already configured `centrifuge` role using this command:

``` bash
tarantool init.lua --bootstrap true
```

`--bootstrap true` automatically assigns `centrifuge` role for node on `127.0.0.1:3301`

Two manually run several Cartridge nodes run in one terminal:

```bash
tarantool init.lua --advertise-uri 127.0.0.1:3301 --workdir one
```

And then in another terminal:

```bash
tarantool init.lua --advertise-uri 127.0.0.1:3302 --http-enabled false --workdir two
```

## Centrifugo server version

These examples require Centrifugo >= 3.0.0

## Topologies

This section describes topologies available with Tarantool Cartridge.

### High availability (leader-follower setup)

- Configure topology on web ui http://127.0.0.1:8081
  - Configure on first node
    - Enable centrifuge
    - Create replicaset
    - Assume the address is `localhost:3301`
  - Configure on second node
    - Join replicaset
    - Assume the address is `localhost:3302`
  - Enable failover (eventual or stateful)

Then run Centrifugo with config like:

```json
{
  ...
  "engine": "tarantool",
  "tarantool_address": "localhost:3301,localhost:3302",
  "tarantool_mode": "leader-follower",
  "tarantool_user": "<user>",
  "tarantool_password": "<password>"
}
```

### Sharded (to scale engine)

- Configure topology on web ui http://127.0.0.1:8081
  - Configure on first node
    - Enable centrifuge
    - Assume the address is `localhost:3301`
  - Configure on second node
    - Enable centrifuge
    - Assume the address is `localhost:3301`

Then run Centrifugo with config like:

```json
{
  ...
  "engine": "tarantool",
  "tarantool_address": "localhost:3301 localhost:3302",
  "tarantool_mode": "standalone",
  "tarantool_user": "<user>",
  "tarantool_password": "<password>"
}
```

Centrifugo will consistently shard data by channel between running Tarantool nodes. 

### Combined (Sharded + Highly Available)

It's possible to combine sharded and high availability setups. For example start 4 Tarantool nodes in Cartridge, create 2 shards, join replicas to each shard. I.e. sth like this:

- Configure topology on web ui http://127.0.0.1:8081
  - Configure on first node
    - Enable centrifuge
    - Assume the address is `localhost:3301`
  - Configure on second node
    - Join replicaset on first node
    - Assume the address is `localhost:3302`
  - Configure on third node
    - Enable centrifuge
    - Assume the address is `localhost:3303`
  - Configure on fourth node
    - Join replicaset on first node
    - Assume the address is `localhost:3304`

Then run Centrifugo with config like:

```json
{
  ...
  "engine": "tarantool",
  "tarantool_address": "localhost:3301,localhost:3302 localhost:3303,localhost:3304",
  "tarantool_mode": "leader-follower",
  "tarantool_user": "<user>",
  "tarantool_password": "<password>"
}
```

## Tests

``` bash
tarantoolctl rocks install luatest
```

- Run

``` bash
.rocks/bin/luatest
```

## Deploy

See [releases](https://github.com/centrifugal/rotor/releases) for assets.

### Install

```
sudo yum install rotor-$RELEASE.rpm
```

### Configuring

- `/etc/tarantool/conf.d/rotor.yml`
  ```
  rotor.x:
    http_port: 8081
    advertise_uri: 127.0.0.1:3301

  rotor.y:
    http_port: 8082
    advertise_uri: 127.0.0.1:3302
  ```

### Start

```
sudo systemctl start rotor@x
```

```
sudo systemctl start rotor@y
```

- Goto web admin
- Configure topology you want

### Manual packing

```
sudo yum install tarantool tarantool-devel cartridge-cli
sudo yum install gcc gcc-c++ cmake unzip zip
```

```
cartridge build
```

```
cartridge pack rpm --unit-template rotor.service --instantiated-unit-template rotor@.service # --version 0.1.0
```
