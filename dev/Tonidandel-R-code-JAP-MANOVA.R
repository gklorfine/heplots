rawdata<-read.csv("C:\\Users\\sctonidandel\\Desktop\\MANOVA Example\\Thompson data\\Vignovic.csv")
attach(rawdata)
thedata<-data.frame(SendExtraversion_mean
                    ,SendAgree_mean 
                    ,CogTrustl_mean
                    ,AffTrust_mean 
                    ,Etiquette_Errors
                    )

#mydata<-cor(mydata)
Labels<-names(thedata)[1:4] #need this 'labels' variables as the 'variables' one created below get modified whenever we call 'multregress'
multRegress<-function(mydata){
numVar<<-NCOL(mydata) #notice that some variable have "<<-" instead of "<-" This is purposeful so you need to amke sure that is carried over
Variables<<- names(mydata)[1:4]
#J<- $numpredic
#Q<- $numcriter

J<- 1
Q<- 4

R<-cor(mydata)
RYY<- R[1:Q,1:Q]
RXX<- R[(Q+1):numVar, (Q+1):numVar]
RXY<- R[1:Q,(Q+1):numVar]

RXX.eigen<-eigen(RXX)
DX<-diag(RXX.eigen$val)
deltax<-sqrt(DX)

lambdax<-RXX.eigen$vec%*%deltax%*%t(RXX.eigen$vec)

RYY.eigen<-eigen(RYY)
DY<-diag(RYY.eigen$val)
deltay<-sqrt(DY)

lambday<-RYY.eigen$vec%*%deltay%*%t(RYY.eigen$vec)

betay<-t(RXY)%*%solve(lambday)
betax<-solve(lambdax)%*%betay

lambdax2<-lambdax^2
betax2<-betax^2

mumatrix=lambdax2%*%betax2
mumatrix=t(mumatrix)
result<<-data.frame(Variables, Raw.RelWeight=mumatrix)
}

multRegress1<-function(mydata){
numVar<<-NCOL(mydata) #notice that some variable have "<<-" instead of "<-" This is purposeful so you need to amke sure that is carried over
Variables<<- names(mydata)[1:5]
#J<- $numpredic
#Q<- $numcriter

J<- 1
Q<- 5

R<-cor(mydata)
RYY<- R[1:Q,1:Q]
RXX<- R[(Q+1):numVar, (Q+1):numVar]
RXY<- R[1:Q,(Q+1):numVar]

RXX.eigen<-eigen(RXX)
DX<-diag(RXX.eigen$val)
deltax<-sqrt(DX)

lambdax<-RXX.eigen$vec%*%deltax%*%t(RXX.eigen$vec)

RYY.eigen<-eigen(RYY)
DY<-diag(RYY.eigen$val)
deltay<-sqrt(DY)

lambday<-RYY.eigen$vec%*%deltay%*%t(RYY.eigen$vec)

betay<-t(RXY)%*%solve(lambday)
betax<-solve(lambdax)%*%betay

lambdax2<-lambdax^2
betax2<-betax^2

mumatrix<<-lambdax2%*%betax2
test<<-mumatrix[2:5]-mumatrix[1]
#test2=t(test)
result<<-data.frame(Labels, Raw.RelWeight=test)
}




multRegress(thedata)
RW.Results<-result


multBootrand<-function(mydata, indices){
  mydata<-mydata[indices,]
	multRWeights<-multRegress1(mydata)
  randStat<-multRWeights$Raw.RelWeight
	return(randStat)
}

myRbootci<-function(x){
  boot.ci(multRBoot,conf=, type="bca", index=x)
}

runRBoot<-function(num){
  INDEX<-1:num
  test<-lapply(INDEX, FUN=myRbootci)
	test2<-t(sapply(test,'[[',i=4)) #extracts confidence interval
	Clresult<<-data.frame(Labels, CI.Lower.Bound=test2[,4],CI.Upper.Bound=test2[,5])
}
randVar<-rnorm(length(thedata[,1]),0,1)
randData<-cbind(randVar,thedata)
multRBoot<-boot(randData,multBootrand, 5000)
multRci<-boot.ci(multRBoot,conf=, type="bca")
runRBoot(length(randData[1:4]))
CI.Significance<-Clresult


