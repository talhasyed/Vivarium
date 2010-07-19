require 'rubygems'
require 'opengl'
require 'glut'
require 'AquaLib'

# Constants

#debug stuff
DebugStill = false

# Window stuff
WINDOW_WIDTH=1000; WINDOW_HEIGHT=500
WINDOW_TITLE='Vivarium'

# GLUPerspective stuff
PERSPECTIVE_ANGLE=45.0; PERSPECTIVE_NEAR=0.1; PERSPECTIVE_FAR=10
ASPECT_RATIO=WINDOW_WIDTH/WINDOW_HEIGHT

# Vivarium stuff (this will be the rectanlge
VIVARIUM_WIDTH=2.0; VIVARIUM_HEIGHT=1.0; VIVARIUM_DEPTH=1.0

# Lighting stuff
LIGHT_DIFFUSE = [1.0,1.0,1.0,1.0]
LIGHT_POSITIONS = [
  [ -1, 1.0, -0.5, 0.0 ],
  [ 1, 1.0, 0.5, 0.0 ],
  [ 0.0, 1.0, 0.0, 0.0 ]
]

# Material stuff
# Note: we'll get some better colors and stuff to choose from here later
SPECULAR = 0; DIFFUSE = 1; AMBIENCE = 2; SHININESS = 3

FloorImage = []
$TexName = []

# File.open("tex.bmp", "rb").each_byte {|ch| FloorImage << ch }
#FloorImage = 
#for i in (0..256-1)
#  for j in (0..256-1)
#     if ((i&0x8==0)!=(j&0x8==0)) then tmp = 1; else tmp=0; end
     #c = ((((i&0x8)==0)^((j&0x8))==0))*255;
#     c = tmp * 255;
#     FloorImage[i*256*4+j*4+0] = c;
#     FloorImage[i*256*4+j*4+1] = c;
#     FloorImage[i*256*4+j*4+2] = c;
#     FloorImage[i*256*4+j*4+3] = 255;
     #c = ((((i&0x10)==0)^((j&0x10))==0))*255;
#     if ((i&0x10==0)!=(j&0x10==0)) then tmp = 1; else tmp=0; end
#     c = tmp * 255;
#  end
#end

MATERIAL = {
  'walls' => [
    [ 0.2, 0.2, 0.2, 1.0 ],
    [ 0.4, 0.4, 0.8, 0.5 ],
    [ 0.5, 0.5, 0.8, 0.3 ],
    [ 200.0 ]
  ], 'male_salmon' => [
    [ 1.0, 1.0, 1.0, 0.5 ],
    [ 0.121, 0.121, 0.317, 0.5 ],
    [ 0.121, 0.121, 0.317, 1.0 ],
    [ 10.0 ]
  ], 'female_salmon' => [
    [ 1.0, 1.0, 1.0, 0.5 ],
    [ 0.85, 0.5, 0.82, 0.5 ],
    [ 0.85, 0.5, 0.79, 1.0 ],
    [ 10.0 ]
  ], 'old_salmon' => [
    [ 1.0, 0.7, 0.7, 0.5 ],
    [ 0.54, 0.54, 0.09, 0.5 ],
    [ 0.54, 0.54, 0.09, 1.0 ],
    [ 0.0 ]
  ], 'sick_fish' => [
    [ 1.0, 0.7, 0.7, 0.5 ],
    [ 0.54, 0.54, 0.09, 0.5 ],
    [ 0.54, 0.54, 0.09, 1.0 ],
    [ 100.0 ]
  ], 'eyes' => [
    [ 1.0, 1.0, 1.0, 0.5 ],
    [ 0.0, 0.5, 0.0, 0.5 ],
    [ 0.0, 0.5, 0.0, 1.0 ],
    [ 10.0 ]
  ], 'mouth' => [
    [ 1.0, 1.0, 1.0, 0.5 ],
    [ 1.0, 1.0, 1.0, 0.5 ],
    [ 1.0, 1.0, 1.0, 1.0 ],
    [ 10.0 ]
  ], 'egg' => [
    [ 0.9, 0.9, 0.7, 1.0 ],
    [ 0.9, 0.9, 0.7, 1.0 ],
    [ 0.9, 0.9, 0.7, 0.2 ],
    [ 200.0 ]
  ],'food' => [
    [ 1.0, 0.7, 0.4, 1.0 ],
    [ 0.9, 0.2, 0.2, 1.0 ],
    [ 0.9, 0.5, 0.3, 0.2 ],
    [ 20.0 ]
  ], 'bubble' => [
    [ 1.0, 0.7, 0.4, 1.0 ],
    [ 0.9, 0.7, 0.7, 1.0 ],
    [ 0.9, 0.8, 0.8, 0.2 ],
    [ 200.0 ]
  ], 'sky' => [
    [ 0.0, 0.75, 0.0, 1.0 ],
    [ 0.0, 0.8, 1.0, 1.0 ],
    [ 0.7, 0.7, 0.7, 1.0 ],
    [ 100.0]
  ], 'bounding_box' => [
    [ 1.0, 1.0, 1.0, 1.0 ],
    [ 1.0, 1.0, 1.0, 1.0 ],
    [ 1.0, 1.0, 1.0, 1.0 ],
    [ 10.0 ]  
  ]
}
# Fog stuff
FogColor = [0.05, 0.05, 0.12, 0.5]
FOG_START = 0.0; FOG_END=5.0


