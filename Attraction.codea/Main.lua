-- Attraction
supportedOrientations(LANDSCAPE_LEFT)

-- Use this function to perform your initial setup
function setup()
    print("Hello World!")
    fill(0, 0, 0, 255)
    maxSpeed = 2
    minSpeed = 0.1
    resolution = 5
    speedRes = 2
    resistance = 0.00005
    maxRad = 25
    maxDistance = WIDTH/2
    tolerance = 20
    gravityRes = 0.1
    bounceLoss = 0.95 -- the amount that remains
    
    total = 200
    
    displayMode(FULLSCREEN)
    
    dragging = 0
    
    circles = {}
    attractors = {}
    -- Initial position and radius
    -- x, y, dx, dy, r,g,b,a, rad
    for i=0,total do
        table.insert(circles,i,{math.random(maxRad,WIDTH), math.random(maxRad,HEIGHT),0.1 + math.cos(math.random(0,8))*maxSpeed, 0.1 + math.cos(math.random(0,8))*maxSpeed, math.random(200,255), math.random(100,200), math.random(0,100), math.random(100,200), math.random(5,maxRad)})
    end
    
    --background(0, 0, 0, 255)
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color
    --blendMode(MULTIPLY)
    --fill(0, 0, 0, 25)
    --rect(0,0,WIDTH,HEIGHT)
    background(0, 0, 0, 255)
    blendMode(ADDITIVE)
    
    -- attractors
    for k,v in pairs(attractors) do
        stroke(255, 255, 255, v[3])
        strokeWidth(1)
        fill(0,0,0,0)
        ellipse(v[1], v[2], 20)
        attractors[k][3] = v[3] - 0.1
        if attractors[k][3] <= 0 then
            table.remove(attractors, k)
        end
    end
    
    noStroke()
    for k,v in pairs(circles) do
        fill(v[5],v[6],v[7],255)
        -- Mutate alpha
        v[8]=math.max(v[8]+math.cos(math.random(0,180)+v[7]+v[8])*2,100)
        -- Draw
        ellipseMode(RADIUS)
        ellipse(v[1], v[2], v[9])
        
        -- Bounce
        if v[1]+v[3]-v[9] < 0 or v[1]+v[3]+v[9] > WIDTH then
            v[3] = -v[3]*bounceLoss
        end
        if v[2]+v[4]-v[9] < 0 or v[2]+v[4]+v[9] > HEIGHT then
            v[4] = -v[4]*bounceLoss
        end
        -- Update position
        circles[k][1] = math.max(math.min(v[1]+v[3], WIDTH-v[9]),v[9])
        circles[k][2] = math.max(math.min(v[2]+v[4], HEIGHT-v[9]),v[9])
        
        -- decrease speed (resistance)
        circles[k][3] = circles[k][3]-circles[k][3]*resistance*v[9]
        circles[k][4] = circles[k][4]-circles[k][4]*resistance*v[9]
        
        -- the color will use the closest attractor
        minDis = 2*WIDTH
        
        -- force
        for a,b in pairs(attractors) do
            dx = b[1]-v[1]
            dy = b[2]-v[2]
            dis = distance(dx,dy)
            minDis = math.min(minDis, dis)
            circles[k][3] = circles[k][3]+(dx*modulate(dis))*speedRes*(5/v[9])
            circles[k][4] = circles[k][4]+(dy*modulate(dis))*speedRes*(5/v[9])
        end
        -- add accelerometer force
        circles[k][3] = circles[k][3]+Gravity.x*gravityRes
        circles[k][4] = circles[k][4]+Gravity.y*gravityRes
        
        maxDis = WIDTH/1.5
        minDis = 1/math.sqrt(circles[k][3]*circles[k][3]+circles[k][4]*circles[k][4])
        maxDis = 1
        
        circles[k][5] = math.max(math.min(v[5]+((maxDis-minDis)*255/maxDis-v[5])*0.1,255),0)
        circles[k][6] = math.max(math.min(v[6]+(math.abs(minDis-maxDis*2)*255/maxDis/10-v[6])*0.1,255),0)
        circles[k][7] = math.max(math.min(v[7]+(minDis*255/maxDis-v[7])*0.1,255),0)
    end
end

function touched(touch)
    -- store attractors
    if(touch.state == 1 and dragging > 0) then
        attractors[dragging][1] = touch.x
        attractors[dragging][2] = touch.y
        attractors[dragging][3] = 255
    elseif(touch.state == 0) then
        for k,v in pairs(attractors) do
            if distance(touch.x - v[1], touch.y -v[2]) < 20 + tolerance then
                dragging = k
                return
            end
        end
        table.insert(attractors, {touch.x, touch.y, 255})
    else
        dragging = 0
    end
    
end

function createCircle(x,y,r)
    local circle = physics.body(CIRCLE, r)
    -- enable smooth motion
    circle.interpolate = true
    circle.x = x
    circle.y = y
    circle.restitution = 0.25
    circle.sleepingAllowed = false
    return circle
end
function distance(dx,dy)
    --return math.sqrt(dx*dx+dy*dy)
    return 1.426776695*math.min(0.7071067812*(math.abs(dx)+math.abs(dy)), math.max (math.abs(dx), math.abs(dy)));    
end
function modulate(dis)
    sig = 300 -- Radius affected by attractor
    return (1/(sig*2*math.pi))*math.exp((-(dis*dis-10))/(2*sig*sig))
end