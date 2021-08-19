# Tarantool engine for Centrifugo based on Tarantool Cartridge

This is a Lua part of Centrifugo integration with [Tarantool](https://www.tarantool.io/en/) database/platform as a possible Engine option. The integration  provides an efficient PUB/SUB, ephemeral publication streams and channel presence functionality. See [additional details](https://centrifugal.dev/docs/server/engines#tarantool-engine) in Centrifugo documentation.

This repo is an engine built with Tarantool Cartridge framework. For other possible Tarantool setups (without Cartridge) refer to the [tarantool-centrifuge](https://github.com/centrifugal/tarantool-centrifuge) repo.

At this stage we consider this **experimental**: API and repo structure can still evolve as we get more feedback from the Centrifugo community.

## Local setup

Prerequisites: Go language and Tarantool should be installed.

Also install dependencies:

``` bash
tarantoolctl rocks install cartridge 2.6.0
tarantoolctl rocks install https://raw.githubusercontent.com/centrifugal/tarantool-centrifuge/main/centrifuge-scm-1.rockspec
```

Then run:

```
cartridge start
```

# Centrifugo server version

These examples require Centrifugo >= 3.0.0

A beta release of Centrifugo v3 available [here](https://github.com/centrifugal/centrifugo/releases/tag/v3.0.0-beta.1)

## Topoligies

This section describes topologies available with Tarantool Cartridge. Use `init.lua` as starting point.

### Single node

``` bash
tarantool init.lua --bootstrap true
```

`--bootstrap true` automatically assigns Centrifuge role for node on `127.0.0.1:3301`

### Multinode

Create a couple of Tarantool instances managed by Cartridge:

First instance on `127.0.0.1:3301`:

```bash
tarantool init.lua --advertise-uri 127.0.0.1:3301 --workdir one
```

Second instance on `127.0.0.1:3302`:

```bash
tarantool init.lua --advertise-uri 127.0.0.1:3302 --http-enabled false --workdir two
```

Now let's look at available Tarantool topologies in Cartridge cluster.

#### High availability

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

#### Sharded

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

#### Combined (Sharded + Highly Available)

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

# Tests

``` bash
tarantoolctl rocks install luatest
```

- Run

``` bash
.rocks/bin/luatest
```

# Deploy

See [releases](https://github.com/centrifugal/tarantool-engine-cartridge/releases) for assets.

## Install

```
sudo yum install centrifuge-tarantool-engine-$RELEASE.rpm
```

## Configuring

- `/etc/tarantool/conf.d/centrifuge-tarantool-engine.yml`
  ```
  centrifuge-tarantool-engine.x:
    http_port: 8081
    advertise_uri: 127.0.0.1:3301

  centrifuge-tarantool-engine.y:
    http_port: 8082
    advertise_uri: 127.0.0.1:3302
  ```

## Start

```
sudo systemctl start centrifuge-tarantool-engine@x
```

```
sudo systemctl start centrifuge-tarantool-engine@y
```

- Goto web admin
- Configure topology you want

## Manual packing

```
sudo yum install tarantool tarantool-devel cartridge-cli
sudo yum install gcc gcc-c++ cmake unzip zip
```

```
cartridge build
```

```
cartridge pack rpm --unit-template centrifuge-tarantool-engine.service --instantiated-unit-template centrifuge-tarantool-engine@.service # --version 0.1.0
```
