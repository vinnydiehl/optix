def grayscale(v)
  { r: v, g: v, b: v }
end

WHITE = grayscale(255)
BLACK = grayscale(0)
RED = { r: 255, g: 0, b: 0 }
BLUE = { r: 0, g: 0, b: 255 }

BACKGROUND_COLOR = grayscale(63)
