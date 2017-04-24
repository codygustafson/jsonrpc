require 'test_helper'

class JsonrpcTest < Minitest::Test

  def test_that_it_has_a_version_number
    refute_nil Jsonrpc::VERSION
  end

end
