from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

out=Path('outputs/agroconecta_avance_ciencias_datos'); out.mkdir(parents=True,exist_ok=True)
m=json.loads((out/'resumen_metricas.json').read_text(encoding='utf8'))
font=lambda size,bold=False: ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf' if bold else 'C:/Windows/Fonts/arial.ttf',size)
img=Image.new('RGB',(1500,760),'white'); d=ImageDraw.Draw(img)
d.text((45,25),'Modelo de datos propuesto para Power BI',font=font(36,True),fill='#173F2A')
boxes=[('DimProductor','ProductorID\nNombre\nDepartamento\nRol',60,180),('DimFinca','FincaID\nProductorID\nFinca\nManzanas',360,180),('DimLoteCafe','LoteID\nFincaID\nVariedad\nCalidad',660,180),('DimFecha','Fecha\nAño\nMes\nSemana',660,500),('FactPedidos','PedidoID\nFecha\nLoteID\nSacos\nPrecioHNL\nTotalHNL\nEstadoPedido',1040,250)]
for name,body,x,y in boxes:
    d.rounded_rectangle((x,y,x+250,y+220),radius=18,fill='#E7F2E9',outline='#2F6B3B',width=4)
    d.rectangle((x,y,x+250,y+48),fill='#2F6B3B')
    d.text((x+16,y+10),name,font=font(21,True),fill='white')
    d.multiline_text((x+18,y+70),body,font=font(20),fill='#173F2A',spacing=9)
for xy in [(310,290,360,290),(610,290,660,290),(910,290,1040,330),(910,610,1040,470)]:
    d.line(xy,fill='#B8860B',width=6); d.polygon([(xy[2],xy[3]),(xy[2]-18,xy[3]-10),(xy[2]-18,xy[3]+10)],fill='#B8860B')
d.text((45,700),'Relaciones activas de uno a varios. El modelo separa dimensiones de la tabla de hechos para filtrar ventas por fecha, finca, productor y variedad.',font=font(18),fill='#4F4F4F')
model_path=out/'Modelo_de_Datos_AgroConecta.png'; img.save(model_path)

doc=Document(); section=doc.sections[0]; section.top_margin=Inches(.65); section.bottom_margin=Inches(.65); section.left_margin=Inches(.75); section.right_margin=Inches(.75)
styles=doc.styles; styles['Normal'].font.name='Arial'; styles['Normal']._element.rPr.rFonts.set(qn('w:eastAsia'),'Arial'); styles['Normal'].font.size=Pt(10.5)
styles['Title'].font.name='Arial'; styles['Title'].font.size=Pt(24); styles['Title'].font.bold=True; styles['Title'].font.color.rgb=RGBColor(23,63,42)
for h in ['Heading 1','Heading 2']:
    styles[h].font.name='Arial'; styles[h].font.color.rgb=RGBColor(47,107,59)
def shade(cell,color):
    tcPr=cell._tc.get_or_add_tcPr(); shd=OxmlElement('w:shd'); shd.set(qn('w:fill'),color); tcPr.append(shd)
def add_heading(text,level=1): doc.add_heading(text,level=level)
def bullet(text): doc.add_paragraph(text,style='List Bullet')
def table(headers, rows, widths=None):
    t=doc.add_table(rows=1,cols=len(headers));t.alignment=WD_TABLE_ALIGNMENT.CENTER;t.style='Table Grid'
    for i,h in enumerate(headers):
        c=t.rows[0].cells[i];c.text=h;shade(c,'2F6B3B');c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
        for r in c.paragraphs[0].runs:r.font.bold=True;r.font.color.rgb=RGBColor(255,255,255)
    for row in rows:
        cells=t.add_row().cells
        for i,val in enumerate(row):cells[i].text=str(val);cells[i].vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
    return t

p=doc.add_paragraph(style='Title');p.alignment=WD_ALIGN_PARAGRAPH.CENTER;p.add_run('Avance del Proyecto Final de Ciencias de Datos I')
p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;r=p.add_run('AgroConecta Honduras');r.bold=True;r.font.size=Pt(16);r.font.color.rgb=RGBColor(47,107,59)
p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;p.add_run('Dashboard para el análisis del marketplace cafetalero').italic=True
for line in ['Estudiante: Eduardo Orellana','Proyecto académico: AgroConecta Honduras','Periodo de análisis: enero a agosto de 2026']:
    p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;p.add_run(line)
doc.add_paragraph('Este avance presenta la base de datos, el modelo analítico y el primer diseño del dashboard. La aplicación usa un esquema PostgreSQL para registrar productores, fincas, lotes, cosechas, publicaciones, pedidos, pagos y envíos. Como el proyecto aún no contiene operaciones reales suficientes para un análisis histórico, el conjunto de 144 pedidos se generó para fines académicos a partir de esa estructura y se identifica como simulado en los archivos entregados.')

add_heading('Definición del problema')
doc.add_paragraph('AgroConecta Honduras busca reducir la falta de visibilidad comercial que enfrentan los pequeños caficultores cuando venden mediante intermediarios. El dashboard permitirá seguir ventas, volumen, precios, estados de pedido y comportamiento por departamento, finca y variedad de café.')
table(['Pregunta','Respuesta'],[
 ['Qué problema desea resolver','La dificultad para monitorear ventas directas de café y detectar dónde se concentran los ingresos, el volumen vendido y los pedidos pendientes.'],
 ['Por qué es importante','El caficultor y las cooperativas necesitan información clara para negociar, planificar cosecha y dar seguimiento a compradores.'],
 ['Quién utilizará el dashboard','Productores, cooperativas y administradores del marketplace AgroConecta.'],
 ['Qué decisiones permitirá tomar','Priorizar variedades y zonas con mejor rotación, revisar pedidos pendientes y ajustar la gestión comercial.'],
 ['Qué preguntas busca responder','Cuánto se vende, qué departamentos y variedades aportan más, cuál es el ticket promedio y qué pedidos requieren seguimiento.'],
])

