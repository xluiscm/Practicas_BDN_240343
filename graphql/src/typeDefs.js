export default `#graphql
  type Review {
    _id: ID
    product_id: Int
    user_id: Int
    seller_id: Int
    rating: Int
    comment: String
    created_at: String
  }

  type Address {
    _id: ID
    user_id: Int
    street: String
    city: String
    state: String
    zip: String
    country: String
  }

  type Query {
    reviewsByProduct(product_id: Int!, minRating: Int): [Review]
    reviewsPaginated(product_id: Int!, page: Int!, pageSize: Int!): ReviewPage
    allReviews: [Review]
    userAddresses(user_id: Int!): [Address]
  }

  type ReviewPage {
    total: Int
    items: [Review]
  }

  type Mutation {
    createReview(
      product_id: Int!
      user_id: Int!
      seller_id: Int
      rating: Int!
      comment: String!
    ): Review
  }
`;
