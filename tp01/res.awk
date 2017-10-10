BEGIN {
    FS="[ \t]+:[ \t]+"
    print "BEGIN"
    comment = 0
    dominio = ""
    sintax = ""
    test = []
}

/^$/ { # linhas em branco
    # nao faz nada
}

/^#/ { # comentarios
    #comment++
    #print "comment", comment
}

/^%/ { # cabecalhos
    # processar o dominio
    dominio = $0
    sub('^.*?(', dominio)
    sub(').*$', dominio)
    if (dominio == "") {
        # dominio universal, caso "()" seja vazio
        dominio = "uni"
    }

    # processar a sintax
    sintax = $0
    sub('^.*(', sintax)
    sub(').*$', sintax)

    # vamos usar `dominio` e `sintax`
    print dominio, sintax
}

$0 !~ /^[$#%]/ { # as outras linhas
    keyword = $1
    #split($2, vals, " ")

    split($2, vals, "[ \t]+|[ \t]+")

    print keyword
    for (val in vals) {
        print vals[val]
    }
}

END {
    print "END"
}
