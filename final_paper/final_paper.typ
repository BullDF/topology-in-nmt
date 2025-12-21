// Typst Template - Converted from LaTeX
// Equivalent to your standard LaTeX article template

// Variables (like \newcommand for assignment details)
#let assignmentname = "Topology in Neural Machine Translation: A Topological Study of Transformers through Attention"
#let shortassignmentname = "Topology in Neural Machine Translation"
#let duedate = "23 Dec 2025"

// Markers for headings without number
#show selector(<nonumber>): set heading(numbering: none)

// Page setup - equivalent to geometry package
#set page(
  paper: "a4",
  margin: (
    x: (8.5in - 7in) / 2, // Centers 7in width on page
    y: (11in - 8.5in) / 2, // Centers 8.5in height on page
  ),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 10pt)
      #grid(
        columns: (1fr, 2fr, 1fr),
        align: (left, center, right),
        [#duedate], [#shortassignmentname], [Johnny Meng],
      )
      #v(-1.5em)
      #line(length: 100%, stroke: 0.5pt)
    ]
  },
  footer: context {
    align(center)[
      #set text(size: 12pt)
      #counter(page).display("1")
    ]
  },
)

// Text settings
#set text(
  size: 12pt,
  lang: "en",
  hyphenate: false, // Equivalent to \usepackage[none]{hyphenat}
)

// Paragraph settings
#set par(
  justify: true,
  leading: 0.65em * 1.5, // Equivalent to \onehalfspacing
  spacing: 7mm, // Paragraph spacing
  first-line-indent: 0em, // Equivalent to parskip package
)

// Heading numbering
#set heading(numbering: "1.")

// List settings
#set list(indent: 1.5em)
#set enum(indent: 1.5em)

// Heading spacing
#show heading: it => {
  set block(above: 1.5em, below: 1.5em)
  it
}

// Hyperlinks
#show link: set text(fill: blue)

// Theorem-like environments
#let proof(body) = [
  _Proof._ #body #h(1fr) $square.filled$
]

#let solution(body) = [
  _Solution._ #body #h(1fr) $square.filled$
]

// Custom math commands (like \newcommand)
#let del = $partial$

// Title page
#align(center)[
  #text(size: 18pt, weight: "bold")[
    #assignmentname
  ]

  #v(0.5em)

  #text(size: 14pt)[
    Yuwei (Johnny) Meng
  ]

  #v(0.3em)

  #text(size: 12pt)[
    #duedate
  ]
]

#v(1em)

// Document content starts here

= Abstract <nonumber>

The transformer architecture revolutionized Natural Language Processing, but understanding how transformers process language remains an active area of research, with NMT being particularly underexplored. This study applies TDA to NMT by analyzing attention maps from the NLLB model on 2,000 sentence pairs each from WMT French-English and Chinese-English datasets. We compute persistent homology on attention-derived graphs and measure cross-language topological similarity using Wasserstein distances between persistence diagrams. For French-English, we find a statistically significant negative correlation between topological dissimilarity and average BLEU scores ($r = -0.132$, $p = 2.84 times 10^(-9)$) after controlling for sentence length, indicating that topological structure preservation independently contributes to translation quality. However, the Chinese-English analysis revealed systematic model limitations that severely affected BLEU scores. The contrast between the strong French-English correlation and the confounded Chinese-English results suggests that topological structure preservation may be particularly important for typologically related language pairs, where the model demonstrates more reliable performance.

= Introduction

In 2017, a group of researchers at Google proudly announced the architecture of the transformer neural model, which revolutionized the field of Natural Language Processing (NLP) #cite(<vaswani>, style: "apa"). Before then, neural NLP models mainly relied on recurrent structures, such as RNNs and LSTMs, optionally with the attention mechanism to boost performance. The transformer architecture, however, abandoned the recurrent structure in RNNs and LSTMs and solely utilized attention for language modeling, which was a novel but successful approach. Since the invention of transformer, NLP researchers have been applying this architecture to various NLP tasks, one of which is Machine Translation (MT). MT is an NLP task that takes a sentence in a source language as input and outputs the translated sentence in a target language, and Neural Machine Translation (NMT) is a subfield of MT that specifically uses neural networks as the model for the translation. According to #cite(<vaswani>, form: "prose", style: "apa"), the transformer model achieved a BLEU score of 41.0 on the WMT14 English-to-French benchmark, establishing a new state-of-the-art performance.

