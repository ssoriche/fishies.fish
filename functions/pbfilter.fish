function pbfilter -d "filter paste buffer contents"
    set -l BUFFER $(mktemp)
    trap 'rm -f $BUFFER' EXIT

    pbpaste >"${BUFFER}"
    sed <"${BUFFER}" 's/^.*/%/g' | pbcopy
end
