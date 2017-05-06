require 'bundler'

# .gitignore
run 'gibo OSX Ruby Rails JetBrains SASS SublimeText > .gitignore' rescue nil
gsub_file '.gitignore', /^config\/initializers\/secret_token\.rb$/, ''
gsub_file '.gitignore', /^config\/secrets\.yml$/, ''

# Ruby Version
ruby_version = `ruby -v`.scan(/\d\.\d\.\d/).flatten.first
insert_into_file 'Gemfile',%(
ruby '#{ruby_version}'
), after: "source 'https://rubygems.org'"
run "echo '#{ruby_version}' > ./.ruby-version"

# add to Gemfile
append_file 'Gemfile', <<-CODE
# ============================
# Controller
# ============================
# Controller action arguments parameterizer
gem 'action_args'

# ============================
# View
# ============================
# Bootstrap & Bootswatch & font-awesome
gem 'bootstrap-sass'
gem 'bootswatch-rails'
gem 'font-awesome-rails'

# Fast Haml
gem 'faml'

# Form Builders
gem 'simple_form'

# Pagenation
gem 'kaminari'

# ============================
# Utils
# ============================
# Process Management
gem 'foreman'

# Presenter Layer Helper
gem 'cells'
gem 'cells-haml'

# Configuration using ENV
gem 'dotenv-rails'

# ============================
# Environment Group
# ============================
group :development do
  gem 'erb2haml'

  # help to kill N+1
  gem 'bullet'

  # To generate haml view by scaffold or other generate command
  gem 'haml-rails'

  # Syntax Checker
  # hook event pre-commit, pre-push
  gem 'overcommit', require: false

  # A static analysis security vulnerability scanner
  gem 'brakeman', require: false

  # Checks for vulnerable versions of gems
  gem 'bundler-audit', require: false

  # Style checker that helps keep CoffeeScript code clean and consistent
  gem 'coffeelint', require: false

  # Syntax checker for HAML
  gem 'haml-lint', require: false

  # Syntax checker for CSS
  gem 'ruby_css_lint', require: false

  # A Ruby static code analyzer
  gem 'rubocop', require: false
end

group :development, :test do
  # Pry & extensions
  gem 'pry-rails'
  gem 'pry-byebug'

  # Show SQL result in Pry console
  gem 'hirb'
  gem 'awesome_print'

  # PG/MySQL Log Formatter
  gem 'rails-flog'

  # Rspec
  gem 'rspec-rails'

  # test fixture
  gem 'factory_girl_rails'

  # Handle events on file modifications
  gem 'guard-rspec',      require: false
  gem 'guard-rubocop',    require: false
  gem 'guard-livereload', require: false
end

group :test do
  # Mock for HTTP requests
  gem 'webmock'
  gem 'vcr'

  # Time Mock
  gem 'timecop'

  # Support to generate Test Data
  gem 'faker'

  # Cleaning test data
  gem 'database_rewinder'

  # This gem brings back assigns to your controller tests
  gem 'rails-controller-testing'
end
CODE

Bundler.with_clean_env do
  run 'bundle install --path vendor/bundle --jobs=4 --without production'
end

# set config/application.rb
application  do
  %q{
    # Set timezone
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # Set locale
    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja

    # Set generator
    config.generators do |g|
      g.orm :active_record
      g.template_engine :haml
      g.test_framework :rspec, :fixture => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
      g.view_specs false
      g.controller_specs true
      g.routing_specs false
      g.helper_specs false
      g.request_specs false
      g.assets false
      g.helper false
    end
  }
end

# For Bullet (N+1 Problem)
insert_into_file 'config/environments/development.rb', %(
  # Bullet Setting (help to kill N + 1 query)
  config.after_initialize do
    Bullet.enable = true # enable Bullet gem, otherwise do nothing
    Bullet.alert = true # pop up a JavaScript alert in the browser
    Bullet.console = true #  log warnings to your browser's console.log
    Bullet.rails_logger = true #  add warnings directly to the Rails log
  end
), after: 'config.assets.debug = true'

# Improve security
insert_into_file 'config/environments/production.rb',%q{

  # Sanitizing parameter
  config.filter_parameters += [/(password|private_token|api_endpoint)/i]
}, after: 'config.active_record.dump_schema_after_migration = false'

# set Japanese locale
get 'https://raw.githubusercontent.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml', 'config/locales/ja.yml'

# erb => haml
Bundler.with_clean_env do
  run 'bundle exec rake haml:replace_erbs'
end

# Bootstrap/Bootswach/Font-Awesome
run 'rm -rf app/assets/stylesheets/application.css'
get 'https://raw.github.com/morizyun/rails5_application_template/master/app/assets/stylesheets/application.css.scss', 'app/assets/stylesheets/application.css.scss'

