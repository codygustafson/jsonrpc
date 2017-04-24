# TODO Make production ready

module Jsonrpc

  class Engine

    def initialize options={}
      @handlers = options[:handlers]
    end

    def handle request, state={}
      response = RequestRunner.run(request) do |req, callbacks|

        request_handler = handler(req)

        if request_handler.nil?
          callbacks.method_not_found
        else
          request_handler.new(state, callbacks).rpc_send(method(req), req['params'])
        end

      end

      yield response unless response.nil?
    end

    def handler(request)
      @handlers[namespace(request)]
    end

    def method(request)
      request['method'].split('.').last
    end

    def namespace(request)
      space = request['method'].split('.')
      if space.size == 1
        ""
      else
        space.first
      end
    end

  end

end

