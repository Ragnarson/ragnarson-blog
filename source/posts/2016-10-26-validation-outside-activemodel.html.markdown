---
title: Validation outside ActiveModel
author: wafcio
cover_photo: cover.jpg
---

On the latest Euruko Ruby Conference (Bulgaria, Sofia, 2016) I had a lightning talk about a different approach to data verification. Today, I want to share and explain more of the good stuff in validation.

In a Ruby on Rails application, we use validation mostly for models:

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

or forms:

```ruby
class UserForm
  include ActiveModel::Model

  attr_accessor :name

  validates :name, presence: true
end
```

There are cases when the application isn't saving data in any database, nor is any data received from a form on a web page, but we still need to perform validations. One example could be sending SMS - before we do it, we need to make sure we're sending correct data.

```ruby
class UserContact
  include ActiveModel::Validations

  attr_accessor :name, :phone_number, :message

  validates :name, presence: true
  validates :phone_number, numericality: { only_integer: true }
  validates :message, presence: true
end

contact = UserContact.new
contact.name = "John Doe"
contact.phone_number = 123456789
contact.valid? # => false
contact.errors # => { message: ["can't be blank"] }
```

## Validating without Rails

For one of our clients, we have decided to build a single page application with API without using Ruby on Rails. This approach allowed us to decrease response time from API. We used Roda for routing, ROM (Ruby Object Mapper) as an access layer to the database and dry-validation for validation.

ROM is a small layer between a database adapter and application. ROM doesn't have validation layer. We used dry-validation gem which provides a lot of fancy validation rules.

Dry-validation is designed to validate any data stored in a hash. It forces us to focus on input data more carefully when validating model attributes. On the other hand, it makes us more aware of the input data.

## Invoking a validation

Validation in dry-validation gem looks a bit different than model oriented validation.

```ruby
input_data = {
  name: "John Doe",
  phone_number: 123456789
}

UserContactSchema = Dry::Validation.Schema do
  required(:name) { filled? }
  required(:phone_number) { filled? & nil? }
end

result = UserContactSchema.call(input_data)
result.success? # => true
result.failure? # => false
result.errors # => { message: ["must be filled"] }
```

In dry-validation, we can also write

```ruby
required(:name).filled
```

which is equal to

```ruby
required(:name) { filled? }
```

## Optional key and value

In models, we predefine attributes in class implementation. We make sure that object will have a filled attribute or an attribute with nil value. In a hash, we have a little more complicated situation, a key can be set or not. Firstly, take a look on hash without name key:

```ruby
{
  age: 30
}
```

Let's write validation rules:

```ruby
Dry::Validation.Schema do
  required(:age) { filled? & int? & gt?(18) }
end
```

Now, we will extend hash with name key:

```ruby
{
  name: "John Doe",
  age: 30
}
```

New validation schema should handle optional key:

```ruby
Dry::Validation.Schema do
  optional(:name) { filled? }
  required(:age) { filled? & int? & gt?(18) }
end
```

Sometimes, when data is sent from the outside world it can contain nil value. For example, someone uses a model-based framework and the application sends keys without values.

```ruby
{
  name: "John Doe",
  age: nil
}
```

When we decide to allow nil value for some attributes we must handle it in schema:

```ruby
Dry::Validation.Schema do
  optional(:name} { filled? }
  required(:age) { none? | (filled? & int? & gt?(18)) }
end
```

## Nested data

Let's go back to our user's contact hash:

```ruby
input_data = {
  name: "John Doe",
  phone_number: 123456789
}
```

We can assume that data will be sending to API in JSON API standard. In this case, the params will look like this:

```ruby
{
  data: {
    attributes: {
      name: "John Doe",
      phone_number: 123456789
    }
  }
}
```

Schema with attributes nested in hash isn't so complicated:

```ruby
Dry::Validation.Schema do
  require(:data).schema do
    require(:attributes).schema do
      optional(:name) { filled? }
      required(:phone_number) { filled? & int? }
    end
  end
end
```

Next great thing is validating an array:

```ruby
input_data = {
  data: {
    attributes: {
      name: "John Doe",
      phone_number: 123456789,
      emails: ["foobar@example.com", "foobar"]
    }
  }
}
```

And validation schema:

```ruby
schema = Dry::Validation.Schema do
  require(:data).schema do
    require(:attributes).schema do
      optional(:name) { filled? }
      required(:phone_number) { filled? & int? }
      optional(:emails).each(:email?)
    end
  end
end

puts schema.call(input_data).message
# {
#   emails: {
#     1 => ["must be valid email address"]
#   }
# }
```

NOTICE: In the example above can you see :email? symbol. This symbol will invoke email? predicate which isn't available in dry-validation. Don’t worry I will show you how to implement your own predicate in the next post. Subscribe to our newsletter and wait for next part.

## Shared schemas

Sometimes we repeat the same data structure like an address on an invoice, customer address and delivery address. With dry-validation, we can create validation for address and attach it many times.

```ruby
data = {
  customer_address: {
    street: "Main Street",
    city: "New York"
  },
  delivery_address: {
    street: "Brodway"
  }
}
```

We can define only one schema:

```ruby
AddressSchema = Dry::Validation.Schema do
  required(:street).filled
  required(:city).filled
end
```

with already prepared schema we can use it twice:

```ruby
invoice_schema = InvoiceSchema = Dry::Validation.Schema do
  required(:customer_address).schema(AddressSchema)
  required(:delivery_address).schema(AddressSchema)
end
```

Let's check how it will behave:

```ruby
data = {
  customer_address: {
    street: "Main Street",
    city: "New York"
  },
  delivery_address: {
    street: "Brodway"
  }
}

puts invoice_schema.call(data).messages
# {
#   delivery_address: {
#     city: ["is missing"]
#   }
# }
```

If you don't use ActiveRecord/ActiveModel/Ruby on Rails or you need to verify something different than a class with attributes, you should try dry-validation.
