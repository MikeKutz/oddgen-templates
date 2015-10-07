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
  invalid_parameter exception;
  
  /** regular expressions used for DIRECTORY_T - defines valid string for names */
  valid_chars constant varchar2(200) := '[[:alnum:]_\$ ]+';
  /** regular expressions used for DIRECTORY_T - defines separator character used to separate filename and snippet */
  snippet_sep constant varchar2(200) := '@';
  /** regular expressions used for DIRECTORY_T - defines valid repository name */
  regexp_repo constant varchar2(200) := '(//' || valid_chars || '/?)';
  /** regular expressions used for DIRECTORY_T - defines valid directory */
  regexp_dir  constant varchar2(200) := '(/?(' || valid_chars || '/)+)';
  /** regular expressions used for DIRECTORY_T - defines valid file name */
  regexp_file constant varchar2(200) := '(' || valid_chars || ')';
  /** regular expressions used for DIRECTORY_T - defines valid snippet */
  regexp_snip constant varchar2(200) := '(' || snippet_sep || valid_chars || ')';
  /** regular expressions used for DIRECTORY_T - defines valid fully quallified path and file name with snippet */
  regexp_full constant varchar2(200) := '^' || regexp_repo || '?' || regexp_dir || '?' || regexp_file || '?' || regexp_snip || '?$';
  
 
  
  function extract_dir_info( p_directory in varchar2 ) return directory_t;
end;
/
