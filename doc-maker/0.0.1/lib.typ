#let set-metadata(
  author,
  date,
  description,
  keywords,
  title_, // need to access the built-in
) = {
  set document(
    author: author,
    date: date,
    description: description,
    keywords: keywords,
    title: title_,
  )
}

#let make-title(
  author,
  date,
  description,
  keywords,
  title_, // need to access the built-in
  format: (
    title: center,
    author: center,
    date: center,
  ),
) = {
  set document(
    author: author,
    date: date,
    description: description,
    keywords: keywords,
    title: title_,
  )

  let output = (
    title: none,
    author: none,
    date: none,
  )

  show title: set align(center)
  output.title = title()

  if type(author) == array and author.len() > 0 {
    output.author = author.map(i => text(weight: "bold")[#i])
  } else if type(author) == str {
    output.author = (text(weight: "bold")[#author],)
  }

  if type(date) == datetime {
    output.date = [#date.display("[month repr:long] [day], [year]")]
  }

  if format.title != none and type(format.title) == alignment {
    align(format.title)[#output.title]
  }
  if format.author != none and type(format.author) == alignment {
    for au in output.author {
      align(format.author)[#au]
    }
  }
  if format.date != none and type(format.date) == alignment {
    align(format.date)[#output.date]
  }
}
