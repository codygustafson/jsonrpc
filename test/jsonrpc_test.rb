require 'test_helper'

class JsonrpcTest < Minitest::Test

  def setup
    @handler = Jsonrpc::RequestHandler
  end

  def test_handles_invalid_json
    invalid_json = '{"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz]'
    result = @handler.run(invalid_json) { assert false }

    assert_equal '2.0', result['jsonrpc']
    assert(-32700, result['error']['code'])
    assert result.key?('id')
    assert_nil result['id']
  end

  def test_invalid_request
    invalid_json = '{"jsonrpc": "2.0", "method": 1, "params": "bar", "id": 1}'
    result = @handler.run(invalid_json) { assert false }

    assert_equal '2.0', result['jsonrpc']
    assert_equal(-32600, result['error']['code'])
    assert_equal(1, result['id'])
  end

  def test_success
    valid_request = '{"jsonrpc": "2.0", "method": "subtract", "id": 1}'
    result = @handler.run(valid_request) do |request, callbacks|
      callbacks.success('5')
    end
    assert_equal '5', result['result']
    assert_equal 1, result['id']
    assert_equal '2.0', result['jsonrpc']
  end

  def test_custom_failure
    valid_request = '{"jsonrpc": "2.0", "method": "subtract", "id": 1}'
    result = @handler.run(valid_request) do |request, callbacks|
      callbacks.error(5, "custom message")
    end
    assert_equal 5, result['error']['code']
    assert_equal 'custom message', result['error']['message']
  end

  def test_method_not_found
    valid_request = '{"jsonrpc": "2.0", "method": "subtract", "params": "1", "id": 1}'

    result = @handler.run(valid_request) do |request, callbacks|
      assert 'subtract', request['method']
      assert '1', request['params']
      callbacks.method_not_found
    end

    assert_equal '2.0', result['jsonrpc']
    assert_equal(-32601, result['error']['code'])
    assert_equal(1, result['id'])
  end

  def test_with_invalid_batch
    invalid_json = '[1]'
    result = @handler.run(invalid_json) { assert false }
    assert result.is_a?(Array)
    assert_equal 1, result.size
    assert_equal(-32600, result.first['error']['code'])
  end

  def test_with_invalid_batch
    invalid_json = '[1,2,3]'
    result = @handler.run(invalid_json) { assert false }
    assert result.is_a?(Array)
    assert_equal 3, result.size
    assert_equal(-32600, result.first['error']['code'])
  end

  def test_with_empty_array
    invalid_json = '[]'
    result = @handler.run(invalid_json) { assert false }
    assert_equal(-32600, result['error']['code'])
  end

  def test_that_it_has_a_version_number
    refute_nil ::Jsonrpc::VERSION
  end

end
