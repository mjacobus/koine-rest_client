# Koine::RestClient

Another http client with async

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'koine-rest_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install koine-rest_client

## Usage

```ruby
# default configuration for every request
request = Koine::RestClient::Request.new(
  base_url: 'http://some.endpoint.com/rest',
  query_params: { auth_token: 'the-auth-token' },
  headers: { 'X-Client' => 'The Collest Client' }
)
client = Koine::RestClient::Client.new(base_request: request)
json_response = client.get('foo/bar')

json_response = client.post(
  'foo/bar',
  campaign_data,
  query_params: { auth_token: 'other_rid' } # other auth_token
)

# or throw on non 200

json_response = client.post(
  'foo/bar',
  campaign_data,
  query_params: { auth_token: nil } # remove auth_token param
)
```

If you care for the response details:

```ruby

json_response = client.get('foo/bar') do |response|
  if response.code == 1
    raise 'what, really?'
  end
end
```

### Async calls

```ruby
data = client.async do |builder|
  builder.get('foo', rid: 'bar') do |response|
  builder.get('bar') do |response|
    Rails.logger.log(response)
  end

  builder.post('baz', { payload: :value })

  # optional. Raise error if ommited
  builder.on_error do |exception|
    # ignore
  end
end

data[0] # foo response
data[1] # bar response
data[2] # baz response
```

### Mocking in rspec

```ruby
require 'koine/rest_client/rspec_mock_client'

let(:mock_client) { Koine::RestClient::RspecMockClient.new(spec) }

client.mock do |mocker|
  mocker.get('foo').will_return(body: { foo: :bar })
  mocker.put('bar', baz: :foo).will_return(body: { baz: :bar })
  mocker.delete('error').will_return(code: 400, body: { message: :oops })
end

# or with custom response use the block

client.mock do |mocker|
  mocker.get('foo').will_return(body: 'parsed-body') do |response|
    double(code: 200, parsed_response: "the #{response.parsed_response}")
  end
end
```

### Mocking a server

Start the server

```bash
./bin/mock_server
```

```ruby
request = Koine::RestClient::Request.new(
  base_url: 'http://localhost:4321/something',
  query_params: { rid: 'internal' },
  headers: { 'X-Foo-Bar' => 'foo-bar' }
)
client = Koine::RestClient::Client.new(base_request: request)

client.get('foo') # check the response
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mjacobus/koine-rest_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Koine::RestClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mjacobus/koine-rest_client/blob/master/CODE_OF_CONDUCT.md).
