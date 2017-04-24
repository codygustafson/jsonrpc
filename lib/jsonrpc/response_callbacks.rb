
module Jsonrpc

  class ResponseCallbacks

    def initialize request
      @request = request
    end

    def success result
      return nil if notification?

      {
        'jsonrpc' => '2.0',
        'id' => @request['id'],
        'result' => result
      }
    end

    def error code, msg, data=nil
      return nil if notification?

      if ErrorCodes::NON_APPLICATION_ERRORS.include?(code) || !code.is_a?(Integer)
        # log this?
        internal_error
      end

      error = {
        'jsonrpc' => '2.0',
        'id' => @request['id'],
        'error' => {
          'code' => code,
          'message' => msg
        }
      }
      error['data'] = data unless data.nil?
      error
    end

    def invalid_parameters msg="invalid parameters", data=nil
      if !@request.is_a?(Hash)
        @request = {'id' => nil}
      end
      error(ErrorCodes::INVALID_REQUEST, msg, data)
    end

    def internal_error msg='internal error', data=nil
      error(ErrorCodes::INTERNAL_ERROR, msg, data)
    end

    def method_not_found msg='Method not found', data=nil
      error(ErrorCodes::METHOD_NOT_FOUND, msg, data)
    end

    private

    def notification?
      @request.is_a?(Hash) && !@request.key?('id')
    end

  end

end

