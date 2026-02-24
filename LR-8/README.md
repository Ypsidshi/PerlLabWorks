# ЛР8 — Доска объявлений (Perl CGI)

Проект под лабораторную: простая доска объявлений на Perl CGI с файловой базой данных.

## Полная инструкция (WSL Ubuntu + Nginx + fcgiwrap)
Эти шаги дают рабочий запуск в браузере.

1. Установите зависимости:
   ```bash
   sudo apt-get update
   sudo apt-get install nginx fcgiwrap libcgi-pm-perl
   ```
2. Включите и запустите `fcgiwrap`:
   ```bash
   sudo systemctl enable --now fcgiwrap
   ```
3. Перенесите проект в `/var/www/lr8` (чтобы сервер имел доступ):
   ```bash
   sudo mkdir -p /var/www/lr8
   sudo rsync -a /root/PerlProjects/LR-8/ /var/www/lr8/
   sudo chown -R www-data:www-data /var/www/lr8
   sudo chmod +x /var/www/lr8/cgi-bin/*.pl
   ```
4. Создайте конфиг Nginx `/etc/nginx/sites-available/lr8`:
   ```nginx
   server {
       listen 80;
       server_name localhost;

       root /var/www/lr8/public;
       index index.html;

       location /cgi-bin/ {
           gzip off;
           include fastcgi_params;
           fastcgi_pass unix:/run/fcgiwrap.socket;
           fastcgi_param SCRIPT_FILENAME /var/www/lr8/cgi-bin$fastcgi_script_name;
           fastcgi_param PATH_INFO $fastcgi_path_info;
       }
   }
   ```
5. Включите сайт и перезапустите Nginx:
   ```bash
   sudo ln -s /etc/nginx/sites-available/lr8 /etc/nginx/sites-enabled/lr8
   sudo nginx -t
   sudo systemctl restart nginx
   ```
6. Откройте в браузере:
   - `http://localhost/index.html`
   - `http://localhost/cgi-bin/hello.pl`
   - `http://localhost/cgi-bin/list.pl`

Если что-то не работает, смотрите раздел «Диагностика».

## Структура
- `public/` — статические страницы и формы
- `cgi-bin/` — CGI-скрипты
- `data/` — текстовая база данных
- `lib/Board/` — общий код

Дерево проекта:
```
LR-8/
  cgi-bin/
    add.pl
    hello.pl
    list.pl
    postcard.pl
    router.pl
    search.pl
  data/
    ads.tsv
  lib/
    Board/
      Storage.pm
  public/
    add.html
    index.html
    postcard.html
    search.html
    styles.css
    img/
      birthday.svg
      new_year.svg
      valentine.svg
  README.md
```

## Быстрый обзор требований
- Главная форма: `public/index.html` (переход к остальным страницам через `cgi-bin/router.pl`)
- Несколько форм: `public/add.html`, `public/search.html`, `public/postcard.html`
- Динамика через CGI: `cgi-bin/list.pl`, `cgi-bin/search.pl`, `cgi-bin/add.pl`, `cgi-bin/postcard.pl`
- База данных: `data/ads.tsv`

## Диагностика (если не открывается)
- 403 Forbidden: сервер не имеет доступа к папке. Проверьте, что проект в `/var/www/lr8` и владелец `www-data`.
- 502 Bad Gateway: `fcgiwrap` не запущен. Проверьте:
  ```bash
  sudo systemctl status fcgiwrap
  ```
- 404 Not Found: неверный путь в конфиге `root` или `SCRIPT_FILENAME`.
- Проверка конфигурации:
  ```bash
  sudo nginx -t
  ```
- Логи:
  ```bash
  sudo tail -n 50 /var/log/nginx/error.log
  ```

## Запуск через Apache (опционально, если нужен)
1. Убедитесь, что модуль `CGI.pm` установлен и Apache разрешает CGI.
2. Выставьте права на исполнение:
   ```bash
   chmod +x cgi-bin/*.pl
   ```
3. Пример минимальной конфигурации виртуального хоста:
   ```apacheconf
   <VirtualHost *:80>
       ServerName localhost
       DocumentRoot /var/www/lr8/public

       ScriptAlias /cgi-bin/ /var/www/lr8/cgi-bin/
       <Directory "/var/www/lr8/cgi-bin">
           Options +ExecCGI
           AddHandler cgi-script .pl
           Require all granted
       </Directory>

       <Directory "/var/www/lr8/public">
           Require all granted
       </Directory>
   </VirtualHost>
   ```
4. Перезапустите Apache и откройте `http://localhost/index.html`.

## База данных
`data/ads.tsv` — простой TSV:
```
id\ttitle\tcategory\tprice\tcity\tcontact\tdescription\tdate
```

## Простейший CGI
`cgi-bin/hello.pl` — минимальная CGI-программа (по теоретической части).
Открывается напрямую по адресу скрипта.