Despite the prominent performance of transformer, similar to other neural network architectures, the specific reasons behind its success remain largely unknown, particularly in the context of NMT. One method to probe the interpretability of neural networks is through Topological Data Analysis (TDA), where topological features that are intrinsic to the data and model are extracted and explained. This method, nevertheless, is also underexplored in NMT. Therefore, in this research project, I propose to apply TDA to explain the power of transformer on the task of NMT. Since the attention mechanism is the core of transformer, topology-related techniques will be applied to analyze the attention maps generated by transformer models during translation. Considering my knowledge of English and French and the abundance of such evaluation datasets, I will focus on the English-to-French translation task. The specific research question is as follows:

#quote(block: true)[
  _Do French and English sentences create similar topological structures in the attention maps generated by transformer models during translation? If so, does similarity in the topological structures of attention maps correlate with translation quality? What about Chinese and English sentences?_
]

= Background

== Algebraic Topology

Topology is a branch of mathematics that characterizes shapes, spaces, and sets by their connectivity #cite(<guss>, style: "apa"). Algebraic topology, more sophisticatedly, is a subfield of topology that attributes algebraic properties such as groups and chains to topological spaces in order to make explanations and interpretations more expressive. Formally, let $X$ be a compact metric space. We can define a $p$-simplex to be a collection of points ${x_0, dots.h.c, x_n} subset.eq X$ in $p$-dimension. Depending on the value of $p$, these simplices bear different names:

- $p=0$: point
- $p=1$: line
- $p=2$: triangle
- $p=3$: tetrahedron
- $dots.h.c$

Now consider a collection of such $p$-simplices, called $cal(K)$. Then $cal(K)$ is called a _simplicial_ complex if it satisfies these conditions:

1. If $sigma in cal(K)$ and $tau$ is a face of $sigma$, then $tau in cal(K)$;
2. If $sigma_1, sigma_2 in cal(K)$, then $sigma_1 inter sigma_2 = emptyset$ or $sigma_1 inter sigma_2 in cal(K)$.

Given a simplicial complex $cal(K)$ in the compact metric space $X$, one method that is frequently used to study $cal(K)$ is homology. The core idea of homology is to construct chains, cycles, and boundaries from the simplices in $cal(K)$ and analyze their relationships. Given a dimension $n$, the $n$th homology group of the compact metric space $X$ is defined as $H_n (X) = bb(Z)^(beta_n)$, where $beta_n$ is called the _$n$th Betti number_. For $n >= 1$, the $n$th Betti number $beta_n$ measures the number of $n$-dimensional holes in the simplicial complex $cal(K)$, while $beta_0$ measures the number of connected components in $cal(K)$. For example, a torus is a 3-dimensional object with 1 connected component, 2 1-dimensional holes, and 1 2-dimensional void. Therefore, the homology groups of the torus are $H_0 (X) = bb(Z)^1$, $H_1 (X) = bb(Z)^2$, and $H_2 (X) = bb(Z)^1$.

== Persistent Homology <sec:persistent_homology>

Realistically, given a collection of $n$-dimensional points in $bb(R)^n$, we would like to extract meaningful topological information that characterizes these points. Persistent homology is thus one method that computes topological characteristics of this collection of points. Given a collection of points $P$, we first construct a simplicial complex $cal(K)$ known as the Vietoris-Rips (VR) complex. The vertices in $cal(K)$ are just the points in $P$. To build the edges that connect the points, we consider an increasing sequence of radii. For each radius $r$ in the sequence, we superimpose a circle of radius $r$ on each point in $P$. If for some radius $r_1$ the circle at point $x_1$ starts to cover another point $x_2$, then we connect $x_1$ and $x_2$ by an edge at $r_1$.

