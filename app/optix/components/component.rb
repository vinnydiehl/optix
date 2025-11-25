class Component
  attr_accessor :pos, :angle

  def initialize(data)
    @pos = { x: data[:pos].x, y: data[:pos].y }
    @angle = data[:angle]
  end
end
