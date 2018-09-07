# POST
### Probabilistic Streaming Tensor Decomposition (oral presentation), The IEEE International Conference on Data Mining (ICDM), 2018
#### Yishuai Du, Yimin Zheng, Kuang-chih Lee, Shandian Zhe



There are 5 dataset:


* MovieLens, a binary three-mode (user, movie, week) tensor of size 400 × 400 × 31
* Twitter Topic, a binary three-mode (user,expert,topic) tensor, of size 500×500×20. 
* ACC, a continuous tensor which record the three-mode interactions (user, action, resource),of size is 3K × 150 × 30K
* DBLP, a binary three-mode (author, conf erence, keyword) tensor ,bibliography relationships, of size 3K × 150 × 30K


Twitter Topic and MovieLens followed a similar procedure to MAST to conduct the experiments. 
Randomly chose {50%, 80%, 90%} entries of the entire tensor as missing for each dataset.
The dimension of embedding vectors(Rank), from {3, 5, 8, 10}


Twitter Topic: RUN "mis90rank10.m", you can change Rank, say "R" and tune "v", the initial variance of the embeddings.
For random missing data, for example, for mising 90%, we have missing 90% with five mat file, say "omegaT_90_i.mat"

MovieLens: same as Twitter Topic.



