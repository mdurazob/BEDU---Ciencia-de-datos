install.packages("lubridate")


library(dplyr)
library(lubridate)
library(TSA)
library(ggplot2)



datos <- read.csv("match.data.csv")

datos <- mutate(datos,TotalGoles = home.score + away.score, date = as.Date(date))




promedio.a�o.mes <-aggregate(datos$TotalGoles,list(year(datos$date),month(datos$date)),mean)


colnames(promedio.a�o.mes)<-c("A�o","Mes","Promedio")

serieTiempo <- ts(promedio.a�o.mes$Promedio, star = c(2010,8), frequency = 12)

plot(serieTiempo,type="l", xlab = "A�o", ylab= "Promedio", main="Promedio de goles por a�o")

