#Fit final DNN model w/ optimized parameters (onlytriage) (Github)
library(readr)
library(dplyr)
library(reshape2)
library(parallel)
library(caret)
library(xgboost)
library(doMC)
library(pROC)
library(keras)

#1) create train/test split
load('C:/Users/kowsh/OneDrive/Desktop/Project/admissionprediction-1.0/Results/5v_sparseMatrix_onlytriage.RData')
load('C:/Users/kowsh/OneDrive/Desktop/Project/admissionprediction-1.0/Results/5v_indeces_list.RData')
indeces <- indeces_list[[1]]
x <- as.matrix(dataset$x)
y <- dataset$y
rm(dataset)

x_test <- x[indeces$i_test,]
y_test <- y[indeces$i_test]

x_train <- x[-indeces$i_test,]
y_train <- y[-indeces$i_test]

rm(x); rm(y)

#4) impute dataset for keras
impute <- preProcess(x_train, method = c('center','scale','medianImpute'))
x_train <- predict(impute, x_train)
x_test <- predict(impute, x_test)


#3) build keras on all data except test set, using the tuned parameters

model <-keras_model_sequential()
model %>%
        layer_dense(units = 300, activation = 'relu', input_shape = ncol(x_train)) %>%
        layer_dense(units = 100, activation = 'relu') %>%
        layer_dense(units = 1, activation = 'sigmoid') %>%
        compile(
                loss = 'binary_crossentropy',
                optimizer = optimizer_rmsprop(lr = 0.001),
                metrics = c('accuracy')
        )
model %>% fit(x_train, y_train, epochs = 3, batch_size = 128)


keras_pred_test <- as.vector(predict(model, x_test))
save(keras_pred_test, file = 'C:/Users/kowsh/OneDrive/Desktop/Project/admissionprediction-1.0/Results/5v_keras_pred_test_onlytriage.RData')
print('Keras onlytriage AUC')
roc(y_test, keras_pred_test)
ci.auc(roc(y_test, keras_pred_test), conf.level = 0.95)



