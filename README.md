# Thread pool emplementation

### Структура проекта
1. client.rb - скрипт в котором выполняются долгие запросы к котнейнеру с сервером
2. config.ru - rack сервер
3. thread_pool - имплементация пула тредов

### Имплементации
| #        | На основе чего | Ветка |
|----------|----------------|----------|
| 1        | Thread         | simple_threads_pool  |
### Запуск приложения
```
docker-compose build
docker-compose up
```