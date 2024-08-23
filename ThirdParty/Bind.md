# Integracja Listy z serwerem Bind9

### Automatyzacja

Integracja Listy na serwerach z rodziny Linux jest z reguły bardzo prosta dzięki łatwemu skryptowaniu oraz wsparcia dla plików w formacie RPZ.

W każdym przypadku należy stworzyć skrypt, który będzie uruchamiał się automatycznie co 5 minut. Można to zagwarantować np. za pomocą usługi cron, wykonując jako root polecenie `crontab -e` i dopisując następującą linijkę:

```
*/5 * * * * NAZWA_SKRYPTU
```

(gdzie NAZWA_SKRYPTU należy podmienić na ścieżkę do stworzonej w dalszej części skrypt. Należy pamiętać, żeby skrypt był wykonywalny, tzn. wykonać na nim `chmod +x skrypt`).

### Bind9

W celu ustawienia RPZ w serwerze Bind można postępować zgodnie z instrukcją https://www.linuxbabe.com/ubuntu/set-up-response-policy-zone-rpz-in-bind-resolver-on-debian-ubuntu.

Konkretnie, należy w pliku `/etc/bind/named.conf.local` umieścić:

```
options {
    response-policy { 
        zone "hole.cert.pl";
    };
    // pozostałe opcje dopasowane do konfiguracji użytkownika
};

zone "hole.cert.pl" {
    type master;
    file "/var/cache/bind/hole-cert-pl.rpz";
    allow-query { localhost; };
};
```

I to wszystko. Pozostaje stworzyć następujący skrypt:

```bash
#!/bin/sh
curl https://hole.cert.pl/domains/v2/domains_rpz.db -o /var/cache/bind/hole-cert-pl.rpz
/usr/sbin/rndc -q reload hole.cert.pl
```

i dodać go do crona.
