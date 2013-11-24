require 'zeus/rails'
ENV.delete('RAILS_ENV')

class CustomPlan < Zeus::Rails
  def coverage
    require 'simplecov'
    SimpleCov.start "rails"  do

      add_filter do |source_file|
        source_file.lines.count < 5
      end
    end

    # require all ruby files
    Dir["#{Rails.root}/app/**/*.rb"].each { |f| load f }

    # run the tests
    test
  end
end

Zeus.plan = CustomPlan.new