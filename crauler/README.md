Необходимо написать краулер с использованием AnyEvent или Coro
Требования к роботу:
Собрать с сайта все уникальные страницы
Для каждой страницы запомнить её размер
Если страниц более 10000, собрать максимум 10000 уникальных
ссылок
Не уходить с сайта на другие сайты
Вывести Top-10 страниц по размеру и суммарный размер всех
страниц
Модули, которые могут помочь в решении: AnyEvent::HTTP,
Coro::LWP, Web::Query. Web::Query допустимо использовать
только как парсер документов, но не как инструмент для скачивания
$AnyEvent::HTTP::MAX_PER_HOST = 100;