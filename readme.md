Replace IP with current interface (eg 33.4.56.2)

```bash
tarantool init.lua --advertise-uri IP:3301
```

```bash
tarantool init.lua --advertise-uri IP:3302 --http-enabled false --workdir two
```

```bash
tarantool init.lua --advertise-uri IP:3303 --http-enabled false --workdir three
```
