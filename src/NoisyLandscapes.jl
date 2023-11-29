module NoisyLandscapes

using Luxor
using Colors
using ColorSchemes

export landscape, ColorSchemes, ColorSettings

# The final images in this post combine 2D noise and 1D noise; 2D noise for the sky, and 1D noise to create the contours.

# There's a `initnoise()` function. This is broadly the equivalent of the `Random.seed!()` function in Julia.
# This is useful when you want the noise to vary from image to image.

struct ColorSettings
    sun
    sky
    clouds::Bool
    mountains::Vector
end

function layer(leftminheight, rightminheight, noiserate;
        detail=1, persistence=0)
    c1, c2, c3, c4 = box(BoundingBox(), vertices=true)
    ip1 = between(c1, c2, leftminheight)
    ip2 = between(c4, c3, rightminheight)
    topedge = Point[]
    initnoise(rand(1:12))
    for x in ip1.x:2:ip2.x
        ypos = between(ip1, ip2, rescale(x, ip1.x, ip2.x, 0, 1)).y
        ypos *= noise(x/noiserate, detail=detail, persistence=persistence)
        push!(topedge, Point(x, ypos))
    end
    p = [c1, topedge..., c4]
    poly(p, :fill, close=true)
end

function clouds(width=800)
    tiles = Tiler(boxwidth(BoundingBox()),
                  boxheight(BoundingBox()),
                  width, width, margin=0)
    @layer begin
        transform([3 0 0 1 0 0])
        setopacity(0.1)
        noiserate = 0.03
        for (pos, n) in tiles
            nv = noise(pos.x * noiserate,
                       pos.y * noiserate,
                       detail=4, persistence=.4)
            setgray(nv)
            box(pos, tiles.tilewidth, tiles.tileheight, :fill)
        end
    end
end

function colorblend(fromcolor, tocolor, n=0.5)
    f = clamp(n, 0, 1)
    nc1 = convert(RGBA, fromcolor)
    nc2 = convert(RGBA, tocolor)
    from_red, from_green, from_blue, from_alpha = convert.(Float64, (nc1.r, nc1.g, nc1.b, nc1.alpha))
    to_red, to_green, to_blue, to_alpha = convert.(Float64, (nc2.r, nc2.g, nc2.b, nc1.alpha))
    new_red = (f * (to_red - from_red)) + from_red
    new_green = (f * (to_green - from_green)) + from_green
    new_blue = (f * (to_blue - from_blue)) + from_blue
    new_alpha = (f * (to_alpha - from_alpha)) + from_alpha
    return RGBA(new_red, new_green, new_blue, new_alpha)
end

function landscape(scheme::Union{Any,ColorSettings}, filename; size=(800,300), fixed_sunposition=nothing)
    d = Drawing(size..., "$filename.png")
    origin()
    ## sky is gradient mesh
    bb = BoundingBox()
    is_fixed_colors = isa(scheme, ColorSettings)
    local sky_color
    if is_fixed_colors
        sky_color = [scheme.sky]
    else
        sky_color = [
            get(scheme, rand()),
            get(scheme, rand()),
            get(scheme, rand()),
            get(scheme, rand())]
    end
    mesh1 = mesh(box(bb, vertices=true), sky_color)
    setmesh(mesh1)
    box(bb, :fill)
    ## clouds are 2D noise
    show_clouds = is_fixed_colors ? scheme.clouds : true
    if show_clouds
        clouds(size[1])
    end
    sun_color = is_fixed_colors ? scheme.sun : get(scheme, .95)
    ## the sun is a disk placed at random
    @layer begin
        setopacity(0.25)
        sethue(sun_color)
        if !isnothing(fixed_sunposition)
            rand() # keep RNG the same
            sunposition = fixed_sunposition
        else
            sunposition = boxtop(bb) + (rand(-boxwidth(bb)/3:boxwidth(bb)/3), boxheight(bb)/10)
        end
        circle(sunposition, boxdiagonal(bb)/30, :fill)
    end
    setopacity(0.8)
    ## how many layers
    len = 6
    default = true
    if default
        noiselevels = range(100, length=len, stop=10)
        detaillevels = 1:len
        persistencelevels = range(0.5, length=len, stop=0.95)
    else
        noiselevels = range(100, length=len, stop=80)
        detaillevels = div(len,2) .* ones(Int, len) # 1:len
        persistencelevels = range(0.5, length=len, stop=0.95)
    end
    for (n, i) in enumerate(range(1, length=len, stop=0))
        if is_fixed_colors
            sethue(scheme.mountains[n])
        else
            ## avoid extremes of range
            sethue(colorblend(get(scheme, .05), get(scheme, .95), i))
        end
        layer(i - rand()/2, i - rand()/2,
              noiselevels[n], detail=detaillevels[n],
              persistence=persistencelevels[n])
    end
    finish()
    preview()
end


end # module
