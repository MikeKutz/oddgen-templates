create or replace type repo_driver_dbobj under template_repo_interface_v1 (
    constructor function repo_driver_dbobj( p_mount_point in varchar2, p_base_url in varchar2 ) return self as result,
    overriding member procedure check_dir( p_directory in varchar2 := null ),
    overriding member procedure check_file( p_file in varchar2 := null ),
    overriding member function ls( p_directory in varchar2 := null ) return XMLType,
    -- overriding member function cd( p_directory in varchar2 := null ) return XMLType, -- parent type's code is sufficient
    overriding member function get_code( p_file_name in varchar2 ) return clob
);
/
