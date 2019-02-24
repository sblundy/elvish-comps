use github.com/zzamboni/elvish-modules/test
use jq

cmds = [(jq:jq-completer jq '')]

(test:set 'jq' [
  (test:set "basic options" [
    (test:check { has-value $cmds '-c' })
    (test:check { has-value $cmds '-C' })
    (test:check { has-value $cmds '-n' })
  ])
  (test:set "used options not suggested" [
    (test:check { not (has-value [(jq:jq-completer jq '-c' '')] '-c') })
    (test:check { and [
        (not (has-value [(jq:jq-completer jq '-c' '-C' '')] '-c')) 
        (not (has-value [(jq:jq-completer jq '-c' '-C' '')] '-C')) 
    ]})
  ])
  (test:set "no suggestions for variable" [
    (test:check { eq [(jq:jq-completer jq '--rawfile' '')] [] })
  ])
])