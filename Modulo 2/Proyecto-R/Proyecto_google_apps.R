# Incluimos las librer�as correspondiendes
library(dplyr)
library(corrplot)
library(ggplot2)

# Inicializamos el working directory
setwd(r'(C:\Users\Asus\OneDrive - Universidad Polit�cnica de Yucat�n\Concursos - Becas\Bedu - Ciencia de datos\Modulo 2\Video integrador R\Data)')

# Previsualizo el contenido del wd para saber que es el adecuado
dir()

# Cargo el csv que incluye las apps
apps <- read.csv('googleplaystore.csv')

# Nos hacemos una idea de la construcci�n del DF
str(apps)

# Visualizamos la cantidad de valores faltantes en el DF
table(is.na(apps))


# Identifico las columnas con valores faltantes en el DF
names(apps)[colSums(is.na(apps))>0]

# Analizamos el tama�o del DF
dim(apps)

"
--- DISCLAIMER --- 
Como hemos identificado que los valores n�los se encuentran �nicamente en 
la columna de Rating, el hacer un drop de los valores nulos es un desperdicio
de informaci�n para las dem�s columnas. Las dimenciones del DF se mantendr�n
como se encuentran hasta el momento con la �nica observaci�n que la columna
Rating ser� manejada de una manera distinta devido a su condici�n. 
"


# Asignamos los datatypes correspondientes para las columnas dentro del DF

