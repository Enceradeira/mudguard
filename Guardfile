# frozen_string_literal: true

rspec_options = {
  cmd: "rspec",
  notification: false
}

guard "rspec", rspec_options do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$}) { |m| Dir.glob("spec/lib/#{m[1]}_*.rb") }
  watch(%r{^app/(.+)\.rb$}) { |m| Dir.glob("spec/app/#{m[1]}_*.rb") }
  watch("spec/spec_helper.rb") { "spec" }
end

