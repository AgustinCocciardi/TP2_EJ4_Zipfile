<# 
.SYNOPSIS
Este script fue creado para manejar operaciones de información, compresión y descompresión sobre archivos .zip.

.DESCRIPTION
El objetivo de este script es permitirle al usuario ingresar un path de un archivo .zip y a partir de dicho archivo, realizar tres operaciones.
1- Descomprimir: el archivo .zip será descomprimido en el directorio que se pase por parámetro.
2- Comprimir: se pasará por parámetro un directorio y ese mismo directorio será comprimido en un archivo .zip.
3- Informar: muestra información de los archivos que se encuentran en el archivo .zip

El script se invoca de la siguiente forma:
./TP2EJ4.ps1 -PathZip [PathDelZip] -Directorio [DirectorioAUsar] -Descomprimir --> Descomprime el Zip en el directorio
./TP2EJ4.ps1 -PathZip [PathDelZip] -Directorio [DirectorioAUsar] -Comprimir    --> Comprime el Zip en el directorio
./TP2EJ4.ps1 -PathZip [PathDelZip] -Informar                                   --> Informa muestra los archivos del Zip 

.NOTES
INTEGRANTES - TP2 - Ejercicio 4
 * Agustin Cocciardi - 40231779
   Vazquez, Mario Waldo - 36623991
   Barra Quelca, Guido Alberto - 39274352
#>

Param(
	[Parameter(Mandatory=$true)][string] $PathZip, #El path del zip que paso por parámetro. Es obligatorio y común a todos ParamenterSets

	[Parameter(Mandatory=$true,ParameterSetName="Operacion")] [string] $Directorio, #Creo un ParameterSet llamado Operación
	[Parameter(ParameterSetName="Operacion")][switch] $Descomprimir,                #Esto se hace porque el parámetro Directorio es común
	[Parameter(ParameterSetName="Operacion")][switch] $Comprimir,					#Tanto a Comprimir como a Descomprimir

	[Parameter(ParameterSetName="Informar")][switch] $Informar	#Creo un ParameterSet llamado Informar
) 

Add-Type -Assembly system.io.compression.zipfile #Esta línea funciona como include o import para la clase zipfile de .Net

if ($Informar -eq $true) {   		#Si informar es igual a true, quiere decir que eligió esa operación
	$ruta = Test-Path $PathZip		#Verifico si la ruta que me pasaron por parámetro existe
	if ($ruta -eq $false) {
		Write-Host "El archivo Zip que pasó por parámetro no es válido"			#Si la ruta no existe, salgo del script
		exit 2;
	}																			#Si la ruta existe, continuo en el script

	if ([System.IO.Path]::IsPathRooted($PathZip)) {			#Pregunto si el directorio que me pasaron por parámetro tiene raíz
	}														#Esto me indica si es una ruta relativa o absoluta
	else {						
		$nuevaRuta = Join-Path -Path $PWD -ChildPath $PathZip -Resolve	#Si el directorio no tiene raíz, uso el método Join-Path para crear una ruta absoluta a partir de la relativa
		$PathZip = $nuevaRuta											#Reemplazo la ruta que recibí con la nueva ruta que acabo de crear 	
	}
	$archivosZip= [System.IO.Compression.ZipFile]::OpenRead($PathZip)	#Guardo en una variable llamada 'archivos.Zip' todos los archivos y directorios del zip
	Write-Output "Listado de archivos"
	foreach($item in $archivosZip.Entries){								#Para todo lo que haya en la variable 'archivos.Zip'
		if ($item.Name -ne "") {										#Me fijo que su nombre contenga aunque sea un caracter. Si no contiene caracteres es porque es un directorio
			Write-Output "------"
			Write-Host Nombre del archivo: $item										#Informo el nombre del archivo
			Write-Host Peso del archivo: $item.Length									#Informo el peso del archivo
			Write-Host Relación de compresión: $item.Length: $item.CompressedLength		#Informo la relación de compresión (Peso Real : Peso en el Zip)
		}
		
	}
	Write-Output ""
}
elseif ($Descomprimir -eq $false -and $Comprimir -eq $false) {		#Si Informar es falso, entonces seleccionó Comprimir o Descomprimir
	Write-Host "Error al invocar al Script: Comprimir y Descomprimir no pueden ser falsos al mismo tiempo"
	exit 1;															#Si los dos son falsos, debo salir				
}
else {
	if ($Descomprimir -eq $true -and $Comprimir -eq $true) {		#Si los dos son verdaderos, debo salir
		Write-Host "Error al invocar al Script: Comprimir y Descomprimir no pueden ser verdaderos al mismo tiempo"
		exit 10;
	}
	if ($Descomprimir -eq $true) {									#Si entro acá, es porque seleccionó Descomprimir
		if (Test-Path $PathZip) {									#Si la ruta del zip existe continuo
			if ([System.IO.Path]::IsPathRooted($PathZip)) {			#Reviso que la ruta tenga raíz y aplico lo mismo que hice con la operación Informar
			}
			else {
				$nuevaRuta = Join-Path -Path $PWD -ChildPath $PathZip -Resolve
				$PathZip = $nuevaRuta
			}
			if (Test-Path $Directorio) {							#Hacer con la carpeta de Destino lo mismo que hice con la ruta del zip
				if ([System.IO.Path]::IsPathRooted($Directorio)) {
				}
				else {
					$nuevaRuta = Join-Path -Path $PWD -ChildPath $Directorio -Resolve
					$Directorio = $nuevaRuta
				}
				[System.IO.Compression.ZipFile]::ExtractToDirectory($PathZip,$Directorio); #Uso este método de zipfile para descomprimir
			}
			else {
				Write-Host "El directorio que pasó como parámetro no existe"
				exit 5;
			}
		}
		else {
			Write-Host "El archivo .Zip que pasó como parámetro no existe"
			exit 4;
		}
	}
	else {
		$zip = $PathZip.Split("/")[-1] #extraer el nombre del Zip
		$ruta = $PathZip.Replace("/$zip","") #me quedo con la ruta del Zip
		
		if (Test-Path $ruta) {	#Me fijo que la ruta donde va a estar el script exista
			if ([System.IO.Path]::IsPathRooted($ruta)) { 	#Me fijo si tiene raíz como en las operaciones anteriores
			}
			else {
				$nuevaRuta = Join-Path -Path $PWD -ChildPath $ruta -Resolve
				$ruta = $nuevaRuta
			}
			if (Test-Path $Directorio) {	#Reviso si el directorio a comprimir existe, y si existe, le aplico lo mismo
				if ([System.IO.Path]::IsPathRooted($Directorio)) {
				}
				else {
					$nuevaRuta = Join-Path -Path $PWD -ChildPath $Directorio -Resolve
					$Directorio = $nuevaRuta
				}

				if ($ruta -eq $Directorio) {	#La clase zipfile no permite comprimir un directorio en su misma ubicación
					Write-Host "El archivo .zip no puede crearse en el mismo directorio que se va a comprimir"
					exit 3;
				}

				$PathZip = "$ruta/$zip" #Convierto la ruta del zip en una ruta absoluta
				if (Test-Path $PathZip) {	#Me fijo si ya existe un .zip con ese nombre
					Remove-Item $PathZip	#Si existe, lo elimino
				}
				[System.IO.Compression.ZipFile]::CreateFromDirectory($Directorio,$PathZip); #Método de la clase zipfile para comprimir
			}else {
				Write-Host "El directorio que desea comprimir no existe"
			}
		}
		else {
			Write-Host "El directorio donde se encuentra el .Zip no existe"
		}
	}
}