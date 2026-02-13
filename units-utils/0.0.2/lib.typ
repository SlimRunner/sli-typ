#import "@preview/unify:0.7.1": qty, unit

#let rnd2 = n => { calc.round(n, digits: 2) }
#let rnd4 = n => { calc.round(n, digits: 4) }

#let auto-si = (n, offset: 0) => {
  if n == 0 {
    return (n, "")
  }
  let digits = calc.log(calc.abs(n)) + offset * 3
  let pos = calc.floor(digits / 3) * 3
  if pos <= -12 {
    return (n * 1e12, "pico ")
  } else if pos == -9 {
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
  } else if pos == 9 {
    return (n * 1e-9, "giga ")
  } else {
    return (n * 1e-12, "tera ")
  }
}

#let unit-functor-gen = (name, find-si: false) => {
  if find-si {
    (n, offset: 0) => {
      let (n, p) = auto-si(n, offset: offset);
      qty(n, p + name)
    }
  } else {
    (n, offset: 0) => qty(n, name)
  }
}
