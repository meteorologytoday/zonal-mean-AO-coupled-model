include("ZAAM.jl")




m = ZAAM.Model(ZAAM.Env(
    ϕn =  deg2rad(90),
    ϕs =  deg2rad(-90),
    npts = 180,
    J = 1e3,
    L = 1e4,
    K = 1e5,
    H = 10e3, 
    N = 2e-4,
    C = ZAAM.ρ0 * ZAAM.c_p * 1e-3 * 10.0,
))


#m.st.SST .= ZAAM.θ0 .+ exp.( - (m.ev.gd.ϕ_T[:] / deg2rad(10)).^2 / 2 ) * 30
m.st.SST .= ZAAM.θ0 .+ cos.( 3 * m.ev.gd.ϕ_T[:] )/2 * 20
#m.st.B[5] = ZAAM.g0

dt = 3600.0
steps = 240

save_B   = zeros(Float64, length(m.st.B),   steps)
save_SST = zeros(Float64, length(m.st.SST), steps)
save_TS  = zeros(Float64, length(m.st.B), steps)
save_Ψ   = zeros(Float64, length(m.st.Ψ),   steps)
save_Γ   = zeros(Float64, length(m.st.Γ),   steps)


for t=1:steps
   
    save_B[:, t]   = m.st.B
    save_SST[:, t] = m.st.SST
    save_TS[:, t]  = ZAAM.computeTS(m, m.st.B)
    save_Ψ[:, t]   = m.st.Ψ
    save_Γ[:, t]   = m.st.Γ
    
    println("Step Model: ", t) 

    ZAAM.step!(m, dt)


end


println("Try to output data...")

println("Loading libraries...")
using YAXArrays, NetCDF
using Dates
println("Done")

axlist = [
    RangeAxis("y", collect(1:length(m.ev.gd.ϕ_T))),
    RangeAxis("time", collect(1:steps)),
]

da_B   = YAXArray(axlist, save_B)
da_SST = YAXArray(axlist, save_SST)
da_TS  = YAXArray(axlist, save_TS)

axlist = [
    RangeAxis("yp1", collect(1:length(m.ev.gd.ϕ_V))),
    RangeAxis("time", collect(1:steps)),
]
da_Ψ   = YAXArray(axlist, save_Ψ)
da_Γ   = YAXArray(axlist, save_Γ)


ds = Dataset(
    B=da_B,
    SST=da_SST,
    TS=da_TS,
    Psi=da_Ψ,
    Gamma=da_Γ,
)


savedataset(ds, path="test_evolve_with_psi.nc", driver=:netcdf, overwrite=true)
