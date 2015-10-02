create or replace
package template_repo_const
as
  /**
    Package of Constants for Template Repository
    
    @headcom
  */
  
  /** used if the defined repository is invalid */
  invalid_repository exception;
  invalid_directory exception;
  invalid_file exception;
  invalid_interface exception;
 
  
  function extract_dir_info( p_directory in varchar2 ) return directory_t;
end;
/
