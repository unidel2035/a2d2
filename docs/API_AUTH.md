# API Аутентификации

Документация по API endpoints для аутентификации через JWT токены.

## Обзор

API аутентификации предоставляет endpoints для входа, выхода и обновления JWT токенов. Все API endpoints используют JWT токены для аутентификации запросов.

## Base URL

```
/api/v1/auth
```

## Endpoints

### 1. Вход (Login)

Аутентификация пользователя и получение JWT токенов.

**Endpoint:** `POST /api/v1/auth/login`

**Параметры запроса:**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Успешный ответ (200 OK):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_in": 86400,
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "Иван Иванов",
    "role": "admin"
  }
}
```

**Ошибки:**

- `401 Unauthorized` - Неверный email или пароль
- `401 Unauthorized` - Email не подтвержден
- `401 Unauthorized` - Аккаунт заблокирован

**Пример запроса (curl):**

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

---

### 2. Выход (Logout)

Выход пользователя и инвалидация токена (добавление в blacklist).

**Endpoint:** `POST /api/v1/auth/logout`

**Заголовки:**

```
Authorization: Bearer {access_token}
```

**Успешный ответ (200 OK):**

```json
{
  "message": "Успешный выход из системы"
}
```

**Ошибки:**

- `401 Unauthorized` - Токен не предоставлен
- `401 Unauthorized` - Недействительный токен
- `401 Unauthorized` - Токен был отозван
- `401 Unauthorized` - Пользователь не найден

**Пример запроса (curl):**

```bash
curl -X POST http://localhost:3000/api/v1/auth/logout \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
```

---

### 3. Обновление токена (Refresh)

Обновление access токена с помощью refresh токена.

**Endpoint:** `POST /api/v1/auth/refresh`

**Параметры запроса:**

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Успешный ответ (200 OK):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_in": 86400
}
```

**Ошибки:**

- `400 Bad Request` - Refresh токен не предоставлен
- `401 Unauthorized` - Недействительный refresh токен
- `401 Unauthorized` - Refresh токен был отозван
- `401 Unauthorized` - Пользователь не найден

**Пример запроса (curl):**

```bash
curl -X POST http://localhost:3000/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
  }'
```

---

## Использование токенов

### Access Token

- **Срок действия:** 24 часа
- **Использование:** Для аутентификации всех API запросов
- **Формат заголовка:** `Authorization: Bearer {access_token}`

### Refresh Token

- **Срок действия:** 7 дней
- **Использование:** Для получения нового access токена без повторного ввода пароля
- **Хранение:** Должен храниться безопасно на клиенте

---

## Защищенные endpoints

Все API endpoints (кроме auth endpoints) требуют аутентификации через JWT токен.

**Пример защищенного запроса:**

```bash
curl -X GET http://localhost:3000/api/v1/robots \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
```

---

## Безопасность

### Token Blacklist

При выходе (logout) токен добавляется в blacklist и становится недействительным. Система автоматически очищает истекшие токены из blacklist.

### Рекомендации

1. **HTTPS:** Всегда используйте HTTPS для API запросов в production
2. **Хранение токенов:** Храните токены безопасно (например, в httpOnly cookies или secure storage)
3. **Refresh токены:** Используйте refresh токены для обновления access токенов вместо хранения пароля
4. **Обработка ошибок:** Обрабатывайте ошибки 401 и перенаправляйте на страницу входа
5. **Rate limiting:** Ограничьте количество попыток входа для защиты от brute-force атак

---

## Коды ошибок

| Код | Описание | Решение |
|-----|----------|---------|
| 400 | Bad Request | Проверьте параметры запроса |
| 401 | Unauthorized | Токен недействителен или отсутствует, войдите снова |
| 403 | Forbidden | Недостаточно прав доступа |
| 404 | Not Found | Endpoint не найден |
| 422 | Unprocessable Entity | Ошибка валидации данных |
| 500 | Internal Server Error | Внутренняя ошибка сервера |

---

## Примеры использования

### JavaScript (Fetch API)

```javascript
// Login
const login = async (email, password) => {
  const response = await fetch('/api/v1/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });

  if (!response.ok) {
    throw new Error('Login failed');
  }

  const data = await response.json();
  localStorage.setItem('access_token', data.access_token);
  localStorage.setItem('refresh_token', data.refresh_token);
  return data;
};

// Authenticated request
const fetchRobots = async () => {
  const token = localStorage.getItem('access_token');
  const response = await fetch('/api/v1/robots', {
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });

  if (response.status === 401) {
    // Try to refresh token
    await refreshToken();
    return fetchRobots(); // Retry
  }

  return response.json();
};

// Refresh token
const refreshToken = async () => {
  const refresh_token = localStorage.getItem('refresh_token');
  const response = await fetch('/api/v1/auth/refresh', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ refresh_token }),
  });

  if (!response.ok) {
    // Redirect to login
    window.location.href = '/login';
    return;
  }

  const data = await response.json();
  localStorage.setItem('access_token', data.access_token);
};

// Logout
const logout = async () => {
  const token = localStorage.getItem('access_token');
  await fetch('/api/v1/auth/logout', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });

  localStorage.removeItem('access_token');
  localStorage.removeItem('refresh_token');
  window.location.href = '/login';
};
```

### Python (requests)

```python
import requests

# Login
def login(email, password):
    response = requests.post('http://localhost:3000/api/v1/auth/login', json={
        'email': email,
        'password': password
    })

    if response.status_code == 200:
        data = response.json()
        return data['access_token'], data['refresh_token']
    else:
        raise Exception('Login failed')

# Authenticated request
def get_robots(access_token):
    response = requests.get('http://localhost:3000/api/v1/robots', headers={
        'Authorization': f'Bearer {access_token}'
    })

    if response.status_code == 401:
        # Try to refresh token
        access_token = refresh_token(refresh_token)
        return get_robots(access_token)

    return response.json()

# Refresh token
def refresh_token(refresh_token):
    response = requests.post('http://localhost:3000/api/v1/auth/refresh', json={
        'refresh_token': refresh_token
    })

    if response.status_code == 200:
        data = response.json()
        return data['access_token']
    else:
        raise Exception('Token refresh failed')

# Logout
def logout(access_token):
    requests.post('http://localhost:3000/api/v1/auth/logout', headers={
        'Authorization': f'Bearer {access_token}'
    })
```

---

## Связанные документы

- [SPECIFICATION.md](../SPECIFICATION.md) - Общая спецификация проекта
- [API_ROBOTS.md](./API_ROBOTS.md) - Документация API для работы с роботами
- [РЕЗЮМЕ-РЕАЛИЗАЦИИ.md](../РЕЗЮМЕ-РЕАЛИЗАЦИИ.md) - Резюме реализации проекта

---

## Changelog

### v1.0.0 (2025-10-29)

- Добавлены endpoints для login, logout, refresh
- Реализована система JWT токенов
- Добавлена система token blacklist
- Добавлена документация и примеры использования
