
fn -default-options [last words]{
  unused_single = [&'-c'=true &'-n'=true &'-e'=true &'-s'=true &'-r'=true &'-R'=true &'-C'=true &'-M'=true &'-S'=true &'--tab'=true]
  for word $words {
    unused_single[$word] = false
    if (eq $word '-C') {
      unused_single['-M'] = false
    } elif (eq $word '-M') {
      unused_single['-C'] = false
    }
  }
  if (or (eq $last '') (eq $last '-')) {
    ks = [(keys $unused_single)]
    for k $ks {
      if (eq true $unused_single[$k]) {
        put $k
      }
    }
  	put '--arg'
    put '--argjson'
    put '--slurpfile'
    put '--rawfile'
    put '--args'
    put '--jsonargs'
    put '--'
  } elif (eq (count $last) 1) {
    return
  } elif  (eq $last '--') {
    put '--tab'
    put '--arg'
    put '--argjson'
    put '--slurpfile'
    put '--rawfile'
    put '--args'
    put '--jsonargs'
    put '--'
  } elif (eq (count $last) 2) {
    return
  } elif  (eq $last[0:3] '--a') {
  	put '--arg'
    put '--argjson'
    put '--args'
  } elif  (eq $last[0:3] '--s') {
    put '--slurpfile'
  } elif  (eq $last[0:3] '--r') {
    put '--rawfile'
  } elif  (eq $last[0:3] '--j') {
    put '--jsonargs'
  } elif  (eq $last[0:3] '--t') {
    put '--tab'
  }
}

fn -nop [last words]{
  nop
}

fn -file-param [last words]{
  edit:complete-filename $words[-1]
  return
}

fn compl [@words]{
  if (eq (count $words) 1) {
    -default-options '' []
  }
  last = $words[-1]
  preceeding = $words[1:-1]
  h = $-default-options~
  file_var_taking = false
  num_args = 0

  for word $preceeding {
    if (or (eq $word '--') (eq $word '--args') (eq $word '--jsonargs')) {
      # Term arg parsing
      return
    } elif (or (eq $word '--arg') (eq $word '--argjson')) {
      file_var_taking = false
      h = $-nop~
    } elif (or (eq $word '--slurpfile') (eq $word '--rawfile')) {
      # Known variable taking
      file_var_taking = true
      h = $-nop~
    } elif (or (eq $word '-c') (eq $word '-n') (eq $word '-e') (eq $word '-s') (eq $word '-r') (eq $word '-R') (eq $word '-C') (eq $word '-M') (eq $word '-S') (eq $word '--tab')) {
      # Known single taking
      file_var_taking = false
      h = $-default-options~
    } elif (eq $num_args 0) {
      num_args = (+ $num_args 1)
      if $file_var_taking {
        h = $-file-param~
      }
    } else {
      num_args = 0
      h = $-default-options~
    }
  }
  $h $last $preceeding
}

fn apply {
    edit:completion:arg-completer[jq] = $compl~
}
