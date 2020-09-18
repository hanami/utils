# frozen_string_literal: true

require "rake"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |task|
    file_list = FileList["spec/**/*_spec.rb"]
    file_list = file_list.exclude("spec/{integration,isolation}/**/*_spec.rb")

    task.pattern = file_list
  end
end

namespace :codecov do
  desc "Uploads the latest simplecov result set to codecov.io"
  task :upload do
    if ENV["CI"]
      require "simplecov"
      require "codecov"

      formatter = SimpleCov::Formatter::Codecov.new
      formatter.format(SimpleCov::ResultMerger.merged_result)
    end
  end
end

task default: "spec:unit"