add_heading('Descripción de los datos')
doc.add_paragraph('La estructura base proviene del repositorio de AgroConecta Honduras. El archivo db/01_schema.sql define ocho tablas principales y db/03_supabase_seed.sql aporta registros iniciales. Para lograr un volumen analizable en esta entrega, se creó una muestra simulada con 144 pedidos durante ocho meses. Los valores respetan las claves y categorías del esquema, pero no representan transacciones reales.')
table(['Elemento','Detalle'],[
 ['Fuente','Esquema PostgreSQL y datos semilla de AgroConecta Honduras; registros transaccionales simulados para el avance.'],
 ['Cantidad de registros','144 pedidos, 12 productores, 8 fincas, 8 lotes de café y 243 fechas en la dimensión calendario.'],
 ['Variables principales','Fecha, departamento, finca, variedad, calidad, sacos, precio en HNL, total, estado del pedido, método y estado de pago.'],
 ['Limpieza aplicada','Estandarización de nombres de columnas, fechas ISO, valores numéricos para sacos, precio y total; validación de total igual a sacos por precio; exclusión de pedidos cancelados en ventas netas.'],
])

add_heading('Objetivo del dashboard')
doc.add_paragraph('La solución propuesta convertirá los datos del marketplace en una vista ejecutiva para revisar el desempeño comercial. Las visualizaciones permiten comparar ventas mensuales, ventas por departamento y volumen por variedad. El filtro de fecha, departamento o estado facilita revisar un segmento sin modificar el modelo.')

add_heading('Modelo de datos')
doc.add_paragraph('Se propone un esquema estrella con FactPedidos como tabla de hechos y DimProductor, DimFinca, DimLoteCafe y DimFecha como dimensiones. Las relaciones activas son de uno a varios hacia FactPedidos. Esta estructura evita duplicaciones y permite segmentar las métricas con consistencia.')
p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;p.add_run().add_picture(str(model_path),width=Inches(6.8))

add_heading('Vista ejecutiva propuesta')
table(['KPI','Definición','Resultado preliminar'],[
 ['Ventas netas','Suma de TotalHNL de pedidos no cancelados',f"HNL {m['ventasNetas']:,.0f}"],
 ['Pedidos no cancelados','Conteo de pedidos con estado diferente de cancelado',f"{m['pedidosActivos']}"],
 ['Sacos vendidos','Suma de sacos en pedidos no cancelados',f"{m['sacos']:,.0f}"],
 ['Ticket promedio','Ventas netas divididas entre pedidos no cancelados',f"HNL {m['boletoPromedio']:,.0f}"],
])
bullet('Gráfico de línea: ventas netas por mes.')
bullet('Gráfico de columnas: ventas netas por departamento de la finca.')
bullet('Gráfico de barras: sacos vendidos por variedad de café.')
bullet('Segmentador recomendado: fecha, departamento y estado del pedido.')

add_heading('Primeros hallazgos')
doc.add_paragraph('Los hallazgos se calculan sobre el conjunto simulado, por lo que sirven para probar el dashboard y no para concluir sobre el mercado real.')
table(['Hallazgo','Relevancia'],[
 ['Se registran 132 pedidos no cancelados de 144 pedidos totales.','Permite dar seguimiento a los 12 pedidos cancelados y revisar posibles causas antes de escalar el marketplace.'],
 ['Las ventas netas acumuladas alcanzan HNL 1,427,480 y el ticket promedio es cercano a HNL 10,814.','Ayuda a establecer una referencia inicial de valor por pedido para medir cambios tras nuevas campañas o alianzas.'],
 ['El análisis separa ocho variedades y cuatro departamentos productores.','Permite identificar qué combinación de origen y variedad requiere mayor inventario, promoción o logística.'],
])

add_heading('Medidas DAX sugeridas')
table(['Medida','Expresión'],[
 ['Ventas Netas','CALCULATE(SUM(FactPedidos[TotalHNL]), FactPedidos[EstadoPedido] <> "cancelado")'],
 ['Pedidos No Cancelados','CALCULATE(COUNTROWS(FactPedidos), FactPedidos[EstadoPedido] <> "cancelado")'],
 ['Sacos Vendidos','CALCULATE(SUM(FactPedidos[Sacos]), FactPedidos[EstadoPedido] <> "cancelado")'],
 ['Ticket Promedio','DIVIDE([Ventas Netas], [Pedidos No Cancelados])'],
])

add_heading('Archivos entregados')
for x in ['AgroConecta_Analitica_2026.xlsx: libro con resumen ejecutivo, gráficos, pedidos, modelo y diccionario.','AgroConecta_Analitica_2026.csv: archivo plano para carga rápida.','DimProductor.csv, DimFinca.csv, DimLoteCafe.csv, DimFecha.csv y FactPedidos.csv: archivos para el modelo de Power BI.','Modelo_de_Datos_AgroConecta.png: captura preparada para insertar en el avance.']:
    bullet(x)
add_heading('Fuentes consultadas')
doc.add_paragraph('Presentación AgroConecta Honduras Plataforma de marketplace + IA para caficultores y pequeños agricultores hondureños. Proyecto de Ingeniería de Software I, 2026.')
doc.add_paragraph('Repositorio AgroConecta Honduras: README.md, docs/ARQUITECTURA.md, db/01_schema.sql y db/03_supabase_seed.sql.')
doc.save(out/'Informe_Avance_AgroConecta_Ciencias_de_Datos_I.docx')
