#import "@preview/unify:0.7.1": qty, unit

#let rnd2 = n => { calc.round(n, digits: 2) }

#let auto-si = n => {
  let digits = calc.log(calc.abs(n))
  let pos = calc.floor(digits / 3) * 3
  if pos <= -9 {
    return (n * 1e9, "nano ")
  } else if pos == -6 {
    return (n * 1e6, "micro ")
  } else if pos == -3 {
    return (n * 1e3, "milli ")
  } else if pos == 0 {
    return (n, "")
  } else if pos == 3 {
    return (n * 1e-3, "kilo ")
  } else if pos == 6 {
    return (n * 1e-6, "mega ")
  } else {
    return (n * 1e-9, "tera ")
  }
}

#let unit-functor-gen = (name, find-si: false) => {
  if find-si {
    n => {
      let (n, p) = auto-si(n);
      qty(n, p + name)
    }
  } else {
    n => qty(n, name)
  }
}
