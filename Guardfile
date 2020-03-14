# frozen_string_literal: true

rspec_options = {
  cmd: "rspec",
  notification: false,
  failed_mode: :focus
}

guard "rspec", rspec_options do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/mudguard/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^lib/mudguard/(.+)\.rb$}) { |m| Dir.glob("spec/lib/#{m[1]}_*.rb") }
  watch("spec/spec_helper.rb") { "spec" }
end