Notice that as the radius $r$ increases, more and more edges would be connected, leading to emergence and disappearance of topological features. We thus can characterize these topological features by their emergence time and disappearance time, or birth time and death time using standard topology terminology. For instance, recall our previous example concerning points $x_1$ and $x_2$. If a 1-dimensional hole $alpha$ emerges because of the addition of the edge between them at $r_1$, then we would say that $alpha$ has a birth time of $r_1$. Similarly, if at some later radius $r_2 > r_1$ that $alpha$ disappears because of adding another edge in the simplicial complex, then we would denote $r_2$ as the death time of $alpha$.

@fig:filtration below shows a visualization of computing persistent homology using the method described above on a set of points in $bb(R)^2$. The left figure shows the sequence of radii increasing from $0$ to $6.15$, along which edges are added to the simplicial complex. Note that at $r = 5.6$, the addition of the edge between $p_1$ and $p_3$ make the simplicial complex into a quadrilateral, which results in a 1-dimensional hole. Subsequently, at $r= 6.15$, the quadrilateral is destroyed by the edge between $p_1$ and $p_4$, causing the 1-dimensional hole to disappear. The simplicial complex constructed by increasing the radius $r$ is called a _filtration_. On the other hand, the right figure shows the persistence diagram of this filtration. Note that the 1-dimensional feature described previously corresponds to the orange point at $(5.6, 6.15)$ in the persistence diagram.

#figure(
  grid(
    columns: 2,
    align: center + horizon,
    image("images/filtration_visualization.png"), image("images/persistence_diagram.png", width: 65%),
  ),
  caption: [Visualization of Vietoris-Rips filtration on a set of points in $bb(R)^2$.],
  placement: auto,
) <fig:filtration>

Now given two sets of points, we can compute separately their persistence diagrams using persistent homology, but we need a metric to compare the two persistence diagrams. _Wasserstein distance_ is the most common metric for this task. Given persistence diagrams $D_1$ and $D_2$, Wasserstein distance finds the best bijection between points in $D_1$ and $D_2$ and computes the sum of distances between matched points. Formally, let $p$ be a fixed dimension. The $p$-Wasserstein distance between $D_1$ and $D_2$ is defined as:

$
  W_p (D_1, D_2) = inf_(phi.alt: D_1 arrow.r D_2) (sum_(x in D_1) ||x - phi.alt(x)||^p)^(1 slash p).
$

The Wasserstein distance between $D_1$ and $D_2$ is thus:

$
  W(D_1, D_2) = sum_(n=0)^infinity W_n (D_1, D_2).
$

= Related Work

There are numerous past studies that focused on using algebraic topology to analyze neural networks. For example, the paper by #cite(<bianchini>, form: "prose", style: "apa") is a pioneer study that leveraged topological tools to compare the expressivity of shallow and deep neural networks. They discovered that for deep neural networks, the sum of the Betti numbers, as a metric that measures the topological complexity that the network can express, can grow exponentially with the number of hidden units. Later, #cite(<guss>, form: "prose", style: "apa") extended this work by empirically applying Betti numbers to measure the topological complexity of real-world datasets and characterize the expressivity of fully-connected neural networks. These studies laid a solid foundation for using topological tools to study neural networks, but the generalization of such techniques to more complex neural structures still remains limited.

In addition to studying neural networks using topology, there are also attempts to apply topological techniques on language modeling. #cite(<fitz>, form: "prose", style: "apa") introduces the notion of a _word manifold_, which turns $n$-gram models on raw texts of various languages into simplicial complexes, allowing for topological analysis. This study differs from my proposed study in that the method is applied to raw texts with no neural models associated with it. More recently, #cite(<draganov>, form: "prose", style: "apa") makes an effort to study word embeddings generated by large language models by considering the $d$-dimensional space that these embeddings are located in as a topological space. Then, they applied persistent homology to extract topological patterns from the embedding spaces formed by 81 languages. Their study suggested statistically significant results that word embeddings carry meaningful linguistic information, but there was no analysis of the underlying neural models.

