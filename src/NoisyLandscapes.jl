module NoisyLandscapes

using Luxor
using Colors
using ColorSchemes

export landscape, ColorSchemes

# The final images in this post combine 2D noise and 1D noise; 2D noise for the sky, and 1D noise to create the contours.

# There's a `initnoise()` function. This is broadly the equivalent of the `Random.seed!()` function in Julia.
# This is useful when you want the noise to vary from image to image.

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

function clouds()
    tiles = Tiler(boxwidth(BoundingBox()),
                  boxheight(BoundingBox()),
                  800, 800, margin=0)
    @layer begin
        transform([3 0 0 1 0 0])
        setopacity(0.3)
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

function landscape(scheme, filename)
    d = Drawing(800, 300, "$filename.png")
    origin()
    ## sky is gradient mesh
    bb = BoundingBox()
    mesh1 = mesh(box(bb, vertices=true), [
        get(scheme, rand()),
        get(scheme, rand()),
        get(scheme, rand()),
        get(scheme, rand())])
    setmesh(mesh1)
    box(bb, :fill)
    ## clouds are 2D noise
    clouds()
    ## the sun is a disk placed at random
    @layer begin
        setopacity(0.25)
        sethue(get(scheme, .95))
        sunposition = boxtop(bb) + (rand(-boxwidth(bb)/3:boxwidth(bb)/3), boxheight(bb)/10)
        circle(sunposition, boxdiagonal(bb)/30, :fill)
    end
    setopacity(0.8)
    ## how many layers
    len = 6
    noiselevels = range(100, length=len, stop=10)
    detaillevels = 1:len
    persistencelevels = range(0.5, length=len, stop=0.95 )
    for (n, i) in enumerate(range(1, length=len, stop=0))
        ## avoid extremes of range
        sethue(colorblend(get(scheme, .05), get(scheme, .95), i))
        layer(i - rand()/2, i - rand()/2,
              noiselevels[n], detail=detaillevels[n],
              persistence=persistencelevels[n])
    end
    finish()
    preview()
end


end # module
