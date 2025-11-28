# Literature Review: Topological Analysis of Neural Machine Translation
## Research Proposal by Johnny
### Course: CSC2517 - Discrete Mathematical Models of Sentence Structure

---

## I. Foundational Papers on Topology in NLP

### Core TDA in NLP

1. **Uchendu, A., et al. (2024).** "Unveiling Topological Structures in Text: A Comprehensive Survey of Topological Data Analysis Applications in NLP." *arXiv preprint arXiv:2411.10298*.
   - **Why cite**: Most recent comprehensive survey (2024) of TDA in NLP
   - **Key finding**: Identifies multilingual tasks as underexplored area needing more TDA research
   - **Quote to use**: "One glaring application is on multi-lingual tasks... its application on multi-lingual tasks is necessary"

2. **Zhu, X. (2013).** "Persistent homology: An introduction and a new text representation for natural language processing." *IJCAI*, pages 1953-1959.
   - **Why cite**: First paper to introduce topological text representation
   - **Use for**: Historical context of TDA in NLP

---

## II. Word Embeddings and Topology (Most Relevant!)

### The Shape of Language

3. **Fitz, S. (2022).** "The Shape of Words: Topological Structure in Natural Language Data." *ICML 2022 Workshop on Topology, Algebra, and Geometry in Machine Learning*.
   - **Why cite**: THIS IS IN YOUR PROJECT! Direct methodology you'll extend
   - **Key contribution**: Introduces "word manifold" - simplicial complex from n-grams
   - **What they did**: Compared topological features (Betti numbers) across 6 languages
   - **Your extension**: You'll apply similar analysis to translation pairs

4. **Draganov, O., & Skiena, S. (2024).** "The Shape of Word Embeddings: Quantifying Non-Isometry with Topological Data Analysis." *Findings of EMNLP 2024*.
   - **Why cite**: Very recent (2024) work on topology of embeddings across 81 languages
   - **Key method**: Uses persistent homology to measure distances between language pairs
   - **Relevance**: Proves that topological "shape" of embeddings carries linguistic information

5. **Gholizadeh, S., Seyeditabari, A., & Zadrozny, W. (2020).** "A novel method of extracting topological features from word embeddings." *arXiv preprint arXiv:2003.13074*.
   - **Why cite**: Specific methods for extracting TDA features from embeddings
   - **Use for**: Technical methodology section

---

## III. Cross-Lingual Topology (CRITICAL FOR YOUR PROJECT!)

### Direct Precedent

6. **Meirom, S. H., & Bobrowski, O. (2022).** "Unsupervised geometric and topological approaches for cross-lingual sentence representation and comparison." *Proceedings of the 7th Workshop on Representation Learning for NLP @ ACL 2022*.
   - **⭐ MOST IMPORTANT PAPER FOR YOUR PROJECT ⭐**
   - **Why cite**: Only paper directly studying topology across languages
   - **Key finding**: "geometric and topological structures of sentences are preserved to a significant level across languages"
   - **What they did**: Used distance matrices + persistent homology for sentence comparison
   - **Your innovation**: They used static embeddings; you'll study active translation with attention

### Cross-Lingual Embeddings (Background)

7. **Lample, G., Conneau, A., Denoyer, L., & Ranzato, M. (2018).** "Unsupervised machine translation using monolingual corpora only." *ICLR*.
   - **Why cite**: Background on unsupervised NMT
   - **Use for**: Contextualizing translation models

8. **Xu, H., & Koehn, P. (2021).** "Cross-lingual BERT contextual embedding space mapping with isotropic and isometric conditions." *arXiv preprint arXiv:2107.09186*.
   - **Why cite**: Geometric properties of cross-lingual embeddings
   - **Relevance**: Discusses isometry (geometric invariance) - contrast with your topological approach

---

## IV. Attention Mechanisms and Linguistic Structure

### Attention Encodes Syntax

