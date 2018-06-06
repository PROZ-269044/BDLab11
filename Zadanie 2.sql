--implementacja typu Variancy
CREATE OR REPLACE TYPE BODY Variancy AS
STATIC FUNCTION ODCIAggregateInitialize
  ( actx IN OUT Variancy
  ) RETURN NUMBER IS 
  BEGIN
    IF actx IS NULL THEN
      actx := Variancy(0,0,0,0);
    ELSE
      actx.salarysumpow := 0; -- suma kwadratow
      actx.salarysum := 0; --suma
      actx.runningCount := 0; -- licznik
      actx.bufor := 0; -- zmienna reprezentujaca kwadrat wartosci w danej iteracji
    END IF;
    RETURN ODCIConst.Success;
  END;
  
MEMBER FUNCTION ODCIAggregateIterate
  ( self  IN OUT Variancy,
    val   IN     NUMBER
  ) RETURN NUMBER IS
  BEGIN
    IF val IS NULL THEN 
        /* Will never happen */
        DBMS_OUTPUT.PUT_LINE('Null on iterate');
    END IF;
    self.bufor := val * val; --zmienna reprezentujaca kwadrat w danej iteracji
    self.salarysumpow := self.salarysumpow + self.bufor; -- kwadrat dodaje do sumy kwadratow
    self.salarysum := self.salarysum + val; -- zmienna w danej iteracji dodawana do sumy pensji
    self.runningCount := self.runningCount + 1; -- licznik
    RETURN ODCIConst.Success;
  END;

MEMBER FUNCTION ODCIAggregateMerge
  (
        self IN OUT Variancy, 
        ctx2 IN Variancy
    
    )RETURN NUMBER is
    BEGIN
      self.bufor:= self.bufor + ctx2.bufor;
        self.salarysumpow :=self.salarysumpow + ctx2.salarysumpow;
        self.salarysum := self.salarysum + ctx2.salarysum;
        self.runningCount := self.runningCount + ctx2.runningCount;
    RETURN ODCIConst.Success;
    END;
     
MEMBER FUNCTION ODCIAggregateTerminate
  ( self        IN  Variancy,
    ReturnValue OUT NUMBER,
    flags       IN  NUMBER
  ) RETURN NUMBER IS
  BEGIN
    dbms_output.put_line('Terminate ' || to_char(flags) || to_char(self.salarysumpow) || to_char(self.salarysum));
    IF self.runningCount <> 0 AND self.runningCount <> 1 THEN
      returnValue := TO_NUMBER(self.salarysumpow - ((self.salarysum * self.salarysum))/self.runningCount)/(self.runningCount-1);--do wyliczenia wariancji na koniec  
    ELSE
      /* It *is* possible to have an empty group, so avoid divide-by-zero. */
      returnValue := null;
    END IF;
    RETURN ODCIConst.Success;
  END;
END;
/

--deklaracje typu Variancy
CREATE OR REPLACE TYPE Variancy 
AS OBJECT
(
    RunningCount Number,
    SalarySum Number,
    SalarySumPow Number,
    bufor number,
    
    Static function ODCIAggregateInitialize
    (
        actx in out Variancy
    ) RETURN NUMBER,
    
    MEMBER FUNCTION ODCIAggregateIterate
    ( 
        self IN OUT Variancy,
        val IN NUMBER
    ) RETURN NUMBER,
    
     MEMBER FUNCTION ODCIAggregateMerge
     (
        self IN OUT Variancy, 
        ctx2 IN Variancy
    
     )RETURN NUMBER,
    
    MEMBER FUNCTION ODCIAggregateTerminate
    ( 
         self  IN   Variancy,
         returnValue  OUT  NUMBER,
         flags        IN   NUMBER
    ) RETURN NUMBER
);


--zbudowanie z obiektu body funkcji
CREATE OR REPLACE FUNCTION VarSample(val NUMBER)
RETURN NUMBER 
AGGREGATE USING Variancy;
/

--testy funkcji var_samp
SELECT DEPARTMENT_ID, VAR_SAMP(SALARY) FROM 
HR.EMPLOYEES
GROUP BY DEPARTMENT_ID ORDER BY DEPARTMENT_ID;


--test funkcji VarSample
SELECT DEPARTMENT_ID, VarSample(SALARY) FROM 
HR.EMPLOYEES GROUP BY DEPARTMENT_ID;


