# Jsonrpc

Jsonrpc is a framework for creating jsonrpc 2.0 servers while being totally transport agnostic.

## Installation

TODO

## Usage

```ruby

class MyRequestHandler < Jsonrpc::RequestHandler

  def my_method params
    my_private_method params
  end

  def validated_method params
    if params.nil?
      @callbacks.invalid_parameters('custom message')
    else
      params
    end
  end

  private

  def my_private_method params
    params
  end

end

engine = Jsonrpc::Engine.new(handlers: {
  'My' => MyRequestHandler
})


engine.handle(raw_json_request, state) do |response_hash|
  puts response_hash.to_json
end

# '"jsonrpc":"2.0", "method":"my_method", "id":"1", "params":"5"'
# {"jsonrpc" => "2.0", "result" => "5", "id" => "1"}

# '"jsonrpc":"2.0", "method":"my_method", "id":"1", "params":"5"'
# {"jsonrpc" => "2.0", "result" => "5", "id" => "1"}

# '"jsonrpc":"2.0", "method":"validated_params", "id":"1", "params":null'
# {"jsonrpc" => "2.0", "error" => {"code": -32600, "message":"custom message"}, "id" => "1"}
```

### Available Callbacks

```ruby
success(result) # default action of method response
error(code, message, data) # custom errors
internal_error(message, data) # default action of uncaught exceptions
invalid_parameters(message, data)
method_not_found(message, data)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codygustafson/jsonrpc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

