# Loading the Statistic model before it tries to read from the cache
# In development, so we can avoid the `Undefined class/module Statistics` 
#
Statistics if Rails.env.development?
