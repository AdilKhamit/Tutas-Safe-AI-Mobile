"""
Inspection Card Service - Генерация «Рабочая карта обследования EXPERTUS» (DOCX)
по шаблону: подстановка данных вместо плейсхолдеров {{...}} и вместо пустых полей (прочерков).
"""
import io
import logging
import os
import re
import shutil
import subprocess
import zipfile

from docx import Document
from app.schemas.inspections import InspectionCardGenerate

logger = logging.getLogger(__name__)

# Правила «подставить данные вместо прочерков» (обратная совместимость со старыми шаблонами):
# (триггерная фраза в параграфе, [ключи значений по порядку]). Один триггер «Примечание» покрывает «Примечание:» и «Примечание ».
FILL_BLANKS_RULES = [
    ("Заказчик", ["customer"]),
    ("Наименование объекта обследования", ["object_name"]),
    ("Место нахождения", ["location"]),
    ("Инв.№", ["inventory_number", "factory_number"]),
    ("Ф.И.О. исполнителя", ["inspector_name", "inspection_date"]),
    ("Температура воздуха", ["temperature_c", "humidity_percent"]),
    ("Уровень освещенности", ["illumination_lux"]),
    ("Комплект ВИК", ["equipment_vik"]),
    ("Комплект пенетрантов", ["equipment_penetrant"]),
    ("дефектоскоп", ["equipment_defectoscope"]),
    ("толщиномер", ["equipment_thickness_gauge"]),
    ("Твердомер", ["equipment_hardness"]),
    ("Состояние рабочей документации", ["documentation_line"]),
    ("Примечание", ["defects_notes"]),
    ("Эскиз", ["sketch_note"]),
]
UNDERSCORE_BLOCK_RE = re.compile(r"_{3,}")
# В XML DOCX текст в <w:t>; заменяем по порядку блоки из 5+ подчёркиваний
XML_UNDERSCORE_W_T_RE = re.compile(r"(<w:t[^>]*>)\s*_{5,}\s*(</w:t>)", re.DOTALL)
# Поиск незаменённых плейсхолдеров в сгенерированном документе
REMAINING_PLACEHOLDER_RE = re.compile(r"\{\{[^}]+\}\}")

_TEMPLATES_DIR = os.path.join(os.path.dirname(__file__), "..", "templates")
_TEMPLATE_DOCX = os.path.join(_TEMPLATES_DIR, "inspection_card_template.docx")
_TEMPLATE_DOTX = os.path.join(_TEMPLATES_DIR, "inspection_card_template.dotx")
_TEMPLATE_DOC = os.path.join(_TEMPLATES_DIR, "inspection_card_template.doc")

_SOFFICE_PATHS = [
    "/Applications/LibreOffice.app/Contents/MacOS/soffice",
    "/usr/bin/soffice",
    "/usr/bin/libreoffice",
]


# Прочерк для пустых необязательных полей в документе (см. FIELD_MAPPING.md)
_EMPTY_PLACEHOLDER = "—"


def _str(val: str | float | None, empty_placeholder: str = "") -> str:
    """Преобразует значение в строку для подстановки в шаблон. empty_placeholder — что подставлять вместо пустого (по умолчанию "")."""
    if val is None:
        return empty_placeholder
    if isinstance(val, float):
        return str(val) if val == int(val) else f"{val:.1f}"
    try:
        s = str(val).strip()
        return s if s else empty_placeholder
    except (TypeError, AttributeError):
        return empty_placeholder


def _xml_escape(s: str) -> str:
    if not s:
        return s
    return (
        s.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&apos;")
    )


def _find_soffice() -> str | None:
    for path in _SOFFICE_PATHS:
        if os.path.isfile(path) and os.access(path, os.X_OK):
            return path
    return None


def _convert_doc_to_docx(doc_path: str, out_dir: str) -> str | None:
    soffice = _find_soffice()
    if not soffice:
        return None
    doc_path = os.path.abspath(doc_path)
    out_dir = os.path.abspath(out_dir)
    try:
        subprocess.run(
            [soffice, "--headless", "--convert-to", "docx", "--outdir", out_dir, doc_path],
            check=True,
            capture_output=True,
            timeout=30,
        )
        base = os.path.splitext(os.path.basename(doc_path))[0]
        docx_path = os.path.join(out_dir, base + ".docx")
        return docx_path if os.path.isfile(docx_path) else None
    except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired) as e:
        logger.warning("Doc to docx conversion failed: %s", e)
        return None


