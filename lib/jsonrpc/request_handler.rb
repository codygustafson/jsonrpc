
module Jsonrpc

  module RequestHandler
    INVALID_JSON_RESPONSE = {
      'jsonrpc' => '2.0',
      'id' => nil,
      'error' => {
        'code' => Jsonrpc::ErrorCodes::INVALID_JSON,
        'message' => 'invalid json'
      }
    }

    INVALID_REQUEST_RESPONSE = {
      'jsonrpc' => '2.0',
      'id' => nil,
      'error' => {
        'code' => Jsonrpc::ErrorCodes::INVALID_REQUEST,
        'message' => 'Invalid Request'
      }
    }

    def self.run incoming_json
      begin
        data = JSON.parse(incoming_json)
      rescue JSON::ParserError
        return INVALID_JSON_RESPONSE
      end

      if !data.is_a?(Array)
        data = [data]
      elsif data.size > 0
        batch = true
      else
        return INVALID_REQUEST_RESPONSE
      end

      results = []

      data.each do |request|
        validator = RequestValidator.new(request)
        response_callbacks = ResponseCallbacks.new(request)

        result = if validator.valid?
          yield(request, response_callbacks)
        else
          response_callbacks.invalid_parameters(validator.errors.join(' '))
        end

        results << result
      end

      results.compact!

      if results.size == 0
        nil
      elsif batch
        results
      else
        results.first
      end
    end

  end

end

