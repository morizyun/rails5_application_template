# Rails5 application template

Rails5 Application Template. - [Rails Application Templates — Ruby on Rails Guides](http://guides.rubyonrails.org/rails_application_templates.html)

It's easy to start Rails5 application with useful gems.

## Preparation

### Upgrading ruby version in rbenv

Fill following commands:

```
# Update Homebrew
$ brew update

# Generate modern .gitignore
$ brew install wget gibo

# Update ruby-build
$ brew upgrade ruby-build

# Show some ruby versions which rbenv can install
$ rbenv install --list

# Install latest Ruby(e.g. 2.4.1)
$ rbenv install 2.4.1
```

### Install latest Rails gem

```
# Set to use rails latest version(e.g. 5.1)
$ gem install rails -v 5.1
```

## Execution command

Execute following commands:

```
# if you want to use PostgreSQL, please execute following command;
$ rails _5.1_ new test_app --database=postgresql -T --skip-bundle -m https://raw.githubusercontent.com/morizyun/rails5_application_template/master/app_template.rb

# if you want to use MySQL, please execute following command;
$ rails _5.1_ new test_app --database=mysql -T --skip-bundle -m https://raw.githubusercontent.com/morizyun/rails5_application_template/master/app_template.rb
```

## Detail explanation

Description of this template in Japanese is as follows;

**[Rails 5.0.0 + Bootstrap 1コマンドで！ - 酒と泪とRubyとRailsと](http://morizyun.github.io/blog/rails5-application-templates/)**

## Supported versions

- Ruby 2.4.1
- Rails 5.1

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