# Initialize SimpleForm
Bundler.with_clean_env do
  run 'bundle exec rails g simple_form:install --bootstrap'
end

# Initialize Kaminari config
Bundler.with_clean_env do
  run 'bundle exec rails g kaminari:config'
end

# Initialize dotenv config
run 'touch .env'
run 'touch .env.development'
run 'touch .env.test'
run "echo '\n.env\n.env*' >> .gitignore"

# Puma(App Server)
run 'rm -rf config/puma.rb'
get 'https://raw.github.com/morizyun/rails5_application_template/master/config/puma.rb', 'config/puma.rb'

# Procfile
run "echo 'web: bundle exec puma -C config/puma.rb' > Procfile"

# Error Notification
# ----------------------------------------------------------------
if yes?('Do you use Airbrake/Errbit? [yes or ELSE]')
  insert_into_file 'Gemfile',%q{

# Exception Catcher
gem 'airbrake'
}, after: "gem 'foreman'"

  run 'wget https://raw.github.com/morizyun/rails5_application_template/tree/master/config/initializers/airbrake.rb -P config/initializers'
  run "echo '\nAIRBRAKE_HOST=\nAIRBRAKE_PROJECT_ID=\nAIRBRAKE_PROJECT_KEY=\n'"
  run "echo 'Please Set AIRBRAKE_HOST, AIRBRAKE_PROJECT_ID, AIRBRAKE_PROJECT_KEY in your environment variables'"

  run 'bundle install --path vendor/bundle --jobs=4 --without production'
end

# Rspec
# ----------------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle exec rails g rspec:install'
end

run "echo '--color -f d' > .rspec"

insert_into_file 'spec/rails_helper.rb',%(
  config.order = 'random'

  config.before :suite do
    DatabaseRewinder.clean_all
  end

  config.after :each do
    DatabaseRewinder.clean
  end

  config.before :all do
    FactoryGirl.reload
    FactoryGirl.factories.clear
    FactoryGirl.sequences.clear
    FactoryGirl.find_definitions
  end

  config.include FactoryGirl::Syntax::Methods

  VCR.configure do |c|
      c.cassette_library_dir = 'spec/vcr'
      c.hook_into :webmock
      c.allow_http_connections_when_no_cassette = true
  end

  [:controller, :view, :request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, :type => type
    config.include ::Rails::Controller::Testing::TemplateAssertions, :type => type
    config.include ::Rails::Controller::Testing::Integration, :type => type
  end
  config.include Cell::Testing, type: :cell
), after: 'RSpec.configure do |config|'

insert_into_file 'spec/rails_helper.rb', "\nrequire 'factory_girl_rails'", after: "require 'rspec/rails'"
run 'rm -rf test'

# Checker
# ----------------------------------------------------------------
get 'https://raw.github.com/morizyun/rails5_application_template/master/root/.rubocop.yml', '.rubocop.yml'
get 'https://raw.github.com/morizyun/rails5_application_template/master/root/.overcommit.yml', '.overcommit.yml'
get 'https://raw.github.com/morizyun/rails5_application_template/master/root/.haml-lint.yml', '.haml-lint.yml'

# Rake DB Create
# ----------------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle exec rake db:create'
end

# Remove Invalid Files
run 'rm -rf ./lib/templates'

# Bundler-audit
# ----------------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle-audit update'
end

# Guard
# ----------------------------------------------------------------
if yes?('Do you use Guard? [yes or ELSE]')
  insert_into_file 'Gemfile',%q{

  # Handle events on file modifications
  gem 'guard-rspec',      require: false
  gem 'guard-rubocop',    require: false
  gem 'guard-livereload', require: false
}, after: "gem 'factory_girl_rails'"

  Bundler.with_clean_env do
    run 'bundle install --path vendor/bundle --jobs=4 --without production'
    run 'bundle exec guard init rspec rubocop livereload'
  end
end

# Wercker(CI)
# ----------------------------------------------------------------
if yes?('Do you use wercker? [yes or ELSE]')
  run 'wget https://raw.githubusercontent.com/morizyun/rails5_application_template/master/root/wercker.yml'
  gsub_file 'wercker.yml', /%RUBY_VERSION/, ruby_version
  run "echo 'Please Set SLACK_URL to https://app.wercker.com'"
end

# Rubocop Auto correct
# ----------------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle exec rubocop --auto-correct'
  run 'bundle exec rubocop --auto-gen-config'
end

# git init
# ----------------------------------------------------------------
git :init
git :add => '.'

# overcommit
# ----------------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle exec overcommit --sign'
end

# git commit
# ----------------------------------------------------------------
git :commit => "-a -m 'Initial commit'"
