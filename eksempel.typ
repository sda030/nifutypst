// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



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
  lang: "en",
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
    size: fontsize,
    lang: lang)
  
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

  set figure.caption(separator: "")

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

#show: doc => NIFU_report(
  title: "Fancy og kort rapporttittel",
  subtitle: "Mer detaljer om hva prosjektet egentlig handler om",
  abstract: "",
  authors: (
        (
      "Bjørnstjerne Bjørnson"
    ),
        (
      "Henrik Karlstrøm"
    ),
        (
      "Rhoshandiatellyneshiaunneveshenk Koyaanisquatsiuth"
    ),
        (
      "Marie Curie"
    )  ),
  report_type: "rapport",
  report_no: "2023:10",
  project_no: "20715",
  isbn: "978-82-327-0607-5",
  isbn_online: "978-82-327-0607-1 (online)",
  issn: "1894-8200 (online)",
  funder: "Utdanningsdirektoratet",
  funder_address: "Schweigaards gate 15B, 0191 Oslo",
  date: "24.12.2023",
  preface: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ultricies at purus vel lacinia. Nunc eu lectus eu dui mattis posuere sed vel tellus. Sed cursus lacinia sem gravida cursus. Proin orci justo, sodales sed elit at, efficitur viverra diam. Proin efficitur scelerisque justo eget fermentum. Mauris sed eros eget nisi pharetra venenatis molestie ut mauris. Nullam cursus, lorem sit amet posuere varius, eros libero tincidunt dui, in facilisis mi diam consectetur neque. Morbi sit amet massa viverra, fringilla quam vitae, eleifend massa. Maecenas gravida tempus lectus sed vulputate. Donec malesuada sapien libero, eget posuere mi laoreet non. Vestibulum venenatis augue et augue interdum, et maximus ligula cursus. In dapibus quam ac sagittis suscipit. Ut a semper mauris. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.

Mauris vitae fermentum quam, id egestas ex. Aenean tempor ornare feugiat. Nulla suscipit elementum neque, in hendrerit tortor blandit at. Ut quis magna vel eros iaculis rutrum. Aliquam varius, tortor sit amet mollis blandit, odio nibh sagittis odio, a commodo nulla arcu vitae nisi. Nunc placerat pulvinar odio eu facilisis. Vivamus nec tempus lorem, bibendum ultricies tortor. Nam vitae laoreet turpis. Donec bibendum arcu sapien, vitae iaculis ligula aliquam ac. Quisque luctus consequat eros in feugiat. Aenean ultricies quam sit amet velit malesuada, sed aliquet velit tempus. Nulla non justo ipsum. Phasellus vel volutpat nisi. Integer sollicitudin cursus enim at maximus. Morbi non convallis erat, eget porta justo.

",
  signer_1: "Michael Spjelkavik Mark",
  signer_2: "Vibeke Opheim",
  signer_1_title: "Forskningsleder",
  signer_2_title: "Direktør",
  references: "refs.bib",
  figure_table: true,
  table_table: true,
  path_cover_upper_image: "",
  doc,
) 

#block[
#heading(
level: 
1
, 
numbering: 
none
, 
[
Sammendrag
]
)
]
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis sagittis posuere ligula sit amet lacinia. Duis dignissim pellentesque magna, rhoncus congue sapien finibus mollis. Ut eu sem laoreet, vehicula ipsum in, convallis erat. Vestibulum magna sem, blandit pulvinar augue sit amet, auctor malesuada sapien. Nullam faucibus leo eget eros hendrerit, non laoreet ipsum lacinia. Curabitur cursus diam elit, non tempus ante volutpat a. Quisque hendrerit blandit purus non fringilla. Integer sit amet elit viverra ante dapibus semper. Vestibulum viverra rutrum enim, at luctus enim posuere eu. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Nunc ac dignissim magna. Vestibulum vitae egestas elit. Proin feugiat leo quis ante condimentum, eu ornare mauris feugiat. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Mauris cursus laoreet ex, dignissim bibendum est posuere iaculis. Suspendisse et maximus elit. In fringilla gravida ornare. Aenean id lectus pulvinar, sagittis felis nec, rutrum risus. Nam vel neque eu arcu blandit fringilla et in quam. Aliquam luctus est sit amet vestibulum eleifend. Phasellus elementum sagittis molestie. Proin tempor lorem arcu, at condimentum purus volutpat eu. Fusce et pellentesque ligula. Pellentesque id tellus at erat luctus fringilla. Suspendisse potenti.