Perhaps the most closely related study to my proposed topic is the one by #cite(<meirom>, form: "prose", style: "apa"). In this study, they also looked at embeddings as #cite(<draganov>, form: "prose", style: "apa") did, but they argue that certain semantics are inherent to the real world and are not language dependent. For example, _dog_ and _cat_ are both common pets so they often appear in the same context regardless of the language. Under this assumption, they claimed that the embedding spaces of different languages should be isomorphic to each other at the sentence level, and their results supported this. An interesting question therefore arose from this study: since the embedding spaces of different languages at the sentence level are isomorphic, and an NMT system transforms a sentence from the source language to the target language, how does the NMT system preserve such isomorphism during translation? This question is thus the main motivation of my proposed research.

Now, is looking at attention feasible? Previous studies said yes. #cite(<ravishankar>, form: "prose", style: "apa") studied fully using the attention of multilingual BERT to decode syntactic dependency trees of 18 languages, including English and French, and their results showed that solely using attention can achieve competitive accuracy in dependency parsing, suggesting that attention does encode meaningful syntactic information, which could be helpful in translation as well. Furthermore, #cite(<kushnareva>, form: "prose", style: "apa") studied the attention mechanism with topology. In the study, they first built weighted graphs from attention maps by treating tokens as nodes and attention weights as edges, followed by applying persistent homology on the graph to construct a filtration. Their topic was on detecting artificially generated texts which is different from mine, but this process is inspiring that I will adopt in my study.

To conclude this section, #cite(<uchendu>, form: "prose", style: "apa") in their paper of a survey on using TDA to approach NLP problems stated that:

#quote(block: true)[
  _One glaring application is on multi-lingual tasks... Due to the benefits of TDA which include performing robustly on heterogeneous, imbalanced, and noisy data, its application on multi-lingual tasks is necessary._
]

Hence, the current study of applying TDA on NMT systems is motivated.

= Methodology

== Model

This study revolves around studying the attention mechanisms of NMT systems. Therefore, an NMT system must be selected so that we can extract the attention maps to analyze. In this study, the NLLB (No Language Left Behind) model developed by Meta was chosen #cite(<nllb>, style: "apa"). This model offers translation between 200 languages, including English, French and Chinese, and is open-sourced. The NLLB models are available on Hugging Face ranging from 600M to 54B parameters. The distilled NLLB with 1.3B parameters was selected for its balance between performance and computational cost. This model has 24 encoder layers and 24 decoder layers, each layer containing 16 attention heads.

== Datasets

The selected model must be run on a corpus to generate the attention maps. I picked the evaluation datasets curated by the _Workshop on Machine Translation (WMT)_. WMT is a well-known NMT benchmark that hosts annual MT competitions, each year with a different combination of source and target languages. In this study, the 2014 WMT (WMT14) benchmark is chosen for the French-English analysis and the 2017 WMT (WMT17) benchmark is chosen for the Chinese-English analysis due to their popularity. #cite(<vaswani>, form: "prose", style: "apa") also used WMT14 to evaluate their transformer model.

The WMT14 French-English benchmark contains 3,000 validation sentence pairs, while the WMT17 Chinese-English benchmark contains only 2,000 validation sentence pairs. To ensure a fair comparison between languages, I selected only the first 2,000 sentence pairs from the WMT14 French-English validation dataset, and all 2,000 sentence pairs from the WMT17 Chinese-English validation dataset to conduct the experiment.

== Experiment

We would like to analyze whether the attention maps generated by the NMT model are different for each language. Therefore, for each French-English sentence pair in the datasets, the model is run on the English sentence to generate the French translation, as well as on the French sentence to generate the English translation. This way, the encoder of NLLB would process the same sentence twice but in two different languages, and so we can extract the encoder attention map for both the English and French sentences. The experiment is repeated for the Chinese-English sentence pairs. Upon generating the translations, only the attention maps in the last layer of the encoder are extracted for analysis, since the last layer is expected to contain the most refined attention information. The attention weights across the 16 heads are mean-aggregated to form a single attention map for each sentence.

