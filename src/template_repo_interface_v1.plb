CREATE OR REPLACE
TYPE BODY template_repo_interface_v1 AS

  CONSTRUCTOR function template_repo_interface_v1( p_mount_point in varchar2, p_base_url in varchar2 ) return self as result AS
  BEGIN
    -- TODO: Implementation required for function REPO_DRIVER_INTERFACE.repo_driver_interface
    self.Guid := dbms_random.value();
    self.repository_guid := self.guid;
    self.mount_point := p_mount_point;
    self.pwd := '/';
    self.base_url := p_base_url;
    
    return;
  END template_repo_interface_v1;

  not final static function list_interfaces return xmltype AS
   l_result xmltype;
  BEGIN
    -- UPDATE AS NEEDED
    with interface_list as (
      select 'constructor' iname from dual union all
      select 'get_code' iname from dual union all
      select 'ls' iname from dual union all
      select 'list_interfaces' iname from dual union all
      select 'has_interface' iname from dual
    )
    select xmlelement( "interface", xmlagg( xmlforest( upper(iname) as "name" )))
      into l_result
    from interface_list;
    return l_result;    
  END list_interfaces;

  not final static function has_interface( p_interface_name in varchar2)  return boolean AS
    l_iname varchar2(32);
    l_list xmltype;
  BEGIN
    l_list := list_interfaces;
    select iname into l_iname
    from xmltable( '/interface'
        passing l_list
        columns
          iname varchar2(32) path '/name'
        )
    where iname = p_interface_name;
    return true;
  exception
    when no_data_found then return false;
  END has_interface;

  not final member procedure cd( p_directory in varchar2 := null ) AS
    l_stuff directory_t;
  BEGIN
    l_stuff := template_repo_const.extract_dir_info( p_directory );

    if l_stuff.repository != self.mount_point then raise template_repo_const.invalid_repository; end if;
    
    check_dir( l_stuff.full_directory );
    pwd := l_stuff.full_directory;
  END cd;

  not final member procedure check_dir( p_directory in varchar2 := null ) AS
  BEGIN
    if p_directory != '/' then raise template_repo_const.invalid_directory; end if;
  END check_dir;

  not final member procedure check_file( p_file in varchar2 := null ) AS
  BEGIN
    -- TODO: Implementation required for procedure REPO_DRIVER_INTERFACE.check_file
    raise template_repo_const.invalid_interface;
  END check_file;

  not final member function ls( p_directory in varchar2 := null ) return XMLType AS
  BEGIN
    -- TODO: Implementation required for function REPO_DRIVER_INTERFACE.ls
    raise template_repo_const.invalid_interface;
  END ls;

  not final member procedure md( p_directory in varchar2 := null ) AS
  BEGIN
    -- TODO: Implementation required for procedure REPO_DRIVER_INTERFACE.md
    raise template_repo_const.invalid_interface;
  END md;

  not final member procedure rm( p_file in varchar2 ) AS
  BEGIN
    -- TODO: Implementation required for procedure REPO_DRIVER_INTERFACE.rm
    raise template_repo_const.invalid_interface;
  END rm;

  not final member procedure rmdir( p_directory in varchar2, p_options in varchar2 := null ) AS
  BEGIN
    -- TODO: Implementation required for procedure REPO_DRIVER_INTERFACE.rmdir
    raise template_repo_const.invalid_interface;
  END rmdir;

  not final member function get_code( p_file_name in varchar2 ) return clob AS
  BEGIN
    -- TODO: Implementation required for function REPO_DRIVER_INTERFACE.get_code
    raise template_repo_const.invalid_interface;
  END get_code;

  not final member function get_properties( p_file_name in varchar2 ) return xmltype AS
  BEGIN
    -- TODO: Implementation required for function REPO_DRIVER_INTERFACE.get_properties
    raise template_repo_const.invalid_interface;
  END get_properties;

  not final member function get( p_file_name in varchar2 ) return xmltype AS
  BEGIN
    -- TODO: Implementation required for function REPO_DRIVER_INTERFACE.get
    raise template_repo_const.invalid_interface;
  END get;

  not final member function propfind( p_directory in varchar2, p_depth in int, p_proplist in xmltype := null ) return xmltype AS
  BEGIN
    -- TODO: Implementation required for function REPO_DRIVER_INTERFACE.propfind
    raise template_repo_const.invalid_interface;
  END propfind;

  not final member procedure propupdate( p_file in varchar2, p_properties in xmltype ) AS
  BEGIN
    -- TODO: Implementation required for procedure REPO_DRIVER_INTERFACE.propupdate
    raise template_repo_const.invalid_interface;
  END propupdate;

  not final member procedure put( p_file in varchar2, p_data in clob, p_properties in xmltype) AS
  BEGIN
    -- TODO: Implementation required for procedure REPO_DRIVER_INTERFACE.put
    raise template_repo_const.invalid_interface;
  END put;

  not final member procedure makecol( p_directory in varchar2 ) AS
  BEGIN
    -- TODO: Implementation required for procedure REPO_DRIVER_INTERFACE.makecol
    raise template_repo_const.invalid_interface;
  END makecol;

END;
/
