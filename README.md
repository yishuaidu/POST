### Probabilistic Streaming Tensor Decomposition @ ICDM'2018
[Yishuai Du](https://www.linkedin.com/in/yishuai-du-583a17b5/) | [Yimin Zheng](http://www.vincheng.me) | [Kuang-chih Lee](https://scholar.google.com/citations?user=r9JOIloAAAAJ&hl=en) | [Shandian Zhe](http://www.cs.utah.edu/~zhe/)

## Requirement
* MIT Licence
* [**Matlab**](https://www.mathworks.com/products/matlab.html) as the software to run POST code

## How to run POST
1. Download POST repository
2. Open Matlab, run the "main.m" file in each subfolder of POST/code.



## Dataset Intro
There are 5 datasets:
* [MovieLens](https://github.com/yishuaidu/POST/blob/master/code/MovieLen/movie_400x400x31.mat), a binary three-mode (user, movie, week) tensor of size 400×400×31
* [Twitter Topic](https://github.com/yishuaidu/POST/blob/master/code/Twitter/data.mat), a binary three-mode (user, expert, topic) tensor, of size 500×500×20
* [ACC](https://github.com/yishuaidu/POST/blob/master/code/ACC/tensor-data-large/acc.mat), a continuous tensor which records the three-mode interactions (user, action, resource), of size is 3K×150×30K
* [DBLP](https://github.com/yishuaidu/POST/tree/master/code/DBLP/tensor-data-large), a binary three-mode (author, conference, keyword) tensor, bibliography relationships, of size 3K×150×30K
* [Kaggle-ctr](https://www.kaggle.com/c/avazu-ctr-prediction/data), a contest for click-through-rate (CTR) prediction in online advertising, sponsored by Avazu Inc，build a four-mode binary tensor (banner_pos,site_id,app_id,device_model), of size 7×2854×4114×6061

## Note
**1. Evaluation on Dynamic Tensor Increments**

Twitter Topic and MovieLens followed a similar procedure to MAST to conduct the experiments. 
Randomly chose {50%, 80%, 90%} entries of the entire tensor as missing for each dataset.
The dimension of embedding vectors(Rank), from {3, 5, 8, 10}. In incremental case, the batch size is training data in this increment.

Example:

* Twitter Topic: RUN "twitter/main.m", you can set Rank, say "R" and tune "v", the initial variance of the embeddings.
For random missing data, for example, for 90% missing, we have missing 90% with five mat file, say "omegaT_90_i.mat"

* MovieLens: same as Twitter Topic.

**2. Evaluation on Streaming Tensor Entries in Arbitrary Orders**

Acc(continuous) and DBLP(binary) are examined POST when tensor entries stream in arbitrary orders. 

Example:

* Acc(continuous): RUN "acc/main.m" ,  you can set Rank, say "R" and tune "v" ,the initial variance of the embeddings. In this case, you can set batch size, say "batch_size"

* DBLP(binary): same as Acc



**3. Uncertainty Investigation**

Example:

* Kaggle-ctr: samse as 2




