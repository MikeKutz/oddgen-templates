create or replace
package repositories_admin
as
  /**
    This package is used to administer the REPOSITORIES table.
    This is like a TAPI for the said table.
    @headcom
  */
  function ls_types return xmltype;
  function check_type( p_type in varchar2 ) return boolean;
  procedure mount( p_type in varchar2, p_mount_point in varchar2, p_base_url in varchar2 );
  procedure unmount( p_mount_point in varchar2 );
  procedure unmount_by_guid( p_guid in varchar2 );
end;
/