def _dotx_to_docx_bytes(template_bytes: bytes) -> bytes:
    """Меняет в .dotx тип контента на document, чтобы python-docx принял файл."""
    out = io.BytesIO()
    with zipfile.ZipFile(io.BytesIO(template_bytes), "r") as zin:
        with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zout:
            for name in zin.namelist():
                data = zin.read(name)
                if name == "[Content_Types].xml":
                    text = data.decode("utf-8")
                    text = text.replace(
                        "wordprocessingml.template.main",
                        "wordprocessingml.document.main",
                    )
                    data = text.encode("utf-8")
                zout.writestr(name, data)
    out.seek(0)
    return out.getvalue()


def _load_template_bytes() -> bytes:
    """Загружает шаблон в байтах. Приоритет: .dotx (основной шаблон) → .docx → .doc (конвертация)."""
    # Строго по шаблону inspection_card_template.dotx: при наличии .dotx используем его первым
    if os.path.isfile(_TEMPLATE_DOTX):
        with open(_TEMPLATE_DOTX, "rb") as f:
            raw = f.read()
        return _dotx_to_docx_bytes(raw)
    if os.path.isfile(_TEMPLATE_DOCX):
        with open(_TEMPLATE_DOCX, "rb") as f:
            return f.read()
    if os.path.isfile(_TEMPLATE_DOC):
        converted = _convert_doc_to_docx(_TEMPLATE_DOC, _TEMPLATES_DIR)
        if converted:
            shutil.move(converted, _TEMPLATE_DOCX)
            with open(_TEMPLATE_DOCX, "rb") as f:
                return f.read()
        raise FileNotFoundError(
            "Шаблон inspection_card_template.docx не найден. "
            "Сконвертируйте .doc в .docx (Word: Файл → Сохранить как → .docx) в backend/app/templates/."
        )
    raise FileNotFoundError(
        f"Шаблон не найден. Положите в backend/app/templates/: "
        f"inspection_card_template.docx, inspection_card_template.dotx или inspection_card_template.doc"
    )


