require "elasticsearch/model"

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1 } do
      mappings dynamic: false do
        indexes :product_name, type: "text"
        indexes :category_id, type: "keyword"
        indexes :price, type: "float"
        indexes :stock, type: "integer"
        indexes :rating, type: "float"
        indexes :sold, type: "integer"
        indexes :feedback_count, type: "integer"
      end
    end

    def as_indexed_json(_options = {})
      {
        product_name:,
        category_id: category_id,
        price: price,
        stock: stock,
        rating: rating,
        sold: sold,
        feedback_count: feedback_count
      }
    end

    def feedback_count
      feedbacks.size
    end
  end
end
