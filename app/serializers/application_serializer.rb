class ApplicationSerializer
  include JSONAPI::Serializer

  # Default serialization options
  # Override in child serializers for specific attribute inclusion
end
