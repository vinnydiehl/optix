SCENES = %w[game].freeze

%w[constants colors optix].each { |f| require "app/optix/#{f}.rb" }

%w[scenes render].each { |dir| SCENES.each { |f| require "app/optix/#{dir}/#{f}.rb" } }

def tick(args)
  args.state.game ||= OptixGame.new(args)
  args.state.game.tick
end
