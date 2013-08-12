module.exports =
  delay: (s,f) -> setTimeout f, s
  interval: (s,f) -> setInterval f, s
  repeat: (n,s) -> o = ''; o += s for i in [0...n]; o
  rand: (m,x) -> Math.floor(Math.random() * (x-m)) + m
