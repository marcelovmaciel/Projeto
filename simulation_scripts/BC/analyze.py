import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

result = pd.read_csv("output.csv")




g = sns.tsplot(time = "time", value = "opinion", data= result, unit = "id", err_style="unit_traces")
plt.show(g)
