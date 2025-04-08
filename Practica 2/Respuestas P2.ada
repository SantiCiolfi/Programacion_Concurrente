//1) Un sistema operativo mantiene 5 instancias de un recurso almacenadas en una cola.
//Además, existen P procesos que necesitan usar una instancia del recurso. Para eso,
//deben sacar la instancia de la cola antes de usarla. Una vez usada, la instancia debe ser encolada nuevamente.

sem espacios = 5; colaRecurso C;

Process proceso[id:0..4]{
	int recurso = 0;
	while(true){
		P(espacios);
		recurso = Sacar(C);
		utilizarRecurso(recurso);
		Agregar(C, recurso);
		V(espacios);
	}
}

//2) Existen N personas que deben ser chequeadas por un detector de metales antes de poder ingresar al avión.
//a) Analice el problema y defina qué procesos, recursos y semáforos serán necesarios/convenientes,
//además de las posibles sincronizaciones requeridas para resolver el problema.
//b)Implemente una solución que modele el acceso de las personas a un detector
//(es decir, si el detector está libre la persona lo puede utilizar; en caso contrario, debe esperar).

sem detectorLibre = 1;

Process Persona[id:0..N]{
	P(detectorLibre);
	realizaElChequeo;
	V(detectorLibre);
	ingresaAlAvion;
}

//c) Modifique su solución para el caso que haya tres detectores.

sem detectoresLibre = 3;

Process Persona[id:0..N]{
	P(detectoresLibre);
	realizaElChequeo;
	V(detectoresLibre);
	ingresaAlAvion;
}

//3) Un sistema de control cuenta con 4 procesos que realizan chequeos en forma colaborativa.
//Para ello, reciben el historial de fallos del día anterior (por simplicidad, de tamaño N).
//De cada fallo, se conoce su número de identificación (ID) y su nivel de gravedad (0=bajo, 1=intermedio, 2=alto, 3=crítico).
//Para cada item realice una solución adecuada a lo pedido:
//a) Se debe imprimir en pantalla los ID de todos los errores críticos (no importa el orden).

Fallo historialFallos [N];
int posicionActual = 0;
termino = N;
sem listo = 1;

Process proceso[id:0..3]{
	Fallo f;
	P(listo);
	while(not termino){
		f = historialFallos [posicionActual];
		termino++;
		posicionActual++;
		V(listo);
		if(f.gravedad = 3) Writeln(f.ID);
		P(listo); //chequeo antes de volver a entrar al while
	}
	v(listo); //libera a los procesos que todavia no terminaron
}

//b) Se debe calcular la cantidad de fallos por nivel de gravedad,
//debiendo quedar los resultados en un vector global.

Fallo historialFallos [N];
int posicionActual = 0;
termino = N;
sem listo = 1;
recuentoFallos [3] = ([N] 0);

Process proceso[id:0..3]{
	Fallo f;
	P(listo);
	while(not termino){
		f = historialFallos [posicionActual];
		recuentoFallos [f.gravedad]++;
		termino++;
		posicionActual++;
		V(listo);
		P(listo); //chequeo antes de volver a entrar al while
	}
	v(listo); //libera a los procesos que todavia no terminaron
}

//c) Ídem b) pero cada proceso debe ocuparse de contar los fallos de un nivel de gravedad determinado.

Fallo historialFallos [N];
termino = N;
sem listo = 1;
recuentoFallos [3] = ([N] 0);

Process proceso[id:0..3]{
	int posicionActual = 0;
	Fallo f;
	
	P(listo);
	while(not termino){
		f = historialFallos [posicionActual];
		termino++;
		V(listo);
		if(f.gravedad = id) recuentoFallos [id]++; //CONSULTAR SI ES NECESARIO QUE ESTO ESTO EN LA SACCION CRITICA O NO, YA QUE CADA POSICION DEL VECTOR ES "PROPIA" DE CADA PROCESO
		posicionActual++;
		P(listo); //chequeo antes de volver a entrar al while
	}
	v(listo); //libera a los procesos que todavia no terminaron
}