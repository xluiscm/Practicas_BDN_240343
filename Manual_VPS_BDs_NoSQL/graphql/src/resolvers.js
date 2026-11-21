export default (db) => ({
  Query: {
    reviewsByProduct: async (_, { product_id, minRating = 0 }) => {
      return await db.collection('col_products_reviews')
        .find({ product_id, rating: { $gte: minRating } })
        .toArray();
    },
    reviewsPaginated: async (_, { product_id, page, pageSize }) => {
      const total = await db.collection('col_products_reviews')
        .countDocuments({ product_id });
      const items = await db.collection('col_products_reviews')
        .find({ product_id })
        .skip((page - 1) * pageSize)
        .limit(pageSize)
        .toArray();
      return { total, items };
    },
    allReviews: async () => {
      return await db.collection('col_products_reviews').find().toArray();
    },
    userAddresses: async (_, { user_id }) => {
      return await db.collection('col_users_adress')
        .find({ user_id })
        .toArray();
    }
  },
  Mutation: {
    createReview: async (_, args) => {
      const doc = {
        ...args,
        created_at: new Date()
      };
      const result = await db.collection('col_products_reviews').insertOne(doc);

      // Trazabilidad automática en col_logs
      await db.collection('col_logs').insertOne({
        fecha_hora: new Date(),
        operacion: 'CREATE',
        usuario: 'graphql_user',
        rol: 'api',
        ip: 'graphql',
        coleccion: 'col_products_reviews',
        documento: result.insertedId.toString(),
        descripcion: 'Reseña creada vía GraphQL',
        estado: 'éxito',
        datos_antes: null,
        datos_despues: doc
      });

      return { _id: result.insertedId, ...doc };
    }
  }
});
