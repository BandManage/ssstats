FROM ruby
# NOTE includes bundler already

RUN mkdir -p /ssstats
WORKDIR /ssstats

ADD Gemfile .
ADD ssstats.gemspec .
ADD lib/ssstats/version.rb ./lib/ssstats/version.rb
ADD Gemfile.lock .
# TODO --deployment or something
RUN bundle install

ADD . .

ENTRYPOINT ["bundle", "exec"]
CMD ["rspec"]