9. **Chi, E. A., Hewitt, J., & Manning, C. D. (2021).** "Attention Can Reflect Syntactic Structure (If You Let It)." *arXiv preprint arXiv:2101.10927*.
   - **Why cite**: Shows attention patterns encode dependency syntax across 18 languages
   - **Key finding**: Individual attention heads track specific linguistic relations
   - **Relevance**: Justifies analyzing attention matrices for linguistic structure

10. **Clark, K., Khandelwal, U., Levy, O., & Manning, C. D. (2019).** "What Does BERT Look At? An Analysis of BERT's Attention." *Proceedings of ACL*.
   - **Why cite**: Foundational work on interpreting attention patterns
   - **Use for**: Background on attention analysis methods

11. **Tenney, I., Das, D., & Pavlick, E. (2019).** "BERT Rediscovers the Classical NLP Pipeline." *Proceedings of ACL*.
   - **Why cite**: Shows different layers encode different linguistic phenomena
   - **Relevance**: Motivates layer-wise topological analysis

---

## V. Topology in Neural Networks (For Methodology)

### Persistent Homology in Deep Learning

12. **Rieck, B., et al. (2019).** "Neural Persistence: A Complexity Measure for Deep Neural Networks Using Algebraic Topology." *ICLR*.
   - **Why cite**: THIS IS IN YOUR PROJECT! Methods for computing topology of networks
   - **Key method**: Filtration based on weight magnitudes to compute persistent homology
   - **Your adaptation**: Apply similar filtration to attention weights

13. **Guss, W. H., & Salakhutdinov, R. (2018).** "On characterizing the capacity of neural networks using algebraic topology." *arXiv preprint arXiv:1802.04443*.
   - **Why cite**: THIS IS IN YOUR PROJECT! Theoretical foundations
   - **Key concept**: Betti numbers characterize network expressivity
   - **Relevance**: Theoretical justification for topological analysis

14. **Balwani, A., & Krzyston, J. (2022).** "Zeroth-Order Topological Insights into Iterative Magnitude Pruning." *ICML 2022 Workshop on TAG-ML*.
   - **Why cite**: THIS IS IN YOUR PROJECT! Zeroth-order (connected components) analysis
   - **Method**: Maximum spanning tree analysis of weight graphs
   - **Your use**: Similar graph construction for attention patterns

---

## VI. Transformer Architecture and NMT

### Core Transformer Papers

15. **Vaswani, A., et al. (2017).** "Attention Is All You Need." *NeurIPS*.
   - **Why cite**: MUST CITE - introduces Transformer architecture
   - **Use for**: Describing the NMT model architecture

16. **Luong, M.-T., Pham, H., & Manning, C. D. (2015).** "Effective Approaches to Attention-based Neural Machine Translation." *EMNLP*.
   - **Why cite**: Foundational attention-based NMT
   - **Use for**: Background on attention in translation

### Multilingual NMT

17. **NLLB Team (2022).** "No Language Left Behind: Scaling Human-Centered Machine Translation." *Nature*.
   - **Why cite**: State-of-the-art multilingual NMT system (200 languages)
   - **Potential use**: Could use this model for experiments

---

## VII. Related Topology Work (Optional/Supplementary)

### Attention Topology

18. **Kushnareva, L., et al. (2021).** "Artificial text detection via examining the topology of attention maps." *EMNLP*.
   - **Why cite**: Uses persistent homology on attention matrices
   - **Relevance**: Demonstrates feasibility of topological attention analysis
   - **Different focus**: They detect synthetic text; you study translation

19. **Cherniavskii, D., et al. (2022).** "Acceptability judgements via examining the topology of attention maps." *Findings of EMNLP*.
   - **Why cite**: Another example of topology on attention
   - **Use for**: Methodological parallels

### BERT Compression with Topology

20. **Balderas, L., & Domínguez, M. (2023).** "Can persistent homology whiten Transformer-based black-box models? A case study on BERT compression." *arXiv preprint arXiv:2312.10702*.
   - **Why cite**: Uses zeroth-dimensional persistent homology on BERT
   - **Relevance**: Shows PH can identify important neurons
   - **Difference**: They compress; you analyze linguistic structure

