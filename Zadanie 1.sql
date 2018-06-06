BEGIN
   DBMS_OUTPUT.ENABLE (1000);
END;

--trigger - cialo funkcji
create or replace trigger stopminussalary
instead of INSERT OR UPDATE ON pracownicy

DECLARE
ex Exception;

begin
    dbms_output.put_line('w triggerze!');
    
   IF UPDATING then
        if :new.SALARY < 0 then
        raise ex;
        end if;
        
       UPDATE EMPS
       set SALARY = :new.SALARY
       WHERE :new.employee_ID = :old.employee_ID;
   END IF;
    
   IF INSERTING then
       if :new.salary < 0 then
       raise ex;
       end if;
       
    INSERT INTO EMPS values(:new.employee_ID, :new.FIRST_NAME, :new.LAST_NAME, :new.EMAIL, :new.PHONE_NUMBER, :new.HIRE_DATE, :new.JOB_ID, :new.SALARY, :new.COMMISSION_PCT, :new.MANAGER_ID, :new.DEPARTMENT_ID);
    END IF;
    
    EXCEPTION
    WHEN ex THEN
    dbms_output.put_line('Pensja poni¿ej 0!');
    
END;
/

--procedura inseru rekordu
INSERT INTO pracownicy VALUES (450, 'bill', 'byford',  'bbyford', '6492394093', '10/06/21', 'SA_REP', 8000, null, 145, 10); 

SELECT * FROM pracownicy;
SELECT * FROM emps;

--procedura updatu pensji
UPDATE pracownicy
    SET SALARY = 2500
    WHERE EMPLOYEE_ID = 197;

--uruchomienie bufora


--zmiana parametrów widzocznoœci triggera
ALTER TRIGGER stopminussalary ENABLE;
DROP TRIGGER stopminussalary;

--tworzenie widoku dla triggera
CREATE OR REPLACE VIEW pracownicy as
SELECT * FROM EMPS;

--usuwanie niepozadanych rekordow(czysczenie po nieudanych testach)
DELETE FROM EMPS WHERE EMPLOYEE_ID = 420;