= Dette er den aller første overskriften, som nok er litt i lengste laget
<dette-er-den-aller-første-overskriften-som-nok-er-litt-i-lengste-laget>
Dette blir bra #cite(<hjorland>, form: "prose");.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis sagittis posuere ligula sit amet lacinia. Duis dignissim pellentesque magna, rhoncus congue sapien finibus mollis. Ut eu sem laoreet, vehicula ipsum in, convallis erat. Vestibulum magna sem, blandit pulvinar augue sit amet, auctor malesuada sapien. Nullam faucibus leo eget eros hendrerit, non laoreet ipsum lacinia. Curabitur cursus diam elit, non tempus ante volutpat a. Quisque hendrerit blandit purus non fringilla. Integer sit amet elit viverra ante dapibus semper. Vestibulum viverra rutrum enim, at luctus enim posuere eu. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Nunc ac dignissim magna. Vestibulum vitae egestas elit. Proin feugiat leo quis ante condimentum, eu ornare mauris feugiat. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Mauris cursus laoreet ex, dignissim bibendum est posuere iaculis. Suspendisse et maximus elit. In fringilla gravida ornare. Aenean id lectus pulvinar, sagittis felis nec, rutrum risus. Nam vel neque eu arcu blandit fringilla et in quam. Aliquam luctus est sit amet vestibulum eleifend. Phasellus elementum sagittis molestie. Proin tempor lorem arcu, at condimentum purus volutpat eu. Fusce et pellentesque ligula. Pellentesque id tellus at erat luctus fringilla. Suspendisse potenti.

Etiam maximus accumsan gravida. Maecenas at nunc dignissim, euismod enim ac, bibendum ipsum. Maecenas vehicula velit in nisl aliquet ultricies. Nam eget massa interdum, maximus arcu vel, pretium erat. Maecenas sit amet tempor purus, vitae aliquet nunc. Vivamus cursus urna velit, eleifend dictum magna laoreet ut. Duis eu erat mollis, blandit magna id, tincidunt ipsum. Integer massa nibh, commodo eu ex vel, venenatis efficitur ligula. Integer convallis lacus elit, maximus eleifend lacus ornare ac. Vestibulum scelerisque viverra urna id lacinia. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Aenean eget enim at diam bibendum tincidunt eu non purus. Nullam id magna ultrices, sodales metus viverra, tempus turpis.

== Mens dette er den aller første underoverskriften på nivå 2, som også er temmelig lang men er ment for å sjekke at justering av nummerering og påfølgende tekst er korrekt
<mens-dette-er-den-aller-første-underoverskriften-på-nivå-2-som-også-er-temmelig-lang-men-er-ment-for-å-sjekke-at-justering-av-nummerering-og-påfølgende-tekst-er-korrekt>
For å sjekke innholdsfortegnelsen.

=== Mens dette er den aller første underoverskriften på nivå 3, som også er temmelig lang men er ment for å sjekke at justering av nummerering og påfølgende tekst er korrekt
<mens-dette-er-den-aller-første-underoverskriften-på-nivå-3-som-også-er-temmelig-lang-men-er-ment-for-å-sjekke-at-justering-av-nummerering-og-påfølgende-tekst-er-korrekt>
Dette blir ikke med i innholdsfortegnelsen.

= Et par avsnitt for å vise tekst
<et-par-avsnitt-for-å-vise-tekst>
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis sagittis posuere ligula sit amet lacinia. Duis dignissim pellentesque magna, rhoncus congue sapien finibus mollis. Ut eu sem laoreet, vehicula ipsum in, convallis erat. Vestibulum magna sem, blandit pulvinar augue sit amet, auctor malesuada sapien. Nullam faucibus leo eget eros hendrerit, non laoreet ipsum lacinia. Curabitur cursus diam elit, non tempus ante volutpat a. Quisque hendrerit blandit purus non fringilla. Integer sit amet elit viverra ante dapibus semper. Vestibulum viverra rutrum enim, at luctus enim posuere eu. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Nunc ac dignissim magna. Vestibulum vitae egestas elit. Proin feugiat leo quis ante condimentum, eu ornare mauris feugiat. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Mauris cursus laoreet ex, dignissim bibendum est posuere iaculis. Suspendisse et maximus elit. In fringilla gravida ornare. Aenean id lectus pulvinar, sagittis felis nec, rutrum risus. Nam vel neque eu arcu blandit fringilla et in quam. Aliquam luctus est sit amet vestibulum eleifend. Phasellus elementum sagittis molestie. Proin tempor lorem arcu, at condimentum purus volutpat eu. Fusce et pellentesque ligula. Pellentesque id tellus at erat luctus fringilla. Suspendisse potenti.

