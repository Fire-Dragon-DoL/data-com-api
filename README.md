# DataComApi

Ruby bindings for Data.com API ( Salesforce, ex Jigsaw ).

## Installation

Add this line to your application's Gemfile:

    gem 'data-com-api', '~> 0.2.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install data-com-api

## Usage

First, create a `DataComApi::Client` instance with the following line:

```ruby
client = DataComApi::Client.new('your-api-token')
```

You can then configure the client in the following way:

```ruby
# Value must be between 1 and 500, 100 will be used if search_company is used
# and supplied value is greater than 100
client.page_size = 100
```

You can also get the totals API calls performed on the client with:

```ruby
client.api_calls_count
```

Then, you can perform one of the following requests:

- `search_contact`
- `search_company`
- `company_contact_count`
- `contacts`

Every method matches the Data.com API call and support the same parameters. All requests are *lazy*,
which means that the request will be performed only once you actually perform an action on the response, like
requesting `size`, `all`, `each` and such (keep reading).

### Client methods aka API responses
#### #search\_contact and #search\_company

The parameters accepted by this method are the keys of the [DataComApi::QueryParameters](https://github.com/Fire-Dragon-DoL/data-com-api/blob/master/lib/data-com-api/query_parameters.rb). Notice that you can use the key specified as `:from` for a more ruby-like
syntax.

**start_at_offset** and **end_at_offset**: This two new parameters allow your response to start fetching data at specified offset or end earlier (if
`end_at_offset` is bigger than max fetchable records, it will be ignored and code will handle things in standard way).

The returned object is a `DataComApi::SearchContact` which is mostly a [DataComApi::SearchBase](https://github.com/Fire-Dragon-DoL/data-com-api/blob/master/lib/data-com-api/responses/search_base.rb) instance with the following main methods:
- `size` which returns the `totalHits` field from the response
  (it will perform a request only if none performed)
- `all` which returns an array containing all records that can be fetched
  (be careful, can be **memory hungry**). Will handle paging by itself
- `each` which yields each record that can be obtained with the request, less memory hungry than previous
  request. Will handle paging by itself
- `each_with_index` same as previous one but with index
- `at_offset` which get one page of records (as an array) at specified offset

Every record returned will be a [DataComApi::Contact](https://github.com/Fire-Dragon-DoL/data-com-api/blob/master/lib/data-com-api/contact.rb) or a [DataComApi::Company](https://github.com/Fire-Dragon-DoL/data-com-api/blob/master/lib/data-com-api/company.rb) instance.

#### #company\_contact\_count

The parameters accepted by this method are `company_id` (required) and the second one is [DataComApi::QueryParameters](https://github.com/Fire-Dragon-DoL/data-com-api/blob/master/lib/data-com-api/query_parameters.rb) which is useful only for the `include_graveyard` key

This method allows you to count contacts per company, the response has the following methods:
- `size` which returns `totalCount` from API response
- `url` which returns `url` from API response
- `levels` which returns an array of [DataComApi::CompanyContactCount::Level](https://github.com/Fire-Dragon-DoL/data-com-api/blob/master/lib/data-com-api/company_contact_count/level.rb)
- `departments` which returns an array of [DataComApi::CompanyContactCount::Departments](https://github.com/Fire-Dragon-DoL/data-com-api/blob/master/lib/data-com-api/company_contact_count/department.rb)

#### #contacts

The parameters accepted by this method are `contact_ids` (an array of `Fixnum`), `username`, `password`
which are required and the optional `purchase_flag` which defaults to `false`.

**Be careful, this method may purchase records.**  
This response has the following methods:
- `size` which returns `totalHits` from API response
- `used_points` which returns `pointsUsed` from API response
- `purchased_contacts` which returns `numberOfContactsPurchased` from API response
- `point_balance` which returns `pointBalance` from API response
- `contacts` which returns an array of [DataComApi::Contact](https://github.com/Fire-Dragon-DoL/data-com-api/blob/master/lib/data-com-api/contact.rb)

## TODO

- Implement `partner` request
- Implement `partner_contacts` request
- Implement `user` request used to purchase points through API
- Write some tests for `search_company` which is exactly the same as
  `search_contact`
- Improve tests organization
- Test exceptions when performing API requests

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
