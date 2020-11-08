library(ggplot2)


hibench_Kmeans_15nodes_article_settings <- read.csv("~/Documents/distributed-A1/Distributed-Data-Processing-Systems-A1/experiments/hibench_15_30exp_hadoopspark_original.report", sep="")
#hibench_Kmean_6nodes_article_settings <- read.csv("~/Documents/distributed-A1/Distributed-Data-Processing-Systems-A1/experiments/hibench.report_6nodes_old", sep="")
#hibench_Kmean_11nodes_our_settings <- read.csv("~/Documents/distributed-A1/Distributed-Data-Processing-Systems-A1/experiments/hibench.report_11nodes_new", sep="")



# for column setting 0 is for article setting and 1 is for our settings

hibench_Kmeans_15nodes_article_settings["node_numb"] <- 15
hibench_Kmeans_15nodes_article_settings["settings"]<- 0

hibench_Kmean_6nodes_article_settings["node_numb"] <- 6
hibench_Kmean_6nodes_article_settings["settings"]<- 0

hibench_Kmean_11nodes_our_settings["node_numb"] <- 11
hibench_Kmean_11nodes_our_settings["settings"]<- 1

hibench_Kmeans_15nodes_article_settings$Type <- as.factor(hibench_Kmeans_15nodes_article_settings$Type)


aggregate(hibench_Kmeans_15nodes_article_settings$Duration.s., list(hibench_Kmeans_15nodes_article_settings$Type), median)

p = ggplot(hibench_Kmeans_15nodes_article_settings, aes(x=))

p <- ggplot(hibench_Kmeans_15nodes_article_settings, aes(x = node_numb, y =Duration.s.)) + 
  geom_boxplot(aes(fill = Type), position = position_dodge(0.9)) +
  scale_fill_manual(values = c("#00AFBB", "#E7B800")) 

p + scale_x_discrete(hibench_Kmeans_15nodes_article_settings$node_numb)

node_amoutn = c(5,10,15)

 # Line plot with multiple groups
boxplot(log(hibench_Kmeans_15nodes_article_settings$Duration.s.)~(hibench_Kmeans_15nodes_article_settings$Type))
