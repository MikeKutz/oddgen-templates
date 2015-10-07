create or replace 
type repo_driver_dbobj under template_repo_interface_v1 (
    object_type varchar2(40),
    schema_name varchar2(34),
    db_link     varchar2(50),
    
    /**
    * p_base_url format "(package|function):schema_name(@db link)?"
    */
    constructor function repo_driver_dbobj( p_mount_point in varchar2, p_base_url in varchar2 ) return self as result,

    overriding member procedure check_file( p_file in varchar2 := null ),
    overriding member function ls( p_directory in varchar2 := null ) return XMLType,

    overriding member function get_code( p_file_name in varchar2 ) return clob,
    member function get_code( p_file_name in varchar2, p_snippet in varchar2 ) return clob,
    /**
      Sets driver specific variables based on p_base_url
      @param p_base_url   string for base url
    */
    member procedure import_base_url( p_base_url in varchar2),

   /**
   * original code from tePLSQL @GitHub
   * Receives the name of the object, usually a package,
   * which contains an embedded template and return the template.
   *
   * @param  p_template_name    the name of the template
   * @param  p_object_name      the name of the object (usually the name of the package)   
   * @param  p_object_type      the type of the object (PACKAGE, PROCEDURE, FUNCTION...)
   * @param  p_schema           the schema of the object
   * @return                    the template.
   */
    static FUNCTION include (p_template_name   IN VARCHAR2 DEFAULT NULL
                    , p_object_name     IN VARCHAR2 DEFAULT 'TE_TEMPLATES'                    
                    , p_object_type     IN VARCHAR2 DEFAULT 'PACKAGE'
                    , p_schema          IN VARCHAR2 DEFAULT NULL )
       RETURN CLOB

);
/