def _build_placeholders(payload: InspectionCardGenerate) -> tuple[dict[str, str], dict[str, str]]:
    """Возвращает (словарь для замены {{key}}, словарь по ключу для заполнения прочерков)."""
    inspection_date_str = (
        payload.inspection_date.strftime("%d.%m.%Y") if payload.inspection_date else ""
    )
    state = (payload.documentation_state or "").strip().lower()
    s1, s2, s3 = "удовлетворительно", "неудовлетворительно", "отсутствует/ не предоставлена"
    if state in ("удовлетворительно", "satisfactory"):
        s1 = "удовлетворительно [x]"
    elif state in ("неудовлетворительно", "unsatisfactory"):
        s2 = "неудовлетворительно [x]"
    elif state in ("отсутствует", "absent", "не предоставлена"):
        s3 = "отсутствует/ не предоставлена [x]"
    documentation_line = f"  {s1}     {s2}     {s3}"

    defects_text = _str(payload.defects_notes)
    if not defects_text:
        defects_text = (
            "В рабочей карте необходимо указать используемое оборудование "
            "(с указанием заводского номера), с помощью которого производился неразрушающий контроль."
        )

    replacements = {
        "{{inspector_name}}": _str(payload.inspector_name) or "Исполнитель",
        "{{inspection_date}}": inspection_date_str,
        "{{customer}}": _str(payload.customer, _EMPTY_PLACEHOLDER),
        "{{object_name}}": _str(payload.object_name, _EMPTY_PLACEHOLDER),
        "{{location}}": _str(payload.location, _EMPTY_PLACEHOLDER),
        "{{inventory_number}}": _str(payload.inventory_number, _EMPTY_PLACEHOLDER),
        "{{factory_number}}": _str(payload.factory_number, _EMPTY_PLACEHOLDER),
        "{{temperature_c}}": _str(payload.temperature_c, _EMPTY_PLACEHOLDER),
        "{{humidity_percent}}": _str(payload.humidity_percent, _EMPTY_PLACEHOLDER),
        "{{illumination_lux}}": _str(payload.illumination_lux, _EMPTY_PLACEHOLDER),
        "{{equipment_vik}}": _str(payload.equipment_vik, _EMPTY_PLACEHOLDER),
        "{{equipment_penetrant}}": _str(payload.equipment_penetrant, _EMPTY_PLACEHOLDER),
        "{{equipment_defectoscope}}": _str(payload.equipment_defectoscope, _EMPTY_PLACEHOLDER),
        "{{equipment_thickness_gauge}}": _str(payload.equipment_thickness_gauge, _EMPTY_PLACEHOLDER),
        "{{equipment_hardness}}": _str(payload.equipment_hardness, _EMPTY_PLACEHOLDER),
        "{{documentation_line}}": documentation_line,
        "{{defects_notes}}": defects_text,
        "{{sketch_note}}": _str(payload.sketch_note, _EMPTY_PLACEHOLDER),
    }
    values_by_key = {
        "inspector_name": replacements["{{inspector_name}}"],
        "inspection_date": replacements["{{inspection_date}}"],
        "customer": replacements["{{customer}}"],
        "object_name": replacements["{{object_name}}"],
        "location": replacements["{{location}}"],
        "inventory_number": replacements["{{inventory_number}}"],
        "factory_number": replacements["{{factory_number}}"],
        "temperature_c": replacements["{{temperature_c}}"],
        "humidity_percent": replacements["{{humidity_percent}}"],
        "illumination_lux": replacements["{{illumination_lux}}"],
        "equipment_vik": replacements["{{equipment_vik}}"],
        "equipment_penetrant": replacements["{{equipment_penetrant}}"],
        "equipment_defectoscope": replacements["{{equipment_defectoscope}}"],
        "equipment_thickness_gauge": replacements["{{equipment_thickness_gauge}}"],
        "equipment_hardness": replacements["{{equipment_hardness}}"],
        "documentation_line": replacements["{{documentation_line}}"],
        "defects_notes": replacements["{{defects_notes}}"],
        "sketch_note": replacements["{{sketch_note}}"],
    }
    return replacements, values_by_key


def _ordered_values_for_xml_fill(values_by_key: dict[str, str]) -> list[str]:
    """Порядок полей для замены блоков прочерков в word/document.xml (обратная совместимость).
    Порядок должен совпадать с порядком полей с прочерками в шаблоне."""
    return [
        values_by_key["customer"],
        values_by_key["object_name"],
        values_by_key["location"],
        values_by_key["inventory_number"],
        values_by_key["factory_number"],
        values_by_key["inspector_name"],
        values_by_key["inspection_date"],
        values_by_key["temperature_c"],
        values_by_key["humidity_percent"],
        values_by_key["illumination_lux"],
        values_by_key["equipment_vik"],
        values_by_key["equipment_penetrant"],
        values_by_key["equipment_defectoscope"],
        values_by_key["equipment_thickness_gauge"],
        values_by_key["equipment_hardness"],
        values_by_key["documentation_line"],
        values_by_key["defects_notes"],
        values_by_key["sketch_note"],
    ]


def _fill_underscores_in_xml(xml_str: str, ordered_values: list[str]) -> str:
    """Заменяет в XML первые N блоков <w:t>____</w:t> на значения по порядку."""
    for value in ordered_values:
        def repl(m):
            return m.group(1) + _xml_escape(value) + m.group(2)
        xml_str = XML_UNDERSCORE_W_T_RE.sub(repl, xml_str, count=1)
    return xml_str


def _find_remaining_placeholders(docx_bytes: bytes) -> list[str]:
    """Ищет в word/document.xml незаменённые плейсхолдеры {{...}}. Возвращает список найденных."""
    found: list[str] = []
    try:
        with zipfile.ZipFile(io.BytesIO(docx_bytes), "r") as zf:
            if "word/document.xml" not in zf.namelist():
                return found
            data = zf.read("word/document.xml")
            text = data.decode("utf-8")
            for m in REMAINING_PLACEHOLDER_RE.finditer(text):
                found.append(m.group(0))
    except Exception as e:
        logger.debug("Could not check for remaining placeholders: %s", e)
    return found


