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

= Introduction

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

Given a simplicial complex $cal(K)$ in the compact metric space $X$, one method that is frequently used to study $cal(K)$ is homology. The core idea of homology is to construct chains, cycles, and boundaries from the simplices in $cal(K)$ and analyze their relationships. Given a dimension $n$, the $n$th homology group of the compact metric space $X$ is defined as $H_n (X) = bb(Z)^(beta_n)$, where $beta_n$ is called the _$n$th Betti number_. For $n >= 1$, the $n$th Betti number $beta_n$ measures the number of $n$-dimensional holes in the space $X$, while $beta_0$ measures the number of connected components in $X$. For example, a torus is a 3-dimensional object with 1 connected component, 2 1-dimensional holes, and 1 2-dimensional void. Therefore, the homology groups of the torus are $H_0 (X) = bb(Z)^1$, $H_1 (X) = bb(Z)^2$, and $H_2 (X) = bb(Z)^1$.

== Persistent Homology

Realistically, given a collection of $n$-dimensional points in $bb(R)^n$, we would like to extract meaningful topological information that characterizes these points. Persistent homology is thus one method that computes topological characteristics of this collection of points. Given a collection of points $P$, we first construct a simplicial complex $cal(K)$ known as the Vietoris-Rips (VR) complex. The vertices in $cal(K)$ are just the points in $P$. To build the edges that connect the points, we consider an increasing sequence of radii. For each radius $r$ in the sequence, we superimpose a circle of radius $r$ on each point in $P$. If for some radius $r_1$ the circle at point $x_1$ starts to cover another point $x_2$, then we connect $x_1$ and $x_2$ by an edge at $r_1$.

Notice that as the radius $r$ increases, more and more edges would be connected, leading to emergence and disappearance of topological features. We thus can characterize these topological features by their emergence time and disappearance time, or birth time and death time using standard topology terminology. For instance, recall our previous example concerning points $x_1$ and $x_2$. If a 1-dimensional hole $alpha$ emerges because of the addition of the edge between them at $r_1$, then we would say that $alpha$ has a birth time of $r_1$. Similarly, if at some later radius $r_2 > r_1$ that $alpha$ disappears because of adding another edge in the simplicial complex, then we would denote $r_2$ as the death time of $alpha$.

_#ref(<filtration>)_ below shows a visualization of computing persistent homology using the method described above on a set of points in $bb(R)^2$. The left figure shows the sequence of radii increasing from $0$ to $6.15$, along which edges are added to the simplicial complex. Note that at $r = 5.6$, the addition of the edge between $p_1$ and $p_3$ make the simplicial complex into a quadrilateral, which results in a 1-dimensional hole. Subsequently, at $r= 6.15$, the quadrilateral is destroyed by the edge between $p_1$ and $p_4$, causing the 1-dimensional hole to disappear. The simplicial complex constructed by increasing the radius $r$ is called a _filtration_. On the other hand, the right figure shows the persistence diagram of this filtration. Note that the 1-dimensional feature described previously corresponds to the orange point at $(5.6, 6.15)$ in the persistence diagram.

#figure(
  grid(
    columns: 2,
    align: center + horizon,
    image("images/filtration_visualization.png"), image("images/persistence_diagrams.png", width: 65%),
  ),
  caption: [Visualization of Vietoris-Rips filtration on a set of points in $bb(R)^2$.],
) <filtration>

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

= Results & Discussion

= Conclusion

// For bibliography, uncomment and create bib.bib file:
#pagebreak()
#bibliography("bib.bib", full: true)
