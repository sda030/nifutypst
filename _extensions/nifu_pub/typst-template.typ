
#import "@preview/tablex:0.0.5": tablex, cellx, hlinex

#let NIFU_report(
  title: none,
  subtitle: none,
  authors: (),
  report_no: none,
  abstract: none,
  paper: "a4",
  margin: (x: 4.2cm, y: 3.5cm),
  fontsize: 10.5pt,
  lang: "nb",
  preface: none,
  project_no: none,
  funder: none,
  funder_address: none,
  references: none,
  appendix: none,
  isbn: none,
  issn: none,
  date: none,
  signer_1: none,
  signer_1_title: none,
  signer_2: none,
  signer_2_title: none,
  figure_table: false,
  table_table: false,
  doc
) = {
  set page(
    paper: paper,
    margin: margin,
    footer: locate(loc => {
      if counter(page).at(loc).first() > 2  [
        #align(center)[
          #text(spacing: 0.2cm)[
            #text(size: 11pt)[#counter(page).display()]
            #text(
              fill: rgb("#C84957"),
              size: 12pt)[#symbol("•")] 
            #text(
              size: 8pt, 
              spacing: 0.1cm,
              font: "Calibri")[Rapport #report_no]]]]
    }),
    background: locate(loc => {
      if counter(page).at(loc).first() == 1 [
        #image("nifu_rapp_bg.png")]
      }
    ))
    

  set heading(numbering: "1.1.1    ")

  
  set par(
    justify: true, 
    first-line-indent: 1cm,
    leading: 0.9em)
  
  set text(
    font: "Cambria",
    size: fontsize)
  
  show heading.where(level: 1): it => [
    #pagebreak(weak: true)
    #set text(
      size: 23.5pt,
      weight: "semibold",
      font: "Calibri")
    #block(
    width: 100%,
    below: 4em,
    inset: (left: -1.75em))[#text(it)]]

  show heading.where(level: 2): it => [
    #set text(
      size: 15.5pt,
      weight: "semibold",
      font: "Calibri")
    #block(
    width: 100%,
    above: 3em,
    below: 1em,
    inset: (left: -2.5em))[#text(it)]]
  
  show heading.where(level: 3): it => [
    #set text(
      size: 13.5pt,
      weight: "semibold",
      font: "Calibri")
    #block(
    width: 100%,
    above: 3em,
    below: 1em,
    inset: (left: -3.1em))[#text(it)]]
    
  show outline.entry.where(level: 1): it => [
    #set text(
      weight: "semibold",
      size: 14pt)
    #block(
    width: 100%,
    below: -0.5em,
    above: 2em)[#text(it)]]
  
  show outline.entry.where(level: 2): it => [
    #set text(
      weight: "regular",
      size: 12pt)
    #block(
      below: -0.8em,
      width: 100%)[#text(it)]]

  show figure.where(kind: "table"): set figure(supplement: "Tabell")
  show figure.where(kind: "quarto-float-fig"): set figure(supplement: "Figur")
      
  if title != none {
    set par(leading: 0.55em)
    place(dx: -6em, dy: 38em)[
      #align(left)[
        #block(inset: 2em)[
          #text(
            weight: "semibold", 
            size: 23pt,
            font: "Calibri"
          )[#title]]]]
  }

  if subtitle != none {
    set par(leading: 0.55em)
    place(dx: -6em, dy: 46em)[
      #align(left)[
        #block(inset: 2em)[
          #text(
            weight: "regular", 
            size: 15.5pt,
            font: "Calibri"
          )[#subtitle]]]]
  }

  if report_no != none {
    set par(leading: 0.55em)
    place(dx: 34em, dy: 29em)[
      #align(right)[
        #text(
          size: 12.5pt,
          font: "Calibri"
        )[Rapport #linebreak()#report_no]]]
  }

  if authors != none {
    place(dx: -4.2em, dy: 56em)[
      #align(left)[
        #text(
          size: 12.5pt,
          font: "Calibri"  
        )[#authors.name]]]
  }

  pagebreak()
  pagebreak()

  place(dx: -6em, dy: 38em)[
    #set par(leading: 0.55em)
      #align(left)[
        #block(inset: 2em)[
          #text(
            weight: "semibold", 
            size: 23pt, 
            font: "Calibri",
          )[#title]]]]

  place(dx: -6em, dy: 46em)[
    #set par(leading: 0.55em)
      #align(left)[
        #block(inset: 2em)[
          #text(
            weight: "regular",
            font: "Calibri",
            size: 15.5pt
          )[#subtitle]]]]

  place(dx: 34em, dy: 29em)[
      #set par(leading: 0.55em)
      #align(right)[
        #text(
          size: 12.5pt,
          font: "Calibri"
        )[Rapport #linebreak() #report_no]]]

    place(dx: -4.2em, dy: 56em)[
      #set par(leading: 0.55em)
      #align(left)[
        #text(
          size: 12.5pt,
          font: "Calibri"
        )[#authors.name]]]

    line(
    stroke: 1.5pt + rgb("#C84957"),
    length: 22%,
    start: (-4.2em, 54em))

  counter(page).update(1)
  
  pagebreak()
  
  tablex(
    columns: (1.1fr, 3.5fr),
    auto-lines: false,
    map-cells: cell => {
      (..cell, content: text(size: 9pt)[#cell.content])
    },
    align: left,
    [Rapport], [#report_no],
    [Utgitt av], [Nordisk institutt for studier av innovasjon, forskning og utdanning],
    [Adresse], [Postboks 2815 Tøyen, 0608 Oslo. Besøksadresse: Økernveien 9, 0653 Oslo],
    [], [],
    [Prosjektnr.], [#project_no],
    [], [],
    [Oppdragsgiver], [#funder],
    [Adresse], [#funder_address],
    [], [],
    [Fotomontasje], [NIFU],
    [], [],
    [ISBN], [#isbn],
    [ISSN], [#issn])
  
  image("by.png", width: 8em)
  
  text(size: 9pt)[Copyright NIFU: CC-BY-4.0]
  
  block(above: 3em)[#text(size: 9pt)[www.nifu.no]]
  
  pagebreak()
  
  block(
    width: 100%,
    below: 10em
  )[
    #text(
    size: 23.5pt,
    weight: "semibold",
    font: "Calibri",
  )[Forord]]

  if preface != none {
   text()[#preface] 
  }

  block(
    width: 100%,
    spacing: 4em
  )[#text()[Oslo, #date]]

  grid(
    columns: 2,
    column-gutter: 15em,
    rows: 2,
    row-gutter: 1em,
    text()[#signer_1],
    text()[#signer_2],
    text()[#signer_1_title],
    text()[#signer_2_title])
  
  pagebreak()
  linebreak()

  outline(
    title: block(
      inset: (left: 1.75em)
    )[#text(
      font: "Calibri",
      weight: "semibold",
      size: 23.5pt
    )[Innhold]],
  depth: 2,
  indent: none)

  pagebreak()

  if abstract != none {
    block(
      width: 100%,
      below: 7em)[
        #text(
          font: "Calibri",
          size: 23.5pt,
          weight: "semibold")[Sammendrag]]
    text()[#abstract]
  }
  
  pagebreak()
  
  doc

  if references != none {
    set par(first-line-indent: 0pt)
    set block(
      inset: (left: 1.5em)
    )
    bibliography(
      references,
      title: [~Referanser],
      style: "apa")}

  if appendix != none {
    [hargle bargle]
  }
  
if table_table {
  heading(numbering: none)[~~~~~~~~Tabelloversikt]
  outline(
    title: none,
    target: figure.where(kind: table))
}

if figure_table {
  heading(numbering: none,
  )[~~~~~~~~Figuroversikt]
  outline(
    title: none,
    target: figure.where(kind: "quarto-float-fig"),
    depth: 1)
}

  pagebreak()
  
  counter(page).update(0)
  place(dy: 45em)[
    #text()[
      Nordisk institutt for studier av #linebreak()
      innovasjon, forskning og utdanning #linebreak() #linebreak()
      Nordic institute for Studies in #linebreak()
      Innovation, Research and Education #linebreak() #linebreak()
      www.nifu.no]]
}