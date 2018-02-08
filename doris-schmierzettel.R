#Punkt 1
install.packages("readstata13")

View(data)

##für faktorisieren - lange Version
data$tornata<- as.factor(data$tornata)
data$id<- as.factor(data$id)
data$risposta<- as.factor(data$risposta)
data$lifesatisfaction<-as.factor(data$lifesatisfaction)
data$lsreddito<-as.factor(data$lsreddito)
data$lsfamiglia<-as.factor(data$lsfamiglia)
data$lslavorostudio<-as.factor(data$lslavorostudio)
data$unpacked<-as.factor(data$unpacked)
