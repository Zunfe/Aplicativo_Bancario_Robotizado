/**
** Name : Zenfu
** Date: 2023-Aug
** Description : Este proyecto es una implementación de un aplicativo bancario robotizado que permite realizar transacciones 
***automatizadas en cuentas bancarias de clientes autorizados. El robot accede a las cuentas bancarias a través de API y realiza acciones como el débito de fondos.
*/

CREATE OR REPLACE PACKAGE DebitFunds AS 

PROCEDURE DebitFunds(p_AccountID IN NUMBER,p_Amount IN NUMBER);
FUNCTION VerificarAutorizacion( p_ClienteID IN NUMBER) RETURN BOOLEAN;

END DebitFunds;
/

CREATE OR REPLACE PACKAGE BODY DebitFunds AS

 PROCEDURE DebitFunds (
    
	p_AccountID IN NUMBER,
    p_Amount IN NUMBER
	
	) IS 
	
	v_CurrentBalance NUMBER;
 
 
BEGIN
    -- Obtener el saldo actual de la cuenta
    SELECT Saldo INTO v_CurrentBalance
    FROM Cuentas
    WHERE CuentaID = p_AccountID;

    -- Verificar si hay suficientes fondos para el débito
    IF v_CurrentBalance >= p_Amount THEN
        -- Realizar el débito
        UPDATE Cuentas
        SET Saldo = Saldo - p_Amount
        WHERE CuentaID = p_AccountID;

        -- Registrar la transacción
        INSERT INTO Transacciones (CuentaID, TipoTransaccion, Monto, FechaHora)
        VALUES (p_AccountID, 'Débito', p_Amount, SYSDATE);
        
        -- Imprimir mensaje de éxito
        DBMS_OUTPUT.PUT_LINE('Débito exitoso: ' || p_Amount || ' debítados de la cuenta ' || p_AccountID);
    ELSE
        -- Imprimir mensaje de fondos insuficientes
        DBMS_OUTPUT.PUT_LINE('Fondos insuficientes en la cuenta ' || p_AccountID);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Imprimir mensaje si la cuenta no existe
        DBMS_OUTPUT.PUT_LINE('Cuenta ' || p_AccountID || ' no encontrada.');
    WHEN OTHERS THEN
        -- Imprimir mensaje si hay un error no manejado
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error al procesar la transacción.');
END;

FUNCTION VerificarAutorizacion (
    p_ClienteID IN NUMBER,
    p_RobotAutorizado OUT BOOLEAN
) RETURN BOOLEAN AS
BEGIN
    SELECT Autorizacion
    INTO p_RobotAutorizado
    FROM ConfiguracionesClientes
    WHERE ClienteID = p_ClienteID;

    RETURN p_RobotAutorizado;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END;
/

