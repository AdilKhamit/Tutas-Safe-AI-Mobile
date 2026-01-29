#!/usr/bin/env python3
"""
Простой скрипт для генерации QR-кодов для труб
"""
import qrcode
import uuid
import sys
import os
from pathlib import Path

def generate_qr_code(company="COMPANY", pipe_uuid=None, output_dir="qr_codes"):
    """
    Генерирует QR-код для трубы в формате PL-COMPANY-UUID
    
    Args:
        company: Название компании (по умолчанию "COMPANY")
        pipe_uuid: UUID трубы (если None, генерируется автоматически)
        output_dir: Директория для сохранения QR-кодов
    """
    # Генерация UUID если не указан
    if pipe_uuid is None:
        pipe_uuid = str(uuid.uuid4())
    
    # Формирование QR-кода в формате PL-COMPANY-UUID
    qr_text = f"PL-{company.upper()}-{pipe_uuid}"
    
    # Создание директории если не существует
    Path(output_dir).mkdir(exist_ok=True)
    
    # Генерация QR-кода
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(qr_text)
    qr.make(fit=True)
    
    # Создание изображения
    img = qr.make_image(fill_color="black", back_color="white")
    
    # Имя файла
    filename = f"{output_dir}/qr_{company.upper()}_{pipe_uuid[:8]}.png"
    
    # Сохранение
    img.save(filename)
    
    print(f"✅ QR-код успешно сгенерирован!")
    print(f"📁 Файл: {filename}")
    print(f"🔢 QR-код: {qr_text}")
    print(f"📏 Размер: {img.size[0]}x{img.size[1]} пикселей")
    
    return filename, qr_text

if __name__ == "__main__":
    # Парсинг аргументов командной строки
    company = "COMPANY"
    pipe_uuid = None
    
    if len(sys.argv) > 1:
        company = sys.argv[1]
    if len(sys.argv) > 2:
        pipe_uuid = sys.argv[2]
    
    print("🔲 Генератор QR-кодов для труб")
    print("=" * 50)
    print(f"Компания: {company}")
    if pipe_uuid:
        print(f"UUID: {pipe_uuid}")
    else:
        print("UUID: (будет сгенерирован автоматически)")
    print("=" * 50)
    print()
    
    # Генерация QR-кода
    filename, qr_text = generate_qr_code(company, pipe_uuid)
    
    print()
    print("💡 Использование:")
    print(f"   python {sys.argv[0]} [COMPANY] [UUID]")
    print()
    print("   Примеры:")
    print(f"   python {sys.argv[0]} COMPANY")
    print(f"   python {sys.argv[0]} TUTAS")
    print(f"   python {sys.argv[0]} COMPANY 123e4567-e89b-12d3-a456-426614174000")
