function cvode{f,r}(::Type{f},::Type{r},d::Array{Int64},p::Vector{Float64}, y0::Vector{Float64}, t::Vector{Float64}; reltol::Float64=1e-4, abstol::Float64=1e-6)
    neq = length(y0)
    mem = Sundials.CVodeCreate(Sundials.CV_BDF, Sundials.CV_NEWTON)
    flag = Sundials.CVodeInit(mem, cfunction(cvode_ode_wrapper, Int32, (Sundials.realtype, Sundials.N_Vector, Sundials.N_Vector, Array{Any,1})), t[1], Sundials.nvector(y0))
    flag = Sundials.CVodeSetUserData(mem, {f,r,d,p})
    flag = Sundials.CVodeSStolerances(mem, reltol, abstol)
    flag = Sundials.CVDense(mem, neq)
    yres = zeros(length(t), length(y0))
    yres[1,:] = y0
    y = copy(y0)
    tout = [0.0]
    for k in 2:length(t)
        flag = Sundials.CVode(mem, t[k], y, tout, Sundials.CV_NORMAL)
        yres[k,:] = y
    end
    Sundials.CVodeFree([mem])
    return yres
end
