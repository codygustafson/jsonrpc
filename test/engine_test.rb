
require 'test_helper'

class EngineTest < Minitest::Test

  class TestHandler < Jsonrpc::RequestHandler

    def test parameters
      "test output"
    end

  end

  def test_valid_request
    valid_request = '{"jsonrpc": "2.0", "method": "Custom.test", "id": 1}'
    @engine = Jsonrpc::Engine.new(handlers: {"Custom" => TestHandler})
    response = nil
    @engine.handle(valid_request) do |resp|
      response = resp
    end
    assert_equal "test output", response
  end

  def test_missing_method
    valid_request = '{"jsonrpc": "2.0", "method": "Custom.testing", "id": 1}'
    @engine = Jsonrpc::Engine.new(handlers: {"Custom" => TestHandler})
    response = nil
    @engine.handle(valid_request) do |resp|
      response = resp
    end
    assert_equal(-32601, response['error']['code'])
  end

  def test_wrong_namespace
    valid_request = '{"jsonrpc": "2.0", "method": "Customs.test", "id": 1}'
    @engine = Jsonrpc::Engine.new(handlers: {"Custom" => TestHandler})
    response = nil
    @engine.handle(valid_request) do |resp|
      response = resp
    end
    assert_equal(-32601, response['error']['code'])
  end

  def test_no_namespace
    valid_request = '{"jsonrpc": "2.0", "method": "test", "id": 1}'
    @engine = Jsonrpc::Engine.new(handlers: {"Custom" => TestHandler})
    response = nil
    @engine.handle(valid_request) do |resp|
      response = resp
    end
    assert_equal(-32601, response['error']['code'])
  end

end

