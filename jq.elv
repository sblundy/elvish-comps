-empty_only = [
  -h
  --help
  --version
]
-single_use = [
  &'-a'=['--ascii-output' '-a']
  &'-C'=['--monochrome-output' '-M' '--color-output' '-C']
  &'-c'=['--compact-output' '-c']
  &'-e'=['--exit-status' '-e']
  &'-f'=['--from-file' '-f']
  &'-j'=['--join-output' '-j']
  &'-M'=['--monochrome-output' '-M' '--color-output' '-C']
  &'-n'=['--null-input' '-n']
  &'-R'=['--raw-input' '-R']
  &'-r'=['--raw-output' '-r']
  &'-S'=['--sort-keys' '-S']
  &'-s'=['--slurp' '-s']
  &'--args'=['--args']
  &'--ascii-output'=['--ascii-output' '-a']
  &'--color-output'=['--monochrome-output' '-M' '--color-output' '-C']
  &'--compact-output'=['--compact-output' '-c']
  &'--exit-status'=['--exit-status' '-e']
  &'--from-file'=['--from-file' '-f']
  &'--indent'=['--indent']
  &'--join-output'=['--join-output' '-j']
  &'--jsonargs'=['--jsonargs']
  &'--monochrome-output'=['--monochrome-output' '-M' '--color-output' '-C']
  &'--null-input'=['--null-input' '-n']
  &'--raw-input'=['--raw-input' '-R']
  &'--raw-output'=['--raw-output' '-r']
  &'--seq'=['--seq']
  &'--slurp'=['--slurp' '-s']
  &'--sort-keys'=['--sort-keys' '-S']
  &'--stream'=['--stream']
  &'--tab'=['--tab']
  &'--unbuffered'=['--unbuffered']
]
-have-args = [
  &'-f'=1
  &'--arg'=2
  &'--argjson'=2
  &'--from-file'=1
  &'--indent'=1
  &'--rawfile'=2
  &'--slurpfile'=2
]
-have-args-with-filename = [
  &'--rawfile'=2
  &'--slurpfile'=2
]
-arg-terminators = [
  &'--'='filenames'
  &'--args'='strings'
  &'--jsonargs'='jsonstrings'
]
-repeatable = [
  -L
  --arg
  --argjson
  --rawfile
  --slurpfile
]
fn -default-options [last preceeding]{
  used_single = [&]
  for word $preceeding {
    used_single[$word] = true
    if (has-key $-single_use $word) {
      others = $-single_use[$word]
      for other $others {
        used_single[$other] = true
      }
    }
  } else {
    explode $-empty_only
  }

  for k [(keys $-single_use)] {
    if (not (has-key $used_single $k)) {
      put $k
    }
  }
  
  explode $-repeatable
}

fn jq-completer [handle words]{
  if (eq (count $words) 1) {
    -default-options '' []
  }
  last = $words[-1]
  preceeding = $words[1:-1]
  h = $-default-options~
  file_var_taking = false
  num_args = 0

  for word $preceeding {
    if (has-key $-arg-terminators $word) {
      if (eq $-arg-terminators[$word] 'filenames') {
        h = $handle
        break
      } else {
        return
      }
    } elif (has-key $-have-args-with-filename $word) {
      file_var_taking = true
      num_args = $-have-args-with-filename[$word]
      h = $nop~
    } elif (has-key $-have-args $word) {
      num_args = $-have-args[$word]
      h = $nop~
    } elif (eq $num_args 2) {
      num_args = (- $num_args 1)
      if $file_var_taking {
        h = $handle
        file_var_taking = false
      }
    } elif (eq $num_args 1) {
      num_args = (- $num_args 1)
      h = $-default-options~
    } else {
      h = $-default-options~
    }
  }
  $h $last $preceeding
}

fn apply {
    edit:completion:arg-completer[jq] = [@words]{
      handle = [last words]{
        edit:complete-filename $words[-1]
      }
      jq-completer $handle $words
    }
}