# Camera stuff

POSITION = 0 ; LOOKAT = 1; LOOKUP = 2

# WV == World view
WV_CAMERA_POSITION = {
  'front' =>[
    [0.0,1.4,3.9], #lookfrom
    [0.0,0.0,0.0], #lookat
    [0.0,1.0,0.0]  #cross
  ], 'top' => [
    [0.0,3.4,0.0],
    [0.0,0.0,0.0],
    [0.0,0.0,1.0]  
  ]  
}

FRONT=0; FIRST_PERSON=1; BEHIND_CAM=2; TOP=3
CAMERA_MODES = [FRONT, FIRST_PERSON, BEHIND_CAM, TOP]

CAMERA_FOLLOW_DISTANCE = 0.3
CAMERA_FOLLOW_UP = 0.1

# this shouldn't be here, it should come from the Aquarium class, fix later
TIMER = 5

# How much food initially spawn
InitialFood = 10

class Vivarium
  
  def initialize
    @aquarium = Aqua::Aquarium.new
    @aquarium.spawn_fish(10)
    @camera_mode = FRONT
    @fish_index = 0
    @firstPersonToggle = false
    @boxToggle = false
    @fogToggle = true
    #debug purposes
    @vToggle = false
    @bezier = Aqua::BezierUtility.create
    @tail_factor = 0
    @tail_increasing_mode = true
    @fin_factor = 0
    @fin_increasing_mode = true 
    srand
    glInit
  end
  
  def start
    GLUT::MainLoop()
  end
  
  
  def toggle(which)
    which ? false : true
  end
  
  # Easy way to set the camera  
  def set_camera(worldView)
    GLU::LookAt(worldView[POSITION][0], worldView[POSITION][1], worldView[POSITION][2], 
                worldView[LOOKAT][0], worldView[LOOKAT][1], worldView[LOOKAT][2], 
                worldView[LOOKUP][0], worldView[LOOKUP][1], worldView[LOOKUP][2])  
  end
  
  # Easy way to set material
  def set_material(material)
    GL::Material(GL::FRONT_AND_BACK, GL::AMBIENT, material[AMBIENCE])
    GL::Material(GL::FRONT_AND_BACK, GL::SPECULAR, material[SPECULAR])
    GL::Material(GL::FRONT_AND_BACK, GL::DIFFUSE, material[DIFFUSE])
    GL::Material(GL::FRONT_AND_BACK, GL::SHININESS, material[SHININESS])
    GL::Material(GL::FRONT, GL::EMISSION, [0.3, 0.3, 0.3, 0.7])
  end
  
  def bind_floor_texture
    GL.Enable(GL::TEXTURE_2D)
    GL.PixelStorei(GL::UNPACK_ALIGNMENT, 1)
    $TexName = GL.GenTextures(1)
    GL.BindTexture(GL::TEXTURE_2D, $TexName[0])
    GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER,GL::NEAREST)
    GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER,GL::NEAREST)
    GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA, 256,256,0, GL::RGBA, GL::UNSIGNED_BYTE,
                 FloorImage.pack("V*"))
  end
  
  
  def glInit
    
    display = Proc.new {
      @fogToggle ? GL.Enable(GL::FOG) : GL.Disable(GL::FOG)
      GL::Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
      GL::LoadIdentity()
      case @camera_mode
      when FRONT
        set_camera(WV_CAMERA_POSITION['front'])  
      when TOP
        set_camera(WV_CAMERA_POSITION['top'])  
      when FIRST_PERSON
        fp = @aquarium.fish[@fish_index]
        set_camera([fp.position.a, fp.direction.a, fp.up_vector.a])
        render_water
      when BEHIND_CAM
        bc = @aquarium.fish[@fish_index]
        set_camera([
                   [bc.position.x-bc.direction.x*CAMERA_FOLLOW_DISTANCE, bc.position.y-bc.direction.y*CAMERA_FOLLOW_DISTANCE+bc.up_vector.y*CAMERA_FOLLOW_UP, bc.position.y-bc.direction.z*CAMERA_FOLLOW_DISTANCE],
                   [bc.position.x, bc.position.y, bc.position.z],
                   [0,1,0]
                   ]
        )
        render_water
      end
      @aquarium.aqua_objects.each {|aqua_obj| render_object(aqua_obj)}
      #render_floor
      render_walls
      render_water
      GLUT::SwapBuffers()  
    }
    
    keyHandler = Proc.new {|key,x,y|
      case (key)
      when ?b
        @boxToggle = toggle(@boxToggle)
      when ?r
        @aquarium.fish[0].direction[0] += 0.1
      when ?F
        @fogToggle = toggle(@fogToggle)
      when ?f
        @aquarium.add_food
      when ?c
        @camera_mode += 1
        @camera_mode %= CAMERA_MODES.length
      when ?s
        @fish_index += 1
        @fish_index %= @aquarium.fish.length
      when ?g
        @aquarium.update_world
      when ?v
        @vToggle = toggle(@vToggle)
      when 27
        exit(0);
      end
      GLUT.PostRedisplay
    }
    
    update_world = Proc.new { |param|  
      @aquarium.update_world
      GLUT::PostRedisplay()
      GLUT::TimerFunc(10,update_world,0)
    }
    
    GLUT::Init()
    GLUT::InitDisplayMode(GLUT::DOUBLE | GLUT::RGB | GLUT::DEPTH)
    GLUT::InitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    GLUT::CreateWindow(WINDOW_TITLE)
    GLUT::DisplayFunc(display)
    GLUT::KeyboardFunc(keyHandler)
    
    # bind_floor_texture
    
    GL::Light(GL::LIGHT0, GL::DIFFUSE, LIGHT_DIFFUSE) 
    GL::Light(GL::LIGHT0, GL::POSITION, LIGHT_POSITIONS[0])
    GL::Light(GL::LIGHT1, GL::DIFFUSE, LIGHT_DIFFUSE) 
    GL::Light(GL::LIGHT1, GL::POSITION, LIGHT_POSITIONS[1])
    GL::Light(GL::LIGHT2, GL::DIFFUSE, LIGHT_DIFFUSE) 
    GL::Light(GL::LIGHT2, GL::POSITION, LIGHT_POSITIONS[2])
    
    # fog
    GL.Fog(GL::FOG_MODE, GL::LINEAR)
    GL.Hint(GL::FOG_HINT, GL::NICEST)
    GL.Fog(GL::FOG_START, FOG_START) # play with these
    GL.Fog(GL::FOG_END, FOG_END)
    GL.Fog(GL::FOG_COLOR, FogColor)
    GL.DepthFunc(GL::LESS)
    GL.Enable(GL::DEPTH_TEST)
    
    #lights
    GL::Enable(GL::LIGHTING)
    GL::Enable(GL::LIGHT0)
    GL::Enable(GL::LIGHT1)
    #    GL::Enable(GL::LIGHT2)    
    GL::Enable(GL::DEPTH_TEST)
    
    GL::MatrixMode(GL::PROJECTION)
    GLU::Perspective(PERSPECTIVE_ANGLE, ASPECT_RATIO, PERSPECTIVE_NEAR,  PERSPECTIVE_FAR)
    GL::MatrixMode(GL::MODELVIEW)
    
    GLUT::TimerFunc(10,update_world,0) unless DebugStill
  end
  
  
  def render_walls
    GL::PushMatrix()
    set_material(MATERIAL['walls'])
    GL.LineWidth(0.75)
    # FLL-FLR
    GL.Begin(GL::LINES)
      GL::Vertex(-2.0,-1.0,1.0)
      GL::Vertex(2.0,-1.0,1.0)
    GL.End
    #FLL-FUL
    GL.Begin(GL::LINES)
      GL::Vertex(-2.0,-1.0,1.0)
      GL::Vertex(-2.0,1.1,1.0)
    GL.End
    #FLR-FUR
    GL.Begin(GL::LINES)
      GL::Vertex(2.0,-1.0,1.0)
      GL::Vertex(2.0,1.1,1.0)
    GL.End
    #FUL-FUR
    GL.Begin(GL::LINES)
      GL::Vertex(-2.0,1.1,1.0)
      GL::Vertex(2.0,1.1,1.0)
    GL.End
    #FLR-BLR
    GL.Begin(GL::LINES)
      GL::Vertex(2.0,-1.0,1.0)
      GL::Vertex(2.0,-1.0,-1.0)
    GL.End
    #FUR-BUR
    GL.Begin(GL::LINES)
      GL::Vertex(2.0,1.1,1.0)
      GL::Vertex(2.0,1.1,-1.0)
    GL.End
    #BLR-BUR
    GL.Begin(GL::LINES)
      GL::Vertex(2.0,-1.0,-1.0)
      GL::Vertex(2.0,1.1,-1.0)
    GL.End
    #FUL-BUL
    GL.Begin(GL::LINES)
      GL::Vertex(-2.0,1.1,1.0)
      GL::Vertex(-2.0,1.1,-1.0)
    GL.End
    #BUL-BUR
    GL.Begin(GL::LINES)
      GL::Vertex(-2.0,1.1,-1.0)
      GL::Vertex(2.0,1.1,-1.0)
    GL.End
    #FLL-BLL
    GL.Begin(GL::LINES)
      GL::Vertex(-2.0,-1.0,1.0)
      GL::Vertex(-2.0,-1.0,-1.0)
    GL.End
    #BLL-BUL
    GL.Begin(GL::LINES)
      GL::Vertex(-2.0,-1.0,-1.0)
      GL::Vertex(-2.0,1.1,-1.0)
    GL.End
    #BLL-BLR
    GL.Begin(GL::LINES)
      GL::Vertex(-2.0,-1.0,-1.0)
      GL::Vertex(2.0,-1.0,-1.0)
    GL.End
    
    GL::End()
    GL::PopMatrix()  
  end
  
  
  # Draw a texture mapped floor for the aquarium
  def render_floor
   GL.PushMatrix()
     GL.BindTexture(GL::TEXTURE_2D, $TexName[0])
     GL.Begin(GL::QUADS)
     GL.TexCoord(0.0, 0.0); GL.Vertex(-2.0, -0.9, 1.0)
     GL.TexCoord(1.0, 0.0); GL.Vertex(2.0, -0.9, 1.0)
     GL.TexCoord(1.0, 1.0); GL.Vertex(2.0, -0.9, -1.0)
     GL.TexCoord(1.0, 1.0); GL.Vertex(-2.0, -0.9, -1.0)
     GL.End()
   GL.PopMatrix
  end
  
  
  # Render the aquarium water
  def render_water
    GL::PushMatrix()
      GL::Scale(4.0,2.0,2.0)
      GL::Material(GL::FRONT, GL::EMISSION, [ 0.1, 0.3, 0.3, 0.5 ])
      GL::Material(GL::FRONT, GL::DIFFUSE, [ 0.1, 0.8, 0.8, 0.5 ])
      GL::Enable(GL::BLEND)
      GL::DepthMask(GL::FALSE)
      GL::BlendFunc(GL::SRC_ALPHA, GL::ONE)
      GLUT::SolidCube(1.0)
      GL::DepthMask(GL::TRUE)
      GL::Disable(GL::BLEND)
    GL.PopMatrix
  end
  
  
  # Render an AquariumObject
  def render_object(object)
    case (object.type)
    when Aqua::Salmon
      render_salmon(object)
      draw_bounding_box(object) if @boxToggle
      draw_path(object) if @vToggle
    when Aqua::Egg
      render_egg(object)
    when Aqua::Food
      render_food(object)
    when Aqua::Bubble
      render_bubble(object)
    end
  end
  
  def render_salmon(salmon)
    if @tail_increasing_mode
      @tail_increasing_mode = false if @tail_factor > 5
      @tail_factor += 0.2
    else
      @tail_factor -= 0.2
      @tail_increasing_mode = true if @tail_factor < 0             
    end
    
    if @fin_increasing_mode
      @fin_increasing_mode = false if @fin_factor > 25
      @fin_factor += 1
    else
      @fin_factor -= 1
      @fin_increasing_mode = true if @fin_factor < 0             
    end
    
    # fish body
    GL.PushMatrix()
    material =  
    if salmon.health < 200
      MATERIAL['sick_fish']
    elsif salmon.sex == Aqua::Male
      MATERIAL['male_salmon']
    elsif salmon.sex == Aqua::Female
      MATERIAL['female_salmon']
    end
    set_material(material)
    GL.Translate(salmon.position.x,salmon.position.y,salmon.position.z)
    GLUT.SolidSphere(0.04, 11, 11)
    GL.PopMatrix
    
    qobj = GLU.NewQuadric
    
    # get rotation
    rotation = salmon.direction.angleBetween(Aqua::Vector.new([1,0,0]))
    rotation *= -1 if salmon.direction.x > 0

    # left fin
    position = [salmon.position.x+salmon.z_vector.x*0.04,
    salmon.position.y+salmon.z_vector.y*0.04,
    salmon.position.z+salmon.z_vector.z*0.04
    ]
    draw_fin(salmon,position,[rotation+22.5,0,-97.5+@fin_factor],qobj,0.03)
    
    # right fin
    position = [salmon.position.x-salmon.z_vector.x*0.04,
    salmon.position.y-salmon.z_vector.y*0.04,
    salmon.position.z-salmon.z_vector.z*0.04
    ]
    draw_fin(salmon,position,[rotation-22.5,0,97.5-@fin_factor],qobj,0.03)
    
    
    # Tail fins
    position = [salmon.position.x-salmon.direction.x*0.04,
    salmon.position.y-salmon.direction.y*0.04,
    salmon.position.z-salmon.direction.z*0.04]
    draw_fin(salmon,position,[rotation+@tail_factor+5,90,0],qobj,0.04)
    draw_fin(salmon,position,[rotation-(@tail_factor+5),90,0],qobj,0.04)
    
    #eyes
    eyeX = 0.025
    eyeY = 0.022
    eyeZ = 0.015
    
    
    #right eye
    GL::PushMatrix()
    set_material(MATERIAL['eyes'])
    right_eye_position = salmon.position + salmon.direction*eyeX + salmon.up_vector*eyeY + salmon.z_vector*eyeZ
    GL::Translate(right_eye_position[0],right_eye_position[1],right_eye_position[2])
    GLUT::SolidSphere(0.005, 11, 11)
    GL::PopMatrix()    
    #left eye
    GL::PushMatrix()
    set_material(MATERIAL['eyes'])
    right_eye_position = salmon.position + salmon.direction*eyeX + salmon.up_vector*eyeY - salmon.z_vector*eyeZ
    GL::Translate(right_eye_position[0],right_eye_position[1],right_eye_position[2])
    GLUT::SolidSphere(0.005, 11, 11)
    GL::PopMatrix()    
    
    #mouth
    GL::PushMatrix()
    set_material(MATERIAL['mouth'])
    GL::Translate(salmon.position.x+salmon.direction.x*0.04,
                  salmon.position.y+salmon.direction.y*0.04,
                  salmon.position.z+salmon.direction.z*0.04)
    GLUT::SolidSphere(0.005, 11, 11)
    GL::PopMatrix()   
  end
  
  def draw_fin(salmon,position,rotation,qobj,size)
    GL.PushMatrix
    GL.Translate(position[0], position[1], position[2])
    GL.Rotate(rotation[Aqua::X],0,1,0)
    GL.Rotate(rotation[Aqua::Y],0,0,1)
    GL.Rotate(rotation[Aqua::Z],1,0,0)        
    GLU.QuadricDrawStyle(qobj, GLU::FILL)
    GLU.QuadricNormals(qobj, GLU::SMOOTH)
    GLU.PartialDisk(qobj, 0, size, 15, 5, 0, 45)
    GL.PopMatrix
  end
  
  
  def render_egg(egg)
    GL::PushMatrix()
    set_material(MATERIAL['egg'])
    GL::Translate(egg.position.x,egg.position.y,egg.position.z)
    GLUT::SolidSphere(0.025, 100, 100)
    GL::PopMatrix()
  end
  
  def render_food(food)
    GL::PushMatrix()
    set_material(MATERIAL['food'])
    GL::Translate(food.position.x,food.position.y,food.position.z)
    GLUT::SolidSphere(0.01, 5, 5)
    GL::PopMatrix()
  end
  
  def render_bubble(bubble)
    GL::PushMatrix()
    set_material(MATERIAL['bubble'])
    GL::Translate(bubble.position.x,bubble.position.y,bubble.position.z)
    GLUT::SolidSphere(0.005, 5, 5)
    GL::PopMatrix()
  end
  
  def draw_bounding_box(object)
    GL::PushMatrix()
    GL::Begin(GL::LINES)
    set_material(MATERIAL['bounding_box'])
    GL::Vertex(object.position.x,object.position.y,object.position.z)
    GL::Vertex(object.position.x+object.direction.x*object.world_perception,
               object.position.y+object.direction.y*object.world_perception,
               object.position.z+object.direction.z*object.world_perception)
    GL::Vertex(object.position.x+object.up_vector.x*object.world_perception,
               object.position.y+object.up_vector.y*object.world_perception,
               object.position.z+object.up_vector.z*object.world_perception)
    GL::Vertex(object.position.x,object.position.y,object.position.z)               
    GL::End()
    GL::PopMatrix()  
  end
  
  
  def draw_path(object)
    ctrl = object.turn_path
    if ctrl
      curve = object.curve
      GL::PushMatrix()
      set_material(MATERIAL['bounding_box'])
      GL::LineWidth(1.5)
      GL::Begin(GL::LINE_STRIP)
      curve.each {|c| GL::Vertex(c[Aqua::X],c[Aqua::Y],c[Aqua::Z]) }
      GL::End()
      GL::PopMatrix()
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
end

Vivarium.new.start