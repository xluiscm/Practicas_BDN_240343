import { ApolloServer } from '@apollo/server';
import { startStandaloneServer } from '@apollo/server/standalone';
import { MongoClient } from 'mongodb';
import typeDefs from './typeDefs.js';
import resolvers from './resolvers.js';

const uri = process.env.MONGO_URI;
const client = new MongoClient(uri);

await client.connect();
const db = client.db('ecommerce');
console.log('Conectado a MongoDB');

const server = new ApolloServer({
  typeDefs,
  resolvers: resolvers(db)
});

const { url } = await startStandaloneServer(server, {
  listen: { port: 4000, host: '0.0.0.0' },
  context: async ({ req }) => ({
    clientIp: req.socket.remoteAddress || 'desconocida'
  })
});

console.log(`GraphQL listo en ${url}`);
