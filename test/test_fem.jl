## test_fem.jl : test GRF defined on FEM

@testset "finite element mesh      " begin

## Load node/element table ##
(p,t) = star()
m = Matern(0.2,2.0)

## Cholesky ##
grf = GaussianRandomField(CovarianceFunction(2,m),Cholesky(),p,t)
@test isa(grf,GaussianRandomField)
@test isa(grf.cov,CovarianceFunction)
@test isa(grf.cov.cov,Matern)
@test ndims(grf.cov) == 2
@test isa(grf,GaussianRandomField{C,Cholesky} where {C})
@test length(grf.pts) == 2
@test size(grf.pts[1],1) == 2
@test size(grf.pts[1],2) == size(p,1)
@test size(grf.pts[2],1) == 3
@test size(grf.pts[2],2) == size(t,1)
#plot_trisurf(grf); close()
#tricontourf(grf); close()
#plot(grf); close()

## Spectral ##
grf = GaussianRandomField(CovarianceFunction(2,m),Spectral(),p,t)
@test isa(grf,GaussianRandomField{C,Spectral} where {C})

## CirculantEmbedding ##
@test_throws ArgumentError GaussianRandomField(CovarianceFunction(2,m),CirculantEmbedding(),p,t)

## KarhunenLoeve ##
grf = GaussianRandomField(CovarianceFunction(2,m),KarhunenLoeve(100),p,t,mode="nodes")
@test isa(grf,GaussianRandomField{C,KarhunenLoeve{100}} where {C})
#plot_eigenvalues(grf); close()
#plot_eigenfunction(grf,1); close()

## Anisotropic random field ##
a = AnisotropicExponential([1000 0; 0 1000])
cov = CovarianceFunction(2,a)
grf = GaussianRandomField(cov,KarhunenLoeve(500),p,t,quad=GaussLegendre())
@test isa(grf.cov.cov,AnisotropicExponential)

## Center mode ##
grf = GaussianRandomField(CovarianceFunction(2,m),KarhunenLoeve(100),p,t,mode="center")
@test isa(grf,GaussianRandomField{C,KarhunenLoeve{100}} where {C})
@test_throws ArgumentError GaussianRandomField(CovarianceFunction(2,m),KarhunenLoeve(100),p,t,mode="cente")
@test_throws ArgumentError GaussianRandomField(1,CovarianceFunction(2,m),KarhunenLoeve(100),p,t,mode="cente")
@test_throws ArgumentError GaussianRandomField(zeros(size(t,1)),CovarianceFunction(2,m),KarhunenLoeve(100),p,t,mode="cente")

## GaussianRandomField with mean value ##
grf = GaussianRandomField(1,CovarianceFunction(2,m),Cholesky(),p,t,mode="center")
@test isa(grf,GaussianRandomField{C,Cholesky} where {C})
@test length(grf.mean) == size(t,1)
@test all(grf.mean.==1)

grf = GaussianRandomField(ones(size(p,1)),CovarianceFunction(2,m),Spectral(),p,t)
@test isa(grf,GaussianRandomField{C,Spectral} where {C})
@test length(grf.mean) == size(p,1)
@test all(grf.mean.==1)

## Non-bounding box method ##
(p,t) = Lshape()
grf = grf = GaussianRandomField(CovarianceFunction(2,Matern(0.2,1.0)),Spectral(),p,t,n=10)
@test size(grf.data.eigenfunc,2) == 10

end
