BEGIN {
    FS="[ \t]+:[ \t]+"
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
    dominio = ler_dominio($0);
    print "dom", dominio
    # processar a sintax
    sintax = $0
    sub(/^.*\(/, "", sintax)
    sub(/).*$/, "", sintax)

    # vamos usar `dominio` e `sintax`
    print "sin", sintax
}

$0 !~ /^[$#%]/ { # as outras linhas
    keyword = $1
    #split($2, vals, " ")

    split($2, vals, "[ \t]*|[ \t]*")

    print keyword
    for (val in vals) {
        print "\t" vals[val]
    }
}

END {
    print "END"
}

function ler_dominio (dominio) {
    if (dominio ~ /\()\(/) {
        # dominio universal, caso "()" seja vazio
        dominio = "universal"
    } else {
        sub(/^.*\(dom=>/, "", dominio)
        sub(/).*$/,  "", dominio)
    }
    return dominio;
}
