class Node
  attr_accessor :key, :value, :forward

  def initialize(key, value, level)
    @key = key
    @value = value
    @forward = Array.new(level + 1, nil)  # Array of next nodes at each level
  end
end

class SkipList
  def initialize(max_level = 16, p = 0.5)
    @max_level = max_level
    @p = p
    @header = create_node(-Float::INFINITY, nil, @max_level)
    @level = 0
  end

  def insert(key, value)
    update = Array.new(@max_level + 1, nil)
    current = @header

    # Start from the highest level
    (@level).downto(0) do |i|
      # Move forward while there's a next node and its key is less than target
      while current.forward[i] && current.forward[i].key < key
        current = current.forward[i]
      end
      update[i] = current
    end

    # Now at level 0, check if key exists
    current = current.forward[0]

    if current && current.key == key
      current.value = value
    else
      new_level = random_level
      if new_level > @level
        ( @level + 1 .. new_level ).each { |i| update[i] = @header }
        @level = new_level
      end

      new_node = create_node(key, value, new_level)
      (0..new_level).each do |i|
        new_node.forward[i] = update[i].forward[i]
        update[i].forward[i] = new_node
      end
    end
  end

  def delete(key)
    current = @header
    prev = nil
    found = false

    (@level).downto(0) do |i|
      while current.forward[i] && current.forward[i].key < key
        prev = current
        current = current.forward[i]
      end

      if current.forward[i] && current.forward[i].key == key
        found = true
        prev = current
        current = current.forward[i]
        prev.forward[i] = current.forward[i]
      end
      current = @header
    end
    if found
      puts "Deleted #{key}."
    else
      puts "#{key} not found."
    end
  end

  def get(key)
    current = @header

    (@level).downto(0) do |i|
      while current.forward[i] && current.forward[i].key < key
        current = current.forward[i]
      end
    end

    current = current.forward[0]
    current && current.key == key ? current.value : nil
  end

  def create_node(key, value, level)
    Node.new(key, value, level)
  end

  def random_level
    level = 0
    level += 1 while rand < @p && level < @max_level
    level
  end

  def display
    (@level).downto(0) do |i|
      print "Level #{i}: "
      node = @header.forward[i]
      while node
        print "(#{node.key}: #{node.value}) -> "
        node = node.forward[i]
      end
      puts "NIL"
    end
  end
end

sl = SkipList.new

20.times do
  num = (rand * 100).to_i
  sl.insert(num, num.to_s) 
end

sl.display
puts "\n\n"

loop do
  print "Insert or Delete [i|d]: "
  opt = gets.chomp
  if opt == 'i'
    5.times do
      num = (rand * 100).to_i
      sl.insert(num, num.to_s) 
    end
    sl.display
    puts "\n\n"
  elsif opt == 'd'
    print "Enter number to delete: "
    num = gets.chomp.to_i
    sl.delete(num) 
    sl.display
    puts "\n\n"
  end
end
