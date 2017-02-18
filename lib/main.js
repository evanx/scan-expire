
module.exports = async context => {
    const {config, logger, client} = context;
    Object.assign(global, context);
    try {
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
            results.forEach(result => {
                console.log(result);
            });
            if (config.limit > 0 && count > config.limit) {
                console.error(clc.yellow('Limit exceeded. Try: limit=0'));
                break;
            }
            if (cursor === 0) {
                break;
            }
        }
    } catch (err) {
       throw err;
    } finally {
    }
};
