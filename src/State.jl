mutable struct State

    B   :: AbstractArray{Float64, 1}
    Γ   :: AbstractArray{Float64, 1}
    SST :: AbstractArray{Float64, 1}

    function State(
        ev :: Env,
    )
        Ny = ev.gd.Ny
 
        B   = zeros( Float64, Ny ) 
        Γ   = zeros( Float64, Ny ) 
        SST = zeros( Float64, Ny ) 

        return new(
            B,
            Γ,
            SST,
        )    
    end
end

