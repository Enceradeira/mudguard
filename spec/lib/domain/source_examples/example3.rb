# frozen_string_literal: true
# Container for decoupling Infrastructure from Domain
class Container < ContainerBase
  configure do |config|
    config.root = Pathname(File.join(Rails.root, "app"))
  end
end

Dependency = Container.injector
