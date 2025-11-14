#let make-title(
  author,
  date,
  description,
  keywords,
  title_, // need to access the built-in
  show-title: false,
  show-author: false,
  show-date: false,
) = {
  set document(
    author: author,
    date: date,
    description: description,
    keywords: keywords,
    title: title_,
  )

  if show-title and type(title_) == content {
    show title: set align(center)
    title()
  }

  align(right)[
    #if show-author {
      if type(author) == array and author.len() > 0 {
        text(weight: "bold")[
          #author.reduce((acc, x) => acc + linebreak() + x)
        ]
      } else if type(author) == str {
        text(weight: "bold")[
          #author
        ]
      }
    }

    #if show-date and type(date) == datetime {
      date.display("[month repr:long] [day], [year]")
    }
  ]
}
