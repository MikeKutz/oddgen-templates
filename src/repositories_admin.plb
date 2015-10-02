create or replace
package body repositories_admin
as
  function ls_types return xmltype
  as
    l_xml xmltype;
  begin
    with t( repo_type, description, obj_type) as (
      select 'DBOBJ', 'Database Objects', 'REPO_DRIVER_DBOBJ' from dual
    )
    select xmlelement( "repositories",
               xmlagg( xmlelement( "repo", xmlforest( repo_type,description, obj_type) ) )
            )
      into l_xml
    from t;
    
  return l_xml;
  end;
  
  function check_type( p_type in varchar2 ) return boolean
  as
    l_type varchar2(20);
  begin
    select repo_type into l_type
    from xmltable( '/repositories/repo'
        passing ls_types
        columns
         repo_type varchar2(20) path '/repo/repo_type'
    )
    where repo_type = p_type;
    return true;
  exception
    when no_data_found then
     return false;
  end;
  
  procedure mount( p_type in varchar2, p_mount_point in varchar2, p_base_url in varchar2 )
  as
    l_repo template_repo_interface_v1;
  begin
    if p_type = 'DBOBJ'
    then
      l_repo := repo_driver_dbobj( p_mount_point => p_mount_point, p_base_url => p_base_url );
/*
    elsif p_type = 'type1'
    then
      l_repo := repo_driver_type1( p_mount_point => p_mount_point, p_base_url => p_base_url );
    elsif p_type = 'type2'
    then
      l_repo := repo_driver_type2( p_mount_point => p_mount_point, p_base_url => p_base_url );
*/
    else
      raise template_repo_const.invalid_repository;
    end if;
    
    insert into repositories values ( l_repo );
  end;
    
  procedure unmount( p_mount_point in varchar2 )
  as
    l_guid repositories.guid%type;
  begin
    select r.guid into l_guid
    from repositories r
    where r.mount_point = p_mount_point;
    
    unmount_by_guid( l_guid );
  exception
    when no_data_found then
      raise template_repo_const.invalid_repository;
  end;
  procedure unmount_by_guid( p_guid in varchar2 )
  as
  begin
    delete from repositories r where r.guid = p_guid;
  end;
end;
/
