# Slug

Slug provides simple, straightforward slugging for your ActiveRecord models.

Slug is based on code from Norman Clarke's fantastic [friendly_id](https://github.com/norman/friendly_id) project and Nick Zadrozny's [friendly_identifier](http://code.google.com/p/friendly-identifier/).

What's different:

* Unlike friendly_id's more advanced modes, slugs are stored directly in your model's table.  friendly_id stores its data in a separate sluggable table, which enables cool things like slug versioning—but forces yet another join when trying to do complex find_by_slugs.
* Like friendly_id, diacritics (accented characters) are stripped from slug strings.
* The number of options is manageable.

## Testing

Run the tests using:

```bash
bundle exec ruby -Ilib:test test/slug_test.rb
```

## Installation

Add the gem to your Gemfile of your Rails project.

```bash
gem 'slug'
```

This is tested with Rails 5.1.4, MRI Ruby 2.4.1

## Usage

### Creating the database column

It's up to you to set up the appropriate column in your model.  By default, slug saves the slug to a column called 'slug', so in most cases you'll just want to add

```ruby
add_column :my_table, :slug, :string
```

in a migration.  You should also add a unque index on the slug field in your migration

```ruby
add_index :model_name, :slug, unique: true
```

Though Slug uses `validates_uniqueness_of` to ensue the uniqueness of your slug, two concurrent INSERTs could try to set the same slug.

### Model setup

Once your table is migrated, just add

```ruby
slug :source_field
```

to your ActiveRecord model.  `:source_field` is the column you'd like to base the slug on.  For example, it might be `:headline`.

#### Using an instance method as the source column

The source column isn't limited to just database attributes—you can specify any instance method.  This is handy if you need special formatting on your source column before it's slugged, or if you want to base the slug on several attributes.

For example:

```ruby
class Article < ActiveRecord::Base
  slug :title_for_slug

  def title_for_slug
    "#{headline}-#{publication_date.year}-#{publication_date.month}"
  end
end
```

would use `headline-pub year-pub month` as the slug source.

From here, you can work with your slug as if it were a normal column.  `find_by_slug` and named scopes will work as they do for any other column.

### Options

There are two options:

#### Column

If you want to save the slug in a database column that isn't called
`slug`, just pass the `:column` option. For example:

```ruby
slug :headline, column: :web_slug
```

would generate a slug based on `headline` and save it to `web_slug`.

#### Generic Default

If the source column is empty, blank, or only contains filtered
characters, you can avoid `ActiveRecord::ValidationError` exceptions
by setting `generic_default: true`. For example:

```ruby
slug :headline, generic_default: true
```

will generate a slug based on your model name if the headline is blank.

This is useful if the source column (e.g. headline) is based on user-generated
input or can be blank (nil or empty).

Some prefer to get the exception in this case. Others want to get a good
slug and move on.

## Notes

* Slug validates presence and uniqueness of the slug column.  If you pass something that isn't sluggable as the source (for example, say you set the headline to '---'), a validation error will be set. To avoid this, use the `:generic_default` option.
* Slug doesn't update the slug if the source column changes.  If you really need to regenerate the slug, call `@model.set_slug` before save.
* If a slug already exists, Slug will automatically append a '-n' suffix to your slug to make it unique.  The second instance of a slug is '-1'.
* If you don't like the slug formatting or the accented character stripping doesn't work for you, it's easy to override Slug's formatting functions. Check the source for details.

## Authors

Ben Koski, ben.koski@gmail.com

With generous contributions from:

* [Derek Willis](http://thescoop.org/)
* [Douglas Lovell](https://github.com/wbreeze)
* [Paul Battley](https://github.com/threedaymonk)
* [Yura Omelchuk](https://github.com/jurgens)
* others listed in the
[GitHub contributor list](https://github.com/bkoski/slug/graphs/contributors).
