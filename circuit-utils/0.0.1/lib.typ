#import "@preview/zap:0.5.0"
#import "@preview/cetz:0.4.2"

#let draw-circuit = (joints, elems) => {
  set text(size: 10pt)
  zap.circuit({
    import zap: *
    set-style(
      resistor: (scale: (x: 0.5, y: 0.75), variant: "ieee"),
      vsource: (scale: (x: 0.75, y: 0.75), variant: "ieee"),
      isource: (scale: (x: 0.75, y: 0.75), variant: "ieee"),
      inductor: (scale: (x: 0.75, y: 0.75), variant: "ieee"),
      capacitor: (scale: (x: 0.5, y: 0.75)),
      switch: (scale: (x: 0.75, y: 1.25)),
    )

    for (name, group) in elems {
      for (index, item) in group.enumerate() {
        if name == "resistors" {
          let c-name = "res" + str(index)
          let ((i, j), label, anchor) = item
          let A = joints.at(i)
          let B = joints.at(j)
          let lbl = if anchor != none { (content: label, anchor: anchor) } else { label }
          resistor(c-name, A, B, label: lbl)
        } else if name == "inductors" {
          let c-name = "ind" + str(index)
          let ((i, j), label, anchor) = item
          let A = joints.at(i)
          let B = joints.at(j)
          let lbl = if anchor != none { (content: label, anchor: anchor) } else { label }
          inductor(c-name, A, B, label: lbl)
        } else if name == "capacitors" or name == "p-capacitors" {
          let dep = if name.at(0) == "p" { true } else { false }
          let c-name = "cap" + str(index)
          let ((i, j), label, anchor) = item
          let A = joints.at(i)
          let B = joints.at(j)
          let lbl = if anchor != none { (content: label, anchor: anchor) } else { label }
          capacitor(c-name, A, B, label: lbl, polarized: dep)
        } else if name == "v-sources" {
          let c-name = "vs" + str(index)
          let ((i, j), label, anchor) = item
          let A = joints.at(i)
          let B = joints.at(j)
          let lbl = if anchor != none { (content: label, anchor: anchor) } else { label }
          // see https://zap.grangelouis.ch/ for reference
          vsource(c-name, A, B, current: "dc", dependent: false, label: lbl)
        } else if name == "i-sources" or name == "id-sources" {
          let dep = if name.at(1) == "d" { true } else { false }
          let c-name = "is" + str(index)
          let ((i, j), label, anchor) = item
          let A = joints.at(i)
          let B = joints.at(j)
          let lbl = if anchor != none { (content: label, anchor: anchor) } else { label }
          isource(c-name, A, B, current: "dc", dependent: dep, label: lbl)
        } else if name == "wires" {
          let c-name = "wire" + str(index)
          let ((i, j), label) = item
          let A = joints.at(i)
          let B = joints.at(j)
          wire(A, B, name: c-name)
          // TODO: draw label next to middle of wire
        } else if name == "earths" {
          let c-name = "earth" + str(index)
          let (i, label, anchor) = item
          // TODO: is there a way to give it direction?
          earth(c-name, joints.at(i), label: label)
        } else if name == "nodes" {
          let c-name = "node" + str(index)
          let (i, label, fill, anchor) = item
          if anchor == none {
            node(name, joints.at(i), label: (content: label), fill: fill)
          } else {
            node(name, joints.at(i), label: (content: label, anchor: anchor), fill: fill)
          }
        } else if name == "labels" {
          let c-name = "lbl" + str(index)
          let (i, label, anchor) = item
          cetz.draw.content((joints.at(i)), label, anchor: anchor)
        } else if name == "custom" {
          let (pts, callback) = item
          callback(pts.map(i => joints.at(i)))
        }
      }
    }
  })
}

#let mark-mesh = (alpha, label, i, j, k, l) => {
  let lerp = (u, v, t) => u.zip(v).map(((p, q)) => p * (1 - t) + q * t)
  let center = array.zip(i, j, k, l).map(p => p.sum() / 4)
  let pairs = ((i, j), (j, k), (k, l), (l, i))
  let distances = pairs.map(((u, v)) => calc.sqrt(u.zip(v).map(((x, y)) => (x - y) * (x - y)).sum()))
  let dist-min = calc.min(..distances)
  let dist-ratio = distances.map(n => n / dist-min)
  let pairs1 = pairs.zip(dist-ratio)
  let pairs2 = pairs.zip((dist-ratio.at(-1),) + dist-ratio.slice(0, dist-ratio.len() - 1))
  let p1 = pairs1.map((((u, v), d)) => lerp(u, v, alpha * 1 / d).zip(u).map(((x, y)) => x - y))
  let p2 = pairs1.map((((u, v), d)) => lerp(u, v, (1 - alpha * 1 / d)).zip(v).map(((x, y)) => x - y))
  let vtx = (
    (0, 3, i),
    (1, 0, j),
    (2, 1, k),
    (3, 2, l),
  ).map(((i1, i2, pt)) => p1.at(i1).zip(p2.at(i2)).map(((a, b)) => a + b).zip(pt).map(((u, v)) => u + v))
  let arc-radius = (1 - alpha * 2) * dist-min / 2
  let arc-start = center.zip((arc-radius, 0)).map(((a, b)) => a + b)
  return cetz.draw.on-layer(-1, {
    cetz.draw.merge-path(
      fill: gray,
      stroke: none,
      {
        cetz.draw.line(vtx.at(0), vtx.at(1))
        cetz.draw.line(vtx.at(1), vtx.at(2))
        cetz.draw.line(vtx.at(2), vtx.at(3))
        cetz.draw.line(vtx.at(3), vtx.at(0))
      },
    )
    // counter clockwise rotation
    cetz.draw.arc(arc-start, radius: arc-radius, mark: (end: "triangle"), start: 0deg, stop: -315deg, stroke: blue)
    cetz.draw.content(center, text(fill: blue)[#label])
  })
}

// #let highlight-node = (indices, color) => {
//   cetz.draw.path(
//     indices.map(i => joints.at(i)),
//     stroke: (paint: color, thickness: 2pt),
//     fill: none,
//     join: "round",
//     cap: "round",
//   )
// }
