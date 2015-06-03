#!/usr/bin/env rake
require "rspec/core/rake_task"
require "gemfury/tasks"

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  RSpec::Core::RakeTask.new(:docs) do |t|
    t.rspec_opts = ["--format doc"]
  end
end

task :default => :spec

gemspec = Gem::Specification.load Dir["*.gemspec"].first

namespace :release do

  task :release do
    Rake::Task["fury:release"].invoke
    Rake::Task["release:tag"].invoke
  end

  task :tag do
    %x(git tag v#{gemspec.version} && git push --tag)
  end
end

desc "Release v#{gemspec.version} of #{gemspec.name}"
task :release => ["release:release"]
