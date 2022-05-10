# 对评论进行分词
import pandas as pd                                                                                                                    
                                                                                                                                       
df = pd.read_csv("whole_review.csv")                                                                                                   
for i in range(len(df['Review'])):                                                                                                     
    df['Review'][i] = " ".join(jieba.cut(df['Review'][i], cut_all=True))
df.to_csv('whole_review.csv') 