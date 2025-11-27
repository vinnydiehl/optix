class Splitter < Component
  include CompilerBehavior
  include SquareShape

  def initialize(data)
    super(data)
  end

  def compile
    if active?
      [@angle - 45, @angle + 45].map do |angle|
        Beam.new(
          start: @pos,
          angle: angle,
          color: color_sum,
          last_hit: self,
        )
      end
    end
  end

  def sprite
    {
      **rect,
      path: "sprites/triangle/gray.png",
    }
  end
end
