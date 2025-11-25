class Component
  attr_accessor :pos, :angle
  attr_reader :type

  def initialize(data)
    @pos = { x: data[:pos].x, y: data[:pos].y }
    @angle = data[:angle]
  end

  def hitbox
    {
      radius: COMPONENT_SIZE / 2,
      x: @pos.x, y: @pos.y,
    }
  end

  def movable?
    @movable
  end
end
