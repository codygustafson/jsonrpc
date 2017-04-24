
module Jsonrpc
  class RequestValidator

    def initialize request_hash
      @errors = RequestValidator.validate(request_hash)
    end

    def errors
      @errors
    end

    def valid?
      @errors.size == 0
    end

    def self.validate hash
      errors = []

      if !hash.is_a?(Hash)
        errors << "Invalid Request"
        return errors
      end

      if hash['id'] && !hash['id'].is_a?(String) && !hash['id'].nil? && !hash['id'].is_a?(Numeric)
        errors << "id must be a string, a number, or null."
        hash['id']=nil
      end

      if hash['jsonrpc'] != '2.0'
        errors << "jsonrpc MUST be exactly '2.0'."
      end

      if !hash.key?('method')
        errors << "method is required."
      elsif !hash['method'].is_a?(String)
        errors << "method must be a string."
      elsif hash['method'].strip == ''
        errors << "method may not be empty."
      elsif hash['method'].strip.start_with?('rpc.')
        errors << "method may not start with 'rpc.'"
      end

      errors
    end

  end
end

