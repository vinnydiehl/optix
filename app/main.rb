SCENES = %w[game].freeze

%w[constants colors optix].each { |f| require "app/optix/#{f}.rb" }

%w[emitter].each { |f| require "app/optix/components/#{f}.rb" }
%w[beam].each { |f| require "app/optix/light/#{f}.rb" }

%w[scenes render].each { |dir| SCENES.each { |f| require "app/optix/#{dir}/#{f}.rb" } }

def tick(args)
  args.state.game ||= OptixGame.new(args)
  args.state.game.tick
end
