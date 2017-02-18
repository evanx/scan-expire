
module.exports = async context => {
    const {config, logger, client} = context;
    Object.assign(global, context);
    try {
        let count = 0;
        const resultCounts = {};
        let cursor;
        while (true) {
            const [result] = await multiExecAsync(client, multi => {
                multi.scan(cursor || 0, 'match', config.pattern);
            });
            cursor = parseInt(result[0]);
            const keys = result[1];
            count += keys.length;
            if (config.limit > 0 && count > config.limit) {
                console.error(clc.yellow('Limit reached. Try: limit=0'));
                break;
            }
            const results = await multiExecAsync(client, multi => {
                keys.forEach(key => multi.expire(key, config.ttl));
            });
            results.forEach((result, index) => {
                if (resultCounts[result] === undefined) {
                    resultCounts[result] = 0;
                }
                resultCounts[result]++;
                console.error(clc.green(result), keys[index]);
            });
            if (cursor === 0) {
                break;
            }
        }
        console.log(JSON.stringify(resultCounts));
    } catch (err) {
       throw err;
    } finally {
    }
};