Etiam maximus accumsan gravida. Maecenas at nunc dignissim, euismod enim ac, bibendum ipsum. Maecenas vehicula velit in nisl aliquet ultricies. Nam eget massa interdum, maximus arcu vel, pretium erat. Maecenas sit amet tempor purus, vitae aliquet nunc. Vivamus cursus urna velit, eleifend dictum magna laoreet ut. Duis eu erat mollis, blandit magna id, tincidunt ipsum. Integer massa nibh, commodo eu ex vel, venenatis efficitur ligula. Integer convallis lacus elit, maximus eleifend lacus ornare ac. Vestibulum scelerisque viverra urna id lacinia. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Aenean eget enim at diam bibendum tincidunt eu non purus. Nullam id magna ultrices, sodales metus viverra, tempus turpis.

Duis ornare ex ac iaculis pretium. Maecenas sagittis odio id erat pharetra, sit amet consectetur quam sollicitudin. Vivamus pharetra quam purus, nec sagittis risus pretium at. Nullam feugiat, turpis ac accumsan interdum, sem tellus blandit neque, id vulputate diam quam semper nisl. Donec sit amet enim at neque porttitor aliquet. Phasellus facilisis nulla eget placerat eleifend. Vestibulum non egestas eros, eget lobortis ipsum. Nulla rutrum massa eget enim aliquam, id porttitor erat luctus. Nunc sagittis quis eros eu sagittis. Pellentesque dictum, erat at pellentesque sollicitudin, justo augue pulvinar metus, quis rutrum est mi nec felis. Vestibulum efficitur mi lorem, at elementum purus tincidunt a. Aliquam finibus enim magna, vitae pellentesque erat faucibus at. Nulla mauris tellus, imperdiet id lobortis et, dignissim condimentum ipsum. Morbi nulla orci, varius at aliquet sed, facilisis id tortor. Donec ut urna nisi.

Aenean placerat luctus tortor vitae molestie. Nulla at aliquet nulla. Sed efficitur tellus orci, sed fringilla lectus laoreet eget. Vivamus maximus quam sit amet arcu dignissim, sed accumsan massa ullamcorper. Sed iaculis tincidunt feugiat. Nulla in est at nunc ultricies dictum ut vitae nunc. Aenean convallis vel diam at malesuada. Suspendisse arcu libero, vehicula tempus ultrices a, placerat sit amet tortor. Sed dictum id nulla commodo mattis. Aliquam mollis, nunc eu tristique faucibus, purus lacus tincidunt nulla, ac pretium lorem nunc ut enim. Curabitur eget mattis nisl, vitae sodales augue. Nam felis massa, bibendum sit amet nulla vel, vulputate rutrum lacus. Aenean convallis odio pharetra nulla mattis consequat.

= Tabeller som viser biler
<tabeller-som-viser-biler>
Kanskje vi skal sjekke kryssreferanser til objekter også, se #ref(<tbl-bil>, supplement: [tabell]).

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis sagittis posuere ligula sit amet lacinia. Duis dignissim pellentesque magna, rhoncus congue sapien finibus mollis. Ut eu sem laoreet, vehicula ipsum in, convallis erat. Vestibulum magna sem, blandit pulvinar augue sit amet, auctor malesuada sapien. Nullam faucibus leo eget eros hendrerit, non laoreet ipsum lacinia. Curabitur cursus diam elit, non tempus ante volutpat a. Quisque hendrerit blandit purus non fringilla. Integer sit amet elit viverra ante dapibus semper. Vestibulum viverra rutrum enim, at luctus enim posuere eu. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

#figure([
#show figure: set block(breakable: true)

