# Power Query Source Drafts

## DimProductor`n`n```powerquery`nlet`n    Source = Csv.Document(File.Contents("C:\AgroConecta2_Honduras\outputs\agroconecta_avance_ciencias_datos\DimProductor.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv])`nin`n    Source`n```
## DimFinca`n`n```powerquery`nlet`n    Source = Csv.Document(File.Contents("C:\AgroConecta2_Honduras\outputs\agroconecta_avance_ciencias_datos\DimFinca.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv])`nin`n    Source`n```
## DimLoteCafe`n`n```powerquery`nlet`n    Source = Csv.Document(File.Contents("C:\AgroConecta2_Honduras\outputs\agroconecta_avance_ciencias_datos\DimLoteCafe.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv])`nin`n    Source`n```
## DimFecha`n`n```powerquery`nlet`n    Source = Csv.Document(File.Contents("C:\AgroConecta2_Honduras\outputs\agroconecta_avance_ciencias_datos\DimFecha.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv])`nin`n    Source`n```
## FactPedidos`n`n```powerquery`nlet`n    Source = Csv.Document(File.Contents("C:\AgroConecta2_Honduras\outputs\agroconecta_avance_ciencias_datos\FactPedidos.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv])`nin`n    Source`n```