After the attention maps for all the sentence pairs are generated and extracted, we apply topological methods to analyze these attention maps. For each attention map, we build a weighted graph by treating the words in the sentence as nodes and adapting the attention weights as edges, following #cite(<kushnareva>, form: "prose", style: "apa"). The weight of each edge has the value of $1 - alpha$, where $alpha$ is the attention weight between two words. This way, a higher attention weight would correspond to a smaller edge weight, resembling a shorter distance between two nodes. This method allows a more intuitive interpretation of the Vietoris-Rips complex constructed later.

Upon building the weighted graph for each attention map, we run the filtration process described in @sec:persistent_homology to compute the persistence diagram using persistent homology. Consequently, for each sentence pair, this step results in two persistence diagrams, one for the English sentence and one for the sentence in the other language (French or Chinese). In this study, only zeroth-order and first-order topological features are considered for two reasons. First, the French-English dataset has mean sentence lengths of 17.9 tokens for English and 19.4 tokens for French, while the means for the Chinese-English dataset are 26.0 for English and 43.9 for Chinese. These numbers indicate that the VR complexes for the sentence pairs are relatively small, making higher-order topological features less likely to appear. Second, zeroth-order and first-order features are easier to interpret in the context of attention maps than higher-order features, which may not have clear meanings in this setting.

The corresponding computed persistence diagrams for each sentence pair permit the calculation of the Wasserstein distance between the two diagrams. From the Wasserstein distance, we learn how NMT systems attend to different languages differently at a topological level. In this context, a smaller Wasserstein distance indicates that the attention maps for the two languages are topologically similar, which shows that the NMT system processes the two languages in a similar manner. Conversely, a larger Wasserstein distance indicates that the attention maps are topologically different, suggesting that the NMT system treats the two languages differently.

Lastly, we would like to see if topological differences in attention maps can be an indication of translation quality. Therefore, given the translation generated in a previous step of the experiment, we compute the BLEU score by comparing the translation to the reference sentence in the dataset. For each language direction, we aggregate the BLEU score information and conduct correlation analysis with the Wasserstein distances computed previously. For this step, we hypothesize a strong negative correlation between BLEU scores and Wasserstein distances, as it is intuitive that better translations should correspond to more similar attention maps between the two languages.

= Results & Discussion

This section presents the topological findings from the experiment described above. @sec:topology_results shows the analysis of attention maps using Wasserstein distance, delving into whether transformer models attend to sentences of different languages differently. Next, @sec:translation_quality presents some insights into the translation quality of the NMT system used in this study. Then, @sec:correlation_analysis combines the results from @sec:topology_results and @sec:translation_quality and conducts correlation analysis to see if topological differences and translation quality are correlated. Lastly, @sec:error_analysis concludes this section by suggesting some possible explanations for the observed results, further enhancing the interpretability of the findings.

== Topology <sec:topology_results>

Before analyzing the topological features in the attention maps, let's examine a typical attention map. The left plot of @fig:attention_example below shows the averaged self-attention in the last layer of the encoder for an English sentence. From the plot, note that the NLLB model creates a language tag at the beginning of the sentence, as well as an end-of-sentence (EOS) tag at the end of the sentence. Further notice that the EOS column of the plot has a very light color, meaning that every token in the sentence seems to attend strongly to the EOS token. This phenomenon suggests that the model considers the EOS token to be very important, perhaps using it as a scratchpad to store information about the entire sentence. The pattern is also present for the language tag, but not as strong as EOS. However, since we are analyzing how the NMT model understands the sentence, not byproducts of the translation process, these special tags are removed and the remaining attention weights are renormalized to 1 for the topological analysis. The middle plot of @fig:attention_example shows the attention map after filtering and renormalization. Additionally, the right plot of @fig:attention_example shows the distance matrix of the sentence, where each distance has the value of $1 - alpha$, with $alpha$ being the attention weight between two words, and the distance of every word to itself is set to 0.

#figure(
  grid(
    columns: 3,
    image("images/attention_example.png"),
    image("images/attention_example_filtered.png"),
    image("images/distance_matrix_example.png"),
  ),
  caption: [Attention maps and distance matrix for the English sentence "A Republican strategy to counter the re-election of Obama".],
  placement: auto,
) <fig:attention_example>

