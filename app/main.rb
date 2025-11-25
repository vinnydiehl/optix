SCENES = %w[game].freeze

%w[constants colors optix
   input].each { |f| require "app/optix/#{f}.rb" }

%w[reflective_behavior].each { |f| require "app/optix/behaviors/#{f}.rb" }
%w[component optical_object
   emitter mirror].each { |f| require "app/optix/components/#{f}.rb" }
%w[beam].each { |f| require "app/optix/light/#{f}.rb" }

%w[scenes render].each { |dir| SCENES.each { |f| require "app/optix/#{dir}/#{f}.rb" } }

def tick(args)
  args.state.game ||= OptixGame.new(args)
  args.state.game.tick
end
