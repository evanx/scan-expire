module.exports = {
    description: 'Redis-based dispatcher to parallel pipelines.',
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
        },
        loggerLevel: {
            description: 'the logging level',
            default: 'info',
            options: ['debug', 'warn', 'error']
        }
    },
    development: {
        loggerLevel: 'debug'
    },
    test: {
        loggerLevel: 'debug'
    }
}
