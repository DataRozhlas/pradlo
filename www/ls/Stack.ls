sum = -> it.reduce (curr, prev = 0) -> prev + curr
container = d3.select ig.containers.base
  ..classed \stack yes
  ..append \h1
    ..html "Ostravská fakultní nemocnice pere třikrát dráž než pražská Thomayerova nemocnice"
  ..append \h2
    ..html "Počet lůžek je přitom srovnatelný."
graphTip = new ig.GraphTip container
data = d3.tsv.parse ig.data.pradlo, (row) ->
  row.count = parseInt row['počet lůžek'], 10
  row.price = parseInt row['náklady na prádlo na jedno lůžko ročně'], 10
  row.laundromat = row['má vlastní prádelnu'] == "T"
  row

lineHeight = 36px


priceScale = d3.scale.linear!
  ..domain [0 d3.max data.map (.price)]
  ..range [0 100]

countScale = d3.scale.linear!
  ..domain [0 d3.max data.map (.count)]
  ..range [0 100]


list = container.append \ul
  ..attr \class \barchart
displayTooltip = ->
  text = "<b>#{it.nemocnice}</b><br>
    Roční náklady na prádlo na jedno lůžko: <b>#{ig.utils.formatNumber it.price} Kč</b><br>
    Počet lůžek: <b>#{ig.utils.formatNumber it.count}</b>"
  if it.laundromat
    text += "<br>Nemocnice má vlastní prádelnu"
  offset = ig.utils.offset @
  graphTip.display offset.left + 0.5 * @clientWidth, offset.top - 5, text
hideTooltip = ->
  graphTip.hide!
listItems = list.selectAll \li .data data .enter!append \li
  ..style \top (d, i) -> "#{i * lineHeight}px"
  ..append \span
    ..attr \class \title
    ..on \mouseover displayTooltip
    ..on \touchstart displayTooltip
    ..on \mouseout hideTooltip
    ..html -> it['nemocnice']
    ..filter (.laundromat)
      ..append \svg
        ..attr \width 18
        ..attr \height 21
        ..append \rect
          ..attr \width 17
          ..attr \height 20
        ..append \rect
          ..attr \width 17
          ..attr \height 4
        ..append \line
          ..attr \x1 12
          ..attr \x2 16
          ..attr \y1 2
          ..attr \y2 2
        ..append \circle
          ..attr \cy 12
          ..attr \cx 9
          ..attr \r 5
  ..append \div
    ..attr \class \bar
    ..append \div
      ..attr \class \item
      ..style \width -> "#{priceScale it.price}%"
      ..on \mouseover displayTooltip
      ..on \touchstart displayTooltip
      ..on \mouseout hideTooltip
    ..append \div
      ..attr \class "count service"
      ..style \left -> "#{priceScale it.price}%"
      ..html -> "#{ig.utils.formatNumber it.price} Kč"
    ..append \svg
      ..on \mouseover displayTooltip
      ..on \touchstart displayTooltip
      ..on \mouseout hideTooltip
      ..attr \width -> "#{countScale it.count}%"
      ..attr \height 4
      ..append \line
        ..attr \x2 -> countScale it.count

legendItems = ['Počet lůžek']
container.append \ul
  ..attr \class \legend
  ..selectAll \li .data legendItems .enter!append \li
    ..html -> it
