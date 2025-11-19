class Emitter
  def initialize(pos:, angle:, color:)
    @pos, @angle, @color = pos, angle, color
  end

  def beam
    Beam.new(start: @pos, angle: @angle, color: @color)
  end

  def sprite
    {
      x: @pos.x, y: @pos.y,
      w: COMPONENT_SIZE, h: COMPONENT_SIZE,
      angle: @angle,
      anchor_x: 0.5, anchor_y: 0.5,
      angle_anchor_x: 0.5, angle_anchor_y: 0.5,
      path: "sprites/circle/black.png",
    }
  end
end
