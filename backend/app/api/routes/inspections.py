"""
Inspection card API - генерация рабочей карты обследования EXPERTUS
"""
import logging
from fastapi import APIRouter, Depends, HTTPException, status, Response
from fastapi.responses import Response as FastAPIResponse

from app.api.routes.auth import get_current_user_or_api_key
from app.models.users import User
from app.schemas.inspections import InspectionCardGenerate
from app.services.inspection_card_service import generate_inspection_card_docx

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/generate-card", status_code=status.HTTP_200_OK)
async def generate_inspection_card(
    payload: InspectionCardGenerate,
    current_user: User | None = Depends(get_current_user_or_api_key),
) -> Response:
    """
    Сформировать документ «Рабочая карта обследования» (DOCX).

    Ф.И.О. исполнителя берётся из payload; если не указано — подставляется из текущего пользователя (аккаунт).
    Дата обследования передаётся в payload.

    Returns:
        DOCX file (application/vnd.openxmlformats-officedocument.wordprocessingml.document)
    """
    # Автоподстановка Ф.И.О. из аккаунта (если залогинен) или из запроса; иначе «Исполнитель»
    inspector_name = (payload.inspector_name or "").strip()
    if not inspector_name and current_user:
        inspector_name = (current_user.full_name or "").strip()
    if not inspector_name and current_user:
        inspector_name = current_user.email or "Исполнитель"
    if not inspector_name:
        inspector_name = "Исполнитель"

    payload_override = InspectionCardGenerate(
        inspector_name=inspector_name,
        inspection_date=payload.inspection_date,
        customer=payload.customer,
        object_name=payload.object_name,
        location=payload.location,
        inventory_number=payload.inventory_number,
        factory_number=payload.factory_number,
        temperature_c=payload.temperature_c,
        humidity_percent=payload.humidity_percent,
        illumination_lux=payload.illumination_lux,
        equipment_vik=payload.equipment_vik,
        equipment_penetrant=payload.equipment_penetrant,
        equipment_defectoscope=payload.equipment_defectoscope,
        equipment_thickness_gauge=payload.equipment_thickness_gauge,
        equipment_hardness=payload.equipment_hardness,
        documentation_state=payload.documentation_state,
        defects_notes=payload.defects_notes,
        sketch_note=payload.sketch_note,
    )

    try:
        docx_bytes = generate_inspection_card_docx(payload_override)
    except Exception as e:
        logger.exception("Failed to generate inspection card DOCX: %s", e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Ошибка формирования документа: {e!s}",
        ) from e

    filename = f"Rabochaya_karta_obsledovaniya_{payload_override.inspection_date.isoformat()}.docx"
    return FastAPIResponse(
        content=docx_bytes,
        media_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
