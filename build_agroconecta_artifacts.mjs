import fs from 'node:fs/promises';
import path from 'node:path';
import { Workbook, SpreadsheetFile } from '@oai/artifact-tool';

const out = path.resolve('outputs/agroconecta_avance_ciencias_datos');
await fs.mkdir(out, { recursive: true });
const departments=['Lempira','Intibucá','Santa Bárbara','Comayagua'];
const producers=[
 ['P001','Carlos Martínez','Lempira','caficultor'],['P002','María Sánchez','Intibucá','caficultor'],['P003','José Hernández','Santa Bárbara','caficultor'],['P004','Ana López','Comayagua','caficultor'],['P005','Luis Mejía','Lempira','caficultor'],['P006','Rosa Aguilar','Intibucá','caficultor'],['P007','Miguel Cruz','Santa Bárbara','caficultor'],['P008','Elena Flores','Comayagua','caficultor'],
 ['P101','Tostadora Capital','Francisco Morazán','comprador'],['P102','Café Centro','Cortés','comprador'],['P103','Hotel Montaña','Intibucá','comprador'],['P104','Exportadora Norte','Cortés','comprador']
];
const farms=[
 ['F001','P001','Finca El Paraíso','Lempira',4.5,1420],['F002','P002','Finca Las Colinas','Intibucá',6.2,1650],['F003','P003','Finca El Roble','Santa Bárbara',5.1,1510],['F004','P004','Finca La Esperanza','Comayagua',3.8,1390],['F005','P005','Finca El Manantial','Lempira',4.1,1480],['F006','P006','Finca Buenavista','Intibucá',5.7,1600],['F007','P007','Finca La Cumbre','Santa Bárbara',4.9,1540],['F008','P008','Finca Los Pinos','Comayagua',3.4,1350]
];
const coffees=['Lempira','Catuaí Rojo','Ihcafe 90','Bourbón','Pacas','Parainema','Caturra','Obatá'];
const lots=farms.map((f,i)=>['L'+String(i+1).padStart(3,'0'),f[0],coffees[i],i%2?'seco':'humedo',i%2?'convencional':'estricto']);
let seed=20260906; const rand=()=>{seed=(seed*1664525+1013904223)>>>0;return seed/4294967296};
const orders=[];
for(let i=0;i<144;i++){
 const farm=farms[i%farms.length], lot=lots[i%lots.length], buyer=producers[8+(i%4)], month=Math.floor(i/18)+1, day=2+((i*7)%25), date=`2026-${String(month).padStart(2,'0')}-${String(day).padStart(2,'0')}`;
 const bags=2+Math.floor(rand()*9), price=1400+(i%4)*180+(lot[4]==='estricto'?180:0), state= i%13===0?'cancelado': i%7===0?'pendiente': i%5===0?'en_ruta':'entregado';
 const method=['ACH','BAC','QR','Efectivo'][i%4], payment=state==='cancelado'?'rechazado':state==='pendiente'?'pendiente':'aprobado';
 orders.push(['PED'+String(i+1).padStart(3,'0'),date,buyer[0],buyer[1],farm[1],producers.find(p=>p[0]===farm[1])[1],farm[0],farm[2],farm[3],lot[0],lot[2],lot[3],lot[4],bags,price,bags*price,state,method,payment]);
}
const headers=['PedidoID','Fecha','CompradorID','Comprador','VendedorID','Vendedor','FincaID','Finca','Departamento','LoteID','Variedad','Beneficio','Calidad','Sacos','PrecioHNL','TotalHNL','EstadoPedido','MetodoPago','EstadoPago'];
const toCsv=(rows)=>rows.map(r=>r.map(v=>`"${String(v).replaceAll('"','""')}"`).join(',')).join('\r\n');
await fs.writeFile(path.join(out,'AgroConecta_Analitica_2026.csv'),toCsv([headers,...orders]),'utf8');
await fs.writeFile(path.join(out,'DimProductor.csv'),toCsv([['ProductorID','Nombre','Departamento','Rol'],...producers]),'utf8');
await fs.writeFile(path.join(out,'DimFinca.csv'),toCsv([['FincaID','ProductorID','Finca','Departamento','Manzanas','AltitudMSNM'],...farms]),'utf8');
await fs.writeFile(path.join(out,'DimLoteCafe.csv'),toCsv([['LoteID','FincaID','Variedad','Beneficio','Calidad'],...lots]),'utf8');
const dates=Array.from({length:243},(_,i)=>{const d=new Date(Date.UTC(2026,0,1+i)); return [d.toISOString().slice(0,10),d.getUTCFullYear(),d.getUTCMonth()+1,d.toLocaleString('en',{month:'long',timeZone:'UTC'}),Math.ceil((i+1)/7)]});
await fs.writeFile(path.join(out,'DimFecha.csv'),toCsv([['Fecha','Anio','MesNumero','Mes','Semana'],...dates]),'utf8');
await fs.writeFile(path.join(out,'FactPedidos.csv'),toCsv([headers,...orders]),'utf8');
const active=orders.filter(o=>o[16]!=='cancelado'), delivered=orders.filter(o=>o[16]==='entregado'), revenue=active.reduce((s,o)=>s+o[15],0), bags=active.reduce((s,o)=>s+o[13],0), ticket=revenue/active.length;
const monthRows=Array.from({length:8},(_,m)=>{const a=active.filter(o=>Number(o[1].slice(5,7))===m+1);return [`2026-${String(m+1).padStart(2,'0')}`,a.length,a.reduce((s,o)=>s+o[15],0)]});
const deptRows=departments.map(d=>{const a=active.filter(o=>o[8]===d);return [d,a.reduce((s,o)=>s+o[15],0)]});
const varietyRows=coffees.map(v=>{const a=active.filter(o=>o[10]===v);return [v,a.reduce((s,o)=>s+o[13],0)]});
const wb=Workbook.create();
const dash=wb.worksheets.add('Resumen Ejecutivo'), data=wb.worksheets.add('Pedidos'), model=wb.worksheets.add('Modelo de Datos'), dict=wb.worksheets.add('Diccionario');
for(const s of [dash,data,model,dict]) { s.showGridLines=false; s.tabColor='#2F6B3B'; }
const title=(s,range,text)=>{s.mergeCells(range);const r=s.getRange(range);r.values=[[text]];r.format={fill:'#173F2A',font:{color:'#FFFFFF',bold:true,size:18},horizontalAlignment:'center',verticalAlignment:'center'};r.format.rowHeight=28;};
title(dash,'A1:J1','AgroConecta Honduras  Avance de Ciencias de Datos I');
dash.getRange('A3:J3').merge(); dash.getRange('A3').values=[['Datos simulados para análisis académico, basados en el esquema PostgreSQL y datos semilla de AgroConecta. Periodo: enero a agosto de 2026.']]; dash.getRange('A3').format={font:{italic:true,color:'#4F4F4F'},wrapText:true};
dash.getRange('A5:D5').values=[['Ventas netas HNL','Pedidos no cancelados','Sacos vendidos','Ticket promedio HNL']];
dash.getRange('A6:D6').values=[[revenue,active.length,bags,ticket]]; dash.getRange('A6').format.numberFormat='#,##0';dash.getRange('B6:C6').format.numberFormat='#,##0';dash.getRange('D6').format.numberFormat='#,##0';
dash.getRange('A5:D6').format={fill:'#E7F2E9',font:{bold:true,color:'#173F2A'},horizontalAlignment:'center',borders:{preset:'all',style:'thin',color:'#AAC5AE'}};
dash.getRange('A9:B9').values=[['Mes','Ventas HNL']];dash.getRange('A10:B17').values=monthRows.map(r=>[r[0],r[2]]);dash.getRange('B10:B17').format.numberFormat='#,##0';
dash.getRange('E9:F9').values=[['Departamento','Ventas HNL']];dash.getRange('E10:F13').values=deptRows;dash.getRange('F10:F13').format.numberFormat='#,##0';
dash.getRange('A20:B20').values=[['Variedad','Sacos vendidos']];dash.getRange('A21:B28').values=varietyRows;
for(const r of ['A9:B9','E9:F9','A20:B20']) dash.getRange(r).format={fill:'#2F6B3B',font:{color:'#FFFFFF',bold:true},horizontalAlignment:'center'};
const c1=dash.charts.add('line',dash.getRange('A9:B17'));c1.titleText='Ventas mensuales';c1.setPosition('E5','J15');
const c2=dash.charts.add('column',dash.getRange('E9:F13'));c2.titleText='Ventas por departamento';c2.setPosition('E17','J28');
const c3=dash.charts.add('bar',dash.getRange('A20:B28'));c3.titleText='Sacos por variedad';c3.setPosition('A30','F42');
data.getRangeByIndexes(0,0,orders.length+1,headers.length).values=[headers,...orders];data.getRange('A1:S1').format={fill:'#173F2A',font:{color:'#FFFFFF',bold:true},wrapText:true};data.freezePanes.freezeRows(1);data.getRange('N2:N145').format.numberFormat='#,##0';data.getRange('O2:P145').format.numberFormat='#,##0';data.getUsedRange().format.autofitColumns();data.getRange('B:B').format.columnWidth=13;
title(model,'A1:H1','Modelo de datos para Power BI');
model.getRange('A3:H12').values=[['Tabla','Tipo','Clave','Relación','Uso','','',''],['DimProductor','Dimensión','ProductorID','1 a muchos con DimFinca','Productores y compradores','','',''],['DimFinca','Dimensión','FincaID','1 a muchos con DimLoteCafe','Ubicación y tamaño de finca','','',''],['DimLoteCafe','Dimensión','LoteID','1 a muchos con FactPedidos','Variedad, beneficio y calidad','','',''],['DimFecha','Dimensión','Fecha','1 a muchos con FactPedidos','Análisis temporal','','',''],['FactPedidos','Hechos','PedidoID','Muchos a uno con dimensiones','Ventas, sacos, estado y pagos','','',''],['Relaciones recomendadas','','','','','','',''],['DimProductor ProductorID','->','DimFinca ProductorID','Activa, uno a varios','','','',''],['DimFinca FincaID','->','DimLoteCafe FincaID','Activa, uno a varios','','','',''],['DimLoteCafe LoteID','->','FactPedidos LoteID','Activa, uno a varios','','','',''],['DimFecha Fecha','->','FactPedidos Fecha','Activa, uno a varios','','','','']];model.getRange('A3:E3').format={fill:'#2F6B3B',font:{color:'#FFFFFF',bold:true}};model.getUsedRange().format.autofitColumns();
title(dict,'A1:F1','Diccionario de datos');
dict.getRange('A3:F12').values=[['Campo','Tabla','Tipo','Descripción','Ejemplo','Origen'],['PedidoID','FactPedidos','Texto','Identificador único del pedido','PED001','Simulado'],['Fecha','FactPedidos','Fecha','Fecha de creación del pedido','2026-01-02','Simulado'],['Departamento','DimFinca','Texto','Departamento de la finca vendedora','Lempira','Esquema'],['Sacos','FactPedidos','Entero','Sacos solicitados','5','Simulado'],['PrecioHNL','FactPedidos','Moneda','Precio por saco en lempiras','1580','Simulado'],['TotalHNL','FactPedidos','Moneda','Sacos por precio','7900','Calculado'],['EstadoPedido','FactPedidos','Texto','Estado del flujo del pedido','entregado','Esquema'],['MetodoPago','FactPedidos','Texto','Canal de pago','ACH','Esquema'],['Calidad','DimLoteCafe','Texto','Clasificación de calidad','estricto','Esquema']];dict.getRange('A3:F3').format={fill:'#2F6B3B',font:{color:'#FFFFFF',bold:true}};dict.getUsedRange().format.autofitColumns();
for(const s of [model,dict]) s.getUsedRange().format.autofitColumns();
for(const col of ['A','B','C','D','E','F','G','H','I','J']) dash.getRange(`${col}:${col}`).format.columnWidth=15;
const xlsx=await SpreadsheetFile.exportXlsx(wb);await xlsx.save(path.join(out,'AgroConecta_Analitica_2026.xlsx'));
await fs.writeFile(path.join(out,'resumen_metricas.json'),JSON.stringify({pedidos:orders.length,pedidosActivos:active.length,ventasNetas:revenue,sacos:bags,boletoPromedio:ticket,entregados:delivered.length,cancelados:orders.length-active.length},null,2));
