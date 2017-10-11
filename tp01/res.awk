BEGIN {
    FS="[ \t]*:[ \t]*"
    print "BEGIN"
    comment = 0
    dominio = ""
    sintax = ""
}

/^$/ { # linhas em branco
    # nao faz nada
}

/^#/ { # comentarios
    #comment++
    #print "comment", comment
}

/^%/ { # cabecalhos
    dominio = ler_dominio($0)
    print "dom", dominio
    sintax = ler_sintax($0)
    print "sin", sintax
}

$0 !~ /^[$#%]/ { # as outras linhas
    termo_base = $1
    print termo_base

    for (n = 2; n <= NF; n++) {
        print "\tfield", n-1
        field = $n
        split_alts(field, alts)
        for (alt in alts) {
            print "\t\t" alts[alt]
        }
    }
}

END {
    print "END"
}

function ler_dominio (dominio) {
    if (dominio ~ /\()\(/) {
        # dominio universo, caso "()" seja vazio
        dominio = "universo"
    } else {
        sub(/^.*\(dom=>/, "", dominio)
        sub(/).*$/,  "", dominio)
    }
    return dominio
}

function ler_sintax (sintax) {
    # processar a sintax
    sintax = $0
    sub(/^.*\(/, "", sintax)
    sub(/).*$/, "", sintax)
    return sintax
}

function split_alts (field, alts) {
    split(field, alts, /[ \t]*\|[ \t]*/)
}