With the distance matrix, the persistence diagram of this attention map can be computed. @fig:persistence_diagrams below shows the persistence diagrams of the same sentence presented in @fig:attention_example in English and French. Note that both persistence diagrams show various zeroth-order topological features, which is expected because different parts of the sentence attend differently to each other. However, first-order topological features seem to be rare and ephemeral in both diagrams, indicating that there are not many loops in the attention maps, and loops tend to be short-lived. These patterns are consistent across most sentences, both in the French-English and Chinese-English datasets.

#figure(
  grid(
    columns: 2,
    image("images/persistence_diagram_en.png"), image("images/persistence_diagram_fr.png"),
  ),
  caption: [Persistence diagrams for the English sentence "A Republican strategy to counter the re-election of Obama" (left) and its French translation "Une stratégie républicaine pour contrer la réélection d'Obama" (right).],
  placement: auto,
) <fig:persistence_diagrams>

@tab:summary_stats below shows the summary statistics for the metrics computed for both the French-English and Chinese-English datasets. The table presents the minimum, maximum, mean, and median values for Wasserstein distances, token counts, and topological features across the 2,000 sentence pairs for each language pair. From the table, note that the majority of topological differences between languages seem to stem from zeroth-order topological features, as we can see that first-order topological features only contribute to smaller than 1.0 Wasserstein distance on average for both datasets. This discovery aligns with the previous observation that first-order topological features are rare in attention maps. Furthermore, the French sentences in our dataset are generally longer than their English counterparts, but the Chinese sentences have about the same number of tokens as their English counterparts. Nevertheless, the model still generates more $H_1$ features for Chinese sentences than for English sentences on average, indicating that the model attends to Chinese sentences in a more complex manner.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    [*Metric*], [*Min*], [*Max*], [*Mean*], [*Median*],
    table.cell(colspan: 5, align: center, [*French-English*]),
    [Wasserstein Distance (Total)], [0.0], [40.9], [5.0], [4.1],
    [Wasserstein Distance ($H_0$)], [0.0], [40.3], [5.0], [4.1],
    [Wasserstein Distance ($H_1$)], [0.0], [0.5], [0.1], [0.0],
    [Token Count ($H_0$ Features) (English)], [1], [117], [24.7], [22],
    [Token Count ($H_0$ Features) (French)], [2], [177], [31.7], [28],
    [$H_1$ Features (English)], [0], [51], [4.6], [3],
    [$H_1$ Features (French)], [0], [78], [5.7], [4],
    table.cell(colspan: 5, align: center, [*Chinese-English*]),
    [Wasserstein Distance (Total)], [0.2], [26.6], [4.4], [3.5],
    [Wasserstein Distance ($H_0$)], [0.2], [26.2], [4.2], [3.3],
    [Wasserstein Distance ($H_1$)], [0.0], [0.7], [0.1], [0.1],
    [Token Count ($H_0$ Features) (English)], [2], [109], [36.0], [35],
    [Token Count ($H_0$ Features) (Chinese)], [4], [111], [36.2], [35],
    [$H_1$ Features (English)], [0], [41], [8.4], [8],
    [$H_1$ Features (Chinese)], [0], [67], [12.6], [11],
  ),
  caption: [Summary statistics for topological metrics computed on the French-English and Chinese-English datasets (2,000 sentence pairs each).],
  placement: auto,
) <tab:summary_stats>

== Translation Quality <sec:translation_quality>

Now we examine the translation quality of the NLLB model on the datasets with BLEU scores. The BLEU metric is a widely-used measurement of translation quality that compares the generated translation to a reference sentence. The BLEU score is comprised of a brevity penalty factor that penalizes the translation from being too short, as well as a geometric mean of modified $n$-gram precisions that measures how many $n$-grams in the translation appear in the reference sentence. The final BLEU score ranges from 0 to 100, with higher scores indicating better translation quality #cite(<papineni>, style: "apa").

@fig:bleu_distributions below shows the distributions of BLEU scores for translations in the French-English and Chinese-English datasets. From the plots, we note that the Chinese-English language pair achieves lower BLEU scores on average than the French-English, by approximately 10 points. In particular, perfect translation ($"BLEU" = 100$) is not uncommon between French and English but rarely seen in Chinese-English translations. This phenomenon is expected because French and English have the same typological roots, while Chinese belongs to a completely different language family. Therefore, it is generally more difficult to translate between Chinese and English than between French and English. A more specific analysis of translation errors is presented in @sec:error_analysis.

