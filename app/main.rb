SCENES = %w[game].freeze

%w[absorbent compiler
   reflective].each { |f| require "app/optix/behaviors/#{f}_behavior.rb" }
%w[flat square].each { |f| require "app/optix/shapes/#{f}_shape.rb" }

%w[component
   combiner emitter filter mirror
   receiver splitter wall].each { |f| require "app/optix/components/#{f}.rb" }
%w[beam color].each { |f| require "app/optix/light/#{f}.rb" }

%w[constants colors optix
   geometry input].each { |f| require "app/optix/#{f}.rb" }

%w[scenes render].each { |dir| SCENES.each { |f| require "app/optix/#{dir}/#{f}.rb" } }

def tick(args)
  args.state.game ||= OptixGame.new(args)
  args.state.game.tick
end