#let nhead = 1;
#let nrow = 10;
#let ncol = 11;

  #let style-array = ( 
    // tinytable cell style after
(pairs: ((0, 0), (0, 1), (0, 2), (0, 3), (0, 4), (0, 5), (0, 6), (0, 7), (0, 8), (0, 9), (0, 10), (1, 0), (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), (2, 0), (2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9), (2, 10), (3, 0), (3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7), (3, 8), (3, 9), (3, 10), (4, 0), (4, 1), (4, 2), (4, 3), (4, 4), (4, 5), (4, 6), (4, 7), (4, 8), (4, 9), (4, 10), (5, 0), (5, 1), (5, 2), (5, 3), (5, 4), (5, 5), (5, 6), (5, 7), (5, 8), (5, 9), (5, 10), (6, 0), (6, 1), (6, 2), (6, 3), (6, 4), (6, 5), (6, 6), (6, 7), (6, 8), (6, 9), (6, 10), (7, 0), (7, 1), (7, 2), (7, 3), (7, 4), (7, 5), (7, 6), (7, 7), (7, 8), (7, 9), (7, 10), (8, 0), (8, 1), (8, 2), (8, 3), (8, 4), (8, 5), (8, 6), (8, 7), (8, 8), (8, 9), (8, 10), (9, 0), (9, 1), (9, 2), (9, 3), (9, 4), (9, 5), (9, 6), (9, 7), (9, 8), (9, 9), (9, 10), (10, 0), (10, 1), (10, 2), (10, 3), (10, 4), (10, 5), (10, 6), (10, 7), (10, 8), (10, 9), (10, 10),), ),
  )

  // tinytable align-default-array before
  #let align-default-array = ( left, left, left, left, left, left, left, left, left, left, left, ) // tinytable align-default-array here
  #show table.cell: it => {
    if style-array.len() == 0 {
      it 
    } else {
      let tmp = it
      for style in style-array {
        let m = style.pairs.find(k => k.at(0) == it.x and k.at(1) == it.y)
        if m != none {
          if ("fontsize" in style) { tmp = text(size: style.fontsize, tmp) }
          if ("color" in style) { tmp = text(fill: style.color, tmp) }
          if ("indent" in style) { tmp = pad(left: style.indent, tmp) }
          if ("underline" in style) { tmp = underline(tmp) }
          if ("italic" in style) { tmp = emph(tmp) }
          if ("bold" in style) { tmp = strong(tmp) }
          if ("mono" in style) { tmp = math.mono(tmp) }
          if ("strikeout" in style) { tmp = strike(tmp) }
        }
      }
      tmp
    }
  }

  #align(center, [

  #table( // tinytable table start
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    stroke: none,
    align: (x, y) => {
      let sarray = style-array.filter(a => "align" in a)
      let sarray = sarray.filter(a => a.pairs.find(p => p.at(0) == x and p.at(1) == y) != none)
      if sarray.len() > 0 {
        sarray.last().align
      } else {
        left
      }
    },
    fill: (x, y) => {
      let sarray = style-array.filter(a => "background" in a)
      let sarray = sarray.filter(a => a.pairs.find(p => p.at(0) == x and p.at(1) == y) != none)
      if sarray.len() > 0 {
        sarray.last().background
      }
    },
 table.hline(y: 1, start: 0, end: 11, stroke: 0.05em + black),
 table.hline(y: 11, start: 0, end: 11, stroke: 0.1em + black),
 table.hline(y: 0, start: 0, end: 11, stroke: 0.1em + black),
    // tinytable lines before

    table.header(
      repeat: true,
[mpg], [cyl], [disp], [hp], [drat], [wt], [qsec], [vs], [am], [gear], [carb],
    ),

    // tinytable cell content after
