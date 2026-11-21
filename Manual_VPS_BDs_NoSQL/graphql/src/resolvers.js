import { ObjectId } from 'mongodb';

export default (db) => {
  const reviews = db.collection('col_products_reviews');
  const logs = db.collection('col_logs');

  const registrarAuditoria = async ({
    operacion, id, ip, datosAntes = null, datosDespues = null
  }) => {
    await logs.insertOne({
      fecha_hora: new Date(),
      operacion,
      usuario: 'graphql_user',
      rol: 'api',
      ip: ip || 'desconocida',
      coleccion: 'col_products_reviews',
      documento: id.toString(),
      descripcion: `Reseña ${operacion} vía GraphQL`,
      estado: 'éxito',
      datos_antes: datosAntes,
      datos_despues: datosDespues
    });
  };

  return {
    Query: {
      reviewsByProduct: async (_, { product_id, minRating = 0 }, context) => {
        const resultado = await reviews.find({
          product_id,
          rating: { $gte: minRating }
        }).toArray();

        await registrarAuditoria({
          operacion: 'READ',
          id: 'consulta_reviewsByProduct',
          ip: context.clientIp,
          datosDespues: { total: resultado.length, product_id, minRating }
        });
        return resultado;
      },

      reviewsPaginated: async (_, { product_id, page, pageSize }, context) => {
        const total = await reviews.countDocuments({ product_id });
        const items = await reviews.find({ product_id })
          .skip((page - 1) * pageSize).limit(pageSize).toArray();

        await registrarAuditoria({
          operacion: 'READ',
          id: 'consulta_reviewsPaginated',
          ip: context.clientIp,
          datosDespues: { total, product_id, page, pageSize }
        });
        return { total, items };
      },

      allReviews: async (_, __, context) => {
        const resultado = await reviews.find().toArray();

        await registrarAuditoria({
          operacion: 'READ',
          id: 'consulta_allReviews',
          ip: context.clientIp,
          datosDespues: { total: resultado.length }
        });
        return resultado;
      },

      userAddresses: async (_, { user_id }) =>
        db.collection('col_users_adress').find({ user_id }).toArray()
    },

    Mutation: {
      createReview: async (_, args, context) => {
        const doc = { ...args, created_at: new Date() };
        const result = await reviews.insertOne(doc);
        await registrarAuditoria({
          operacion: 'CREATE',
          id: result.insertedId,
          ip: context.clientIp,
          datosDespues: doc
        });
        return { _id: result.insertedId, ...doc };
      },

      updateReview: async (_, { id, ...changes }, context) => {
        if (!ObjectId.isValid(id)) throw new Error('ID inválido');
        const actual = await reviews.findOne({ _id: new ObjectId(id) });
        if (!actual) throw new Error('Reseña no encontrada');
        const datosAntes = { ...actual };

        const updates = {};
        if (changes.rating !== undefined && changes.rating !== null)
          updates.rating = changes.rating;
        if (changes.comment !== undefined && changes.comment !== null)
          updates.comment = changes.comment;
        if (!Object.keys(updates).length)
          throw new Error('Debes indicar rating o comment');

        await reviews.updateOne(
          { _id: actual._id },
          { $set: updates }
        );
        const actualizado = await reviews.findOne({ _id: actual._id });

        await registrarAuditoria({
          operacion: 'UPDATE',
          id: actual._id,
          ip: context.clientIp,
          datosAntes: datosAntes,
          datosDespues: actualizado
        });
        return actualizado;
      },

      deleteReview: async (_, { id }, context) => {
        if (!ObjectId.isValid(id)) throw new Error('ID inválido');
        const actual = await reviews.findOne({ _id: new ObjectId(id) });
        if (!actual) throw new Error('Reseña no encontrada');

        const result = await reviews.deleteOne({ _id: actual._id });
        if (result.deletedCount !== 1)
          throw new Error('No se pudo eliminar la reseña');

        await registrarAuditoria({
          operacion: 'DELETE',
          id: actual._id,
          ip: context.clientIp,
          datosAntes: actual
        });
        return true;
      }
    }
  };
};
