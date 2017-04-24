require 'test_helper'

class RequestRunnerTest < Minitest::Test

  def setup
    @runner = Jsonrpc::RequestRunner
  end

  def test_handles_invalid_json
    invalid_json = '{"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz]'
    result = @runner.run(invalid_json) { assert false }

    assert_equal '2.0', result['jsonrpc']
    assert(-32700, result['error']['code'])
    assert result.key?('id')
    assert_nil result['id']
  end

  def test_invalid_request
    invalid_json = '{"jsonrpc": "2.0", "method": 1, "params": "bar", "id": 1}'
    result = @runner.run(invalid_json) { assert false }

    assert_equal '2.0', result['jsonrpc']
    assert_equal(-32600, result['error']['code'])
    assert_equal(1, result['id'])
  end

  def test_success
    valid_request = '{"jsonrpc": "2.0", "method": "subtract", "id": 1}'
    result = @runner.run(valid_request) do |request, callbacks|
      callbacks.success('5')
    end
    assert_equal '5', result['result']
    assert_equal 1, result['id']
    assert_equal '2.0', result['jsonrpc']
  end

  def test_custom_failure
    valid_request = '{"jsonrpc": "2.0", "method": "subtract", "id": 1}'
    result = @runner.run(valid_request) do |request, callbacks|
      callbacks.error(5, "custom message")
    end
    assert_equal 5, result['error']['code']
    assert_equal 'custom message', result['error']['message']
  end

  def test_internal_error
    valid_request = '{"jsonrpc": "2.0", "method": "subtract", "params": "1", "id": 1}'

    result = @runner.run(valid_request) do |request, callbacks|
      assert 'subtract', request['method']
      assert '1', request['params']
      callbacks.internal_error
    end

    assert_equal '2.0', result['jsonrpc']
    assert_equal(-32603, result['error']['code'])
    assert_equal(1, result['id'])
  end

  def test_method_not_found
    valid_request = '{"jsonrpc": "2.0", "method": "subtract", "params": "1", "id": 1}'

    result = @runner.run(valid_request) do |request, callbacks|
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
    result = @runner.run(invalid_json) { assert false }
    assert result.is_a?(Array)
    assert_equal 1, result.size
    assert_equal(-32600, result.first['error']['code'])
  end

  def test_with_invalid_batch_multiple
    invalid_json = '[1,2,3]'
    result = @runner.run(invalid_json) { assert false }
    assert result.is_a?(Array)
    assert_equal 3, result.size
    assert_equal(-32600, result.first['error']['code'])
  end

  def test_with_empty_array
    invalid_json = '[]'
    result = @runner.run(invalid_json) { assert false }
    assert_equal(-32600, result['error']['code'])
  end

  def test_validate_method_required
    invalid_json = '{"jsonrpc": "2.0", "params": "bar", "id": 1}'
    result = @runner.run(invalid_json) { assert false }

    assert_equal '2.0', result['jsonrpc']
    assert_equal(-32600, result['error']['code'])
    assert_equal(1, result['id'])
  end

  def test_validate_jsonrpc
    invalid_json = '{"jsonrpc": 2.0, "method":"subtract", "params": "bar", "id": 1}'
    result = @runner.run(invalid_json) { assert false }

    assert_equal '2.0', result['jsonrpc']
    assert_equal(-32600, result['error']['code'])
    assert_equal(1, result['id'])
  end

  def test_validate_id
    invalid_json = '{"jsonrpc": "2.0", "method":"subtract", "params": "bar", "id": {}}'
    result = @runner.run(invalid_json) { assert false }

    assert_equal '2.0', result['jsonrpc']
    assert_equal(-32600, result['error']['code'])
    assert_nil(result['id'])
  end

  def test_method_cannot_be_blank
    invalid_json = '{"jsonrpc": "2.0", "method":"", "params": "bar", "id": 1}'
    result = @runner.run(invalid_json) { assert false }

    assert_equal '2.0', result['jsonrpc']
    assert_equal(-32600, result['error']['code'])
    assert_equal(1, result['id'])
  end

  def test_method_cannot_start_with_rpc_namespace
    invalid_json = '{"jsonrpc": "2.0", "method":"rpc.Shoot", "params": "bar", "id": 1}'
    result = @runner.run(invalid_json) { assert false }

    assert_equal '2.0', result['jsonrpc']
    assert_equal(-32600, result['error']['code'])
    assert_equal(1, result['id'])
  end

end

