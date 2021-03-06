/***********************************************
* Author:  Karsten Besserdich
* Firma:   Besserdich Sustainable IT Solutions GmbH
* Date:	   03.11.2014
* URL:	   http://www.besserdich.com
* Twitter: @BesserdichIT
* EMail:   karsten.besserdich@besserdich.com
*
* SQLPlus Script enthaelt 2 Parameter, die entweder 
* durch Scriptparameter gesetzt werden koennen, 
* oder bei einer manuellen Ausfuehrung ohne 
* Angabe der Parameter mittels Eingabeprompt 
* abgefragt werden.
*
* More Informations: 
* http://www.besserdich.com/oracle/sqlplus-script-parameteruebergabe-mittels-commandline-oder-prompt/
************************************************/
SET SERVEROUTPUT ON
SET VERIFY OFF
 
PROMPT Bitte geben Sie den Wert fuer Parameter 1 ein [JA|NEIN] (Mit ENTER -> DEFAULT JA):
SET TERMOUT OFF
DEFINE _PARAMETER_01	=&1 JA
SET TERMOUT ON
 
PROMPT Bitte geben Sie den Wert fuer Parameter 2 ein [JA|NEIN] (Mit ENTER -> DEFAULT NEIN):
SET TERMOUT OFF
DEFINE _PARAMETER_02	=&2 NEIN
SET TERMOUT ON
 
PROMPT
PROMPT Ihre getroffene Auswahl
PROMPT ***********************
PROMPT 
PROMPT Parameter 01: &_PARAMETER_01
PROMPT Parameter 02: &_PARAMETER_02
PROMPT 
 
EXIT
