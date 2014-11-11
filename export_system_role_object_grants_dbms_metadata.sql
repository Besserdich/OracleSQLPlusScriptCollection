/***********************************************
* Author:  Karsten Besserdich
* Firma:   Besserdich Sustainable IT Solutions GmbH
* Date:	   11.11.2014
* URL:	    http://www.besserdich.com
* Twitter: @BesserdichIT
* EMail:   karsten.besserdich@besserdich.com
*
* PARAMETER 1 - Pfad inkl. Name der zu erstellenden SQL-Datei 
* PARAMETER 2 - Rolle- oder Username von dem die Rechte 
*               extrahiert werden sollen
*
* Hinweis: Der Aufruf muss vom User sys oder system erfolgen
*
* Beispielaufruf
* sqlplus / as sysdba @extract_grants.sql /tmp/my_user1.sql MY_USER1
************************************************/
 
SET LONG 10000000
SET PAGESIZE 0
SET TRIMSPOOL ON
SET LINESIZE 2000
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF 
SET TERM OFF
SET VERIFY OFF
 
DEFINE _FILENAME = &1
DEFINE _USER_ROLE_NAME = &2
 
spool &_FILENAME
 
SELECT 
CASE type_num
-- TYPE_NUM 48 ist keine Scheduler Class sondern eine Consumer Group - Bug seitens Oracle?
WHEN 48 THEN
  'EXEC DBMS_RESOURCE_MANAGER_PRIVS.grant_switch_consumer_group( grantee_name    => ''' || x.grantee || ''', consumer_group  => '''  || x.obj || ''', grant_option    => FALSE)'
-- TYPE_NAM 23 ist ein Directory - hier ist die Syntax etwas anders
WHEN 23 THEN
  'GRANT ' || x.priv || ' ON DIRECTORY ' || x.grantor || '.' || x.obj || ' TO ' || x.grantee || ';'
ELSE
  'GRANT ' || x.priv || ' ON ' || x.grantor || '.' || x.obj || ' TO ' || x.grantee || ';'
END  
FROM (SELECT XMLTYPE(dbms_metadata.get_granted_xml('OBJECT_GRANT', dtp.grantee)) xml FROM dba_tab_privs dtp WHERE dtp.grantee = '&_USER_ROLE_NAME' AND ROWNUM <= 1) t,
XMLTABLE ('/ROWSET/ROW/OBJGRANT_T' PASSING t.xml
                                  COLUMNS grantee  VARCHAR2(30) PATH 'GRANTEE',
                                          grantor  VARCHAR2(30) PATH 'GRANTOR',
                                          priv     VARCHAR2(30) PATH 'PRIVNAME',
                                          obj      VARCHAR2(30) PATH 'BASE_OBJ/NAME',
                                          obj_type VARCHAR2(30) PATH 'BASE_OBJ/TYPE_NAME',
                                          type_num NUMBER				PATH 'BASE_OBJ/TYPE_NUM'
                                          ) x
WHERE 1=1
AND grantor = 'SYS' /*Hier findet dich Einschränkung statt - Gebe mir alle Objektberechtigungen vom USER SYS*/
UNION ALL
SELECT 'GRANT ' || x.rol || ' TO ' || x.grantee || ';'
FROM (SELECT XMLTYPE(dbms_metadata.get_granted_xml('ROLE_GRANT', drp.grantee)) xml FROM dba_role_privs drp WHERE drp.grantee = '&_USER_ROLE_NAME' AND ROWNUM <= 1) t,
XMLTABLE ('/ROWSET/ROW/ROGRANT_T' PASSING t.xml
                                  COLUMNS grantee VARCHAR2(30) PATH 'GRANTEE',                                          
                                          rol    VARCHAR2(30)  PATH 'ROLE'
                                          ) x
UNION ALL
SELECT 'GRANT ' || x.priv || ' TO ' || x.grantee || ';'
FROM (SELECT XMLTYPE(dbms_metadata.get_granted_xml('SYSTEM_GRANT', dsp.grantee)) xml FROM dba_sys_privs dsp WHERE dsp.grantee = '&_USER_ROLE_NAME' AND ROWNUM <= 1) t,
XMLTABLE ('/ROWSET/ROW/SYSGRANT_T' PASSING t.xml
                                  COLUMNS priv    VARCHAR2(100) PATH 'PRIVNAME',                                          
                                          grantee VARCHAR2(30)  PATH 'GRANTEE'
                                          ) x;
 
spool off
 
quit
