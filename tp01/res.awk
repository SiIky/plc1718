BEGIN {
    FS="[ \t]*:[ \t]*"
}

/^%/ { # cabecalhos
    dominio = ler_dominio($0)
    sintax = ler_sintax($0)
}

$0 !~ /^[$#%]/ { # as outras linhas
    termo_base = $1

    split(sintax, relacoes, ":")
    for (n = 2; n <= NF; n++) {
        field = $n
        split_alts(field, alts)
        for (alt in alts) {
            estrutura[dominio][termo_base][relacoes[n]][alts[alt]] = alts[alt]
        }
    }
}

END {
    alien_a(estrutura)
    alien_b(estrutura)
}

function li (txt) {
    return "<li>" txt "</li>"
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
    sub(/^.*\(/, "", sintax)
    sub(/).*$/, "", sintax)
    return sintax
}

function split_alts (field, alts) {
    split(field, alts, /[ \t]*\|[ \t]*/)
}

function print_to_file (str, filename) {
    print str > filename
}

function alien_a (estrutura) {
    for (dom in estrutura) {
        html = "<h1>" dom "</h1>"
        html = html "<ul>"
        for (tbase in estrutura[dom]) {
            html = html li(tbase)
            html = html "<ul>"
            for (n in estrutura[dom][tbase]) {
                if (n != "DE" && n != "EN") {
                    html = html li(n)
                    html = html "<ul>"
                    for (alt in estrutura[dom][tbase][n]) {
                        html = html li(estrutura[dom][tbase][n][alt])
                    }
                    html = html "</ul>"
                }
            }
            html = html "</ul>"
        }
        html = html "</ul>"
        print_to_file(html, dom ".html")
    }
}

function alien_b (estrutura) {
    html_pt["EN"] = "<ul>"
    html_pt["DE"] = "<ul>"

    for (dom in estrutura) {
        for (tbase in estrutura[dom]) {
            for (n in estrutura[dom][tbase]) {
                if (n == "DE" || n == "EN") {
                    html_pt[n] = html_pt[n] li(tbase)
                    html_pt[n] = html_pt[n] "<ul>"
                    for (alt in estrutura[dom][tbase][n]) {
                        html_pt[n] = html_pt[n] li(estrutura[dom][tbase][n][alt])
                    }
                    html_pt[n] = html_pt[n] "</ul>"
                }
            }
        }
    }

    html_pt["EN"] = html_pt["EN"] "</ul>"
    html_pt["DE"] = html_pt["DE"] "</ul>"

    print_to_file(html_pt["EN"], "pt-en.html")
    print_to_file(html_pt["DE"], "pt-de.html")
}
