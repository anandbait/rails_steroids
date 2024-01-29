---
        ____        _ __        _____ __                  _     __
       / __ \____ _(_) /____   / ___// /____  _________  (_)___/ /____
      / /_/ / __ `/ / / ___/   \__ \/ __/ _ \/ ___/ __ \/ / __  / ___/
     / _, _/ /_/ / / (__  )   ___/ / /_/  __/ /  / /_/ / / /_/ (__  )
    /_/ |_|\__,_/_/_/____/   /____/\__/\___/_/   \____/_/\__,_/____/

---

# RailsSteroids

Any small idea evolves when it actually starts taking shape. But most of the time, when we think of developing an idea as a POC or hobby project, we end up spending more time in setting up the project and lose the momentum. And you must have realised that many tasks that we do with a new project from scratch are quite repetitive. 

Rails templates and other templating gems are a way of quickly generating an application but when it comes to adding some features in an already generated application then we need some way to do that. We have certain inbuilt generators which can be used for basic components but they need more coding over it.

So here are steroids for your application, which are actually generators with special powers. This gem contains different steroids which will setup commonly used features very quickly and reduce your coding work so that you can focus on your precious idea.

## Installation

You can add this line to your application's Gemfile:
```
gem 'rails_steroids', group: :development
```
And then execute:
```
bundle install
```
Or the best way is to install the gem by executing:
```
gem install rails_steroids
```

## Usage

You can use the gem from command line using gem's CLI.
You can inject the steroid into your application using command like:
```
rails_steroids inject steroid:STEROID_NAME
```

You can check the list of available steroids using command:
```
rails_steroids list
```

## Available Steroids

| Functionality | Command |
|---|---|

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### How to develop a new steroid?

The gem comes with a handy tool to scaffold a new steroid.
You can run `bin/rails_steroids prepare STEROID_NAME`
This will create a new directory `STEROID_NAME` inside `lib/generators/steroid` containing empty `templates` directory, a `STEROID_NAME_generator.rb` and a `USAGE` file.
It will also make an entry into `README.md` and array in list method. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports, feature requests and pull requests are welcome on GitHub at https://github.com/anandbait/rails_steroids. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/anandbait/rails_steroids/blob/main/CODE_OF_CONDUCT.md).

## Changelog

RailsSteroids is evolving with the time and awesome contributions. You can find the evolution changelog [here](https://github.com/anandbait/rails_steroids/blob/main/CHANGELOG.md)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RailsSteroids project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/anandbait/rails_steroids/blob/main/CODE_OF_CONDUCT.md).
