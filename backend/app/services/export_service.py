import json
from datetime import datetime
from typing import List, Dict
import io

# Try to import reportlab, but don't fail if not installed
try:
    from reportlab.lib import colors
    from reportlab.lib.pagesizes import A4, landscape
    from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.units import inch
    REPORTLAB_AVAILABLE = True
except ImportError:
    REPORTLAB_AVAILABLE = False
    print("⚠️ ReportLab not installed. PDF export will not work. Run: pip install reportlab")

async def generate_json_export(entries: List[Dict]) -> str:
    """Generate JSON export string"""
    export_data = {
        "exported_at": datetime.utcnow().isoformat(),
        "total_entries": len(entries),
        "timetable": entries
    }
    return json.dumps(export_data, indent=2, default=str)

async def generate_pdf_export(entries: List[Dict]) -> bytes:
    """Generate PDF export as bytes"""
    if not REPORTLAB_AVAILABLE:
        # Return a simple error message as PDF is not available
        return b"PDF export requires reportlab. Please install it with: pip install reportlab"
    
    buffer = io.BytesIO()
    
    # Create PDF document
    doc = SimpleDocTemplate(buffer, pagesize=landscape(A4))
    story = []
    styles = getSampleStyleSheet()
    
    # Title
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#1a237e'),
        alignment=1,  # Center
        spaceAfter=30
    )
    title = Paragraph("My Timetable", title_style)
    story.append(title)
    
    # Date
    date_style = ParagraphStyle(
        'DateStyle',
        parent=styles['Normal'],
        fontSize=10,
        textColor=colors.grey,
        alignment=2  # Right
    )
    date = Paragraph(f"Exported on: {datetime.now().strftime('%Y-%m-%d %H:%M')}", date_style)
    story.append(date)
    story.append(Spacer(1, 20))
    
    # Group by day
    days_order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    entries_by_day = {day: [] for day in days_order}
    
    for entry in entries:
        if entry['day'] in entries_by_day:
            entries_by_day[entry['day']].append(entry)
    
    # Sort by time within each day
    for day in entries_by_day:
        entries_by_day[day].sort(key=lambda x: x['start_time'])
    
    # Create table for each day
    for day in days_order:
        if entries_by_day[day]:
            # Day header
            day_style = ParagraphStyle(
                'DayStyle',
                parent=styles['Heading2'],
                fontSize=16,
                textColor=colors.HexColor('#0d47a1'),
                spaceAfter=10,
                spaceBefore=20
            )
            story.append(Paragraph(f"📅 {day}", day_style))
            
            # Table data
            table_data = [
                ['Time', 'Course', 'Teacher', 'Room', 'Color']
            ]
            
            for entry in entries_by_day[day]:
                table_data.append([
                    f"{entry['start_time']} - {entry['end_time']}",
                    entry['course_name'],
                    entry['teacher'],
                    entry['room'],
                    entry.get('color', '#4CAF50')
                ])
            
            # Create table
            table = Table(table_data, colWidths=[1.2*inch, 2*inch, 1.5*inch, 1.2*inch, 0.8*inch])
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1a237e')),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 12),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                ('GRID', (0, 0), (-1, -1), 1, colors.black),
                ('FONTSIZE', (0, 1), (-1, -1), 10),
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ]))
            
            # Color the "Color" column
            for i, entry in enumerate(entries_by_day[day], start=1):
                color_hex = entry.get('color', '#4CAF50')
                # Add # if missing
                if not color_hex.startswith('#'):
                    color_hex = '#' + color_hex
                try:
                    table.setStyle(TableStyle([
                        ('BACKGROUND', (4, i), (4, i), colors.HexColor(color_hex)),
                    ]))
                except:
                    # Fallback to default color if invalid
                    table.setStyle(TableStyle([
                        ('BACKGROUND', (4, i), (4, i), colors.HexColor('#4CAF50')),
                    ]))
            
            story.append(table)
            story.append(Spacer(1, 20))
    
    # Footer
    footer_style = ParagraphStyle(
        'FooterStyle',
        parent=styles['Normal'],
        fontSize=8,
        textColor=colors.grey,
        alignment=1
    )
    story.append(Paragraph("Generated by SmartCampus Companion", footer_style))
    
    # Build PDF
    doc.build(story)
    buffer.seek(0)
    return buffer.getvalue()