[21.0], [6], [160.0], [110], [3.90], [2.620], [16.46], [0], [1], [4], [4],
[21.0], [6], [160.0], [110], [3.90], [2.875], [17.02], [0], [1], [4], [4],
[22.8], [4], [108.0], [93], [3.85], [2.320], [18.61], [1], [1], [4], [1],
[21.4], [6], [258.0], [110], [3.08], [3.215], [19.44], [1], [0], [3], [1],
[18.7], [8], [360.0], [175], [3.15], [3.440], [17.02], [0], [0], [3], [2],
[18.1], [6], [225.0], [105], [2.76], [3.460], [20.22], [1], [0], [3], [1],
[14.3], [8], [360.0], [245], [3.21], [3.570], [15.84], [0], [0], [3], [4],
[24.4], [4], [146.7], [62], [3.69], [3.190], [20.00], [1], [0], [4], [2],
[22.8], [4], [140.8], [95], [3.92], [3.150], [22.90], [1], [0], [4], [2],
[19.2], [6], [167.6], [123], [3.92], [3.440], [18.30], [1], [0], [4], [4],

    // tinytable footer after

  ) // end table

  ]) // end align
], caption: figure.caption(
position: top, 
[
Moro med biler
]), 
kind: "quarto-float-tbl", 
supplement: "Tabell", 
)
<tbl-bil>


#figure([
#show figure: set block(breakable: true)

#let nhead = 1;
#let nrow = 10;
#let ncol = 11;

  #let style-array = ( 
    // tinytable cell style after
(pairs: ((0, 0), (0, 1), (0, 2), (0, 3), (0, 4), (0, 5), (0, 6), (0, 7), (0, 8), (0, 9), (0, 10), (1, 0), (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), (2, 0), (2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9), (2, 10), (3, 0), (3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7), (3, 8), (3, 9), (3, 10), (4, 0), (4, 1), (4, 2), (4, 3), (4, 4), (4, 5), (4, 6), (4, 7), (4, 8), (4, 9), (4, 10), (5, 0), (5, 1), (5, 2), (5, 3), (5, 4), (5, 5), (5, 6), (5, 7), (5, 8), (5, 9), (5, 10), (6, 0), (6, 1), (6, 2), (6, 3), (6, 4), (6, 5), (6, 6), (6, 7), (6, 8), (6, 9), (6, 10), (7, 0), (7, 1), (7, 2), (7, 3), (7, 4), (7, 5), (7, 6), (7, 7), (7, 8), (7, 9), (7, 10), (8, 0), (8, 1), (8, 2), (8, 3), (8, 4), (8, 5), (8, 6), (8, 7), (8, 8), (8, 9), (8, 10), (9, 0), (9, 1), (9, 2), (9, 3), (9, 4), (9, 5), (9, 6), (9, 7), (9, 8), (9, 9), (9, 10), (10, 0), (10, 1), (10, 2), (10, 3), (10, 4), (10, 5), (10, 6), (10, 7), (10, 8), (10, 9), (10, 10),), ),
  )

  // tinytable align-default-array before
  #let align-default-array = ( left, left, left, left, left, left, left, left, left, left, left, ) // tinytable align-default-array here
  #show table.cell: it => {
    if style-array.len() == 0 {
      it 
    } else {
      let tmp = it
      for style in style-array {
        let m = style.pairs.find(k => k.at(0) == it.x and k.at(1) == it.y)
        if m != none {
          if ("fontsize" in style) { tmp = text(size: style.fontsize, tmp) }
          if ("color" in style) { tmp = text(fill: style.color, tmp) }
          if ("indent" in style) { tmp = pad(left: style.indent, tmp) }
          if ("underline" in style) { tmp = underline(tmp) }
          if ("italic" in style) { tmp = emph(tmp) }
          if ("bold" in style) { tmp = strong(tmp) }
          if ("mono" in style) { tmp = math.mono(tmp) }
          if ("strikeout" in style) { tmp = strike(tmp) }
        }
      }
      tmp
    }
  }

  #align(center, [

  #table( // tinytable table start
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    stroke: none,
    align: (x, y) => {
      let sarray = style-array.filter(a => "align" in a)
      let sarray = sarray.filter(a => a.pairs.find(p => p.at(0) == x and p.at(1) == y) != none)
      if sarray.len() > 0 {
        sarray.last().align
      } else {
        left
      }
    },
    fill: (x, y) => {
      let sarray = style-array.filter(a => "background" in a)
      let sarray = sarray.filter(a => a.pairs.find(p => p.at(0) == x and p.at(1) == y) != none)
      if sarray.len() > 0 {
        sarray.last().background
      }
    },
 table.hline(y: 1, start: 0, end: 11, stroke: 0.05em + black),
 table.hline(y: 11, start: 0, end: 11, stroke: 0.1em + black),
 table.hline(y: 0, start: 0, end: 11, stroke: 0.1em + black),
    // tinytable lines before

    table.header(
      repeat: true,
[mpg], [cyl], [disp], [hp], [drat], [wt], [qsec], [vs], [am], [gear], [carb],
    ),

    // tinytable cell content after
