# scan-expire

Containerized utility to scan Redis keys and expire keys matching a specified pattern.

<img src="https://raw.githubusercontent.com/evanx/reo/master/docs/readme/main.png"/>

## Use case

## Config

See `lib/config.js`
```javascript
module.exports = {
    description: 'Containerized utility to scan Redis keys and expire keys matching a specified pattern.',
    required: {
        pattern: {
            description: 'the matching pattern for Redis scan',
            example: '*'
        },
        ttl: {
            description: 'the TTL expiry to set on archived keys',
            unit: 'seconds',
            example: 60
        },
        limit: {
            description: 'the maximum number of keys to expire',
            default: 10,
            note: 'zero means unlimited'
        },
        host: {
            description: 'the Redis host',
            default: 'localhost'
        },
        port: {
            description: 'the Redis port',
            default: 6379
        }
    }
}
```

## Usage

## Docker

You can build as follows:
```shell
```

See `test/demo.sh` https://github.com/evanx/reo/blob/master/test/demo.sh
```shell
```

Creates:
- isolated network `reo-network`
- isolated Redis instance named `reo-redis`
- two `spiped` containers to test encrypt/decrypt tunnels
- the prebuilt image `evanxsummers/reo`
- host volume `$HOME/volumes/reo/data`

```
evan@dijkstra:~/reo$ sh test/demo.sh
...
```

## Implementation

See `lib/index.js`

```javascript
    let cursor;
    while (true) {
        const [result] = await multiExecAsync(client, multi => {
            multi.scan(cursor || 0, 'match', config.pattern);
        });
        cursor = parseInt(result[0]);
        const keys = result[1];
        const results = await multiExecAsync(client, multi => {
            keys.forEach(key => multi.expire(key, config.ttl));
        });
        if (config.limit > 0 && count > config.limit) {
            console.error(clc.yellow('Limit exceeded. Try: limit=0'));
            break;
        }
        if (cursor === 0) {
            break;
        }
    }
```

### Appication archetype

Incidently `lib/index.js` uses the `redis-app-rpf` application archetype.
```
require('redis-app-rpf')(require('./spec'), require('./main'));
```
where we extract the `config` from `process.env` according to the `spec` and invoke our `main` function.

See https://github.com/evanx/redis-app-rpf.

This provides lifecycle boilerplate to reuse across similar applications.

<hr>
https://twitter.com/@evanxsummers
