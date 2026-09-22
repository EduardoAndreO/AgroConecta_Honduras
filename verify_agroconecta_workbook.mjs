import { FileBlob, SpreadsheetFile } from '@oai/artifact-tool';
const input=await FileBlob.load('outputs/agroconecta_avance_ciencias_datos/AgroConecta_Analitica_2026.xlsx');
const wb=await SpreadsheetFile.importXlsx(input);
console.log((await wb.inspect({kind:'table',range:'Resumen Ejecutivo!A1:N32',include:'values,formulas',tableMaxRows:32,tableMaxCols:14})).ndjson);
console.log((await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:100},summary:'formula error scan'})).ndjson);
const preview=await wb.render({sheetName:'Resumen Ejecutivo',range:'A1:N32',scale:1.5,format:'png'});
await (await import('node:fs/promises')).writeFile('outputs/agroconecta_avance_ciencias_datos/Resumen_Ejecutivo_preview.png',new Uint8Array(await preview.arrayBuffer()));
