module Aqua
  
  require 'al3d'
  require 'matrix'
  include Math
  
  # Module constants
  X = 0; Y = 1; Z = 2
  Salmon=0; Shark=1; Food=2; Bubble=3; Egg=4
  SalmonSpeed = 0.0005; FoodSpeed = 0.0005; BubbleSpeed = 0.01; EggSpeed = 0.001
  Food_Spawn_Chance = 0.025; Bubble_Spawn_Chance = 0.16
  
  # Salmon specific parameters
  Idle = 0; Pursuing = 1; Escaping = 2; Mating = 3; Dead = 4; Turning = 5; Avoiding = 6
  Male = 0; Female = 1
  ReadyForAction = 200
  Adolescence = 3000; OldAge = 6000; MaxAge = 7000
  MaxHealth=10000; MaxAttractiveness=MaxResilience=10.0; MaxVirility=1000
  HealthFromFood = 600
  MaxDirectionChangeFactor=10.0
  RejectionThreshold = 10
  DefaultSpeed = 0.001; DefaultWorldVision = 0.05
  DefaultFoodPerception = 0.2; DefaultMatePerception = 0.2
  DefaultChangeFactor = 10
  MaxBabiesFromEgg = 4; EggHatchChance = 0.003; EggNestHeight = -0.96
  DecomposeChance = 0.00003; FishDeathbed = 0.99; DeadFishFloatSpeed = 0.0002
  FoodHeight = -0.98; FoodDissapearChance = 0.01; BubbleHeight = 0.98; BubbleDissapearChance = 0.0001
  EatingAndMatingRange = 0.05

  # Movement
  # Turns
  Left = 0; Right = 1
  Turn_X1_Factor = 0.2; Turn_X2_Factor = 0.3; Turn_Z_Factor = 0.2
  # U-Turns
  SharpRight = 2; WideRight = 3
  SharpLeft = 4; WideLeft = 5
  Sharp_Z1_Factor = 0.05; Sharp_Z2_Factor = 0.05 ; Sharp_X_Factor = 0.15
  Wide_Z1_Factor = 0.15; Wide_Z2_Factor = 0.15; Wide_X_Factor = 0.2
  # Spirals
  SpiralLeftUp = 6; SpiralRightUp = 7
  SpiralLeftDown = 8; SpiralRightDown = 9
  
  Spiral_X1_Factor = 0.1; Spiral_X2_Factor = 0.2; Spiral_X3_Factor = 0.1; Spiral_X4_Factor = 0.1
  Spiral_Y1_Factor = 0.05; Spiral_Y2_Factor = 0.125; Spiral_Y3_Factor = 0.2; Spiral_Y4_Factor = 0.15
  Spiral_Z1_Factor = 0.05; Spiral_Z2_Factor = 0.15; Spiral_Z3_Factor = 0.25; Spiral_Z4_Factor = 0.2
  
  # Dodges
  DodgeLeft = 10; DodgeRight = 11; DodgeUp = 12; DodgeDown = 13
  
  
  ## ===========================================================================
  ### Instances of this class represent a quantity that has a magnitude and a
  ### direction.
  class Vector < GLIT::Vec
    include Comparable
    
    ## Instantiate and return a new Aqua::Vector. Defaults to a 3rd order zero
    ## vector if no arguments are given
    def initialize(a =[0.0, 0.0, 0.0])
      super(a)
    end
    
    ### Return the 'x' element of the Vector
    def x; self[X]; end
    
    ### Return the 'y' element of the Vecotr
    def y; self[Y]; end
    
    ### Return the 'z' element of the Vector
    def z; self[Z]; end
    
    ### Return a reflection vector based on the formula 
    ### <tt>R= 2*(-I dot N)*N + I</tt>
    def reflection
      i = self.copy
      n = self.normalized
      r = ( 2 * ((i*(-1.0)).dot(n)) * (n) ) + ( n )
      r = Vector.new(r.a)
    end
    
    def normalized
      Vector.new(super.normalized.a)
    end
    
    def rotate(theta,x=true,y=true,z=true)
      rads = toRadians(theta)
      rotation_x = Matrix[
        [1.0,0,1.0,0],
        [0,Math::cos(rads), Math::sin(rads)*-1, 0],
        [0,Math::sin(rads), Math::cos(rads), 0],
        [0,0,0,1.0]
      ]
      rotation_y = Matrix[
        [Math::cos(rads), 0, Math::sin(rads), 0],
        [0,1.0,0,0],
        [Math::sin(rads)*-1, 0, Math::cos(rads), 0],
        [0,0,0,1.0]
      ]
      rotation_z = Matrix[
        [Math::cos(rads), Math::sin(rads)*-1, 0, 0],
        [Math::sin(rads), Math::cos(rads), 0, 0],
        [0,0,1.0,0],
        [0,0,0,1.0]
      ]
      
      rotation_matrix = rotation_x if x
      if y
        if rotation_matrix == nil
          rotation_matrix = rotation_y
        else 
          rotation_matrix *= rotation_y
        end
      end
      if z
        if rotation_matrix == nil
          rotation_matrix = rotation_z
        else 
          rotation_matrix *= rotation_z
        end 
      end
      vector = Matrix[
        [self[X]],
        [self[Y]],
        [self[Z]],
        [1]
      ]
      a = (rotation_matrix * vector).to_a
      Vector.new([a[X][0],a[Y][0],a[Z][0]])
    end
    
    def toRadians(theta)
      theta * Math::PI/180
    end
    
    def toDegrees(rads)
      rads * 180/Math::PI
    end
    
    def angle
      toDegrees(Math.atan(length(self)))
    end
    
    def angleBetween(v)
      len = length(self)*length(v)
      val = self.dot(v)/len
      unless len == 0 or val.abs > 1
        toDegrees(Math.acos(self.dot(v)/len))
      else
        0
      end
    end
    
    def length(v)
      Math.sqrt(self[X]**2+self[Y]**2+self[Z]**2)
    end
    
  end
  
  
  ## ===========================================================================
  ## Instances of this class represent a 3D position in space
  class Position < Vector
    
    Origin = new([0,0,0])
    
    def initialize(a=Origin)
      super(a)
    end
    
    def distance(other=Origin)
      raise TypeError, "no implicit conversion from %s to %s" %
      [other.class.name, self.class.name] unless
      other.is_a?(Position)
      return Math::sqrt( 
       (self.x - other.x)**2 +	(self.y - other.y)**2 +	(self.z - other.z)** 2)
    end
    
    def to_s
      "<Position> x,y,z: (#{self.x},#{self.y},#{self.z})"
    end
    
  end
  
  ## ===========================================================================
  ## Instances of this class represent a vivarium that us used to represent
  ## an aquarium
  class Aquarium
    
    attr_reader :fish, :eggs, :dead_fish, :food, :bubbles, :width, :height, :depth
    
    # Initializes the Aquarium
    def initialize(fish=nil)
      @fish = fish || []
      @food = []
      @bubbles = []
      @eggs = []
      @dead_fish = []
      @width, @height, @depth = 1.95, 0.95, 0.95
    end
    
    
    def aqua_objects
      @fish + @eggs + @dead_fish + @food + @bubbles
    end
    
    
    # this should have randomness to it, will do that later
    def spawn_fish(n=20)
      for i in 0..n-1
        type = Aqua::Salmon
        srand
        sex = rand(2) == 0 ? Aqua::Male : Aqua::Female
        fish_desc = {
          'type'              =>  type,
          'sex'               =>  sex,
          'speed'             =>  Aqua::DefaultSpeed, # the following 3 can be lumped into one constant
          'world_perception'  =>  Aqua::DefaultWorldVision,
          'food_perception'   =>  Aqua::DefaultFoodPerception,
          'mate_perception'   =>  Aqua::DefaultMatePerception,
          'position'          =>  Aqua::Position.new([randomFloatSigned, 0, randomFloatSigned]),
          'direction_change_factor' => Aqua::DefaultChangeFactor
        };
        self << Aqua::SalmonObject.new(fish_desc)
      end
    end
    
    
    # Return true if the fish is within the 'safe range' in the aquarium
    def check_walls(fish)
      rtn = false
      rangeStates = {}
      if fish.direction.x > 0
        rangeStates['xp'] = true if fish.position.x+0.04+fish.direction.x*0.2 >= @width
      else
        rangeStates['xn'] = true if fish.position.x+0.04+fish.direction.x*0.2 <= -@width
      end
      if fish.direction.y > 0
        rangeStates['yp'] = true if fish.position.y+0.04+fish.direction.y*0.2 >= @height
      else        
        rangeStates['yn'] = true if fish.position.y+0.04+fish.direction.y*0.2 <= -@height
      end
      if fish.direction.z > 0
        rangeStates['zp'] = true if fish.position.z+0.04+fish.direction.z*0.2 >= @depth
      else
        rangeStates['zn'] = true if fish.position.z+0.04+fish.direction.z*0.2 <= -@depth
      end 
      if (rangeStates['xp'] or rangeStates['yp'] or rangeStates['zp'] or
        rangeStates['xn'] or rangeStates['yn'] or rangeStates['zn'])
        rtn = true
        if fish.turn_path == nil
          turn_type = nil                
          if rangeStates['xp'] and rangeStates['zp'] or rangeStates['xn'] and rangeStates['zp']
            turn_type = SharpRight
            if rangeStates['yp']
              SpiralRightUp 
            elsif rangeStates['yn']
              SpiralRightDown
            end
          elsif rangeStates['xn'] and rangeStates['zn'] or rangeStates['xp'] and rangeStates['zn']
            turn_type = SharpLeft
            if rangeStates['yp']
              SpiralLeftUp 
            elsif rangeStates['yn']
              SpiralLeftDown
            end
          else
            turn_type = SpiralLeftDown
          end
          fish.setup_turn(Avoiding,turn_type)
        end
      end
      rtn
    end
    
    # Return true if a given position is within the aquarium
    def in_aquarium?(position, range)
      position.x.abs+range.abs < @width.abs and
      position.y.abs+range.abs < @height.abs and
      position.z.abs+range.abs < @depth
    end
    
    
    # Return true if the fish is within the 'safe range' in the aquarium
    def in_aquarium_range?(fish)
      in_aquarium?(fish.position, fish.world_perception)
    end
    
    
    def to_s
      "Fish: "+@fish.join(', ')
    end
    
    
    # Add AquariumObject instances to the aquarium. The object can be in an
    # or just by themselves
    def <<(stuff)
      if stuff.respond_to?(:to_ary)
        stuff.each do |thing|
          @fish << thing if thing.is_a?(SalmonObject)
          @food << thing if thing.is_a?(FishFood)
          @bubbles << thing if thing.is_a?(BubbleObject)
          @eggs << thing if thing.is_a?(EggObject)
        end
      else
        @fish << stuff if stuff.is_a?(SalmonObject)
        @food << stuff if stuff.is_a?(FishFood)
        @bubbles << stuff if stuff.is_a?(BubbleObject)
        @eggs << stuff if stuff.is_a?(EggObject)
      end
    end
    
    
    # Find all the AqariumObjects around the position within the given range
    def objects_around(position, r=0.000002)
      objects = {}
      xc, yc, zc = position.x, position.y, position.z
      foods = @food.find_all do |food|
        xn, yn, zn = food.position.x, food.position.y, food.position.z
        x, y, z = xn-xc, yn-yc, zn-zc
        (x*x)+(y*y)+(z*z)-(r*r) < 0
      end
      @fish.compact!
      fish = @fish.find_all do |fish|
        xn, yn, zn = fish.position.x, fish.position.y, fish.position.z
        x, y, z = xn-xc, yn-yc, zn-zc
        (x*x)+(y*y)+(z*z)-(r*r) < 0
      end
      objects['food'], objects['fish'] = foods, fish
    end
    
    
    # Find all the food around a given position within the given range
    def food_around(position, range=100)
      objects_around(position, range)[0]
    end
    
    
    # Find all the salmon around a given position within the given range
    def salmon_around(position, range=10)
     (objects_around(position, range)[1]).find_all {|fish| fish.type == Salmon}
    end
    
    
    # Find all the female salmon around a given position within the given range
    def mate_around(position, range=10)
      salmon_around(position, range).find_all {|salmon| salmon.sex == Female}
    end
    
    
    # Drop a food piece into the aquarium
    def add_food
      srand
      self << FishFood.new(Position.new([randomFloatSigned*2,1,randomFloatSigned]))
    end
    
    
    # Make a bubble float up the aquarium
    def add_bubble
      srand
      self << BubbleObject.new(Position.new([randomFloatSigned*2,-1.0,randomFloatSigned]))
    end
    
    
    # Update the state of the world
    def update_world
      update_fish
      update_eggs
      update_food
      update_bubbles
    end
    
    
    # Update the status of each fish in the aquarium, taking into account status 
    # and other Aquarium objects like food, predators/prey, and mates
    def update_fish
      @dead_fish.each do |dead_fish|
        if dead_fish.position.y >= FishDeathbed and rand<=DecomposeChance
          puts "decomposed!!"
          @dead_fish.delete(dead_fish)
          @dead_fish.compact!
        elsif dead_fish.position.y <= FishDeathbed
          dead_fish.move
        end
      end
      @fish.each do |fish|
        case fish.status
        when Idle || Turning
          unless check_walls(fish)
            look_for_food(fish)
            look_for_mate(fish) unless (fish.target or fish.sex==Female or fish.virility<200)
          end
        when Avoiding
        when Pursuing
          case fish.target
          when FishFood
            look_for_food(fish)
          when SalmonObject
            look_for_mate(fish)
          when Shark
          end
        when Dead
          @fish.delete(fish) 
          @fish.compact!
          @dead_fish << fish
          return
        end
        fish.move
      end
    end
    
    
    # Floats the eggs down the aquarium
    def update_eggs
      @eggs.each do |egg|
        if egg.position.y <= EggNestHeight and rand<EggHatchChance
          self << egg.hatch
          @eggs.delete(egg)
          @eggs.compact!
        elsif egg.position.y > EggNestHeight
          egg.move
        end
      end
    end
    
    # Floats the food down through the aquarium
    def update_food
      @food.each do |food|
        if food.position.y <= FoodHeight and rand<FoodDissapearChance
          @food.delete(food)
          @food.compact!
        else
          food.move
        end
      end
      # randomly add food
      add_food if rand <= Food_Spawn_Chance
    end
    
    
    # Bubbles float up the aquarium
    def update_bubbles
      @bubbles.each do |bubble|
        if bubble.position.y >= BubbleHeight or rand<BubbleDissapearChance
          @bubbles.delete(bubble)
          @bubbles.compact!
        else
          bubble.move
        end
      end
      add_bubble if rand <= Bubble_Spawn_Chance
    end
    
    
    # Look for food in the hunting range specified
    def look_for_food(fish)
      fish.stop_turn
      food_range = fish.food_perception
      food = food_around(fish.position, food_range)
      if food.size > 0 && !(fish.status==Escaping)
        food_found = food[0]
        if fish.position.distance(food_found.position) <= EatingAndMatingRange
          fish.consume(food_found)
          @food.delete(food_found)
          @food.compact!
        else
          fish.spot_food(food_found)
        end
      end
    end
    
    
    # Look for a mate in the mating range specified
    def look_for_mate(fish)
      fish.stop_turn
      mate_range = fish.mate_perception
      mate = mate_around(fish.position, mate_range)
      if mate.size > 0 && !(fish.status==Escaping)
        mate_found = mate[0]
        if (fish.position.distance(mate_found.position) <= EatingAndMatingRange) and 
           (fish.virility >= ReadyForAction) and 
           (mate_found.sex==Female)
          if fish.court(mate_found)==true
            egg = fish.mate(mate_found)
            self << egg
          end
        else
          fish.spot_mate(mate_found) unless fish.virility < ReadyForAction
        end
      end
    end
    
    
  end
  
  
  ## ===========================================================================
  ## Instances of this class represent arbitrary objects in the Aquarium world
  ## that have a position (location), and a type (food, salmon, shark)
  class AquariumObject
    attr_accessor :position, :type, :speed
    def initlaize(position, type)
      @position, @type = position, type
    end
  end
  
  
  ## ===========================================================================
  # we can put a bunch of stuff in here, discuss later
  class FishAquariumObject < AquariumObject
    
    attr_accessor :type, :sex, :speed, :maneuvarability, :rejections, :virility, :attractiveness, :behaviour, :health, :position, :target,
    :world_perception, :food_perception, :predator_perception, :mate_perception, :direction, :up_vector, :z_vector, :curve, :status, :turn_path
    
    def initialize(params)
      rand
      @type = params['type']
      @sex = params['sex']
      @speed = params['speed'] || DefaultSpeed
      @behaviour = params['behaviour']
      @age = params['age'] || Adolescence
      @maneuvarability = params['maneuvarability']
      @health = params['health'] || MaxHealth
      @attractiveness = params['attractiveness'] || MaxAttractiveness/2
      @resilience = params['resilience'] || MaxResilience/2
      @virility = params['virility'] || MaxVirility
      @rejections = 0
      @world_perception = params['world_perception']
      @food_perception = params['food_perception'] || DefaultFoodPerception
      @mate_perception = params['mate_perception'] || DefaultMatePerception
      @position = params['position']
      @next_move = nil
      @turn_path = nil
      @move_counter = 0
      @mate_count, @birth_count = 0, 0
      @direction_change_factor = params['direction_change_factor'] || MaxDirectionChangeFactor/2.0
      @target = nil
      @status = Idle
      @direction = Vector.new([rand,rand,rand]).normalized
      @up_vector= Vector.new([0.0,1.0,0.0]).normalized
      @z_vector = Vector.new(@direction.cross(@up_vector).a).normalized
      @behaviour = SalmonBehaviour.new(self)
      @@bezier = BezierUtility.create
    end
    
    def stop_turn
      @direction[Y] = 0
      @up_vector[X] = 0
      @up_vector[Y] = 1
      @up_vector[Z] = 0
      @z_vector = Vector.new(@up_vector.cross(@direction).a).normalized      
      @status = Idle
      @target = nil
      @turn_path = nil
    end
    
    
    def setup_turn(state,path)
      @status = state
      set_turn_path(path)
      @turnCounter = 0.0
    end
    
    def set_turn_path(type)
      @z_vector = Vector.new(@up_vector.cross(@direction).a)
      @turn_path = [
        [0,0,0],
        [@position[X],@position[Y],@position[Z]]
      ]
      case type
      when Left
        point1 = @position + @direction * Turn_X1_Factor
        point2 = @position - @z_vector * Turn_Z_Factor + @direction * Turn_X2_Factor
        @turn_path << [point1[X],point1[Y],point1[Z]]
        @turn_path << [point2[X],point2[Y],point2[Z]]
      when Right
        point1 = @position + @direction * Turn_X1_Factor
        point2 = @position - @z_vector * Turn_Z_Factor + @direction * Turn_X2_Factor
        @turn_path << [point1[X],point1[Y],point1[Z]]
        @turn_path << [point2[X],point2[Y],point2[Z]]
      when SharpLeft
        point1 = @position - @z_vector * Sharp_Z1_Factor  + @direction * Sharp_X_Factor 
        point2 = @position - @z_vector * Sharp_Z2_Factor 
        @turn_path << [point1[X],point1[Y],point1[Z]]
        @turn_path << [point2[X],point2[Y],point2[Z]]
      when WideLeft
        point1 = @position + @z_vector * Wide_Z1_Factor  + @direction * Wide_X_Factor 
        point2 = @position + @z_vector * Wide_Z2_Factor 
        @turn_path << [point1[X],point1[Y],point1[Z]]
        @turn_path << [point2[X],point2[Y],point2[Z]]
      when SharpRight
        point1 = @position + @z_vector * Sharp_Z1_Factor  + @direction * Sharp_X_Factor 
        point2 = @position + @z_vector * Sharp_Z2_Factor 
        @turn_path << [point1[X],point1[Y],point1[Z]]
        @turn_path << [point2[X],point2[Y],point2[Z]]
      when WideRight
        point1 = @position + @z_vector * Wide_Z1_Factor  + @direction * Wide_X_Factor 
        point2 = @position + @z_vector * Wide_Z2_Factor 
        @turn_path << [point1[X],point1[Y],point1[Z]]
        @turn_path << [point2[X],point2[Y],point2[Z]]
      when SpiralLeftUp
        point1 = @position + @direction * Spiral_X1_Factor + @up_vector * Spiral_Y1_Factor - @z_vector * Spiral_Z1_Factor
        point2 = @position + @direction * Spiral_X2_Factor + @up_vector * Spiral_Y2_Factor - @z_vector * Spiral_Z2_Factor
        point3 = @position + @direction * Spiral_X3_Factor + @up_vector * Spiral_Y3_Factor - @z_vector * Spiral_Z3_Factor
        point4 = @position - @direction * Spiral_X4_Factor + @up_vector * Spiral_Y4_Factor - @z_vector * Spiral_Z4_Factor
        @turn_path << [point1[X],point1[Y],point1[Z]]
        @turn_path << [point2[X],point2[Y],point2[Z]]
        @turn_path << [point3[X],point3[Y],point3[Z]]
        @turn_path << [point4[X],point4[Y],point4[Z]]
      when SpiralLeftDown
        point1 = @position + @direction * Spiral_X1_Factor - @up_vector * Spiral_Y1_Factor - @z_vector * Spiral_Z1_Factor
        point2 = @position + @direction * Spiral_X2_Factor - @up_vector * Spiral_Y2_Factor - @z_vector * Spiral_Z2_Factor
        point3 = @position + @direction * Spiral_X3_Factor - @up_vector * Spiral_Y3_Factor - @z_vector * Spiral_Z3_Factor
        point4 = @position - @direction * Spiral_X4_Factor - @up_vector * Spiral_Y4_Factor - @z_vector * Spiral_Z4_Factor
        @turn_path << [point1[X],point1[Y],point1[Z]]
        @turn_path << [point2[X],point2[Y],point2[Z]]
        @turn_path << [point3[X],point3[Y],point3[Z]]
        @turn_path << [point4[X],point4[Y],point4[Z]]
      when SpiralRightUp
        point1 = @position + @direction * Spiral_X1_Factor + @up_vector * Spiral_Y1_Factor + @z_vector * Spiral_Z1_Factor
        point2 = @position + @direction * Spiral_X2_Factor + @up_vector * Spiral_Y2_Factor + @z_vector * Spiral_Z2_Factor
        point3 = @position + @direction * Spiral_X3_Factor + @up_vector * Spiral_Y3_Factor + @z_vector * Spiral_Z3_Factor
        point4 = @position - @direction * Spiral_X4_Factor + @up_vector * Spiral_Y4_Factor + @z_vector * Spiral_Z4_Factor
        @turn_path << [point1[X],point1[Y],point1[Z]]
        @turn_path << [point2[X],point2[Y],point2[Z]]
        @turn_path << [point3[X],point3[Y],point3[Z]]
        @turn_path << [point4[X],point4[Y],point4[Z]]
      when SpiralRightDown
        point1 = @position + @direction * Spiral_X1_Factor - @up_vector * Spiral_Y1_Factor + @z_vector * Spiral_Z1_Factor
        point2 = @position + @direction * Spiral_X2_Factor - @up_vector * Spiral_Y2_Factor + @z_vector * Spiral_Z2_Factor
        point3 = @position + @direction * Spiral_X3_Factor - @up_vector * Spiral_Y3_Factor + @z_vector * Spiral_Z3_Factor
        point4 = @position - @direction * Spiral_X4_Factor - @up_vector * Spiral_Y4_Factor + @z_vector * Spiral_Z4_Factor
        @turn_path << [point1[X],point1[Y],point1[Z]]
        @turn_path << [point2[X],point2[Y],point2[Z]]
        @turn_path << [point3[X],point3[Y],point3[Z]]
        @turn_path << [point4[X],point4[Y],point4[Z]]        
      end
      
      @curve = []
      i=0
      c=0
      while i<1+1.0/10.0
        @curve[c] = @@bezier.bezier(@turn_path,i)
        i += 1.0/10.0
        c += 1
      end
    end   
  
  end
  
  ## ===========================================================================
  ## Instances of this class represent a salmon in the Aquarium world
  class SalmonObject < FishAquariumObject
    
    
    # Consume the food, and increase health. 
    # Do fish live to eat, or eat to live??
    def consume(food)
      @health = (@health>=(MaxHealth-HealthFromFood)) ? MaxHealth : @health+HealthFromFood
      @status = Idle
      @target = nil
    end
    
    
    # Attempt to woo a female fish
    def court(mate)
      response = false
      if @sex == Male and mate.sex == Female
        response = mate.response_to(self)
        @rejections = (response==true) ? 0 : @rejections+=1
        # self esteem takes a dive if you get rejected too often
        @virility = 0 if @rejections >= RejectionThreshold
      end
      response
    end
    
    
    # Return a response to a courting male
    def response_to(mate)
      acceptance = false
      if @sex == Female and mate.sex == Male
        reaction = rand
        acceptance = (reaction <= mate.attractiveness/1000.0)
      end
      acceptance
      true
    end
    
    
    # What you see on the Discovery Channel
    def mate(mate)
      @mate_count += 1
      @status = Idle
      @target = nil
      @virility = 0
      return mate.lay_egg
    end
    
    
    # Lay an egg (which will eventually hatch)
    def lay_egg
      egg = nil
      if @sex == Female
        @birth_count +=1
        egg = EggObject.new(Position.new([@position.x, @position.y, @position.z]))
      end
      egg
    end
    
    
    # Take a move based on position, interaction with other objects, and state
    # The basic formula for movement is below, and is affected by the factors 
    # listed above:
    #     position = position + speed*direction  (vector math)
    def move
      case @status
      when Dead
        @position += @direction * DeadFishFloatSpeed
      when Idle
        coin = rand(1000.0)
        if coin <= (@direction_change_factor/1000)
          turn = rand(10)
          setup_turn(Turning,turn)
        else
          @position += @direction * @speed
        end
      when Avoiding
        self.turn
      when Turning 
        self.turn
      when Pursuing
        speed = 
          case @target.type
          when Food
            5*@speed
          when Salmon
            2*@speed
          when Shark
            4*@speed
          end
        @position += @direction * speed
      end
      @position = Position.new(@position.a)
      # update the state of the fish:
      @virility += (@virility >= 9999) ? 1 : 0 
      health_to_subtract = (rand>(@resilience/10.0)) ? 1 : 0
      @health -= health_to_subtract
      @age += (rand<0.2) ? 1 : 0
      self.die if @health<=0 or @age >= MaxAge
    end
    
    
    # Die! and float to the top of the tank like all good dead fish that make 
    # their mothers proud do
    def die
      self.stop_turn
      @status = Dead
      @direction = Vector.new([0.0,1.0,0.0]).normalized
    end
    
    
    # Execute a turn
    def turn
      if @turnCounter < 1.0+1.0*@speed
        lastPosition = @position
        @position = Position.new(@@bezier.bezier(@turn_path, @turnCounter))
        # recalculate direction
        @direction = Vector.new((@position - lastPosition)).normalized unless lastPosition.a == @position.a
        #get z vector
        @z_vector = Vector.new(@up_vector.cross(@direction))
        # recalculate up vector
        @up_vector = Vector.new(@direction.cross(@z_vector))
        @turnCounter += 1.0*@speed
      else
        @position += @direction * @speed
        stop_turn
      end
    end
    
    
    def move_towards(object)
      distance = object.position-self.position
      turnDirection = (object.position-self.position).normalized
      @direction = Vector.new(turnDirection)
    end
    
    def move_away_from(objet)
      turn = (self.position-object.position).normalized
      @direction = Vector.new(turn)
    end
    
    def spot_food(food)
      @behaviour.spot_food(food)
    end
    
    def spot_mate(mate)
      @behaviour.spot_mate(mate)
    end
    
    def spot_predator(predator)
      @behaviour.spot_predator(predator)
    end
    
    def state=(state)
      @state = state
    end
    
    def to_s
      "type #{@type}, position #{@position}, health #{@health}, sex #{@sex}, status #{@status}"
    end
    
  end
  
  
  ## ===========================================================================
  ## Instances of this class represent food in the Aquarium world
  class FishFood < AquariumObject
    attr_accessor :position, :speed
    def initialize(position)
      @position = position
      @type = Food
      srand
      @speed = FoodSpeed * rand
      @direction = Vector.new([0,-1,0]).normalized
    end
    
    def move
      @position += @direction * @speed
      @position = Position.new(@position.a)
    end
    
    def to_s
      "food: location#{@position}"
    end
  end
  
  
  ## ===========================================================================
  ## Instances of this class represent a bubble in the Aquarium world
  class BubbleObject < AquariumObject
    attr_accessor :position, :speed
    def initialize(position)
      @position = position
      @type = Bubble
      srand
      @speed = BubbleSpeed * rand
      @direction = Vector.new([0,1,0]).normalized
    end
    def move
      @position += @direction * @speed
      @position = Position.new(@position.a)
    end
  end
  
  
  ## ===========================================================================
  ## Insances of this class represent an unhatched egg
  class EggObject < AquariumObject
    attr_accessor :position, :speed
    
    # Create an egg at a given initial position
    def initialize(position)
      @position = position
      @type = Egg
      srand
      @speed = EggSpeed
      @direction = Vector.new([0,-1,0]).normalized
    end
    
    # Move the egg
    def move
      @position += @direction * @speed
      @position = Position.new(@position.a)
    end
    
    # Hatch the egg creating 0-MaxBabiesFromEgg baby salmon
    def hatch
      @status = Idle
      @target = nil
      @virility = 0
      babies = []
      rand(MaxBabiesFromEgg).to_i.times {babies << baby_salmon}
      babies
    end
    
    # Baby salmon template
    def baby_salmon
      child_desc = {
        'type'              =>  Aqua::Salmon,
        'sex'               =>  rand(2) == 0 ? Aqua::Male : Aqua::Female,
        'speed'             =>  0.001,
        'virility'          =>  0,
        'age'               =>  0,
        'world_perception'  =>  0.05,
        'predator_perception'=> 0.005,
        'food_perception'   => 0.2,
        'mate_perception'   => 0.2,
        'position'          =>  Aqua::Position.new([@position.x, @position.y, @position.z]),
        'direction_change_factor' => 10
      }
      child = SalmonObject.new(child_desc)
    end
    
  end
  
  
  ## ===========================================================================
  ## Instances of this class encapsulate the behaviour of Fish by defining their
  ## interaction with other objects in the Aquarium world
  class Behaviour
    def spot_food(food); end
    def spot_predator(predator); end
    def spot_mate(mate); end
    def spot_wall(wall); end
  end
  
  
  ## ===========================================================================
  ## Instances of this class encapsulate the bahviour of Salmon in the Aquarium
  ## world
  class SalmonBehaviour < Behaviour
    
    # Set the fish to which this behaviour will apply to
    def initialize(fish)
      @fish = fish
    end
    
    
    # When spotting food, move towards it
    def spot_food(food)
      @fish.direction = @fish.move_towards(food)
      @fish.status = Pursuing
      @fish.target = food
    end
    
    # Move towards potential mates
    def spot_mate(mate)
      @fish.direction = @fish.move_towards(mate)
      @fish.status = Pursuing
      @fish.target = mate
    end
    
    # Move away from walls
    def spot_wall(wall)
      @fish.move_away_from(wall)
    end
    
  end
  
  
  ## ===========================================================================
  # this is mostly the same as: http://www.scs.ryerson.ca/~tmcinern/Courses/bezier.c
  # ported to Ruby by Matt Rossner
  class BezierUtility
    
    private_class_method :new
    
    @@utility = nil
    
    def BezierUtility.create
      @@utility = new unless @@utility
      @@utility
    end
    
    def bezier(ctrlPoints, t) 
      t = 1.0 if (1.0-t) < 5e-6
      point = [0.0,0.0,0.0]
      for i in 1..ctrlPoints.length - 1
        basis = getBasis(ctrlPoints.length-2, i-1, t)
        point[X] += basis * ctrlPoints[i][X]
        point[Y] += basis * ctrlPoints[i][Y]
        point[Z] += basis * ctrlPoints[i][Z]
      end
      point
    end
    
    def ni(n,i)
      fact(n)/(fact(i)*fact(n-i))
    end
    
    def getBasis(n,i,t)
      ti = (t==0 && i == 0) ? 1.0 : t**i
      tni = (n==i && t==1) ? 1.0 : (1.0-t) ** (n-i)
      ni(n,i)*ti*tni
    end
    
    def fact(n)
      ntop = 6
      a = [1.0,1.0,2.0,6.0,24.0,120.0,720.0]
      j1 = 0
      while ntop < n
        j1 = ntop
        ntop += 1
        a[n] = a[j1]*ntop
      end
      a[n]
    end
    
  end
  
end

def randomFloatSigned
  num = rand
  rand(2) == 0 ? num : num*-1
end  

def randomFloatSigned3v
  srand
  [randomFloatSigned,randomFloatSigned,randomFloatSigned]
end  
