#!/bin/bash
# Confere cada site de sites.txt: 3 tentativas (com 20 s entre elas) de resposta 200 contendo o texto esperado, e
# certificado HTTPS com pelo menos 14 dias de validade. Escreve resultado.tsv: nome<TAB>ok|falha<TAB>detalhe.
set -u
: > resultado.tsv
while IFS='|' read -r nome url esperado; do
  nome=$(echo "$nome" | xargs); url=$(echo "$url" | xargs); esperado=$(echo "$esperado" | sed 's/^ *//;s/ *$//')
  [ -z "$nome" ] || [ "${nome#\#}" != "$nome" ] && continue
  detalhe=""
  for tentativa in 1 2 3; do
    corpo=$(curl -sS -m 20 -w '\n%{http_code} %{time_total}' "$url" 2>&1) || true
    codigo=$(echo "$corpo" | tail -1 | cut -d' ' -f1); tempo=$(echo "$corpo" | tail -1 | cut -d' ' -f2)
    if [ "$codigo" = "200" ] && echo "$corpo" | grep -qF -- "$esperado"; then detalhe=""; break; fi
    detalhe="HTTP ${codigo:-sem resposta} (tentativa $tentativa): $(echo "$corpo" | head -c 200 | tr '\n\t' '  ')"
    [ $tentativa -lt 3 ] && sleep 20
  done
  if [ -z "$detalhe" ]; then
    host=$(echo "$url" | sed -E 's#https?://([^/:]+).*#\1#')
    fim=$(echo | openssl s_client -servername "$host" -connect "$host:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -n "$fim" ]; then
      dias=$(( ( $(date -d "$fim" +%s) - $(date +%s) ) / 86400 ))
      [ "$dias" -lt 14 ] && detalhe="certificado HTTPS vence em $dias dia(s) ($fim)"
    fi
  fi
  if [ -z "$detalhe" ]; then printf '%s\tok\tresposta em %ss\n' "$nome" "$tempo" >> resultado.tsv
  else printf '%s\tfalha\t%s\n' "$nome" "$detalhe" >> resultado.tsv; fi
done < <(tr -d '' < sites.txt)
cat resultado.tsv
