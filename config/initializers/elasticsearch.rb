Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: ENV["ELASTICSEARCH_URL"],
  log: true,
  transport_options: {
    request: { timeout: 5 }
  }
)
