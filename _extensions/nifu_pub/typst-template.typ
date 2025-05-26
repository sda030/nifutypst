

#let NIFU_report(
  title: none,
  subtitle: none,
  authors: (),
  report_type: none,
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
    appendix: none,
  isbn: none,
  isbn_online: none,
  issn: none,
  date: none,
  signer_1: none,
  signer_1_title: none,
  signer_2: none,
  signer_2_title: none,
  references: none,
  figure_table: false,
  table_table: false,
  path_cover_upper_image: none,
  doc
) = {
  set page(
    paper: paper,
    margin: margin,
    footer: context if counter(page).get().at(0) > 2  [
        #align(center)[
          #text(spacing: 0.2cm)[
            #text(size: 11pt)[#counter(page).display()]
            #text(
              fill: if report_type == "rapport" {rgb("#C84957")} else {rgb("#2D8E9F")},
              size: 12pt)[#symbol("•")] 
            #text(
              size: 8pt, 
              spacing: 0.1cm,
              font: "Calibri")[Rapport #report_no]]]],
    background: context if counter(page).get().at(0) == 1 [
        #image("_images/cover_nedre.png")]
    )
    
  let concatenatedAuthors = if type(authors) != str [
     #authors.join(", ", last: " og ")
     ] else [#authors]

  set heading(numbering: "1.1.1    ")
  
  set par(
    justify: true, 
    first-line-indent: 0.6cm,
    leading: 0.8em,
    spacing: 0.8em)
  
  set text(
    font: "Cambria",
    size: fontsize)
  
  show heading.where(level: 1): it => {
    if it.numbering != none {
      colbreak(weak: true)
      set text(
        size: 23.5pt,
        weight: "semibold",
        font: "Calibri")
      block(
      width: 100%,
      below: 3em,
      inset: (left: -1.75em))[#text(it)]
    } else {
      colbreak(weak: true)
      set text(
        size: 23.5pt,
        weight: "semibold",
        font: "Calibri")
      block(
      width: 100%,
      below: 3em
      )[#text(it)]
      parbreak()
    }
    }

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
    
  show outline.entry.where(level: 1): it => {
    set text(
      weight: "semibold",
      size: 13pt)
    block(
    width: 100%,
    below: -0.5em,
    //inset: (left: 0.75em),
    above: 2em)[#text(it)]
    }
  
  show outline.entry.where(level: 2): it => {
    set text(
      weight: "regular",
      size: 12pt)
    block(
      below: -0.8em,
      width: 100%)[#text(it)]
  }

  show figure.where(kind: "quarto-float-fig"): it => {
  block(width: 100%)[
    #it.body
    #set align(left)
    #text(weight: "bold",
    font: "Calibri")[#it.caption]]
  }
  
  show figure.where(kind: "quarto-float-tbl"): it => {
  block(below: 3em)
  block(width: 100%)[
          #set align(left)
          #text(weight: "bold", font: "Calibri")[#it.caption]
          #it.body]
  }
  // Forsidens illustrasjon
  if path_cover_upper_image == "" {
      box(place(top + left,
        dx: -margin.at("x"), dy: -margin.at("y"))[
    #image("_images/cover-ovre.png",
           width: 210mm)
  ])
  } else {
  box(place(top + left,
        dx: -margin.at("x"), dy: -margin.at("y"))[
    #image(path_cover_upper_image,
           width: 210mm)
  ])

  }
    
    
  
  if title != none {
    set par(leading: 0.55em)
    place(dx: -6.4em, dy: 32em)[
      #align(left)[
        #block(inset: 2em)[
          #text(
            weight: "semibold", 
            size: 23pt,
            font: "Calibri"
          )[#title]]]]
  }
  
  place(dx: 36.2em, dy: 25em)[
    #circle(
      radius: 11pt,
      fill: if report_type == "rapport" {rgb("#C84957")} else {rgb("#2D8E9F")},
      stroke: white)
    ]
  
  if subtitle != none {
    set par(leading: 0.55em)
    place(dx: -6.4em, dy: 36em)[
      #align(left)[
        #block(inset: 2em)[
          #text(
            weight: "regular", 
            size: 15.5pt,
            font: "Calibri"
          )[#subtitle]]]]
  }

  if report_no != none {
    set par(leading: 0.65em)
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
          font: "Calibri",
          costs: (hyphenation: 500%)
        )[#concatenatedAuthors]
      ]
    ]
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
        )[#concatenatedAuthors]]]

    line(
    stroke: 1.5pt + rgb("#C84957"),
    length: 22%,
    start: (-4.2em, 54em))

  counter(page).update(1)
  
  pagebreak()
  
  {
  show table.cell: set text(size: 9pt)
  table(
    columns: (1.1fr, 3.5fr),
    stroke: none,
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
    [ISBN], [#isbn_online],
    [ISSN], [#issn]
    )
  }
  
  image("_images/CC-BY.svg", width: 8em)
  
  text(size: 9pt)[Copyright NIFU: CC-BY-4.0]
  
  block(above: 3em)[#text(size: 9pt)[www.nifu.no]]
  
  // Kun om det er et forord
  if preface != "" {
  
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

    preface

  block(
    width: 100%,
    spacing: 4em
  )[#text()[Oslo, #date]]

  if signer_1 != "" {
  grid(
    columns: 2,
    column-gutter: 15em,
    rows: 2,
    row-gutter: 1em,
    text()[#signer_1],
    text()[#signer_2],
    text()[#signer_1_title],
    text()[#signer_2_title])
  }
  }

  
  pagebreak()
  linebreak()

  outline(
    title: block()[#text(
      font: "Calibri",
      weight: "semibold",
      size: 23.5pt
    )[Innhold]],
  depth: 2,
  indent: 0cm)
  
  pagebreak()
  
  {
    set figure(numbering: n => {
	              let hdr = counter(heading).get().first()
	              let num = query(selector(heading).before(here())).last().numbering
	              numbering("1.1", hdr, n)
    })
  doc
  }

  if references != "" {
    set par(first-line-indent: 0pt, 
            hanging-indent: 1.27cm)
    set text(hyphenate: false)

    bibliography(
      references,
      title: [Referanser],
      style: "apa")}

  if appendix != none {
    [hargle bargle]
  }
  
  if table_table {
    outline(
        title: block()[#heading(text()[Tabelloversikt], outlined: true)],
        target: figure.where(kind: "quarto-float-tbl"),
        depth: 1)
  }
  
  if figure_table {
    outline(
      title: block()[#heading(text()[Figuroversikt], outlined: true)],
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