#!/usr/bin/env ruby
# Adds Flutter iOS flavor build configurations (Debug-dev, Release-prod, …).
# Idempotent: safe to run multiple times after `flutter create`.
require "xcodeproj"

FLAVORS = %w[dev prod].freeze
BASE_CONFIGS = %w[Debug Release Profile].freeze
XCCONFIG_BY_CONFIG = {
  "Debug-dev" => "Flutter/Debug-dev.xcconfig",
  "Release-dev" => "Flutter/Release-dev.xcconfig",
  "Profile-dev" => "Flutter/Profile-dev.xcconfig",
  "Debug-prod" => "Flutter/Debug-prod.xcconfig",
  "Release-prod" => "Flutter/Release-prod.xcconfig",
  "Profile-prod" => "Flutter/Profile-prod.xcconfig"
}.freeze

ios_dir = ARGV.fetch(0) { File.expand_path("../template/ios", __dir__) }
project_path = File.join(ios_dir, "Runner.xcodeproj")
abort("Missing #{project_path}") unless File.directory?(project_path)

project = Xcodeproj::Project.open(project_path)

def duplicate_config(project, list, base_name, new_name)
  return if list.build_configurations.any? { |c| c.name == new_name }

  base = list.build_configurations.find { |c| c.name == base_name }
  abort("Base configuration #{base_name} not found") unless base

  new_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
  new_config.name = new_name
  new_config.build_settings = base.build_settings.transform_values(&:dup)
  if base.base_configuration_reference
    new_config.base_configuration_reference = base.base_configuration_reference
  end
  list.build_configurations << new_config
  new_config
end

def attach_xcconfig(project, config, relative_path)
  file_ref = project.files.find { |f| f.path == relative_path }
  unless file_ref
    group = project.main_group["Flutter"] || project.main_group
    file_ref = group.new_file(relative_path)
  end
  config.base_configuration_reference = file_ref
end

# Project-level configurations
BASE_CONFIGS.each do |base|
  FLAVORS.each do |flavor|
    duplicate_config(project, project.build_configuration_list, base, "#{base}-#{flavor}")
  end
end

# Target-level configurations (Runner + RunnerTests)
project.targets.each do |target|
  BASE_CONFIGS.each do |base|
    FLAVORS.each do |flavor|
      new_name = "#{base}-#{flavor}"
      duplicate_config(project, target.build_configuration_list, base, new_name)
      next unless target.name == "Runner"

      config = target.build_configurations.find { |c| c.name == new_name }
      path = XCCONFIG_BY_CONFIG[new_name]
      attach_xcconfig(project, config, path) if config && path
    end
  end
end

project.save
puts "iOS flavor build configurations ready."
