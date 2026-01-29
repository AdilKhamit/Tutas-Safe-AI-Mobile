# Настройка локальной Llama модели через Ollama

## Установка Ollama

### macOS
```bash
brew install ollama
# или скачайте с https://ollama.ai/download
```

### Linux
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

### Windows
Скачайте установщик с https://ollama.ai/download

## Запуск Ollama

На macOS Ollama обычно запускается автоматически как сервис. Если нет:

```bash
# Запустить Ollama сервер
ollama serve

# Или запустить в фоне
ollama serve &
```

Ollama будет доступен на `http://localhost:11434`

**Примечание:** На macOS Ollama обычно работает как фоновый сервис автоматически после установки.

## Установка модели Llama

```bash
# Рекомендуемые модели (выберите одну):
ollama pull llama3.2        # Llama 3.2 (1.3B параметров, быстрая)
ollama pull llama3.1        # Llama 3.1 (8B параметров, хороший баланс)
ollama pull llama2          # Llama 2 (7B параметров)
ollama pull mistral         # Mistral (7B параметров, хорошее качество)
ollama pull qwen2.5         # Qwen 2.5 (хорошая поддержка русского)
```

## Настройка переменных окружения

Создайте файл `.env` в папке `backend/`:

```env
# Ollama Configuration
OLLAMA_API_URL=http://localhost:11434/api/generate
LLM_MODEL=llama3.2
```

Или экспортируйте переменные:

```bash
export OLLAMA_API_URL="http://localhost:11434/api/generate"
export LLM_MODEL="llama3.2"
```

## Проверка работы

```bash
# Проверьте что Ollama работает
curl http://localhost:11434/api/tags

# Проверьте что модель установлена
ollama list

# Протестируйте модель
ollama run llama3.2 "Hello, how are you?"
```

## Использование в приложении

После настройки Ollama, backend автоматически будет использовать локальную модель для чата.

Если Ollama не запущен или модель не установлена, система будет использовать fallback-ответы на основе данных из базы данных.
