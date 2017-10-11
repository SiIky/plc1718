BEGIN {
    FS="[ \t]*:[ \t]*"
}

/^$/ { # linhas em branco
    # nao faz nada
}

/^#/ { # comentarios
    #comment = 0
    #comment++
    #print "comment", comment
}

/^%/ { # cabecalhos
    dominio = ler_dominio($0)
    #print "dom", dominio
    sintax = ler_sintax($0)
    #print "sin", sintax
}

$0 !~ /^[$#%]/ { # as outras linhas
    termo_base = $1
    #print termo_base

    split(sintax, relacoes, ":")
    for (n = 2; n <= NF; n++) {
        #print "\tfield", n-1
        field = $n
        split_alts(field, alts)
        for (alt in alts) {
            estrutura[dominio][termo_base][relacoes[n]][alts[alt]] = alts[alt]
            #print "\t\t" alts[alt]
        }
    }

}

END {
    print "<ul>"
    for (dom in estrutura) {
        print_li(dom)
        print "<ul>"
        for (t in estrutura[dom]) {
            print_li(t)
            print "<ul>"
            for (n in estrutura[dom][t]) {
                if (n != "DE" && n != "EN") {
                    print_li(n)
                    print "<ul>"
                    for (alt in estrutura[dom][t][n]) {
                        print_li(estrutura[dom][t][n][alt])
                    }
                    print "</ul>"
                }
            }
            print "</ul>"
        }
        print "</ul>"
    }
    print "</ul>"
}

function print_li (txt) {
    print "<li>", txt, "</li>"
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
