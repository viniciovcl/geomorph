setwd("C:/geom")
getwd()
list.files()

#Parametros do terreno
list.files (pattern = '^.*\\.asc$')          #listando todos os files na pasta com extens?o .asc
TP.list <- list.files(pattern= '^.*\\.asc$')       #arquivos de extens?o asc
TP.list <- TP.list [-9]     #Retirando o Flow Direction

summary(TP.list)

#Abrindo os par?metros no R 

library(rgdal)


grids5m <- readGDAL("fdir.asc")

class(grids5m)
str (grids5m)
for(i in 1:length(TP.list)){grids5m@data[strsplit(TP.list[i], ".asc")[[1]]] <- readGDAL(TP.list[i]) $band1}

summary(grids5m)

#Substituindo os NAs nas bordas dos par?metros

grids5m$grad_downslp[is.na(grids5m$grad_downslp[])] <- 0.1596  #Esse valor ? a m?dia do parametro

grids5m$grad_downslp_dif[is.na(grids5m$grad_downslp_dif[])] <- -0.0122 #Esse valor ? a m?dia do parametro

grids5m$hofd[is.na(grids5m$hofd[])] <- 147.9 #Esse valor ? a m?dia do parametro

grids5m$ofdcn[is.na(grids5m$ofdcn[])] <- 16.25 #Esse valor ? a m?dia do parametro

grids5m$vofd[is.na(grids5m$vofd[])] <- 16.25 #Esse valor ? a m?dia do parametro
-----------------------------------------------------------------------------------------------------------------------
#An?lise explorat?ria

#Filtrando dataset

grids5m <- grids5m[-1]   #Tirou o flow_dir = band1
summary (grids5m)

======================================================
#listando e identificando o que h? dentro de um objeto
#Os objetos s?o: grids5m///TP.list.....
summary(grids5m)
str(grids5m@data)
ls()
rm()  #remover objeto da mem?ria
-------------------------------------------------------------

hist.grids <- grids5m[- c(3, 4, 5, 6)]  #Defini??o do objeto hist.grids, que ? composto dos par?metros que ter?o histograma.
str(hist.grids)
summary (hist.grids)
log.grids <- grids5m[c(3, 4, 5, )]     #Defini??o do objeto log.grids, que ? composto dos par?metros 
					       #que ter?o histograma em LOG pois os valores s?o muito baixos.

summary(log.grids)
-----------------------------------------------------------------------------------------------------------------------
#Histogramas


library(Hmisc)

hist.data.frame(hist.grids@data)
str(grids5m@data)

hist.data.frame(log2(log.grids@data), main="Log2") 

--------------------------------------------------------------------
#Compartmenta??o do relevo por classifica??o n?o supervisionada

library(stats)

#=======================================
#An?lise de Componentes Principais
str(grids5m@data)
?prcomp

pc.dem <- prcomp(~ aspect + baselev + log(c_area) + c_long + c_tan + dem + 
grad_downslp + grad_downslp_dif + hofd + ofdcn + slope + vdcn + vofd, na.action = na.omit,
scale=TRUE, grids5m@data) 


head(pc.dem$x)
-------------------------------------------------------------------
#Biplot PC1 x PC2

biplot(pc.dem, arrow.len=0.1, xlabs=rep(".", length(pc.dem$x[,1])), main="PCA Biplot")

summary(grids5m)
-------------------------------------------------------------------
#Numero ideal de classes Cluster Kmeans

demdata <- as.data.frame(pc.dem$x)
wss <- (nrow(demdata)-1)*sum(apply(demdata,2,var))
for (i in 2:20){wss[i] <- sum(kmeans(demdata, centers=i) $withinss)}

-------------------------------------------------------------------
#Kmeans para 12 classes

kmeans.dem <- kmeans(demdata, 12)
grids5m$kmeans.dem <- kmeans.dem$cluster
grids5m$landform <- as.factor(kmeans.dem$cluster)
summary(grids5m$landform)
------------------------------------------------------------------

#Write Raster

grids5m$landform <- as.numeric(grids5m$landform)

writeGDAL(grids5m, fname= "grids10.tif", drivername= "GTiff")

#Plot

class(grids5m)
image(grids5m["landform"], axes= TRUE, col = topo.colors(72))
------------------------------------------------------------------
plot(grids5m["landform"], axes=TRUE, col="set2")






