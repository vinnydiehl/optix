def grayscale(v)
  Color.new(r: v, g: v, b: v)
end

WHITE = grayscale(255)
BLACK = grayscale(0)

RED = Color.new(r: 255, g: 0, b: 0)
GREEN = Color.new(r: 0, g: 255, b: 0)
BLUE = Color.new(r: 0, g: 0, b: 255)

BACKGROUND_COLOR = grayscale(63)
