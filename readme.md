# Developer mode

``` bash
tarantoolctl rocks install cartridge 2.4.0
tarantoolctl rocks install https://raw.githubusercontent.com/moonlibs/indexpiration/master/rockspecs/indexpiration-scm-1.rockspec
```

Replace IP with current interface (eg `33.4.56.2`)

```bash
tarantool init.lua --advertise-uri IP:3301 --workdir one
```

```bash
tarantool init.lua --advertise-uri IP:3302 --http-enabled false --workdir two
```

```bash
tarantool init.lua --advertise-uri IP:3303 --http-enabled false --workdir three
```


## Tests

``` bash
tarantoolctl rocks install luatest
```

- Run

``` bash
.rocks/bin/luatest
```