#figure(
  grid(
    rows: 2,
    image("images/bleu_distributions_fr_en.png"),
    image("images/bleu_distributions_zh_en.png"),
  ),
  caption: [Distributions of BLEU scores for translations in the French-English (top) and Chinese-English (bottom) datasets.],
  placement: auto,
) <fig:bleu_distributions>

== Correlation Analysis <sec:correlation_analysis>

After computing the Wasserstein distances and BLEU scores for all 2,000 sentence pairs in the datasets, we conduct a correlation analysis to examine whether Wasserstein distance is an indication of translation quality. @fig:wasserstein_bleu below shows the scatter plots of Wasserstein distances and BLEU scores for the datasets. We notice that in all 6 plots, the Pearson correlation coefficients are all negative, but the magnitudes are all smaller than 0.1. All the coefficients are statistically significant at the significance level of 0.05, with $p$-values less than 0.05. These results suggest that, although the correlations are weak, there is significant evidence that there are negative correlations between Wasserstein distances and BLEU scores in all language directions. This finding partially supports our earlier hypothesis that there is a negative correlation between topological differences and translation quality, as better translations should correspond to more similar attention maps. However, the correlation is not as strong as expected.

#figure(
  grid(
    rows: 2,
    image("images/wasserstein_bleu_fr_en.png"),
    image("images/wasserstein_bleu_zh_en.png"),
  ),
  caption: [Scatter plots showing the relationship between Wasserstein distances and BLEU scores for the French-English (top) and Chinese-English (bottom) datasets.],
  placement: auto,
) <fig:wasserstein_bleu>

Now, as shown in @tab:summary_stats above, token count directly reflect the number of zeroth-order topological features in the sentence, which can possibly confound the correlation analysis of Wasserstein distances and BLEU scores. This factor is also intuitively worrisome because longer sentences are generally more difficult to translate correctly, hence lowering translation quality. Therefore, a correlation analysis that controls for the effect of token count is necessary. @fig:partial_correlation below shows the scatter plots for this purpose.

#figure(
  grid(
    rows: 2,
    image("images/partial_correlation_fr_en.png"),
    image("images/partial_correlation_zh_en.png"),
  ),
  caption: [Scatter plots showing the relationship between Wasserstein distances and BLEU scores after controlling for token counts for the French-English (top) and Chinese-English (bottom) datasets.],
  placement: auto,
) <fig:partial_correlation>

@fig:partial_correlation shows the scatter plots for the partial correlation between Wasserstein distances and BLEU scores. Given the two variables of interest for correlation analysis and one or more possibly confounding variables, partial correlation first fits two linear regression models that use the confounding variables to predict each variable of interest separately. With the linear regression models comes the residuals of the two variables of interest that the confounding variables cannot explain. Then, we carry out the correlation analysis on the two sets of residuals, attempting to find correlation between the two variables of interest in the parts that are not affected by the confounding variables. In the context of this paper, the two variables of interest are the Wasserstein distances and the BLEU scores, while the only confounding variable is the token count.

From @fig:partial_correlation, we note that the partial correlations for the French-English pair are higher than the correlations from @fig:wasserstein_bleu in both language directions, and the partial correlation for the averaged case is the highest. These results are also strongly statistically significant with very small $p$-values. This suggests that, even though French and English sentences have very different token counts as indicated in @tab:summary_stats, this does not seem to confound the correlation between topological differences in the attention maps and translation quality. In fact, controlling for token count renders the correlation stronger, which shows that token count is masking the true correlation between Wasserstein distances and BLEU scores. Therefore, we can conclude that preserving topological features in attention maps independently contributes to translation quality between French and English.

