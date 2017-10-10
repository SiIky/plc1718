BEGIN {
    FS="[ \t]+:[ \t]+"
    print "BEGIN"
    comment = 0
    cabecalho = 0
}

/^$/ { # linhas em branco
    # nao faz nada
}

/^#/ { # comentarios
    #comment++
    #print "comment", comment
}

/^%/ { # cabecalhos
    #++cabecalho
    #print "cabecalho", cabecalho
}

$0 !~ /^[$#%]/ { # as outras linhas
    keyword = $1
    #FS=":"
    #split($2, vals, " ")

    FS="[ \t]+:[ \t]+"
    split($2, vals, "[ \t]+|[ \t]+")

    print keyword
    for (val in vals) {
        print vals[val]
    }
}

END {
    print "END"
}
