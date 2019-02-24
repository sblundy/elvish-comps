use github.com/zzamboni/elvish-modules/test
use jq

fn sut [@words]{
    h = [last preceeding]{
        put 'test.txt'
    }
    jq:jq-completer $h $words
}
cmds = [(sut jq '')]

(test:set 'jq' [
  (test:set "basic options" [
    (test:check { has-value $cmds '-c' })
    (test:check { has-value $cmds '-C' })
    (test:check { has-value $cmds '-n' })
  ])
  (test:set "used options not suggested" [
    (test:check { not (has-value [(sut jq '-c' '')] '-c') })
    (test:check { and [
        (not (has-value [(sut jq '-c' '-C' '')] '-c')) 
        (not (has-value [(sut jq '-c' '-C' '')] '-C')) 
    ]})
  ])
  (test:set "used short options remove long" [
    (test:check { not (has-value [(sut jq '-C' '')] '--color-output') })
  ])
  (test:set "no suggestions for variable" [
    (test:check { eq [(sut jq '--rawfile' '')] [] })
    (test:check { eq [(sut jq '--rawfile' 'x' '')] ['test.txt'] })
  ])
])