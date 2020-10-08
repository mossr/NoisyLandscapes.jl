### A Pluto.jl notebook ###
# v0.12.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ c94a7510-09b6-11eb-30ae-c5ce7773f6f5
using NoisyLandscapes

# ╔═╡ 4cc69540-09b7-11eb-3741-0183ae696dec
using PlutoUI

# ╔═╡ 8e823d50-09b6-11eb-0810-d1446ca0fd80
md"""
## NoisyLandscapes.jl
Using Perlin noise to generate random colored landscapes.

- Credit: [cormullion](https://cormullion.github.io/pages/2018-10-11-noise/)
"""

# ╔═╡ 138d8900-09b7-11eb-323a-51d5c9121602
ColorSchemes.avocado

# ╔═╡ cbec7020-09b6-11eb-3ef0-1f459ac9658a
landscape(ColorSchemes.avocado, "../images/landscape-avocado")

# ╔═╡ 2b5359c0-09b7-11eb-38f1-2bde892062b5
md"""
---
"""

# ╔═╡ 22c4cc80-09b7-11eb-30be-232b1e0c782c
ColorSchemes.starrynight

# ╔═╡ 26c0b240-09b7-11eb-0fa2-5145137f091a
landscape(ColorSchemes.starrynight, "../images/landscape-starrynight")

# ╔═╡ 9561b3a0-09b9-11eb-3667-9b32ca523eb8
md"""
## Pick your color!
"""

# ╔═╡ 6b4c4dc0-09b7-11eb-28a7-9b71e711b542
colorschemes = sort([string(k)=>k for (k,v) in ColorSchemes.colorschemes]);

# ╔═╡ 4f690580-09b7-11eb-2c2a-b19eb6e081d8
@bind colorscheme Select(colorschemes; default="oslo")

# ╔═╡ 7d8dd920-09b9-11eb-2205-755bc036c48a
scheme = getfield(ColorSchemes, Symbol(colorscheme))

# ╔═╡ 4b80ced0-09b7-11eb-1d61-bd8b598825f1
landscape(scheme, "../images/landscape-$colorscheme")

# ╔═╡ Cell order:
# ╟─8e823d50-09b6-11eb-0810-d1446ca0fd80
# ╠═c94a7510-09b6-11eb-30ae-c5ce7773f6f5
# ╠═138d8900-09b7-11eb-323a-51d5c9121602
# ╠═cbec7020-09b6-11eb-3ef0-1f459ac9658a
# ╟─2b5359c0-09b7-11eb-38f1-2bde892062b5
# ╠═22c4cc80-09b7-11eb-30be-232b1e0c782c
# ╠═26c0b240-09b7-11eb-0fa2-5145137f091a
# ╟─9561b3a0-09b9-11eb-3667-9b32ca523eb8
# ╠═4cc69540-09b7-11eb-3741-0183ae696dec
# ╠═6b4c4dc0-09b7-11eb-28a7-9b71e711b542
# ╠═4f690580-09b7-11eb-2c2a-b19eb6e081d8
# ╠═7d8dd920-09b9-11eb-2205-755bc036c48a
# ╠═4b80ced0-09b7-11eb-1d61-bd8b598825f1
