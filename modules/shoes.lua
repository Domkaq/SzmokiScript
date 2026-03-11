-- Shoe system module

local Shoes = {}

function Shoes.new(name, size, color)
    return { name = name, size = size, color = color }
end

function Shoes.printDetails(shoe)
    print(string.format("Shoe Name: %s, Size: %d, Color: %s", shoe.name, shoe.size, shoe.color))
end

return Shoes