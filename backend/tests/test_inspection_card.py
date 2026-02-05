"""
Тесты генерации «Рабочая карта обследования EXPERTUS» (DOCX).
Для прохождения тестов нужен шаблон: inspection_card_template.docx, .dotx или .doc в backend/app/templates/.
Создать эталонный .docx: python scripts/generate_inspection_template.py
"""
import io
import os
import re
import zipfile
from datetime import date

import pytest

from app.schemas.inspections import InspectionCardGenerate
from app.services.inspection_card_service import generate_inspection_card_docx

_TEMPLATES_DIR = os.path.join(os.path.dirname(__file__), "..", "app", "templates")
_TEMPLATE_DOCX = os.path.join(_TEMPLATES_DIR, "inspection_card_template.docx")
_TEMPLATE_DOTX = os.path.join(_TEMPLATES_DIR, "inspection_card_template.dotx")
_TEMPLATE_DOC = os.path.join(_TEMPLATES_DIR, "inspection_card_template.doc")


def _template_exists() -> bool:
    return (
        os.path.isfile(_TEMPLATE_DOCX)
        or os.path.isfile(_TEMPLATE_DOTX)
        or os.path.isfile(_TEMPLATE_DOC)
    )


@pytest.fixture
def sample_payload() -> InspectionCardGenerate:
    return InspectionCardGenerate(
        inspector_name="Иванов И.И.",
        inspection_date=date(2026, 2, 5),
        customer="ТОО Заказчик",
        object_name="Участок трубопровода №1",
        location="г. Алматы",
        inventory_number="INV-001",
        factory_number="FN-100",
        temperature_c=22.0,
        humidity_percent=45.0,
        illumination_lux=300.0,
        equipment_vik="Комплект ВИК-1",
        equipment_penetrant="ПВК-2",
        equipment_defectoscope="УД2-102",
        equipment_thickness_gauge="ТУ-3",
        equipment_hardness="ТД-4",
        documentation_state="удовлетворительно",
        defects_notes="Дефектов не обнаружено.",
        sketch_note="Схема прилагается.",
    )


@pytest.fixture
def minimal_payload() -> InspectionCardGenerate:
    """Минимальный payload: только обязательная дата."""
    return InspectionCardGenerate(inspection_date=date(2026, 1, 15))


@pytest.mark.skipif(not _template_exists(), reason="No inspection card template (.docx/.dotx/.doc) in app/templates")
def test_generate_inspection_card_docx_returns_valid_docx(sample_payload: InspectionCardGenerate) -> None:
    """Генерация возвращает валидный DOCX (zip с word/document.xml)."""
    out = generate_inspection_card_docx(sample_payload)
    assert isinstance(out, bytes)
    assert len(out) > 100

    with zipfile.ZipFile(io.BytesIO(out), "r") as zf:
        names = zf.namelist()
        assert "word/document.xml" in names
        doc_xml = zf.read("word/document.xml").decode("utf-8")

    # Ключевые подстановки (шаблон может быть .dotx со своей вёрсткой — проверяем минимум)
    assert "Иванов И.И." in doc_xml
    assert "05.02.2026" in doc_xml

    # Не должно остаться незаменённых плейсхолдеров
    remaining = re.findall(r"\{\{[^}]+\}\}", doc_xml)
    assert not remaining, f"Unreplaced placeholders: {remaining}"


@pytest.mark.skipif(not _template_exists(), reason="No inspection card template (.docx/.dotx/.doc) in app/templates")
def test_generate_inspection_card_minimal_payload(minimal_payload: InspectionCardGenerate) -> None:
    """Минимальный payload: дата подставляется, пустые поля — прочерк."""
    out = generate_inspection_card_docx(minimal_payload)
    assert isinstance(out, bytes)

    with zipfile.ZipFile(io.BytesIO(out), "r") as zf:
        doc_xml = zf.read("word/document.xml").decode("utf-8")

    assert "15.01.2026" in doc_xml
    # Пустые опциональные поля заменяются на «—»
    assert "—" in doc_xml


def test_generate_inspection_card_requires_inspection_date() -> None:
    """Без inspection_date сервис выбрасывает ValueError (шаблон не требуется)."""
    payload = InspectionCardGenerate.model_construct(inspection_date=None)
    with pytest.raises(ValueError, match="inspection_date"):
        generate_inspection_card_docx(payload)
