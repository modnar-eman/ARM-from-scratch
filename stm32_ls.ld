/*
********************************Linker Script*******************************
En este archivo se explica como las diferentes secciones de los archivos objeto
se van a fusionar para crear un archivo de salida

La combinación de enlazador y localizador asigna direcciones absolutas únicas a diferent>
secciones del archivo de salida al referirse a la información de dirección mencionada
en el script del enlazador

También incluye el código y los datos de direcciones de memoria y tamaño de la informaci>
*/

/*
El comando ENTRY es usado para inicializar las direcciones de puntos de entrada
en nuestro caso "Reset_Handler" es el punto de entrada dentro de la aplicación
la primer pieza de código que se ejecuta justo despues de un reset del procesador
no es obligatorio, sólamente si queremos hacer un debugger con el archivo .ELF
*/

ENTRY(Reset_Handler)

/*El comando MEMORY permite describir las diferentes secciones de memoria que están en el target
y sus direcciones e información de tamaño el linker las usa para asignar las direcciones y fucionar las secciones,
puedes afinar varias memorias disponibles en el target y permite a las diferentes secciones ocupar diferentes áreas de memoria*/

/*etiqueta atributo
name     (attr): ORIGIN=origin,LENGTH=len 
la etiqueta define el nombre de la región de memoria*/

MEMORY
{
	FLASH(rx):ORIGIN =0x08000000,LENGTH =1024K
	SRAM(rwx):ORIGIN =0x20000000,LENGTH =128K
/*	SRAM1(rwx):ORIGIN=0x20000000,LENGTH=116k
//	SRAM2(rwx):ORIGIN=0x20000000+116K-4,LENGTH=16k*/
/*si tienes más memorias en tu microcontrolador las puedes poner aquí, si es que las quieres usar*/
}

/*El comando sections se usa para crear diferentes secciones de salida en el .ELF
con esta intrucción puedes elegir en qué región de memoria colocar las secciones
*/
SECTIONS
{
/*Aquí se le indica al linker a que cree dos seciones, se deben de poner en orden
 */
	.text :
	{
/*esta sección es usada para fusionar las secciones .text .isr .rodata de los archivos de entrada 
((.text main.o) (.text startup.o) (.isr main.o)(.isr startup.o) (.rodata main.o) (.rodata startup.o) etc
*/	

/*si vemos el diagrama de cómo debe de estar almacenado el código ejecutable en la FLASH vemos que 
primero debe de contener (la tabla de vectores) .isr_vector después .text .rodata .data */

	*(.isr_vector)
	*(.text)
	*(.text.*) /*para que todas las secciones .text se conglemeren en una sola*/
	*(.init)
	*(.fini)
	*(.rodata)
	*(.rodata.*) /*también que se conglomere rodata*/
/*
la sección data que estará almacenada en la FLASH será reubicada por el startup code a la SRAM
para reubicarla se necesita conocer los boundaries (donde termina la sección) en este caso termina donde termina .rodata
para que el startup sepa esa información es necesario que nosotros aquí en el linker se la pasemos,
y vamos a usar un linker simbol llamado location counter, el linker automáticamente actualiza este símbolo con información
de localización, aquí como no estamos escribiendo un archivo de C sino un linkerscript no podemos definir una dirección como si fuera una variable
porque el linker no se compila, él enlaza,entonces tenemos que usar símbolos,estos símbolos se le van a pasar 
a la tabla de símbolos del archivo final
End of text, nombre del símbolo _etext = .;("." es el location counter
el location counter al principio es igual a VMA (FLASH)0x0800 0000 y se va incrementando por el tamaño de la versión de salida 
esto pasa automáticamante por el linker*/
	. = ALIGN(4); /*alinear a 4 bytes respecto a la localización anterior del location counter */
	_etext = .;	/*Entonces ahora podremos exportar este símbolo al programa C para que sepa dónde acaba .text section*/

	}> FLASH /*> FLASH AT> FLASH (también podría ponerse así o así)//>VMA AT> LMA*/
/*esta sección se almacena en dos regiones de la memoria ROM VMA (Virtual Memory Address)y 
LMA (Load Memory Address) */

_la_data = LOADADDR(.data);


	.data :
	{
/* y aquí lo mismo pero con la sección .data de los diferentes archivos *.o*/
	_sdata = .;/*start_of_data =0x20000000 asigna el valor al símbolo, aquí, el location counter se reinicia al inicio de VMA de esta sección*/
  /* el location counter siempre va rastreando dónde está respecto a VMA */
	
	*(.data)
	*(.data.*)
	. = ALIGN(4);
	_edata = .;
	}> SRAM AT> FLASH /*todo lo de esta sección va a la SRAM*/

	.bss :
	{

		_sbss = .;
		__bss_start__ = _sbss;
		*(.bss)
		*(.bss.*)
		*(COMMON)
		. = ALIGN(4);
		_ebss = .;
		__bss_end__ = _ebss;
		end = .;
		__end__ = .;
	}> SRAM




}
