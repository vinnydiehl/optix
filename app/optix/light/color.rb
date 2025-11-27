class Color
  attr_reader :r, :g, :b

  def initialize(r: r, g: g, b: b)
    @r = clamp(r)
    @g = clamp(g)
    @b = clamp(b)
  end

  # Additive mixing
  def +(other)
    Color.new(r: @r + other.r, g: @g + other.g, b: @b + other.b)
  end

  # Scale intensity
  def *(scalar)
    Color.new(r: @r * scalar, g: @g * scalar, b: @b * scalar)
  end

  def ==(other)
    @r == other.r && @g == other.g && @b == other.b
  end

  def filter(other)
    Color.new(
      r: [@r, other.r].min,
      g: [@g, other.g].min,
      b: [@b, other.b].min,
    )
  end

  def to_h
    { r: @r, g: @g, b: @b }
  end

  private

  def clamp(value)
    value.clamp(0, 255)
  end
end
