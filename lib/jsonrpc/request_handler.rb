
module Jsonrpc

  class RequestHandler

    # Any methods in here which you don't want to show
    # through rpc should either be private or in this constant
    NON_RPC_METHODS = ['rpc_send']

    def initialize state, callbacks
      @callbacks = callbacks
    end

    def rpc_send method, parameters
      if rpc_methods.include?(method)
        public_send(method.to_sym, parameters)
      else
        @callbacks.method_not_found
      end
    end

    def rpc_methods
      (public_methods.map(&:to_s) - NON_RPC_METHODS) - Object.public_methods.map(&:to_s)
    end

  end

end

