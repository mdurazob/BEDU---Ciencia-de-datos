setwd(r"(C:\Users\Asus\OneDrive - Universidad Polit�cnica de Yucat�n\Concursos - Becas\Bedu - Ciencia de datos\Modulo 2\Sesi�n 2\Postwork)")

# Importa los datos de soccer de las temporadas 2017/2018, 2018/2019 y 2019/2020 de la primera divisi�n de la liga espa�ola a R
df <- lapply(dir(),read.csv)

# Importo la librer�a dplry
library(dplyr)
select(df, Date)

# Me quedo solo con las columnas que me servir�an
df <- lapply(df,'[',c('Date','HomeTeam','AwayTeam','FTHG','FTAG','FTR'))

# Unifico la lista en un solo Dataframe
df <- do.call(rbind, df)

# Obteniendo una idea de las caracter�sticas del df
str(df)
head(df)
View(df)
summary(df)

# Transformando las columnas que deber�an ser de otro datatype
df <- mutate(df, Date = as.Date(Date, "%d/%m/%y"))


df["Date"]
