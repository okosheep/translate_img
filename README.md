# TranslateImg

## Installation

You will need to install cairo first.

On a Mac, you can use `brew install cairo` to install it.

Add this line to your application's Gemfile:

```ruby
gem 'translate_img_cli'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install translate_img_cli

## Usage

    $ translate_img_cli -i, --src-file-path=SRC_FILE_PATH -o, --dest-file-path=DEST_FILE_PATH

Translate the text in the file specified by SRC_FILE_PATH and write it to the file specified by DEST_FILE_PATH.

### Options

- -i, --src-file-path=SRC_FILE_PATH
  - Specify a input file path.
- -o, --dest-file-path=DEST_FILE_PATH
  - Specify a output file path.
- -l, [--source-language-code=SOURCE_LANGUAGE_CODE]
  - Specify a source language code. Default: en
- -t, [--target-language-code=TARGET_LANGUAGE_CODE]
  - Specify a target language code. Default: ja 


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
