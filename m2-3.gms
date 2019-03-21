$TITLE: M2-3.GMS add a rationing constraint to model M2-2
*    MAXIMIZE UTILITY SUBJECT TO A LINEAR BUDGET CONSTRAINT
*    PLUS RATIONING CONSTRAINT ON X1
*    two goods, Cobb-Douglas preferences

PARAMETERS
    M       "Income"
    P1, P2  "Prices of goods X1 and X2"
    S1, S2  "utility shares of X1 and X2"
    RATION  "rationing constraint on the quantity of X1";


M = 100;
P1 = 1;
P2 = 1;
S1 = 0.5;
S2 = 0.5;
RATION = 100;


POSITIVE VARIABLE X1       "Commodity demands";
POSITIVE VARIABLE X2       "Commodity demands";
VARIABLE U                 "Welfare";


EQUATION UTILITY   "Utility";
EQUATION INCOME    "Income-expenditure constraint";
EQUATION RATION1   "Rationing constraint on good X1";


UTILITY..   U =E= 2 * (X1**S1) * (X2**S2);

INCOME..    M =G= P1*X1 + P2*X2;

RATION1..   RATION =G= X1;

U.L = 100;
X1.L = 50;
X2.L = 50;

MODEL OPTIMIZE / UTILITY, INCOME, RATION1 /;

* unload data to use in the Julia/JuMP version
EXECUTE_UNLOAD "m2_3_data.gdx" M,P1,P2,S1,S2,RATION;
EXECUTE 'python3 ./gdx2json.py --in=m2_3_data.gdx';




SOLVE OPTIMIZE USING NLP MAXIMIZING U;

PARAMETER report(*,*);

report('no_ration',"X1") = X1.L;
report('no_ration',"X2") = X2.L;
report('no_ration',"U") = U.L;



RATION = 25;
SOLVE OPTIMIZE USING NLP MAXIMIZING U;


report('ration_25',"X1") = X1.L;
report('ration_25',"X2") = X2.L;
report('ration_25',"U") = U.L;

EXECUTE_UNLOAD 'm2_3_soln.gdx';