---

## VIII. Theoretical Foundations (Mathematical Background)

### TDA Theory

21. **Edelsbrunner, H., Letscher, D., & Zomorodian, A. (2002).** "Topological persistence and simplification." *Discrete & Computational Geometry*, 28(4):511-533.
   - **Why cite**: Foundational paper on persistent homology
   - **Use for**: Explaining persistent homology in methodology

22. **Carlsson, G. (2009).** "Topology and data." *Bulletin of the American Mathematical Society*, 46(2):255-308.
   - **Why cite**: Accessible introduction to TDA
   - **Use for**: Mathematical background section

23. **Zomorodian, A. (2012).** "Topological data analysis." *Advances in applied and computational topology*, 70:1-39.
   - **Why cite**: TDA tutorial/survey
   - **Use for**: General TDA methodology

---

## IX. Libraries and Tools (For Methods Section)

24. **Bauer, U. (2021).** "Ripser: Efficient computation of Vietoris-Rips persistence barcodes." *Journal of Applied and Computational Topology*, 5:391-423.
   - **Why cite**: Ripser library for computing persistent homology
   - **Use for**: Describing computational tools

25. **Wolf, T., et al. (2020).** "Transformers: State-of-the-Art Natural Language Processing." *EMNLP: System Demonstrations*.
   - **Why cite**: HuggingFace Transformers library
   - **Use for**: Describing how you'll extract attention matrices

---

## Suggested Citation Organization in Your Proposal

### Introduction (Papers 15, 16, 1, 3)
Start with Transformer/NMT background, then motivation from TDA survey and "Shape of Words"

### Related Work - Section A: Topology in NLP (Papers 1, 2, 3, 4, 5)
Establish that topological analysis has been successfully applied to text

### Related Work - Section B: Cross-Lingual Topology (Papers 6, 7, 8)
**Emphasize paper #6 (Meirom & Bobrowski)** as your direct precedent

### Related Work - Section C: Attention and Linguistic Structure (Papers 9, 10, 11)
Justify that attention patterns are worth analyzing

### Related Work - Section D: Topology of Neural Networks (Papers 12, 13, 14)
Methods for applying topology to network architectures

### Methodology (Papers 21, 22, 23, 24, 25)
Mathematical foundations and tools

---

## Key Arguments to Make in Your Proposal

1. **Gap Identification**: 
   - Cite papers 1, 6: "Recent surveys identify multilingual tasks as underexplored in TDA"
   - Cite paper 6: "While Meirom & Bobrowski (2022) studied static embeddings, no work analyzes topology during active translation"

2. **Feasibility**:
   - Cite papers 3, 12, 14: "Topological methods have been successfully applied to both text data and neural networks"
   - Cite papers 18, 19: "Attention matrices can be analyzed topologically"

3. **Theoretical Grounding**:
   - Cite papers 9, 11: "Attention patterns encode linguistic structure"
   - Cite papers 4, 6: "Topological features capture language-specific information"

4. **Novelty**:
   - YOUR CONTRIBUTION: First work to study how translation affects topological structure through attention analysis

---

## Papers NOT to Miss in Your Proposal

**Critical Must-Cites:**
- Paper #3 (Fitz - Shape of Words) - YOUR COURSE PAPER
- Paper #6 (Meirom & Bobrowski) - DIRECT PRECEDENT
- Paper #9 (Chi et al. - Attention reflects syntax) - JUSTIFIES ATTENTION ANALYSIS
- Paper #12 (Rieck - Neural Persistence) - YOUR COURSE PAPER
- Paper #15 (Vaswani - Transformers) - FOUNDATIONAL

**Strong Recommendations:**
- Papers #1, 4 (Recent surveys and shape work)
- Papers #13, 14 (Topology methods from your course)
- Papers #21, 22 (TDA foundations)

---

## Total: ~25 papers
- Core citations: 8-10 papers
- Supporting citations: 15-17 papers
- This is a good range for a course project proposal