def _fill_docx_xml_underscores(docx_bytes: bytes, ordered_values: list[str]) -> bytes:
    """В word/document.xml подставляет значения вместо первых N блоков прочерков в <w:t>."""
    out = io.BytesIO()
    with zipfile.ZipFile(io.BytesIO(docx_bytes), "r") as zin:
        with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zout:
            for name in zin.namelist():
                data = zin.read(name)
                if name == "word/document.xml":
                    text = data.decode("utf-8")
                    text = _fill_underscores_in_xml(text, ordered_values)
                    data = text.encode("utf-8")
                zout.writestr(name, data)
    out.seek(0)
    return out.getvalue()


def _replace_in_paragraph(
    paragraph,
    replacements: dict[str, str],
    values_by_key: dict[str, str],
) -> None:
    """Подставляет данные: сначала {{плейсхолдеры}}, затем прочерки по правилам FILL_BLANKS_RULES."""
    try:
        text = paragraph.text
        if not text:
            return
        new_text = text
        for placeholder, value in replacements.items():
            if placeholder in new_text:
                new_text = new_text.replace(placeholder, value)
        for trigger, keys in FILL_BLANKS_RULES:
            if trigger not in new_text:
                continue
            parts = UNDERSCORE_BLOCK_RE.split(new_text)
            if len(parts) >= len(keys) + 1:
                built = parts[0]
                for i, key in enumerate(keys):
                    built += values_by_key.get(key, "")
                    if i + 1 < len(parts):
                        built += parts[i + 1]
                if len(parts) > len(keys) + 1:
                    built += "".join(parts[len(keys) + 1 :])
                new_text = built
            break
        if new_text != text:
            paragraph.clear()
            paragraph.add_run(new_text)
    except Exception as e:
        logger.debug("Replace in paragraph skipped: %s", e)


def _replace_in_document(
    doc: Document,
    replacements: dict[str, str],
    values_by_key: dict[str, str],
) -> None:
    """Проходит по всем параграфам и ячейкам таблиц, подставляет значения и заполняет прочерки."""
    def replace_one(p):
        _replace_in_paragraph(p, replacements, values_by_key)

    try:
        for paragraph in doc.paragraphs:
            replace_one(paragraph)
    except Exception as e:
        logger.warning("Replace in body paragraphs: %s", e)
    try:
        for table in doc.tables:
            for row in table.rows:
                for cell in row.cells:
                    for paragraph in cell.paragraphs:
                        replace_one(paragraph)
    except Exception as e:
        logger.warning("Replace in tables: %s", e)
    try:
        for section in doc.sections:
            try:
                for paragraph in section.header.paragraphs:
                    replace_one(paragraph)
            except Exception:
                pass
            try:
                for paragraph in section.footer.paragraphs:
                    replace_one(paragraph)
            except Exception:
                pass
    except Exception as e:
        logger.warning("Replace in headers/footers: %s", e)


def generate_inspection_card_docx(payload: InspectionCardGenerate) -> bytes:
    """
    Генерирует «Рабочая карта обследования EXPERTUS» по шаблону.
    Сначала заполняет прочерки в XML (все word/*.xml, включая текст в фигурах),
    затем дообрабатывает параграфы и таблицы через python-docx.
    """
    if not payload.inspection_date:
        raise ValueError("inspection_date is required")

    template_bytes = _load_template_bytes()
    replacements, values_by_key = _build_placeholders(payload)
    ordered_values = _ordered_values_for_xml_fill(values_by_key)
    template_bytes = _fill_docx_xml_underscores(template_bytes, ordered_values)

    doc = Document(io.BytesIO(template_bytes))
    _replace_in_document(doc, replacements, values_by_key)

    buffer = io.BytesIO()
    doc.save(buffer)
    buffer.seek(0)
    out = buffer.getvalue()

    remaining = _find_remaining_placeholders(out)
    if remaining:
        logger.warning("Inspection card: some placeholders were not replaced: %s", list(dict.fromkeys(remaining)))

    logger.info("Inspection card DOCX generated from template, size=%s bytes", len(out))
    return out
