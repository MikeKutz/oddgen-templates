create view tabcols as
select 
OWNER               
,TABLE_NAME      as object_name
,COLUMN_NAME         
,DATA_TYPE           
,DATA_TYPE_MOD       
,DATA_TYPE_OWNER     
,DATA_LENGTH         
,DATA_PRECISION      
,DATA_SCALE          
,NULLABLE            
,COLUMN_ID          as order_by
,DEFAULT_LENGTH      
,DATA_DEFAULT        
,NUM_DISTINCT        
,LOW_VALUE           
,HIGH_VALUE          
,DENSITY             
,NUM_NULLS           
,NUM_BUCKETS         
,LAST_ANALYZED       
,SAMPLE_SIZE         
,CHARACTER_SET_NAME  
,CHAR_COL_DECL_LENGTH
,GLOBAL_STATS      
,USER_STATS        
,AVG_COL_LEN       
,CHAR_LENGTH       
,CHAR_USED         
,V80_FMT_IMAGE     
,DATA_UPGRADED     
,HIDDEN_COLUMN     
,VIRTUAL_COLUMN    
,SEGMENT_COLUMN_ID 
,INTERNAL_COLUMN_ID
,HISTOGRAM        
,QUALIFIED_COL_NAME
from all_tab_cols;

create or replace
package template_oddgen_master
as
  /**
  This is the oddgen API Master template
  */
end;
/

create or replace
package body template_oddgen_master
as

$if false $then
<%@ template name=headcom %>
/**
  oddgen DD API
  
  @headcom
*/
$end

$if false $then
<%@ template name=make_spec %>
create or replace
package oddgen_dd_api
as
<%@ include(TEMPLATE_ODDGEN_MASTER@headcom) %>
<%@ include(TEMPLATE_ODDGEN_UTIL@make_spec) %>
-- loop views ${view_name}
<%@ include(TEMPLATE_ODDGEN_FUNCTIONS@make_spec) %>

end;
$end

$if false $then
<%@ template name=make_body %>
create or replace
package body oddgen_dd_api
as
<%@ include(TEMPLATE_ODDGEN_UTIL@make_body) %>

-- loop views
<%@ include(TEMPLATE_ODDGEN_FUNCTIONS@make_body) %>
$end

end;
/

create or replace
package template_oddgen_functions
as
  /**
  This is the oddgen template for function on views
  requird parameter "view_name"
  */
end;
/


create or replace
package body template_oddgen_functions
as

$if false $then
<%@ template name=headcom %>
/**
  Searches view "${view_name}" and returns results as a SYS_REFCURSOR
  
  @param p_owner       owner of the object
  @param p_object_name name of the object
  @param p_sxquery     simplified xquery. NULL returns all. default NULL
  @return the results as a SYS_REF_CURSOR
*/
$end


$if false $then
<%@ template name=spec %>
function get_${view_name}( p_owner in varchar2, p_object_name in varchar2, p_sxquery in varchar2 DEFAULT null)
  return sys_refcursor
$end

$if false $then
<%@ template name=body %>
as
  l_xqeury  clob;
  l_sql     clob;
  c         pls_integer;
begin
  l_xquery := sxquery2xquery( p_sxquery );
  l_sql := q'{
    with data as (
      select <loop over column names>
        xmlelement( "row",
           xmlforest( <loop over coulmn names>
        ) search_xml
    from ${view_name}
    where owner=:owner
     and objec_name=:object_name
   )
   select <loop over column names>
   from data d
   where xquery( :xquery passing d.search_xml returning result ) is not null
   }';
   
   c := dbms_sql.open_cursor();
   dbms_sql.parse(c,l_sql,dbms_sql.native);
   dbms_sql.bind_variable( ':owner', p_owner );
   dbms_sql.bind_variable( ':object_name', p_object_name );
   dbms_sql.bind_variable( ':xquery', l_xquery );
   
   dbms_sql.execute( c );
   
   return SYS.DBMS_SQL.TO_REFCURSOR( c );
end;

end;
$end
--template_oddgen_functions
$if false $then
<%@ template name=make_spec %>
<%@ include(TEMPLATE_ODDGEN_FUNCTIONS@headcom) %>
<%@ include(TEMPLATE_ODDGEN_FUNCTIONS@spec) %>;
$end

$if false $then
<%@ template name=make_body %>
<%@ include(TEMPLATE_ODDGEN_FUNCTIONS@spec) %>
<%@ include(TEMPLATE_ODDGEN_FUNCTIONS@body) %>
$end


end;
/

create or replace
package template_oddgen_util
as
/**
  template for oddgen DD API utility functions
*/
end;
/

create or replace
package body template_oddgen_util
as
$if false $then
<%@ template name=sxquery2xquery_doc %>
/**
  converts simplified XQuery into an appropriate XQuery
*/
$end

$if false $then
<%@ template name=sxquery2xquery_spec %>
function sxquery2xquery( p_sxquery in varchar2 ) return varchar2
$end

$if false $then
<%@ template name=sxquery2xquery_body %>
as
  l_sxquery varchar2;
begin
  l_sxquery := regexp_replace( p_sxquery, '([^[:alnum:]_])/', '\1 $i/');
  
  return 'for $i in /row' || chr(10)
      || case when p_sxquery is not null then 'where ' || l_sxquery end || chr(10)
      || 'return $i';
end
$end

$if false $then
<%@ template name=make_spec %>
<%@ include(TEMPLATE_ODDGEN_UTIL@sxquery2xquery_doc) %>
<%@ include(TEMPLATE_ODDGEN_UTIL@sxquery2xquery_spec) %>;

$end
$if false $then
<%@ template name=make_spec %>
<%@ include(TEMPLATE_ODDGEN_UTIL@sxquery2xquery_spec) %>
<%@ include(TEMPLATE_ODDGEN_UTIL@sxquery2xquery_body) %>
$end


end;
/

