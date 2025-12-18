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

Realistically, given a collection of $n$-dimensional points in $bb(R)^n$, we would like to extract meaningful topological information that characterizes these points. Persistent homology is thus one method that computes topological characteristics of this collection of points. Given a collection of points $P$, we first construct a simplicial complex $cal(K)$ known as the Vietoris-Rips (VR) complex. The vertices in $cal(K)$ are just the points in $P$. To build the edges that connect the points, we consider an increasing sequence of radii. For each radius $r$ in the sequence, we superimpose a circle of radius $r$ on each point in $P$. If for some radius $r_1$ the circle of point $x_1$ starts to cover another point $x_2$, then we connect $x_1$ and $x_2$ by an edge at $r_1$.

Notice that as the radius $r$ increases, more and more edges would be connected, leading to emergence and disappearance of topological features. We thus can characterize these topological features by their emergence time and disappearance time, or birth time and death time using standard topology terminology. For instance, recall our previous example concerning points $x_1$ and $x_2$. If a 1-dimensional hole $alpha$ emerges because of the addition of the edge between them at $r_1$, then we would say that $alpha$ has a birth time of $r_1$. Similarly, if at some later radius $r_2 > r_1$ that $alpha$ disappears because of adding another edge in the simplicial complex, then we would denote $r_2$ as the death time of $alpha$.

_#ref(<filtration>)_ below shows a visualization of computing persistent homology using the method described above on a set of points in $bb(R)^2 $. The left figure shows the sequence of radii increasing from $0 $ to $6.15 $, along which edges are added to the simplicial complex. Note that at $r = 5.6 $, the addition of the edge between $p_1 $ and $p_3 $ make the simplicial complex into a quadrilateral, which results in a 1-dimensional hole. Subsequently, at $r= 6.15 $, the quadrilateral is destroyed by the edge between $p_1 $ and $p_4 $, causing the 1-dimensional hole to disappear. The simplicial complex constructed by increasing the radius $r $ is called a _filtration_. On the other hand, the right figure shows the persistence diagram of this filtration. Note that the 1-dimensional feature described previously corresponds to the orange point at $(5.6, 6.15) $ in the persistence diagram.

#figure(
  grid(
    columns: 2,
    align: center + horizon,
    image("images/filtration_visualization.png"), image("images/persistence_diagrams.png", width: 65%),
  ),
  caption: [Visualization of Vietoris-Rips filtration on a set of points in $bb(R)^2$.],
) <filtration>

= Related Work

= Methodology

= Results & Discussion

= Conclusion

// For bibliography, uncomment and create bib.bib file:
#pagebreak()
#bibliography("bib.bib", full: true)
