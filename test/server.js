const Hapi = require('hapi');


const server = new Hapi.Server();
server.connection({port: 4004});

server.register(require('inert'), (err) => {

    if (err) throw err;

    server.route({
        method: 'GET',
        path: '/{param*}',
        handler: {directory: {path: 'data'}}
    })

    server.start((err) => {
        if (err) throw err;

        console.log('Server running ', server.info.uri);
    })
})