[15.2], [8], [304.0], [150], [3.15], [3.435], [17.30], [0], [0], [3], [2],
[13.3], [8], [350.0], [245], [3.73], [3.840], [15.41], [0], [0], [3], [4],
[19.2], [8], [400.0], [175], [3.08], [3.845], [17.05], [0], [0], [3], [2],
[27.3], [4], [79.0], [66], [4.08], [1.935], [18.90], [1], [1], [4], [1],
[26.0], [4], [120.3], [91], [4.43], [2.140], [16.70], [0], [1], [5], [2],
[30.4], [4], [95.1], [113], [3.77], [1.513], [16.90], [1], [1], [5], [2],
[15.8], [8], [351.0], [264], [4.22], [3.170], [14.50], [0], [1], [5], [4],
[19.7], [6], [145.0], [175], [3.62], [2.770], [15.50], [0], [1], [5], [6],
[15.0], [8], [301.0], [335], [3.54], [3.570], [14.60], [0], [1], [5], [8],
[21.4], [4], [121.0], [109], [4.11], [2.780], [18.60], [1], [1], [4], [2],

    // tinytable footer after

  ) // end table

  ]) // end align
], caption: figure.caption(
position: top, 
[
Moro med biler
]), 
kind: "quarto-float-tbl", 
supplement: "Tabell", 
)
<tbl-bil2>


= En graf som viser noe annet
<en-graf-som-viser-noe-annet>
Vi tester kryssreffing her også, bare se hvordan det funker med #ref(<fig-iris>, supplement: [figur]).

Noen ekstra avsnitt.

Noen ekstra avsnitt.

Noen ekstra avsnitt.

Noen ekstra avsnitt.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis sagittis posuere ligula sit amet lacinia. Duis dignissim pellentesque magna, rhoncus congue sapien finibus mollis. Ut eu sem laoreet, vehicula ipsum in, convallis erat. Vestibulum magna sem, blandit pulvinar augue sit amet, auctor malesuada sapien. Nullam faucibus leo eget eros hendrerit, non laoreet ipsum lacinia. Curabitur cursus diam elit, non tempus ante volutpat a. Quisque hendrerit blandit purus non fringilla. Integer sit amet elit viverra ante dapibus semper. Vestibulum viverra rutrum enim, at luctus enim posuere eu. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

Nunc ac dignissim magna. Vestibulum vitae egestas elit. Proin feugiat leo quis ante condimentum, eu ornare mauris feugiat. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Mauris cursus laoreet ex, dignissim bibendum est posuere iaculis. Suspendisse et maximus elit. In fringilla gravida ornare. Aenean id lectus pulvinar, sagittis felis nec, rutrum risus. Nam vel neque eu arcu blandit fringilla et in quam. Aliquam luctus est sit amet vestibulum eleifend. Phasellus elementum sagittis molestie. Proin tempor lorem arcu, at condimentum purus volutpat eu. Fusce et pellentesque ligula. Pellentesque id tellus at erat luctus fringilla. Suspendisse potenti.

#figure([
#box(image("eksempel_files/figure-typst/fig-iris-1.svg"))
], caption: figure.caption(
position: bottom, 
[
Sjekk de bladene! Dette er en ganske så lang figurtittel for å sjekke at den fortsetter på neste linje på en pen måte som helst ikke begynner under Figur X.
]), 
kind: "quarto-float-fig", 
supplement: "Figur", 
)
<fig-iris>


== Undertittel for å sjekke figurnummerering
<undertittel-for-å-sjekke-figurnummerering>
#ref(<fig-iris>, supplement: [Figur]) viser akkurat det samme, bare motsatt.

#figure([
#box(image("eksempel_files/figure-typst/fig-iris2-1.svg"))
], caption: figure.caption(
position: bottom, 
[
Sjekk de bladene
]), 
kind: "quarto-float-fig", 
supplement: "Figur", 
)
<fig-iris2>


= En tabell
<en-tabell>
For å se om nummereringen oppfører seg pent.

#figure([
#show figure: set block(breakable: true)

