library(reticulate)

# Changing the working directory to the source file location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Gain and fall script
source_python('gain_fall.py')

d <- data2[data2$Company == 'Microsoft Corporation',]

df_and_spread = gain_fall(d) # using the gain_fall function

# Print out the new dataset
df_and_spread[1] # Stores as a list typeof()

# Print out the data spread
df_and_spread[2]

new_data <- as.data.frame(df_and_spread[1])
typeof(new_data)
head(new_data)


# The Model
source_python('py_model_script.py')

eval_array <- model(new_data) # Using the model function

eval_array[[1]]

