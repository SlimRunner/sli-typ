#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3"

#let simple-plot(
  func,
  x-range,
  y-range,
  x-axis: $x$,
  y-axis: $y$,
  axis-style: "school-book",
  size: (5, 5),
  shared-zero: false,
  tick-steps: (none, none),
  style-props: (),
  plot-props: (),
  func-props: (),
) = {
  cetz.canvas({
    import cetz.draw: *
    import cetz-plot.plot

    // Set-up a thin axis style
    set-style(
      axes: (
        y: (label: (anchor: "south")),
        x: (label: (anchor: "west")),
        stroke: .5pt,
        tick: (stroke: .5pt),
        shared-zero: shared-zero,
      ),
      legend: (stroke: none, orientation: ttb, item: (spacing: .3), scale: 80%),
      ..style-props,
    )

    plot.plot(
      size: size,
      y-min: y-range.at(0),
      y-max: y-range.at(1),
      x-tick-step: tick-steps.at(0),
      y-tick-step: tick-steps.at(1),
      x-label: x-axis,
      y-label: y-axis,
      axis-style: axis-style,
      ..plot-props,
      {
        plot.add(
          func,
          domain: x-range,
          ..(func-props),
        )
      },
    )
  })
}
