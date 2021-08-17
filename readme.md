# Tarantool engine for Centrifugo

This is a Lua part of Centrifugo integration with [Tarantool](https://www.tarantool.io/en/) database/platform as a possible Engine option. The integration  provides an efficient PUB/SUB, ephemeral publication streams and channel presence functionality. See [additional details](https://centrifugal.dev/docs/server/engines#tarantool-engine) in Centrifugo documentation.

At this stage we consider this module **experimental**: API and repo structure can still evolve as we get more feedback from the Centrifugo community.

Prerequisites: Go language and Tarantool should be installed.

Also install dependencies:

``` bash
tarantoolctl rocks install cartridge 2.6.0
tarantoolctl rocks install https://raw.githubusercontent.com/centrifugal/tarantool-centrifuge/main/centrifuge-scm-1.rockspec
```

## Pure Tarantool

This section describes topologies available with pure Tarantool (i.e. no Cartridge). Use `init_standalone.lua` as starting point. As soon as Tarantool backend started you can connect to it from Centrifuge-based server (see below).

### Single node

Run single Tarantool instance (`127.0.0.1:3301`):

``` bash
tarantool init_standalone.lua
```

### High Availability

Not available with pure Tarantool yet - see Cartridge section.

### Sharded

First shard (`127.0.0.1:3301`):

``` bash
TARANTOOL_PORT=3301 tarantool init_standalone.lua
```

Second shard (`127.0.0.1:3302`):

``` bash
TARANTOOL_PORT=3302 tarantool init_standalone.lua
```

## Cartridge

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
  - Configure on second node
    - Join replicaset
  - Enable failover (eventual or stateful)

#### Sharded

- Configure topology on web ui http://127.0.0.1:8081
  - Configure on first node
    - Enable centrifuge
  - Configure on second node
    - Enable centrifuge

#### Combined (Sharded + Highly Available)

It's possible to combine sharded and high availability setups. For example start 4 Tarantool nodes in Cartridge, create 2 shards, join replicas to each shard. I.e. sth like this:

- Configure topology on web ui http://127.0.0.1:8081
  - Configure on first node
    - Enable centrifuge
  - Configure on second node
    - Join replicaset on first node
  - Configure on third node
    - Enable centrifuge
  - Configure on fourth node
    - Join replicaset on first node

# Start Centrifugo v3 server

A beta release of Centrifugo v3 available [here](https://github.com/centrifugal/centrifugo/releases/tag/v3.0.0-beta.1)

## Pure Tarantool

This section describes how to connect Centrifuge-based server to pure Tarantool setup.

### Single node

```bash
./centrifugo --engine=tarantool --tarantool_address="127.0.0.1:3301"
```

### Multinode

#### High Availability

Not available for pure Tarantool yet.

#### Sharded

```bash
./centrifugo --engine=tarantool --tarantool_address="127.0.0.1:3301 127.0.0.1:3302"
```

## Cartridge

This section describes how to connect Centrifuge-based server to Tarantool Cartridge setup.

### Single node

``` bash
CENTRIFUGO_TARANTOOL_USER=admin CENTRIFUGO_TARANTOOL_PASSWORD="secret-cluster-cookie" ./centrifugo --engine=tarantool
```

### Multinode

#### High Availability

``` bash
CENTRIFUGO_TARANTOOL_USER=admin CENTRIFUGO_TARANTOOL_PASSWORD="secret-cluster-cookie" CENTRIFUGO_TARANTOOL_MODE="leader-follower" ./centrifugo --engine=tarantool --tarantool_address="127.0.0.1:3301,127.0.0.1:3302"
```

#### Sharded

``` bash
CENTRIFUGO_TARANTOOL_USER=admin CENTRIFUGO_TARANTOOL_PASSWORD="secret-cluster-cookie" CENTRIFUGO_TARANTOOL_MODE="leader-follower" ./centrifugo --engine=tarantool --tarantool_address="127.0.0.1:3301,127.0.0.1:3302 127.0.0.1:3303,127.0.0.1:3304"
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
## Packing

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
