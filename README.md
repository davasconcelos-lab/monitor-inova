# Monitor externo

Confere, a cada 10 minutos e de fora da VPS (servidores do GitHub), se os sites de `sites.txt` respondem.

- **Caiu:** abre uma issue "Fora do ar: <site>" com o erro. O GitHub manda e-mail para quem acompanha este repositório.
- **Voltou:** comenta quanto tempo ficou fora e fecha a issue.
- **Certificado HTTPS** com menos de 14 dias de validade também abre issue.

Cada site é testado 3 vezes (20 s entre elas) antes de contar como fora do ar, para não alarmar por uma oscilação.
Para incluir outro site, acrescente uma linha em `sites.txt`: `nome | endereço | texto esperado na resposta`.
Público de propósito: no GitHub, Actions em repositório público é gratuito (não gasta a cota dos repositórios
privados). Aqui só há endereços públicos; nenhum segredo.
