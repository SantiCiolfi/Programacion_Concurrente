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

Process Persona[id:0..N-1]{
	P(detectorLibre); //tomo el detector
	realizaElChequeo();
	V(detectorLibre); //libero
	ingresaAlAvion();
}

//c) Modifique su solución para el caso que haya tres detectores.

sem detectoresLibre = 3;

Process Persona[id:0..N]{
	P(detectoresLibre);
	realizaElChequeo();
	V(detectoresLibre);
	ingresaAlAvion();
}

//3) Un sistema de control cuenta con 4 procesos que realizan chequeos en forma colaborativa.
//Para ello, reciben el historial de fallos del día anterior (por simplicidad, de tamaño N).
//De cada fallo, se conoce su número de identificación (ID) y su nivel de gravedad (0=bajo, 1=intermedio, 2=alto, 3=crítico).
//Para cada item realice una solución adecuada a lo pedido:
//a) Se debe imprimir en pantalla los ID de todos los errores críticos (no importa el orden).

Fallo historialFallos [N];
int posicionActual = 0;
sem listo = 1;

Process proceso[id:0..3]{
	Fallo f;
	P(listo);
	while(posicionActual <> N){
		f = historialFallos [posicionActual];
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
sem listo = 1;
int recuentoFallos [3, 0];

Process proceso[id:0..3]{
	Fallo f;
	P(listo);
	while(posicionActual <> N){
		f = historialFallos [posicionActual];
		recuentoFallos [f.gravedad]++;
		posicionActual++;
		V(listo);
		P(listo); //chequeo antes de volver a entrar al while
	}
	v(listo); //libera a los procesos que todavia no terminaron
}

//c) Ídem b) pero cada proceso debe ocuparse de contar los fallos de un nivel de gravedad determinado.

Fallo historialFallos [N];
sem listo = 1;
recuentoFallos [3] = ([N] 0);

Process proceso[id:0..3]{
	int posicionActual = 0;
	Fallo f;
	
	P(listo);
	while(posicionActual <> N){
		f = historialFallos [posicionActual];
		V(listo);
		if(f.gravedad = id) recuentoFallos [id]++; //CONSULTAR SI ES NECESARIO QUE ESTO ESTE EN LA SECCION CRITICA O NO, YA QUE CADA POSICION DEL VECTOR ES "PROPIA" DE CADA PROCESO
		posicionActual++;
		P(listo); //chequeo antes de volver a entrar al while
	}
	v(listo); //libera a los procesos que todavia no terminaron
}

//4) En una empresa de logística de paquetes existe una sala de contenedores donde se preparan las entregas.
//Cada contenedor puede almacenar un paquete y la sala cuenta con capacidad para N contenedores.
//Resuelva considerando las siguientes situaciones:
//a) La empresa cuenta con 2 empleados:
//un empleado Preparador que se ocupa de preparar los paquetes y dejarlos en los contenedores;
//un empelado Entregador que se ocupa de tomar los paquetes de los contenedores y realizar la entregas.
//Tanto el Preparador como el Entregador trabajan de a un paquete por vez.

sem mutex = 1;
sem paquetes = 0;
sem espacios = N;

Process Preparador::{
	while(true){
		prepararPaquete();
		P(espacios) //si hay un espacio intento dejarlo
		P(mutex); //si nadie esta interactuando con la sala
		dejarloEnContenedor();
		V(mutex); 
		V(paquetes);
	}
}

Process Entregador::{
	while(true){
		P(paquetes);
		P(mutex)
		tomarContenedor();
		V(mutex);
		V(espacios);
		RealizarEntrega();
	}
}

//b) Modifique la solución a) para el caso en que haya P Preparadores y E Entregadores.

sem mutex = 1;
sem paquetes = 0;
sem espacios = N;

Process Preparador[id:0..P-1]{
	while(true){
		prepararPaquete();
		P(espacios) //si hay un espacio intento dejarlo
		P(mutex); //si nadie esta interactuando con la sala
		dejarloEnContenedor();
		V(mutex); 
		V(paquetes);
	}
}

Process Entregador[id:0..E-1]{
	while(true){
		P(paquetes);
		P(mutex)
		tomarContenedor();
		V(mutex);
		V(espacios);
		RealizarEntrega();
	}
}

//5)Suponga que se tiene un curso con 50 alumnos. Cada alumno debe realizar una tarea y existen 10 enunciados posibles.
Una vez que todos los alumnos eligieron su tarea, comienzan a realizarla.
Cada vez que un alumno termina su tarea, le avisa al profesor y se queda esperando el puntaje del grupo,
el cual está dado por todos aquellos que comparten el mismo enunciado.
Cuando todos los alumnos que tenían la misma tarea terminaron,
el profesor les otorga un puntaje que representa el orden en que se terminó esa.

//Nota: para elegir la tarea suponga que existe una función elegir que le asigna una tarea a un alumno
(esta función asignará 10 tareas diferentes entre 50 alumnos, es decir, que 5 alumnos tendrán la tarea 1, otros 5 la tarea 2 y así sucesivamente para las 10 tareas).

Sem espera = 0;
sem mutex = 1;
sem alumnos = 0;
sem tareas [10, 0];
colaTareas c;
sem pilaTareas = 0;

Process Alumno[id:0..49]{
	int idTarea = ElegirTarea();
	V(alumnos);
	P(espera);
	resolverTarea();
	P(mutex);
	agregar(c, idTarea);
	V(pilaTareas)
	V(mutex);
	//esperar a que el profesor corriga a su grupo
	//recibir la nota
}

Process Profesor::{
	int idT = -1;
	for[int i=0; i<50; i++]	P(alumnos); //es busy-waiting??
	V(espera);
	for[int i=0; i<50; i++]{
		P(mutex);
		P(pilaTareas);
		sacar(c, idT); //saco la tarea y su id
		V(mutex);
		//no corrige hasta que haya 5 tareas con el mismo id
		//corregir al grupo
		//entrega la nota en funcion del orden que entregaron esta tarea (se necesita una cola para guardar las tareas del grupo)
	}
}