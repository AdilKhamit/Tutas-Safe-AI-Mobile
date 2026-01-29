"""
Report Service - PDF Generation for Pipe Passports
"""
import io
import logging
from datetime import date
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import inch
from reportlab.lib.colors import HexColor, black
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader
import qrcode

from app.models.pipes import Pipe

logger = logging.getLogger(__name__)


class ReportService:
    """Service for generating PDF reports"""

    def __init__(self):
        """Initialize report service"""
        pass

    async def generate_pipe_passport(self, pipe: Pipe) -> bytes:
        """
        Generate PDF passport for pipe.

        Args:
            pipe: Pipe model instance

        Returns:
            PDF bytes
        """
        # Create BytesIO buffer for PDF
        buffer = io.BytesIO()
        c = canvas.Canvas(buffer, pagesize=A4)

        # Page dimensions
        page_width, page_height = A4
        margin = 0.5 * inch
        content_width = page_width - 2 * margin

        # 1. Title Section
        title_y = page_height - margin - 0.5 * inch
        c.setFont("Helvetica-Bold", 20)
        c.drawString(margin, title_y, "PIPELINE PASSPORT")

        # 2. QR Code Section (top right)
        qr_size = 1.5 * inch
        qr_x = page_width - margin - qr_size
        qr_y = page_height - margin - qr_size

        # Generate QR code
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=2,
        )
        qr.add_data(pipe.qr_code)
        qr.make(fit=True)

        # Create QR image
        qr_img = qr.make_image(fill_color="black", back_color="white")
        qr_buffer = io.BytesIO()
        qr_img.save(qr_buffer, format="PNG")
        qr_buffer.seek(0)

        # Draw QR code
        c.drawImage(ImageReader(qr_buffer), qr_x, qr_y, width=qr_size, height=qr_size)

        # QR label
        c.setFont("Helvetica", 10)
        c.drawString(qr_x, qr_y - 0.2 * inch, f"QR: {pipe.qr_code[:20]}...")

        # 3. Pipe Information Section
        info_y = title_y - 0.8 * inch
        c.setFont("Helvetica-Bold", 14)
        c.drawString(margin, info_y, "Pipe Information")

        info_start_y = info_y - 0.4 * inch
        y_offset = info_start_y
        line_height = 0.25 * inch

        c.setFont("Helvetica", 11)

        # ID
        c.drawString(margin, y_offset, f"ID: {str(pipe.id)}")
        y_offset -= line_height

        # Material
        material_text = pipe.material or "N/A"
        c.drawString(margin, y_offset, f"Material: {material_text}")
        y_offset -= line_height

        # Diameter
        diameter_text = f"{pipe.diameter_mm} mm" if pipe.diameter_mm else "N/A"
        c.drawString(margin, y_offset, f"Diameter: {diameter_text}")
        y_offset -= line_height

        # Wall Thickness
        thickness_text = f"{pipe.wall_thickness_mm} mm" if pipe.wall_thickness_mm else "N/A"
        c.drawString(margin, y_offset, f"Wall Thickness: {thickness_text}")
        y_offset -= line_height

        # Production Date
        prod_date_text = (
            pipe.production_date.strftime("%Y-%m-%d") if pipe.production_date else "N/A"
        )
        c.drawString(margin, y_offset, f"Production Date: {prod_date_text}")
        y_offset -= line_height

        # Manufacturer
        if pipe.manufacturer:
            c.drawString(margin, y_offset, f"Manufacturer: {pipe.manufacturer}")
            y_offset -= line_height

        # Length
        if pipe.length_meters:
            c.drawString(margin, y_offset, f"Length: {pipe.length_meters} m")
            y_offset -= line_height

        # 4. Status Section (AI)
        status_y = y_offset - 0.3 * inch
        c.setFont("Helvetica-Bold", 14)
        c.drawString(margin, status_y, "AI Status & Prediction")

        status_start_y = status_y - 0.4 * inch
        y_offset = status_start_y

        c.setFont("Helvetica", 11)

        # Current Status
        status_text = pipe.current_status or "active"
        c.drawString(margin, y_offset, f"Current Status: {status_text.upper()}")
        y_offset -= line_height

        # Risk Score
        risk_y = y_offset
        risk_label = "Risk Score: "
        c.drawString(margin, risk_y, risk_label)

        if pipe.risk_score is not None:
            risk_value = pipe.risk_score
            risk_text = f"{risk_value:.2f}"

            # Color based on risk level
            if risk_value >= 0.7:
                risk_color = HexColor("#DC143C")  # Crimson (red)
                risk_status = "HIGH"
            elif risk_value >= 0.4:
                risk_color = HexColor("#FF8C00")  # DarkOrange
                risk_status = "MEDIUM"
            else:
                risk_color = HexColor("#228B22")  # ForestGreen
                risk_status = "LOW"

            # Draw risk value with color
            text_x = margin + c.stringWidth(risk_label, "Helvetica", 11)
            c.setFillColor(risk_color)
            c.setFont("Helvetica-Bold", 11)
            c.drawString(text_x, risk_y, f"{risk_text} ({risk_status})")
            c.setFillColor(black)  # Reset to black
            c.setFont("Helvetica", 11)
        else:
            c.drawString(margin + c.stringWidth(risk_label, "Helvetica", 11), risk_y, "N/A")
        y_offset -= line_height

        # Predicted Lifetime
        lifetime_text = (
            f"{pipe.predicted_lifetime_years} years"
            if pipe.predicted_lifetime_years
            else "N/A"
        )
        c.drawString(margin, y_offset, f"Predicted Lifetime: {lifetime_text}")
        y_offset -= line_height

        # 5. Footer
        footer_y = margin + 0.3 * inch
        c.setFont("Helvetica", 9)
        today = date.today()
        footer_text = f"Generated by Tutas Ai System on {today.strftime('%Y-%m-%d')}"
        c.drawString(margin, footer_y, footer_text)

        # Save PDF
        c.save()
        buffer.seek(0)

        logger.info(f"PDF passport generated for pipe_id: {pipe.id}")
        return buffer.getvalue()