#let nhead = 1;
#let nrow = 6;
#let ncol = 5;

  #let style-array = ( 
    // tinytable cell style after
(pairs: ((0, 0), (0, 1), (0, 2), (0, 3), (0, 4), (0, 5), (0, 6), (1, 0), (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (2, 0), (2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (3, 0), (3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (4, 0), (4, 1), (4, 2), (4, 3), (4, 4), (4, 5), (4, 6),), ),
  )

  // tinytable align-default-array before
  #let align-default-array = ( left, left, left, left, left, ) // tinytable align-default-array here
  #show table.cell: it => {
    if style-array.len() == 0 {
      it 
    } else {
      let tmp = it
      for style in style-array {
        let m = style.pairs.find(k => k.at(0) == it.x and k.at(1) == it.y)
        if m != none {
          if ("fontsize" in style) { tmp = text(size: style.fontsize, tmp) }
          if ("color" in style) { tmp = text(fill: style.color, tmp) }
          if ("indent" in style) { tmp = pad(left: style.indent, tmp) }
          if ("underline" in style) { tmp = underline(tmp) }
          if ("italic" in style) { tmp = emph(tmp) }
          if ("bold" in style) { tmp = strong(tmp) }
          if ("mono" in style) { tmp = math.mono(tmp) }
          if ("strikeout" in style) { tmp = strike(tmp) }
        }
      }
      tmp
    }
  }

  #align(center, [

  #table( // tinytable table start
    columns: (auto, auto, auto, auto, auto),
    stroke: none,
    align: (x, y) => {
      let sarray = style-array.filter(a => "align" in a)
      let sarray = sarray.filter(a => a.pairs.find(p => p.at(0) == x and p.at(1) == y) != none)
      if sarray.len() > 0 {
        sarray.last().align
      } else {
        left
      }
    },
    fill: (x, y) => {
      let sarray = style-array.filter(a => "background" in a)
      let sarray = sarray.filter(a => a.pairs.find(p => p.at(0) == x and p.at(1) == y) != none)
      if sarray.len() > 0 {
        sarray.last().background
      }
    },
 table.hline(y: 1, start: 0, end: 5, stroke: 0.05em + black),
 table.hline(y: 7, start: 0, end: 5, stroke: 0.1em + black),
 table.hline(y: 0, start: 0, end: 5, stroke: 0.1em + black),
    // tinytable lines before

    table.header(
      repeat: true,
[Sepal.Length], [Sepal.Width], [Petal.Length], [Petal.Width], [Species],
    ),

    // tinytable cell content after
[5.1], [3.5], [1.4], [0.2], [setosa],
[4.9], [3.0], [1.4], [0.2], [setosa],
[4.7], [3.2], [1.3], [0.2], [setosa],
[4.6], [3.1], [1.5], [0.2], [setosa],
[5.0], [3.6], [1.4], [0.2], [setosa],
[5.4], [3.9], [1.7], [0.4], [setosa],

    // tinytable footer after

  ) // end table

  ]) // end align
], caption: figure.caption(
position: top, 
[
Bla bla bla
]), 
kind: "quarto-float-tbl", 
supplement: "Tabell", 
)
<tbl-iris>


== Noe på nivå 2
<noe-på-nivå-2>
=== Noe på nivå 3
<noe-på-nivå-3>
==== Med en liten underinndeling på nivå 4
<med-en-liten-underinndeling-på-nivå-4>
= En siste tabell
<en-siste-tabell>
For å se om nummereringen oppfører seg pent.

#figure([
#table(
  columns: 5,
  align: (auto,auto,auto,auto,auto,),
  table.header([Sepal.Length], [Sepal.Width], [Petal.Length], [Petal.Width], [Species],),
  table.hline(),
  [5.1], [3.5], [1.4], [0.2], [setosa],
  [4.9], [3.0], [1.4], [0.2], [setosa],
  [4.7], [3.2], [1.3], [0.2], [setosa],
  [4.6], [3.1], [1.5], [0.2], [setosa],
  [5.0], [3.6], [1.4], [0.2], [setosa],
  [5.4], [3.9], [1.7], [0.4], [setosa],
)
], caption: figure.caption(
position: top, 
[
Bla bla bla 2
]), 
kind: "quarto-float-tbl", 
supplement: "Tabell", 
)
<tbl-iris2>






