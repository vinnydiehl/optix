class Color
  attr_reader :r, :g, :b

  def initialize(r: r, g: g, b: b)
    @r = clamp(r)
    @g = clamp(g)
    @b = clamp(b)
  end

  # Additive mixing
  def +(other)
    Color.new(@r + other.r, @g + other.g, @b + other.b)
  end

  # Scale intensity
  def *(scalar)
    Color.new(@r * scalar, @g * scalar, @b * scalar)
  end

  def ==(other)
    @r == other.r && @g == other.g && @b == other.b
  end

  def to_h
    { r: @r, g: @g, b: @b }
  end

  private

  def clamp(value)
    value.clamp(0, 255)
  end
end
