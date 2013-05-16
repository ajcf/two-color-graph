#this is a class, which will hold each of the verticies in the graph.
class Vertex
  #color = red or blue, shade = white/grey/black, edges=adjacency list, 
  #parents=path from root node, id = index in nodes[]
  attr_accessor :shade, :color, :edges, :id, :parents
end
#this method is called to find odd loops when a conflict is detected.
def findloop(a, b)
  #the array of nodes in the odd loop
  loopnodes = []
  #traverses the first node's parents from node to root
  a.parents.reverse.each do |m|
    #stores that node m is in the loop between a and b
    loopnodes << m
    #traverses the second node's parents from node to root
    b.parents.reverse.each do |j|
      #checks if the intersection in the node's parent lists has been found
      if m == j
        #adds the nodes between common root and conflict node 1 to the return array
        loopnodes.concat(b.parents.slice(b.parents.index(j)+1, b.parents[-1]))
        #adds the first conflict node ot the return string
        retstr = "Odd loop occured at the following nodes: #{a.id}, "
        #adds to the return string each node within the loop, separated by ", "
        retstr  += loopnodes.join(", ")
        #adds the second conflict node to the string
        retstr += ", #{b.id}."
        return retstr
      end
    end
  end
end

def check(nodes)

  #initializes queue, which holds the list of nodes to look at. Starts with 1.
  queue = [nodes[1]]

  #red and blue have been converted to true and false for ease of computation. 
  #We arbitrarily make node 1 true.
  nodes[1].color = true

  #the shade can be 0 (white), 1 (grey), or 2 (black).  shades are initialized to 0,   #set to 1 when a node  is pushed into queue, and set to 2 when a node is popped.
  nodes[1].shade = 1

  #if queue is empty, there are no more nodes to check. 
  #We continue until this is the case.
  while !queue.empty?

    #ruby's array.shift is equivilent to queue.pop. 
    #This takes the first element out of the array, and moves the rest up 1.
    #we temporarily name the first node u.
    u = queue.shift

    #we now loop through each node which is connected to the current node, 
    #temporarily assigning each adjacent node to i.
    u.edges.each do |i|

      #i is an integer, so this line sets v = the node in the array at position i.
      v = nodes[i]

      #this checks to see if the current node is the same node as any of its edges.
      #if the other node is not colored, its color will be nil,
      #so it's not equal to either color.
      if(u.color == v.color)

        #if the colors are the same, then the graph is not two-colorable, 
        #and we print out a message with the nodes in the loop and return an error.
        puts findloop(u, v) 
        return false
      end
      #we check to see if the node we've been comparing to is white
      if v.shade == 0
        #the .uniq method prevents duplicate parents
        v.parents = u.parents.uniq
        #v's parents are the same as u's parents, plus u
        v.parents << u.id
        #if it is, we trun it grey, assign it a color which is opposite 
        #to the color of the current node, and put it in queue to evaluate it later.
        v.shade = 1
        v.color = !u.color
        queue << v
      end
    end
    #finally, we turn the current node black. 
    #Since the current node has already been looked at, this is unnecessary.
    u.shade = 2
  end
  #the graph would have already broken if it wasn't two-colorable.
  return true
end


######## START OF SCRIPT EXECUTION ####################

puts 'enter a filename: (if not in same directory, please enter a path) '
s = ''
#reads in the filename from the user
s = gets.chomp
#creates a file object with the given filename
file = File.new(s, 'r')
#checks the first line of the file to get the number of nodes of the graph. 
length = file.gets
#changes the length to an int so we can use it for looping.
length = length.to_i

#nodes is an empty array to hold G.V
nodes = []


#this loop initializes as many new nodes as are specified on line 1 of the file.
length.times do |t|
  #create a new node
  n = Vertex.new
  #set its id to the number node it is
  n.id = t+1
  #set its state to white
  n.shade = 0
  #set its color to neither true (red) nor false (blue)
  n.color = nil
  #declare an empty array for its adjacency list
  n.edges = []
  #declare an empty array to keep track of parents for help in finding odd loops
  n.parents = []
  #insert the new node into the array
  nodes[t+1] = n
end



#this loop reads each line of the file, splits it into comma-separated nodes,
#and then inserts each node into the other's adjacency array
lines = []
while a = file.gets
  x = a.split(',')
  nodes[x[0].to_i].edges << x[1].to_i
  nodes[x[1].to_i].edges << x[0].to_i
end

#runs the check() method above. if it returns true, prints out the coloring both 
#into a file and (if its short enough) to stdout.
if check(nodes)
  #ensures output will be in the current directory, regardless if input was.
  z = s.split('/').last
  #formats the name of the output file
  fname = z.chomp(".txt") + "_output.txt"
  open(fname, "w"){|f|
    (1..nodes.length).each do |m|
      n = nodes[m]
      #the first node is nil, which I guess means that this line is necessary.
      if !n.nil?
        #prints coloring to stdout     
        puts "Node #{n.id} is #{n.color ? 'red' : 'blue'}" unless length > 50
        #prints coloring to xxx_output.txt
        f.puts"Node #{n.id} is #{n.color ? 'red' : 'blue'}"
      end
    end
  }
  #prints final result: succcess!
  puts "Graph has been two-colored!"
  puts "see #{fname}."
else
  #prints final result: failure!
  puts "Graph could not be two-colored."
end  