On the other hand, the partial correlations for the Chinese-English pair become weaker as shown in @fig:partial_correlation, with statistically insignificant $p$-values in the English-Chinese direction and the averaged case. This shows that token count, in the Chinese-English case, is strongly confounding with the correlation between Wasserstein distances and BLEU scores. In other words, the difficulty in translating longer sentences stands out more in this case, possibly overwriting the topological differences in the attention maps that the model generates. We will try to provide reasons for this outcome in @sec:error_analysis below.

== Error Analysis <sec:error_analysis>

This section makes an effort to analyzing possible explanations for the observed results. Particularly, we would like to examine the distributions of BLEU scores by delving into assessing the translations that the model generates. As mentioned in @sec:translation_quality, the translations for the Chinese-English pair are generally worse than the translations for the French-English pair, with approximately 10 points lower BLEU scores on average. Therefore, understanding if this is a systematic issue or just random errors is important.

Among the 2,000 Chinese-English sentence pairs, I selected and analyzed the 10 sentence pairs with the lowest average BLEU scores. One severe problem I identified is that many Chinese translations are truncated and incomplete. For example, the English sentence

#quote(block: true)[
  _At 10:00pm, Sun Yijie, who had been pregnant for four months, was released on bail of NT\$200,000._
]

is translated into Chinese as

#quote(block: true)[
  苏伊杰已经怀孕四个月,

  _(Su Yijie had been pregnant for four months,)_
]

and the translation is cut off abruptly at a comma, leaving the latter part of the original sentence untranslated. This is not an isolated case. In fact, 8 out of the 10 sentences with the lowest BLEU scores suffer from this truncation issue. With some experiment, I figured out that this problem persists across multiple decoding strategies, including greedy decoding and beam search, and is specific in the English to Chinese direction.Hence, there is sufficient evidence to claim that the NLLB model has systematic issues when translating from English to Chinese, which severely affects the translation quality. As a result, the correlation analysis between Wasserstein distances and BLEU scores is rendered inaccurate, thus the conclusion for the Chinese-English language pair should be taken with caution.

= Conclusion

To summarize, this paper attempts to understand and interpret Neural Machine Translation (NMT) systems using tools from topological data analysis. A particular focus is placed on analyzing the attention maps that NMT models generate during the translation process. In the study, the NLLB (No Language Left Behind) NMT model with 1.3B parameters developed by Meta is selected for analysis, due to its wide inclusion of languages and powerfulness in this task #cite(<nllb>, style: "apa"). Both French-English and Chinese-English language pairs are selected, considering their typological differences. From the WMT14 and WMT17 MT benchmarks, 2,000 French-English and Chinese-English sentence pairs are acquired, respectively, and the corresponding attention maps are extracted for topological data analysis and the computed Wasserstein distances are correlated with translation quality, measured by BLEU scores.

Before the study, the hypothesis was that higher topological differences, or larger Wasserstein distances between attention maps in the encoder for different languages, are correlated with lower translation quality, or BLEU scores. It is intuitive to formulate this hypothesis because the NMT model is likely to process the two languages in a similar manner and translate better if the attention maps are topologically similar. From the results, we note that this hypothesis is partially supported. Higher topological differences are indeed correlated with lower translation quality, but the correlations are very weak with magnitudes being approximately 0.1. The analysis also shows that the partial correlations between Wasserstein distances and BLEU scores after removing token count are stronger for French-English, but, contrarily, become negligible and statistically insignificant for Chinese-English.

== Future Directions

As mentioned in @sec:error_analysis, the problem that the NLLB model generates truncated Chinese translations from English source sentences is discovered. Therefore, it is recommended that future researchers address this problem by either fixing the bug intrinsically or changing a model completely. After resolving this issue, the Chinese translations can hopefully be more accurate, which would allow a more reliable correlation analysis given better BLEU scores. In addition, this study only looks at French-English and Chinese-English language pairs. Future studies are encouraged to choose other language pairs that have different typological relationships, such as German-English or Arabic-English, to see if the findings in this study generalize.

= Acknowledgements

I am extremely grateful to Professor Gerald Penn and TA Jinman Zhao for giving valuable feedback and conceptual guidance in algebraic topology throughout the process of this research.

// For bibliography, uncomment and create bib.bib file:
#pagebreak()
#bibliography("bib.bib", full: true)
