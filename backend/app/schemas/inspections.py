"""
Pydantic schemas for inspection card (Рабочая карта обследования EXPERTUS)
"""
from datetime import date
from typing import Optional

from pydantic import BaseModel, Field


class InspectionCardGenerate(BaseModel):
    """Payload for generating inspection card document."""

    # Auto from account if empty (server fills from current_user)
    inspector_name: Optional[str] = Field(None, description="Ф.И.О. исполнителя (из аккаунта)")
    inspection_date: date = Field(..., description="Дата обследования (в документе выводится в формате ДД.ММ.ГГГГ)")

    # Object / contract
    customer: Optional[str] = Field(None, description="Заказчик (Договор/проект)")
    object_name: Optional[str] = Field(None, description="Наименование объекта обследования")
    location: Optional[str] = Field(None, description="Место нахождения")
    inventory_number: Optional[str] = Field(None, description="Инв.№")
    factory_number: Optional[str] = Field(None, description="Зав. №")

    # Conditions
    temperature_c: Optional[float] = Field(None, description="Температура воздуха, °C")
    humidity_percent: Optional[float] = Field(None, description="Влажность воздуха, %")
    illumination_lux: Optional[float] = Field(None, description="Уровень освещенности, лк")

    # Equipment (name + serial)
    equipment_vik: Optional[str] = Field(None, description="Комплект ВИК")
    equipment_penetrant: Optional[str] = Field(None, description="Комплект пенетрантов ПВК")
    equipment_defectoscope: Optional[str] = Field(None, description="Ультразвуковой дефектоскоп")
    equipment_thickness_gauge: Optional[str] = Field(None, description="Ультразвуковой толщиномер")
    equipment_hardness: Optional[str] = Field(None, description="Ультразвуковой/динамический твердомер")

    # Documentation state: satisfactory | unsatisfactory | absent
    documentation_state: Optional[str] = Field(
        None,
        description="Состояние документации: удовлетворительно / неудовлетворительно / отсутствует",
    )

    # Defects list / notes (plain text or structured)
    defects_notes: Optional[str] = Field(None, description="Дефектная ведомость / примечания")
    sketch_note: Optional[str] = Field(None, description="Эскиз, схема объекта (примечание)")