"Para trabajar sobre la columna de Rating y ponerla como num�rica sin que
me arroje erroes por los valores de NA (que como ya comentamos, no queremos
eliminar, esto tuvo que hacerse por fases como veremos a continuaci�n"


# Creo un vector con los valores de Rating como n�meros, sin valores nulos. 
a <- as.numeric(na.omit(apps$Rating))
# A�ado valores nulos a mi vector para poder tener las mismas dimenciones de mi DF
a <- append(a,rep(NA,dim(apps)[1]-length(a)))
# Reemplazo la columna Rating con el vector a 
apps <- mutate(apps, Rating = a)

# ------ cambio el formato de los reviews y del precio ------
b <- apps$Reviews

# Al momento de cambiar mi datatype en la columna reviews, me doy cuenta de que 
# Se inserta un valor NA por coerci�n.... 
b <- as.integer(gsub(",|+","",b))
table(is.na(b))
which(is.na(b),arr.ind = T)
# Verifico el valor original que no pudo ser alterado a num�rico y me doy cuenta
# que en efecto es un error al momento de introducir los datos, pues este es el peso de una aplicaci�n y que s� debe ser tomado como un NA
apps$Reviews[10473]

# Transformo la columna entonces a num�rico con un valor v�lido de NA
apps <- mutate(apps, Reviews = b) 

# Transformo la columna price a un numeric 
p <- apps$Price
p <- gsub('\\$','',p)
p <- as.numeric(p)

# termino de asignar la columna corregida de precio
apps <- mutate(apps, Price = p) 



# Me arroj� un NA por coerci�n, el cu�l es v�lido porque era una entrada de category
which(is.na(p), arr.ind = T)
apps$Price[10473]

# Me fijo que el �ndex de donde pas� ese problema es el mismo que el del problema anterior. Procedo a investigar esa fila
checar <- apps[10473,]
checar
# Una vez que me he cerciorado de que en efecto esa fila es inv�lida, procedo a eliminarla
apps <- apps[-c(10473),]


# cambio el datatype de Installs
i <- apps$Installs
i <- as.integer(gsub('\\+|,','',i))
apps <- mutate(apps, Installs = i)

# ---Visualizo una matriz de correlacion entre las variables num�ricas---

# Coeficientes de correlacion de las variables
cof_corr = cor(na.omit(apps[,c(3,4,6,8)]))

# Prueba visual
corrplot(cof_corr,method = 'pie',tl.col = 'black', tl.srt = 0,type = 'lower',
         col.main  = 'Black') +
  title('Correlaci�n entre variables', line = 3)


" Podemos facilmente notar que la �nica correlaci�n semi-�til es la de los
reviews-installs. Hace total sentido, pues mientras m�s personas han descargado
la aplicaci�n, ser�n m�s quienes tienen una opini�n sobre la misma. Lo realmente
interesante es el hecho de que ni el precio, ni el rating tienen alg�n impacto
signficativo en el n�mero de veces que se instala una app"


# Una vez entendiendo lo anterior, visualizamos la distrubuci�n en los tipos de apps

e <- filter(apps, Type %in% c("Paid","Free"))
ggplot(e, aes(Type)) + 
  geom_bar(show.legend = T, fill = '#7CA3D8') +
  theme_gray(base_size = 14) +
  labs(x = "Tipo ", y = "Cantidad", 
       title = "Distribuci�n en los tipos de aplicaciones")


# Entre aquellas pocas aplicaciones que cobran, �cu�l es el rango de precios? 

cobran <- filter(apps, Price>0 )

sprintf("El precio m�s bajo es $%.2f y el alto es de $%.2f d�lares",min(cobran$Price), max(cobran$Price))

"Notamos que el rango de precios es muy amplio tomando en cuenta el contexto, 
�C�mo es su distribuci�n?"

ggplot(cobran, aes(Price)) + 
         geom_boxplot()

"
Es m�s que evidente que los precios demasiado altos son son outliers y 
afectan en gran medida a nuestros datos. Procedemos a eliminarlos
"

# Me quedo con los datos que est�n por debajo o igual de dos veces la media
cobran.clean <- filter(cobran, Price <= mean(cobran$Price)*2)


# Visualizo su distribuci�n 
ggplot(cobran.clean, aes(Price)) + 
  geom_boxplot()

gratis <- filter(apps, Price == 0)

cobran.v = cobran.clean$Installs

sample.gratis <- sample_n(gratis, length(cobran.v))

"
Kolmogorov-Smirnov Tests porque los datos no se comportaban normal
y de dos colas porque buscamos diferencias
"
ks.test(cobran.v, sample.gratis$Installs, alternative = "two.side")

ks.test(cobran.clean$Rating, sample.gratis$Rating, alternative = "two.side")


"
Con los an�lisis anteriores, podemos concluir que las aplicaciones gratis
se descargan mucho m�s que aquellas de paga, sin embargo, el que una aplicaci�n
sea de paga o no, no afecta la persepci�n (Ranking) de la gente
"


# Visualizo cu�les son las categor�as que "dominan" el mercado
category.c <- count(apps, Category, sort = T)

# Me quedo con el top 10 categor�as m�s descargadas
category.c <- head(category.c, 10)

# Grafico los resultados
ggplot(category.c, aes(x = Category, y = n)) +
  geom_bar(stat = 'identity', fill = "#CD9118", width = .95) +
  labs(x = "Categoria",
       y = "N�mero de apps",
       title = "Top categor�as con m�s descargas") +
  theme(axis.text.x = element_text(angle = 10, size = 10, face = "bold"),
        axis.text.y = element_text(size = 10, face = "bold"),
        axis.title.y = element_text(size = 15),
        axis.title.x = element_text(size = 15),
        plot.title = element_text(size = 18, hjust =0.5))


# --- Visualizo cuales son las categor�as que est�n mejor calificadas por los usuarios ---

# Elimino los NA values
rating.category <- na.omit(apps)
# Calculo la media del Rating por categor�a
rating.category <- aggregate(rating.category$Rating,list(rating.category$Category), mean)
# Me quedo con las 5 categor�as con la media m�s grande 
rating.category <- head(rating.category[order(rating.category$x,decreasing = T),],5)
# Visualizo la informaci�n obtenida
ggplot(rating.category, aes(x = Group.1, y = x, group=1)) +
  geom_line(size = 1.3, color = '#225B6A') +
  geom_point(size = 4, shape = 16, color = "#6A223C") +
  labs(x = " Categor�a", y = "Rating promedio",
       title = "Top 5 categor�as m�s valoradas") +
  theme(axis.text.x = element_text(size = 10, face = "bold"),
        axis.text.y = element_text(size = 10, face = "bold"),
        plot.title = element_text(size = 15, hjust = 0.5),
        axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15)) 