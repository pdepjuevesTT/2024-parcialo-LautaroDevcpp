object poblacion
{

    var personas = []

    // PUNTO 6
    method personaConMasObjetos() = personas.max{persona => persona.cantObjetos()}
    
    method pagarCuentas()
    {

        // recorre toda la coleccion de personas y hace que todas cobren el sueldo, por consecuente todas intentan pagar sus deudas
        personas.forEach{persona => persona.cobrarSueldo()}

    }


}

// BANCO

object bancoCentral
{

    // debería tirar un random mejor, pero representa la tasa de interes asignada a cada entidad bancaria
    var interes = 3

    method interes () = interes

}

class Banco
{

    var interes
    var maxPermitido

    method maxPermitido() = maxPermitido
    method interes() = bancoCentral.interes()
    
}

//  TARJETAS

class tarjeta
{

    var banco

    var cantMeses

    method cantMeses() = cantMeses
    method interes() = banco.interes()
    method maxPermitido() = banco.maxPermitido()

}

// PERSONAS


object mes
{

    // numero actual de mes
    var nroMes = 0

    method nroMes() = nroMes

    // PUNTO 3
    method pasarMes()
    {

        // aumenta el numero del mes y asigna los sueldos por persona
        nroMes += 1
        poblacion.pagarCuentas()

    }

}

class Deuda
{


    var meses = [] // conjunto de numeros desde el nroMes que empieza la deuda hasta donde termina
    var pagoPorMes //es el precio del objeto por el interes divido la cantidad de meses
    var saldada = false

    method pagarDeuda()
    {


            // saco el primer elemento (no recuerdo si tiene efecto de lado)
            meses.drop(meses.length()-1)

            if(meses==0)
            {

              saldada = true

            }

    
    }

    

    // el total de los montos vencidos es la cantidad de meses vencidos por el monto por mes
    method montosVencidos() = meses.filter{ nroMes => nroMes < mes.nroMes() }*pagoPorMes

}

class trabajo
{

    var sueldo 
    method sueldo()=sueldo

}

class Persona 
{

    var efectivo
    var objetos = []
    var metodosDePago = []
    var deudas = []
    var metodoPreferido // apunta a un metodo 
    var trabajo
    var sueldo = trabajo.sueldo()

    method restarEfectivo(cantidad){ efectivo -= cantidad}
    method restarSueldo(cantidad){sueldo -= cantidad}
    method puedePagar(sueldoo,pagoPorMes) = sueldoo > pagoPorMes

    method cobrarSueldo()
    {
        
        // cuando cobro el sueldo pago todas las deudas que puedo mientras me alcance el sueldo
        deudas.forEach{ deuda => 
            
            if(self.puedePagar(sueldo, deuda.pagoPorMes()))
            {

                deuda.pagar() 
                self.restarSueldo(deuda.pagoPorMes())

            }
        
        }

        efectivo += sueldo

    }

    method cantObjetos() = objetos.length()

    method generarDeuda(pago)
    { 
        
        var mesesNum = [] // una lista de numeros con numeros desde el mes que se inicio la deuda hasta el mes que termina
        
        deudas.add(new Deuda( meses = mesesNum, pagoPorMes= pago)) 
        
    }

    // PUNTO 1

    method comprar(objeto) 
    {
        if(metodoPreferido.puedeComprar(self,objeto)) 
        {

            metodoPreferido.cobrar(self,objeto.precio())
            objetos = objetos + objeto

        }
        
    }

    // PUNTO 2
    method nuevoMetodoPreferido(metodo) 
    {
        
        //si tiene el metodo entonces lo asigna como preferido
        if(metodosDePago.contains(metodo))
        {

            metodoPreferido = metodo

        }    
        
    }


    // PUNTO 4
    // es la suma de todas las deudas vencidas
    method totalMontosVencidos() = deudas.sum{ deuda => deuda.montosVencidos() }

}


// SEGUNDA PARTE

class CompradorCompulsivo inherits Persona
{

    

    override method comprar(objeto)
    {

        // incluye el if original con su condicion
        // utilizaría super pero no sé si funciona con el conseucuente de if
        // mi idea es usar super() y luego el consucuente else

        if(metodoPreferido.puedeComprar(self,objeto)) 
        {

            metodoPreferido.cobrar(self,objeto.precio())
            objetos = objetos + objeto

        }

        else
        {

            // el metodo preferido se borra ya que no pudo pagarlo
            var metodosAlternativos = metodosDePago.filter{metodo => metodo.puedeComprar(self,objeto)}    

            // verifico que la lista no este vacia
            if(metodosAlternativos.isEmpty())
            {

                metodosAlternativos.get(0).cobrar(self,objeto.precio())

            }
            


        }

    }

}


class PagadoresCompulsivos inherits Persona
{

    override method cobrarSueldo()
    {

        // cuando cobro el sueldo pago todas las deudas que puedo mientras me alcance el sueldo
        deudas.forEach{ deuda => 
            
            if(self.puedePagar(sueldo, deuda.pagoPorMes()))
            {

                deuda.pagar() 
                self.restarSueldo(deuda.pagoPorMes())

            }

            else if(self.puedePagar(efectivo, deuda.pagoPorMes()))
            {
                
                deuda.pagar() 
                self.restarEfectivo(deuda.pagoPorMes())

            }
        
        }



        efectivo += sueldo


    }

}




// COMPRAR

class Metodo 
{

    method puedeComprar(persona,objeto)=true
    method cobrar(persona,precio){}

}

class Efectivo inherits Metodo
{

    override method puedeComprar(persona,objeto)= persona.efectivo() > objeto.precio()

    override method cobrar(persona,precio)
    {

        persona.restarEfectivo(precio)

    }

}


class DebitoBancario inherits Metodo
{

    var debito 

    override method puedeComprar(persona,objeto)= debito > objeto.precio()

    override method cobrar(persona,precio)
    {

        debito -= precio

    }

}


class TarjetaDeCredito inherits Metodo
{

    var tarjeta 

    method puedeComprar(objeto)= tarjeta.maxPermitido() > objeto.precio()*tarjeta.interes()

    override method cobrar(persona,precio)
    {

        var pago = precio*tarjeta.interes()/tarjeta.cantMeses()
        persona.generarDeuda(pago)

    }

}



// PUNTO 5

// puede pagar un objeto programando para la persona que lo esta vendiendo 
class ServicioDeProgramacion inherits Metodo
{

    var horasDeTrabajo
    var precioPorHora = 1000 

    method puedeComprar(objeto)= horasDeTrabajo*PrecioPorHora > objeto.precio()

    // metodo cobrar no modifica nada ya que el pago es con trabajo humano
    override method cobrar(persona,precio){}

}




// persona.comprar(objeto)

class Objeto {


    var precio

    method precio() = precio
  
}


